import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'location_service.dart';

final sensorFusionServiceProvider = Provider<SensorFusionService>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return SensorFusionService(locationService);
});

class FusionData {
  final double speedMps; // Filtered speed, m/s
  final double distanceMeters; // Filtered along-track distance, m
  final Duration elapsed; // Monotonic time since the fusion stream started
  final int gpsFixCount; // Accepted GNSS fixes so far
  final bool gpsLost; // No accepted fix for longer than [_gpsTimeout]
  final Position? lastValidPosition;
  final String rawDebugLog;

  FusionData({
    required this.speedMps,
    required this.distanceMeters,
    required this.elapsed,
    this.gpsFixCount = 0,
    this.gpsLost = false,
    this.lastValidPosition,
    this.rawDebugLog = '',
  });
}

/// 1D constant-velocity Kalman filter along the running direction.
///
/// State: [distance, speed]. It is *predicted* at accelerometer rate (~50 Hz)
/// and *corrected* with GNSS Doppler speed (`Location.getSpeed()`), which is
/// far more precise (±0.1–0.5 m/s) than differencing noisy positions (±3–5 m).
class _SpeedKalman {
  double d = 0.0;
  double v = 0.0;
  double p00 = 0.0, p01 = 0.0, p11 = 1.0;

  void reset() {
    d = 0.0;
    v = 0.0;
    p00 = 0.0;
    p01 = 0.0;
    p11 = 1.0;
  }

  /// [sigmaA] is the expected unmodelled acceleration (m/s²).
  void predict(double dt, double sigmaA) {
    if (dt <= 0) return;
    final q = sigmaA * sigmaA;
    final dt2 = dt * dt;
    d += v * dt;
    p00 += dt * (2 * p01 + dt * p11) + q * dt2 * dt2 / 4;
    p01 += dt * p11 + q * dt2 * dt / 2;
    p11 += q * dt2;
  }

  /// Speed measurement with standard deviation [sigmaV] (m/s).
  void updateSpeed(double z, double sigmaV) {
    final r = sigmaV * sigmaV;
    final s = p11 + r;
    final k0 = p01 / s;
    final k1 = p11 / s;
    final y = z - v;
    d += k0 * y;
    v += k1 * y;
    final n00 = p00 - k0 * p01;
    final n01 = p01 - k0 * p11;
    final n11 = p11 - k1 * p11;
    p00 = n00;
    p01 = n01;
    p11 = n11;
    if (v < 0) v = 0;
  }
}

class SensorFusionService {
  final LocationService _locationService;

  // Tuning
  static const double _maxPositionAccuracyM = 25.0;
  static const double _maxSpeedAccuracyMps = 2.0;
  static const double _defaultSpeedSigmaMps = 0.5;
  static const double _minSpeedSigmaMps = 0.1;
  static const Duration _gpsTimeout = Duration(milliseconds: 2500);

  StreamSubscription<Position>? _gpsSubscription;
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  StreamController<FusionData>? _controller;

  final _kf = _SpeedKalman();
  final Stopwatch _clock = Stopwatch();
  Duration _lastPredict = Duration.zero;
  Duration? _lastGpsAt;
  DateTime? _lastFixTimestamp;

  Position? _lastGpsPosition;
  double _lastGpsSpeed = 0.0;
  double _lastGpsSpeedSigma = 0.0;
  int _gpsFixCount = 0;
  int _gpsRejected = 0;
  double _accelSmoothed = 0.0;
  double _displayDistance = 0.0;
  Duration _lastLogAt = Duration.zero;
  String _lastDebugLog = '';

  IOSink? _logSink;

  SensorFusionService(this._locationService);

  Future<void> _initLogFile(StreamController<FusionData> owner) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final folder = Directory('${directory.path}/SprintLogs');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];
      final file = File('${folder.path}/sprint_log_$timestamp.csv');
      final sink = file.openWrite();
      if (!identical(_controller, owner)) {
        // Stream was stopped before the file was ready.
        await sink.close();
        return;
      }
      _logSink = sink;
      sink.writeln(
          't_ms,type,accel_mag,kf_speed_kmh,kf_dist_m,gps_speed_kmh,gps_speed_sigma,gps_acc_m,lat,lon,fix_dt_ms');
      debugPrint('Sprint log file created at: ${file.path}');
    } catch (e) {
      debugPrint('Failed to create log file: $e');
    }
  }

  void _log(String type, {double accel = 0, Position? p, int fixDtMs = 0}) {
    final sink = _logSink;
    if (sink == null) return;
    sink.writeln([
      _clock.elapsedMilliseconds,
      type,
      accel.toStringAsFixed(3),
      (_kf.v * 3.6).toStringAsFixed(2),
      _kf.d.toStringAsFixed(2),
      p == null ? '' : (p.speed * 3.6).toStringAsFixed(2),
      p == null ? '' : p.speedAccuracy.toStringAsFixed(2),
      p == null ? '' : p.accuracy.toStringAsFixed(1),
      p == null ? '' : p.latitude.toStringAsFixed(7),
      p == null ? '' : p.longitude.toStringAsFixed(7),
      fixDtMs,
    ].join(','));
  }

  /// Advances the filter to "now" on the monotonic clock.
  void _predictToNow() {
    final now = _clock.elapsed;
    final dt = (now - _lastPredict).inMicroseconds / 1e6;
    _lastPredict = now;
    if (dt <= 0) return;

    // Faster, harder accelerations (sprint start) → let the filter follow
    // the next GPS speed more aggressively.
    final sigmaA = math.min(0.5 + _accelSmoothed, 8.0);
    _kf.predict(dt, sigmaA);

    // GPS silent for too long: don't keep extrapolating a stale speed,
    // otherwise distance runs away (the old "100 m in 2 s" bug).
    if (_isGpsLost(now)) {
      _kf.v *= math.exp(-dt / 1.0);
    }
  }

  bool _isGpsLost(Duration now) =>
      _lastGpsAt == null || now - _lastGpsAt! > _gpsTimeout;

  Stream<FusionData> startFusionStream() {
    stopFusionStream();
    _resetState();
    _clock
      ..reset()
      ..start();

    final controller = StreamController<FusionData>.broadcast();
    _controller = controller;
    _initLogFile(controller);

    // 1. Raw GNSS (gps provider, every fix the chip delivers) — source of truth.
    _gpsSubscription =
        _locationService.getPositionStream().listen(_onGps, onError: (e) {
      debugPrint('GPS stream error: $e');
    });

    // 2. Accelerometer (~50 Hz) — drives prediction rate and process noise.
    _accelSubscription = userAccelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(_onAccel);

    return controller.stream;
  }

  void _onGps(Position position) {
    // Reject mocked or poor fixes.
    final badPosition = position.isMocked ||
        position.accuracy <= 0 ||
        position.accuracy > _maxPositionAccuracyM;
    final badSpeed = position.speedAccuracy > _maxSpeedAccuracyMps;
    // Duplicate fix (same GNSS timestamp delivered twice).
    final duplicate = _lastFixTimestamp != null &&
        !position.timestamp.isAfter(_lastFixTimestamp!);
    if (badPosition || badSpeed || duplicate) {
      _gpsRejected++;
      _log('GPS_REJECT', p: position);
      return;
    }

    final fixDtMs = _lastFixTimestamp == null
        ? 0
        : position.timestamp.difference(_lastFixTimestamp!).inMilliseconds;
    _lastFixTimestamp = position.timestamp;

    _predictToNow();

    // Doppler speed sigma; Android reports 0 when unavailable.
    final sigma = position.speedAccuracy > 0
        ? math.max(position.speedAccuracy, _minSpeedSigmaMps)
        : _defaultSpeedSigmaMps;
    _kf.updateSpeed(math.max(position.speed, 0.0), sigma);

    _lastGpsPosition = position;
    _lastGpsSpeed = position.speed;
    _lastGpsSpeedSigma = sigma;
    _lastGpsAt = _clock.elapsed;
    _gpsFixCount++;

    _log('GPS', p: position, fixDtMs: fixDtMs);
    _emitUpdate();
  }

  void _onAccel(UserAccelerometerEvent event) {
    // Gravity is already removed by UserAccelerometer.
    final mag = math.sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z);
    _accelSmoothed += (mag - _accelSmoothed) * 0.1;

    _predictToNow();

    // Zero-velocity update: GPS says ~0 and the phone is calm → stand still.
    // Prevents distance creeping while waiting at the start line.
    if (_gpsFixCount > 0 && _lastGpsSpeed < 0.3 && _accelSmoothed < 0.6) {
      _kf.updateSpeed(0.0, 0.05);
    }

    _log('ACC', accel: mag);

    final now = _clock.elapsed;
    if (now - _lastLogAt >= const Duration(seconds: 1)) {
      _lastLogAt = now;
      final secs = now.inMilliseconds / 1000.0;
      final hz = secs > 0 ? _gpsFixCount / secs : 0.0;
      _lastDebugLog =
          'GPS ${(_lastGpsSpeed * 3.6).toStringAsFixed(1)} km/h ±${(_lastGpsSpeedSigma * 3.6).toStringAsFixed(1)}'
          ' | acc ${_lastGpsPosition?.accuracy.toStringAsFixed(1) ?? '-'} m\n'
          'KF  ${(_kf.v * 3.6).toStringAsFixed(1)} km/h | ${_kf.d.toStringAsFixed(1)} m\n'
          'Fix ${hz.toStringAsFixed(2)} Hz ($_gpsFixCount ok / $_gpsRejected rej)'
          '${_isGpsLost(now) ? '  GPS LOST' : ''}';
    }

    _emitUpdate();
  }

  void _emitUpdate() {
    final controller = _controller;
    if (controller == null || controller.isClosed) return;
    // Kalman corrections can nudge distance slightly backwards; the UI
    // value must never go back.
    if (_kf.d > _displayDistance) _displayDistance = _kf.d;
    controller.add(FusionData(
      speedMps: _kf.v,
      distanceMeters: _displayDistance,
      elapsed: _clock.elapsed,
      gpsFixCount: _gpsFixCount,
      gpsLost: _isGpsLost(_clock.elapsed),
      lastValidPosition: _lastGpsPosition,
      rawDebugLog: _lastDebugLog,
    ));
  }

  void stopFusionStream() {
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
    _accelSubscription?.cancel();
    _accelSubscription = null;
    _clock.stop();
    final sink = _logSink;
    _logSink = null;
    sink?.close();
    _controller?.close();
    _controller = null;
  }

  void _resetState() {
    _kf.reset();
    _lastPredict = Duration.zero;
    _lastGpsAt = null;
    _lastFixTimestamp = null;
    _lastGpsPosition = null;
    _lastGpsSpeed = 0.0;
    _lastGpsSpeedSigma = 0.0;
    _gpsFixCount = 0;
    _gpsRejected = 0;
    _accelSmoothed = 0.0;
    _displayDistance = 0.0;
    _lastLogAt = Duration.zero;
    _lastDebugLog = '';
  }
}
