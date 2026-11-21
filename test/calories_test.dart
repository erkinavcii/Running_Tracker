import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/core/calories.dart';

void main() {
  test('70 kg at 10 km/h on flat ground ≈ 770 kcal/h (ACSM running)', () {
    final perHour = kcalPerMinute(speedMps: 10 / 3.6, weightKg: 70) * 60;
    expect(perHour, closeTo(773, 5));
  });

  test('walking speed uses the walking equation', () {
    // 5 km/h = 83.3 m/min → VO2 = 0.1·83.3 + 3.5 = 11.83
    final perMin = kcalPerMinute(speedMps: 5 / 3.6, weightKg: 80);
    expect(perMin, closeTo(11.83 * 80 / 1000 * 5, 0.01));
  });

  test('uphill costs more, downhill is clamped to flat', () {
    final flat = kcalPerMinute(speedMps: 3, weightKg: 70);
    expect(kcalPerMinute(speedMps: 3, weightKg: 70, grade: 0.05),
        greaterThan(flat));
    expect(kcalPerMinute(speedMps: 3, weightKg: 70, grade: -0.1), flat);
  });

  test('no movement or no weight gives 0', () {
    expect(kcalPerMinute(speedMps: 0, weightKg: 70), 0);
    expect(kcalForInterval(speedMps: 3, durationS: 60, weightKg: 0), 0);
  });
}
