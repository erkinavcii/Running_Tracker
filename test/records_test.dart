import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/data/database.dart';
import 'package:sprint_tracker/data/records.dart';

EffortEntry e(EffortKind k, int runId, int day, double v) => EffortEntry(
      kind: k,
      runId: runId,
      runStartedAt: DateTime.utc(2026, 11, day),
      value: v,
    );

void main() {
  test('progression keeps only improvements, ties keep the older run', () {
    final r = RecordsSummary.fromEntries([
      e(EffortKind.sprint100m, 3, 3, 12900), // slower → not a PR
      e(EffortKind.sprint100m, 1, 1, 13500),
      e(EffortKind.sprint100m, 2, 2, 12800),
      e(EffortKind.sprint100m, 4, 4, 12800), // tie → not a PR
      e(EffortKind.sprint100m, 5, 5, 12400),
    ]);
    expect(r.best[EffortKind.sprint100m]!.runId, 5);
    expect(
      r.progression[EffortKind.sprint100m]!.map((x) => x.runId),
      [1, 2, 5],
    );
    expect(r.isPr(1), isTrue);
    expect(r.isPr(3), isFalse);
    expect(r.isPr(4), isFalse);
  });

  test('top speed and longest use higher-is-better', () {
    final r = RecordsSummary.fromEntries([
      e(EffortKind.topSpeed, 1, 1, 8.5),
      e(EffortKind.topSpeed, 2, 2, 9.1),
      e(EffortKind.topSpeed, 3, 3, 8.9),
    ]);
    expect(r.best[EffortKind.topSpeed]!.value, 9.1);
    expect(r.prsByRun.keys, [1, 2]);
  });
}
