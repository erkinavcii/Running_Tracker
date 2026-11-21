import 'database.dart';

/// Whether a smaller value is better for this kind (times) or larger
/// (top speed, longest distance).
bool lowerIsBetter(EffortKind k) =>
    k != EffortKind.topSpeed && k != EffortKind.longest;

/// One stored effort joined with its run.
class EffortEntry {
  final EffortKind kind;
  final int runId;
  final DateTime runStartedAt;
  final double value; // ms, m/s or m depending on kind

  const EffortEntry({
    required this.kind,
    required this.runId,
    required this.runStartedAt,
    required this.value,
  });
}

class RecordsSummary {
  /// Current best per kind.
  final Map<EffortKind, EffortEntry> best;

  /// Every effort that improved its kind's record when it was set, oldest
  /// first — the progression line and the "PR" badges come from this.
  final Map<EffortKind, List<EffortEntry>> progression;

  /// Kinds each run improved at the time it was run.
  final Map<int, Set<EffortKind>> prsByRun;

  const RecordsSummary({
    required this.best,
    required this.progression,
    required this.prsByRun,
  });

  static const empty = RecordsSummary(best: {}, progression: {}, prsByRun: {});

  bool isPr(int runId) => prsByRun[runId]?.isNotEmpty ?? false;

  /// Walks the efforts in run order and records every improvement.
  /// Ties do not count as a new record (the earlier run keeps it).
  factory RecordsSummary.fromEntries(Iterable<EffortEntry> entries) {
    final sorted = entries.toList()
      ..sort((a, b) {
        final c = a.runStartedAt.compareTo(b.runStartedAt);
        return c != 0 ? c : a.runId.compareTo(b.runId);
      });

    final best = <EffortKind, EffortEntry>{};
    final progression = <EffortKind, List<EffortEntry>>{};
    final prsByRun = <int, Set<EffortKind>>{};

    for (final e in sorted) {
      final current = best[e.kind];
      final improves = current == null ||
          (lowerIsBetter(e.kind)
              ? e.value < current.value
              : e.value > current.value);
      if (!improves) continue;
      best[e.kind] = e;
      progression.putIfAbsent(e.kind, () => []).add(e);
      prsByRun.putIfAbsent(e.runId, () => {}).add(e.kind);
    }
    return RecordsSummary(
      best: best,
      progression: progression,
      prsByRun: prsByRun,
    );
  }
}
