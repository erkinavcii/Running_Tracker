import 'dart:math';

import 'sprint_controller.dart';

/// Static, randomised sprint data for store screenshots and README images.
///
/// Enabled with `--dart-define=DEMO=running` (or `ready` / `finished` /
/// `nogps`);
/// it never touches GPS or sensors.
const demoMode = String.fromEnvironment('DEMO');

class DemoSprintController extends SprintController {
  DemoSprintController(super.fusionService, super.locationService) {
    state = _buildDemoState(demoMode);
  }

  static SprintData _buildDemoState(String mode) {
    final r = Random();
    double between(double a, double b) => a + r.nextDouble() * (b - a);

    final top = between(30.5, 34.5) / 3.6; // m/s
    final accuracy = between(2.4, 4.6);
    final log = 'GPS ${(top * 3.6 - between(0.3, 1.2)).toStringAsFixed(1)} km/h '
        '±${between(0.3, 0.7).toStringAsFixed(1)} | acc ${accuracy.toStringAsFixed(1)} m\n'
        'KF  ${(top * 3.6 - between(0.1, 0.9)).toStringAsFixed(1)} km/h\n'
        'Fix 1.00 Hz (${r.nextInt(6) + 7} ok / 0 rej)';

    switch (mode) {
      case 'finished':
        final time = between(12.1, 13.4);
        return SprintData(
          state: SprintState.finished,
          distanceRun: 100,
          currentSpeed: 0,
          maxSpeed: top,
          elapsed: Duration(milliseconds: (time * 1000).round()),
          gpsAccuracy: accuracy,
          debugLog: log,
        );
      case 'running':
        final dist = between(55, 72);
        final time = dist / (top * 0.86);
        return SprintData(
          state: SprintState.running,
          distanceRun: dist,
          currentSpeed: top * between(0.95, 0.99),
          maxSpeed: top,
          elapsed: Duration(milliseconds: (time * 1000).round()),
          gpsAccuracy: accuracy,
          debugLog: log,
        );
      case 'nogps':
        return SprintData(state: SprintState.ready, gpsIssue: GpsIssue.noFix);
      default:
        return SprintData(state: SprintState.ready, gpsAccuracy: accuracy);
    }
  }

  @override
  Future<void> startCalibration() async {}

  @override
  void startCountdown() {}

  @override
  void cancelRun() {}

  @override
  void stopRunning() {}
}
