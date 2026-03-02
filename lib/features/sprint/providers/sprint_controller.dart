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

  SprintData({
    required this.state,
    this.currentSpeed = 0.0,
    this.maxSpeed = 0.0,
    this.distanceRun = 0.0,
    this.elapsed = Duration.zero,
    this.countdown = 3,
    this.debugLog = '',
  });

  SprintData copyWith({
    SprintState? state,
    double? currentSpeed,
    double? maxSpeed,
    double? distanceRun,
    Duration? elapsed,
    int? countdown,
    String? debugLog,
  }) {
    return SprintData(
      state: state ?? this.state,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      distanceRun: distanceRun ?? this.distanceRun,
      elapsed: elapsed ?? this.elapsed,
      countdown: countdown ?? this.countdown,
      debugLog: debugLog ?? this.debugLog,
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
  DateTime? _startTime;

  // Configuration
  final double targetDistance = 100.0; // 100 meters sprint

  SprintController(this._fusionService, this._locationService)
      : super(SprintData(state: SprintState.calibrating));

  void startCalibration() {
    state = SprintData(state: SprintState.calibrating);
    _calibrationSub?.cancel();

    // Relaxed accuracy requirement and added timeout so it doesn't hang forever
    bool isCalibrated = false;

    _calibrationSub = _locationService.getPositionStream().listen((position) {
      if (!isCalibrated && position.accuracy <= 20.0) {
        isCalibrated = true;
        _calibrationSub?.cancel();
        state = state.copyWith(state: SprintState.ready);
      }
    });

    // Timeout: If we can't get good GPS in 5 seconds, just let the user run anyway
    Future.delayed(const Duration(seconds: 5), () {
      if (!isCalibrated && state.state == SprintState.calibrating) {
        isCalibrated = true;
        _calibrationSub?.cancel();
        state = state.copyWith(state: SprintState.ready);
      }
    });
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
    );
    _startTime = DateTime.now();

    // Start precision timer for UI
    _runTimer?.cancel();
    _runTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!);
        state = state.copyWith(elapsed: elapsed);
      }
    });

    // Start Sensor Fusion algorithm
    _fusionSub?.cancel();
    _fusionSub = _fusionService.startFusionStream().listen((data) {
      final newMaxSpeed =
          data.speedMps > state.maxSpeed ? data.speedMps : state.maxSpeed;

      state = state.copyWith(
        currentSpeed: data.speedMps,
        maxSpeed: newMaxSpeed,
        distanceRun: data.distanceMeters,
        debugLog: data.rawDebugLog.isNotEmpty ? data.rawDebugLog : state.debugLog,
      );

      // Auto-stop condition
      if (state.distanceRun >= targetDistance) {
        stopRunning();
      }
    });
  }

  void stopRunning() {
    _fusionService.stopFusionStream();
    _fusionSub?.cancel();
    _runTimer?.cancel();

    // Snap distance to exact target if slightly over
    final finalDist =
        state.distanceRun > targetDistance ? targetDistance : state.distanceRun;

    state = state.copyWith(
      state: SprintState.finished,
      distanceRun: finalDist,
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
