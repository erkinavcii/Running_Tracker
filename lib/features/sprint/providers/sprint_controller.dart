import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/sensor_fusion_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/calories.dart';
import '../../../data/database.dart' show GpsQuality;
import '../../../data/run_repository.dart';

enum SprintState { calibrating, ready, countdown, running, finished }

/// Why GPS can't be trusted right now (shown as a warning banner).
enum GpsIssue {
  none,
  permissionDenied, // Location permission not granted
  disabled, // Location / GPS switched off on the device
  noFix, // Calibration timed out without a single fix
  weak, // Calibration timed out with only poor fixes
}

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
  final GpsIssue gpsIssue;
  final int? savedRunId; // Set once the finished sprint is in the history

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
    this.gpsIssue = GpsIssue.none,
    this.savedRunId,
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
    GpsIssue? gpsIssue,
    int? savedRunId,
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
      gpsIssue: gpsIssue ?? this.gpsIssue,
      savedRunId: savedRunId ?? this.savedRunId,
    );
  }
}

final sprintControllerProvider =
    StateNotifierProvider<SprintController, SprintData>((ref) {
  final fusionService = ref.watch(sensorFusionServiceProvider);
  final locationService = ref.watch(locationServiceProvider);
  return SprintController(
    fusionService,
    locationService,
    repository: ref.watch(runRepositoryProvider),
  );
});

class SprintController extends StateNotifier<SprintData> {
  final SensorFusionService _fusionService;
  final LocationService _locationService;
  final RunRepository? _repository;

  StreamSubscription? _calibrationSub;
  StreamSubscription? _fusionSub;
  Timer? _countdownTimer;
  Timer? _runTimer;
  Duration _prevElapsed = Duration.zero;
  double _prevDistance = 0.0;
  int _calibrationGen = 0; // Ignores timeouts of an earlier calibration
  DateTime? _runStartedAt;
  final List<int> _splitTimesMs = []; // cumulative ms at 10, 20 … m
  static const double splitStepM = 10.0;
  GpsQuality _runGpsQuality = GpsQuality.good;

  // Configuration
  final double targetDistance = 100.0; // 100 meters sprint
  static const double calibratedAccuracyM = 10.0;
  static const Duration calibrationTimeout = Duration(seconds: 15);

  SprintController(
    this._fusionService,
    this._locationService, {
    RunRepository? repository,
  })  : _repository = repository,
        super(SprintData(state: SprintState.calibrating));

  Future<void> startCalibration() async {
    final gen = ++_calibrationGen;
    state = SprintData(state: SprintState.calibrating);
    _calibrationSub?.cancel();

    // Location permission must be granted before any GNSS stream is opened.
    final hasPermission = await _locationService.handlePermissions();
    if (!mounted || gen != _calibrationGen) return;
    if (!hasPermission) {
      final enabled = await _locationService.isLocationEnabled();
      if (!mounted || gen != _calibrationGen) return;
      state = state.copyWith(
        gpsIssue: enabled ? GpsIssue.permissionDenied : GpsIssue.disabled,
      );
      return;
    }

    // Wait for a good fix (or time out). The subscription is kept alive
    // after calibration so the GNSS chip stays warm until the run starts;
    // otherwise the first seconds of the sprint would have no fixes.
    bool isCalibrated = false;

    _calibrationSub = _locationService.getPositionStream().listen(
      (position) {
        if (!mounted) return;
        final good = position.accuracy <= calibratedAccuracyM;
        state = state.copyWith(
          gpsAccuracy: position.accuracy,
          // A good fix arriving late clears an earlier warning.
          gpsIssue: good ? GpsIssue.none : null,
        );
        if (!isCalibrated && good) {
          isCalibrated = true;
          state = state.copyWith(state: SprintState.ready);
        }
      },
      onError: (Object _) {
        if (!mounted) return;
        state = state.copyWith(gpsIssue: GpsIssue.disabled);
      },
    );

    // Timeout: let the user run anyway, but say why the result may be off.
    Future.delayed(calibrationTimeout, () {
      if (!mounted || gen != _calibrationGen) return;
      if (!isCalibrated && state.state == SprintState.calibrating) {
        isCalibrated = true;
        state = state.copyWith(
          state: SprintState.ready,
          gpsIssue: state.gpsAccuracy == null ? GpsIssue.noFix : GpsIssue.weak,
        );
      }
    });
  }

  /// Opens the system screen that fixes the current [GpsIssue].
  Future<void> openGpsSettings() async {
    if (state.gpsIssue == GpsIssue.permissionDenied) {
      await _locationService.openAppSettings();
    } else {
      await _locationService.openLocationSettings();
    }
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
    _runStartedAt = DateTime.now();
    _splitTimesMs.clear();
    _runGpsQuality = switch (state.gpsIssue) {
      GpsIssue.none => GpsQuality.good,
      GpsIssue.weak => GpsQuality.weak,
      _ => GpsQuality.none,
    };

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
    _recordSplits(data);

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
      _saveSprint();
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

  /// Interpolated crossing time of every 10 m mark passed since the last
  /// sample (same method as the finish line).
  void _recordSplits(FusionData data) {
    if (data.gpsFixCount == 0) return;
    final dd = data.distanceMeters - _prevDistance;
    if (dd <= 0) return;
    final dtUs = (data.elapsed - _prevElapsed).inMicroseconds;
    while (_splitTimesMs.length * splitStepM + splitStepM <= targetDistance) {
      final mark = (_splitTimesMs.length + 1) * splitStepM;
      if (data.distanceMeters < mark) break;
      final frac = ((mark - _prevDistance) / dd).clamp(0.0, 1.0);
      final at = _prevElapsed + Duration(microseconds: (dtUs * frac).round());
      _splitTimesMs.add(at.inMilliseconds);
    }
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

  /// Stores the finished sprint (only runs that reached the finish line).
  Future<void> _saveSprint() async {
    final repo = _repository;
    final startedAt = _runStartedAt;
    if (repo == null || startedAt == null) return;
    final result = state;
    try {
      final profile = await repo.getProfile();
      final secs = result.elapsed.inMilliseconds / 1000;
      final weight = profile.weightKg;
      final id = await repo.saveSprint(SprintResult(
        startedAt: startedAt,
        time: result.elapsed,
        distanceM: targetDistance,
        maxSpeedMps: result.maxSpeed,
        gpsQuality: _runGpsQuality,
        track: _fusionService.track,
        splitTimesMs: List.of(_splitTimesMs),
        kcal: weight == null || secs <= 0
            ? null
            : kcalForInterval(
                speedMps: targetDistance / secs,
                durationS: secs,
                weightKg: weight,
              ),
      ));
      if (mounted && state.state == SprintState.finished) {
        state = state.copyWith(savedRunId: id);
      }
    } catch (e) {
      // Saving must never break the result screen.
      if (mounted) {
        state = state.copyWith(debugLog: 'Could not save run: $e');
      }
    }
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
