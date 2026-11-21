import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/core/weeks.dart';

typedef R = (DateTime, double);

void main() {
  test('weeks start on Monday', () {
    expect(weekStart(DateTime(2026, 11, 21, 18)), DateTime(2026, 11, 16));
    expect(weekStart(DateTime(2026, 11, 16)), DateTime(2026, 11, 16));
    expect(weekStart(DateTime(2026, 11, 22, 23, 59)), DateTime(2026, 11, 16));
  });

  test('groups runs per week with totals, newest first', () {
    final runs = <R>[
      (DateTime(2026, 11, 21), 100),
      (DateTime(2026, 11, 17), 5000),
      (DateTime(2026, 11, 12), 100),
    ];
    final g = groupByWeek<R>(
      runs,
      startedAt: (r) => r.$1,
      distanceM: (r) => r.$2,
      moving: (_) => const Duration(minutes: 1),
    );
    expect(g.map((w) => w.start), [DateTime(2026, 11, 16), DateTime(2026, 11, 9)]);
    expect(g.first.distanceM, 5100);
    expect(g.first.moving, const Duration(minutes: 2));
  });

  test('weekly totals fill empty weeks with zero', () {
    final totals = weeklyTotals<R>(
      [(DateTime(2026, 11, 21), 300), (DateTime(2026, 11, 3), 200)],
      now: DateTime(2026, 11, 21),
      startedAt: (r) => r.$1,
      distanceM: (r) => r.$2,
      weeks: 4,
    );
    expect(totals.map((t) => t.$2), [0, 200, 0, 300]);
    expect(totals.last.$1, DateTime(2026, 11, 16));
  });

  test('week labels', () {
    final now = DateTime(2026, 11, 21);
    expect(weekLabel(DateTime(2026, 11, 16), now: now), 'This week');
    expect(weekLabel(DateTime(2026, 11, 9), now: now), 'Last week');
    expect(weekLabel(DateTime(2026, 11, 2), now: now), '2 – 8 Nov');
    expect(weekLabel(DateTime(2026, 10, 26), now: now), '26 Oct – 1 Nov');
  });
}
