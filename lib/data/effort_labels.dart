import '../core/format.dart';
import 'database.dart';

/// Display name of a record kind.
String effortLabel(EffortKind k) => switch (k) {
      EffortKind.sprint100m => '100 m sprint',
      EffortKind.topSpeed => 'Top speed',
      EffortKind.best400m => '400 m',
      EffortKind.best1k => '1 km',
      EffortKind.best5k => '5 km',
      EffortKind.best10k => '10 km',
      EffortKind.bestHalf => 'Half marathon',
      EffortKind.longest => 'Longest run',
    };

/// Target distance of a time-based kind, null for the others.
double? effortDistanceM(EffortKind k) => switch (k) {
      EffortKind.sprint100m => 100,
      EffortKind.best400m => 400,
      EffortKind.best1k => 1000,
      EffortKind.best5k => 5000,
      EffortKind.best10k => 10000,
      EffortKind.bestHalf => 21097.5,
      EffortKind.topSpeed || EffortKind.longest => null,
    };

/// Formats a stored effort value (ms, m/s or m) for its kind.
String formatEffort(EffortKind k, double value, {bool miles = false}) =>
    switch (k) {
      EffortKind.sprint100m =>
        '${formatSprintTime(Duration(milliseconds: value.round()))} s',
      EffortKind.topSpeed => formatSpeed(value, miles: miles),
      EffortKind.longest => formatDistance(value, miles: miles),
      _ => formatClock(Duration(milliseconds: value.round())),
    };

const sprintKinds = [EffortKind.sprint100m, EffortKind.topSpeed];
const enduranceKinds = [
  EffortKind.best400m,
  EffortKind.best1k,
  EffortKind.best5k,
  EffortKind.best10k,
  EffortKind.bestHalf,
  EffortKind.longest,
];
