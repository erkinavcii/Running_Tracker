import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/sensor_fusion_service.dart';
import '../../../core/services/location_service.dart';

enum SprintState { calibrating, ready, countdown, running, finished }

class SprintData {
  final SprintState state;
  final double currentSpeed; // m/s
  final double maxSpeed; // m/s
  final double distanceRun; // meters
  final Duration elapsed;
  final int countdown;
  final String debugLog;
  final double? gpsAccuracy; // Last fix horizontal accuracy (m), null = no fix
  final bool gpsLost;

  SprintData({
    required this.state,
    this.currentSpeed = 0.0,
    this.maxSpeed = 0.0,
    this.distanceRun = 0.0,
    this.elapsed = Duration.zero,
    this.countdown = 3,
    this.debugLog = '',
    this.gpsAccuracy,
    this.gpsLost = false,
  });

  SprintData copyWith({
    SprintState? state,
    double? currentSpeed,
    double? maxSpeed,
    double? distanceRun,
    Duration? elapsed,
    int? countdown,
    String? debugLog,
    double? gpsAccuracy,
    bool? gpsLost,
  }) {
    return SprintData(
      state: state ?? this.state,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      distanceRun: distanceRun ?? this.distanceRun,
      elapsed: elapsed ?? this.elapsed,
      countdown: countdown ?? this.countdown,
      debugLog: debugLog ?? this.debugLog,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      gpsLost: gpsLost ?? this.gpsLost,
    );
  }
}

final sprintControllerProvider =
    StateNotifierProvider<SprintController, SprintData>((ref) {
  final fusionService = ref.watch(sensorFusionServiceProvider);
  final locationService = ref.watch(locationServiceProvider);
  return SprintController(fusionService, locationService);
});

class SprintController extends StateNotifier<SprintData> {
  final SensorFusionService _fusionService;
  final LocationService _locationService;

  StreamSubscription? _calibrationSub;
  StreamSubscription? _fusionSub;
  Timer? _countdownTimer;
  Timer? _runTimer;
  Duration _prevElapsed = Duration.zero;
  double _prevDistance = 0.0;

  // Configuration
  final double targetDistance = 100.0; // 100 meters sprint

  SprintController(this._fusionService, this._locationService)
      : super(SprintData(state: SprintState.calibrating));

  Future<void> startCalibration() async {
    state = SprintData(state: SprintState.calibrating);
    _calibrationSub?.cancel();

    // Location permission must be granted before any GNSS stream is opened.
    final hasPermission = await _locationService.handlePermissions();
    if (!mounted) return;
    if (!hasPermission) {
      state = state.copyWith(
        debugLog: 'Location permission denied or location is off.\n'
            'Enable it and reopen this screen.',
      );
      return;
    }

    // Wait for a good fix (or time out). The subscription is kept alive
    // after calibration so the GNSS chip stays warm until the run starts;
    // otherwise the first seconds of the sprint would have no fixes.
    bool isCalibrated = false;

    _calibrationSub = _locationService.getPositionStream().listen((position) {
      if (!mounted) return;
      state = state.copyWith(gpsAccuracy: position.accuracy);
      if (!isCalibrated && position.accuracy <= 10.0) {
        isCalibrated = true;
        state = state.copyWith(state: SprintState.ready);
      }
    });

    // Timeout: If we can't get good GPS in 15 seconds, just let the user run anyway
    Future.delayed(const Duration(seconds: 15), () {
      if (!mounted) return;
      if (!isCalibrated && state.state == SprintState.calibrating) {
        isCalibrated = true;
        state = state.copyWith(state: SprintState.ready);
      }
    });
  }

  /// Abort a run without saving a result.
  void cancelRun() {
    _countdownTimer?.cancel();
    _fusionService.stopFusionStream();
    _fusionSub?.cancel();
    _runTimer?.cancel();
    startCalibration();
  }

  void startCountdown() {
    if (state.state != SprintState.ready) return;

    state = state.copyWith(state: SprintState.countdown, countdown: 3);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown > 1) {
        state = state.copyWith(countdown: state.countdown - 1);
      } else {
        timer.cancel();
        _startRunning();
      }
    });
  }

  void _startRunning() {
    state = state.copyWith(
      state: SprintState.running,
      distanceRun: 0,
      currentSpeed: 0,
      maxSpeed: 0,
      elapsed: Duration.zero,
    );
    _prevElapsed = Duration.zero;
    _prevDistance = 0.0;

    // Start Sensor Fusion algorithm. Its monotonic clock is the race clock,
    // so the displayed time and the finish-line interpolation share one base.
    _fusionSub?.cancel();
    _fusionSub = _fusionService.startFusionStream().listen(_onFusion);
    // Fusion now holds its own GNSS request; release the warm-up one.
    _calibrationSub?.cancel();
    _calibrationSub = null;

    // UI refresh for the stopwatch between fusion events.
    _runTimer?.cancel();
    final uiClock = Stopwatch()..start();
    _runTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (state.state != SprintState.running) return;
      if (uiClock.elapsed > state.elapsed) {
        state = state.copyWith(elapsed: uiClock.elapsed);
      }
    });
  }

  void _onFusion(FusionData data) {
    if (state.state != SprintState.running) return;

    final newMaxSpeed =
        data.speedMps > state.maxSpeed ? data.speedMps : state.maxSpeed;

    // Finish line crossed between two fusion samples: interpolate the exact
    // crossing time instead of using the (later) sample time.
    // Only trust it once at least one real GNSS fix arrived.
    if (data.gpsFixCount > 0 && data.distanceMeters >= targetDistance) {
      final dd = data.distanceMeters - _prevDistance;
      final frac = dd > 0 ? (targetDistance - _prevDistance) / dd : 1.0;
      final dtUs = (data.elapsed - _prevElapsed).inMicroseconds;
      final crossing = _prevElapsed +
          Duration(microseconds: (dtUs * frac.clamp(0.0, 1.0)).round());
      state = state.copyWith(
        maxSpeed: newMaxSpeed,
        distanceRun: targetDistance,
        elapsed: crossing,
        debugLog: data.rawDebugLog.isNotEmpty ? data.rawDebugLog : null,
      );
      stopRunning();
      return;
    }

    _prevElapsed = data.elapsed;
    _prevDistance = data.distanceMeters;

    state = state.copyWith(
      currentSpeed: data.speedMps,
      maxSpeed: newMaxSpeed,
      distanceRun: data.distanceMeters,
      elapsed: data.elapsed > state.elapsed ? data.elapsed : null,
      gpsAccuracy: data.lastValidPosition?.accuracy,
      gpsLost: data.gpsLost,
      debugLog: data.rawDebugLog.isNotEmpty ? data.rawDebugLog : null,
    );
  }

  void stopRunning() {
    _calibrationSub?.cancel();
    _calibrationSub = null;
    _fusionService.stopFusionStream();
    _fusionSub?.cancel();
    _runTimer?.cancel();

    if (state.state != SprintState.running) return;

    state = state.copyWith(
      state: SprintState.finished,
      distanceRun: state.distanceRun > targetDistance
          ? targetDistance
          : state.distanceRun,
      currentSpeed: 0.0,
    );
  }

  @override
  void dispose() {
    _calibrationSub?.cancel();
    _fusionSub?.cancel();
    _countdownTimer?.cancel();
    _runTimer?.cancel();
    super.dispose();
  }
}
