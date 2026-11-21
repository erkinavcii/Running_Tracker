/// Monday-based week grouping for the history screen.
library;

/// Local Monday 00:00 of the week containing [t].
DateTime weekStart(DateTime t) {
  final l = t.toLocal();
  final day = DateTime(l.year, l.month, l.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

class WeekGroup<T> {
  final DateTime start;
  final List<T> items;
  final double distanceM;
  final Duration moving;

  const WeekGroup({
    required this.start,
    required this.items,
    required this.distanceM,
    required this.moving,
  });
}

/// Groups items (already sorted newest first) into weeks, newest first.
List<WeekGroup<T>> groupByWeek<T>(
  List<T> items, {
  required DateTime Function(T) startedAt,
  required double Function(T) distanceM,
  required Duration Function(T) moving,
}) {
  final groups = <DateTime, List<T>>{};
  for (final it in items) {
    groups.putIfAbsent(weekStart(startedAt(it)), () => []).add(it);
  }
  final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final k in keys)
      WeekGroup(
        start: k,
        items: groups[k]!,
        distanceM: groups[k]!.fold(0.0, (s, it) => s + distanceM(it)),
        moving: groups[k]!.fold(Duration.zero, (s, it) => s + moving(it)),
      ),
  ];
}

/// Distance per week for the last [weeks] weeks ending with the week of
/// [now], oldest first. Weeks without runs are 0.
List<(DateTime, double)> weeklyTotals<T>(
  List<T> items, {
  required DateTime now,
  required DateTime Function(T) startedAt,
  required double Function(T) distanceM,
  int weeks = 8,
}) {
  final current = weekStart(now);
  final starts = [
    for (var i = weeks - 1; i >= 0; i--)
      DateTime(current.year, current.month, current.day - 7 * i),
  ];
  final totals = {for (final s in starts) s: 0.0};
  for (final it in items) {
    final w = weekStart(startedAt(it));
    if (totals.containsKey(w)) totals[w] = totals[w]! + distanceM(it);
  }
  return [for (final s in starts) (s, totals[s]!)];
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "This week", "Last week" or "17 – 23 Nov" / "28 Oct – 3 Nov".
String weekLabel(DateTime start, {required DateTime now}) {
  final current = weekStart(now);
  if (start == current) return 'This week';
  if (start == DateTime(current.year, current.month, current.day - 7)) {
    return 'Last week';
  }
  final end = DateTime(start.year, start.month, start.day + 6);
  if (start.month == end.month) {
    return '${start.day} – ${end.day} ${_months[end.month - 1]}';
  }
  return '${start.day} ${_months[start.month - 1]} – '
      '${end.day} ${_months[end.month - 1]}';
}

/// "17 Nov" for chart axis labels.
String shortDay(DateTime d) => '${d.day} ${_months[d.month - 1]}';
