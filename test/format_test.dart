import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/core/format.dart';

void main() {
  test('pace rounds the total, never shows :60', () {
    // 1000 m / 359.6 s → 5:59.6 → 6:00
    expect(formatPace(1000 / 359.6), '6:00 /km');
    expect(formatPace(1000 / 323), '5:23 /km');
    expect(formatPace(0.1), '–');
  });

  test('sprint and clock times', () {
    expect(formatSprintTime(const Duration(milliseconds: 12480)), '12.48');
    expect(formatSprintTime(const Duration(milliseconds: 62340)), '1:02.34');
    expect(formatClock(const Duration(minutes: 4, seconds: 5)), '4:05');
    expect(
      formatClock(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '1:02:03',
    );
  });

  test('distance and speed units', () {
    expect(formatDistance(100), '100 m');
    expect(formatDistance(5240), '5.24 km');
    expect(formatDistance(5240, miles: true), '3.26 mi');
    expect(formatSpeed(10), '36.0 km/h');
    expect(formatSpeed(10, miles: true), '22.4 mph');
  });
}
