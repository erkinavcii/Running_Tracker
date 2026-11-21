/// Fastest time to cover a given distance anywhere inside a run.
library;

class BestEffort {
  final double targetM;
  final int durationMs;
  final int startIndex; // sample at or just before the effort start
  final int endIndex; // sample where the effort ends

  const BestEffort({
    required this.targetM,
    required this.durationMs,
    required this.startIndex,
    required this.endIndex,
  });

  @override
  String toString() => 'BestEffort($targetM m in $durationMs ms, '
      '$startIndex..$endIndex)';
}

/// Two-pointer sliding window over cumulative [distM] / [tMs] (same length,
/// both non-decreasing). The window ends on a sample; its start is
/// interpolated so the covered distance is exactly [targetM]. O(n).
///
/// Returns null if the run is shorter than [targetM].
BestEffort? bestEffort({
  required List<int> tMs,
  required List<double> distM,
  required double targetM,
}) {
  assert(tMs.length == distM.length);
  final n = distM.length;
  if (n < 2 || targetM <= 0 || distM.last - distM.first < targetM) {
    return null;
  }

  BestEffort? best;
  var i = 0;
  for (var j = 1; j < n; j++) {
    final startDist = distM[j] - targetM;
    if (startDist < distM.first) continue;
    // Move i to the last sample at or before the start distance.
    while (i + 1 < j && distM[i + 1] <= startDist) {
      i++;
    }
    final d0 = distM[i], d1 = distM[i + 1];
    final t0 = tMs[i], t1 = tMs[i + 1];
    final frac = d1 > d0 ? (startDist - d0) / (d1 - d0) : 0.0;
    final startT = t0 + (t1 - t0) * frac.clamp(0.0, 1.0);
    final duration = (tMs[j] - startT).round();
    if (best == null || duration < best.durationMs) {
      best = BestEffort(
        targetM: targetM,
        durationMs: duration,
        startIndex: i,
        endIndex: j,
      );
    }
  }
  return best;
}

/// Time at which cumulative distance first reaches each multiple of [stepM]
/// (e.g. 10 m splits of a sprint, 1000 m splits of a run), interpolated.
List<int> crossingTimes({
  required List<int> tMs,
  required List<double> distM,
  required double stepM,
}) {
  final out = <int>[];
  if (distM.length < 2) return out;
  var next = distM.first + stepM;
  for (var k = 1; k < distM.length; k++) {
    while (distM[k] >= next) {
      final d0 = distM[k - 1], d1 = distM[k];
      final frac = d1 > d0 ? (next - d0) / (d1 - d0) : 1.0;
      out.add((tMs[k - 1] + (tMs[k] - tMs[k - 1]) * frac).round());
      next += stepM;
    }
  }
  return out;
}
