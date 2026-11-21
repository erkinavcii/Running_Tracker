import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/core/best_efforts.dart';

void main() {
  test('constant pace: best 1 km equals pace × 1 km', () {
    // 4 m/s for 5 km, one sample per second.
    final t = [for (var i = 0; i <= 1250; i++) i * 1000];
    final d = [for (var i = 0; i <= 1250; i++) i * 4.0];
    final e = bestEffort(tMs: t, distM: d, targetM: 1000)!;
    expect(e.durationMs, 250000);
  });

  test('finds the fast section in the middle of a run', () {
    // 0–1000 m at 3 m/s, 1000–2000 m at 5 m/s, 2000–3000 m at 3 m/s.
    final t = <int>[0];
    final d = <double>[0];
    void run(double meters, double speed) {
      final steps = (meters / speed).round();
      for (var i = 0; i < steps; i++) {
        t.add(t.last + 1000);
        d.add(d.last + speed);
      }
    }

    run(999, 3);
    run(1000, 5);
    run(999, 3);
    final e = bestEffort(tMs: t, distM: d, targetM: 1000)!;
    expect(e.durationMs, closeTo(200000, 1000)); // 1000 m / 5 m/s
  });

  test('start is interpolated between samples', () {
    // Sparse samples: 0 m @0 s, 50 m @10 s, 150 m @20 s.
    final e = bestEffort(
      tMs: const [0, 10000, 20000],
      distM: const [0, 50, 150],
      targetM: 100,
    )!;
    // Window ends at 150 m (20 s), starts at 50 m (10 s).
    expect(e.durationMs, 10000);
  });

  test('run shorter than target gives null', () {
    expect(
      bestEffort(tMs: const [0, 1000], distM: const [0, 50], targetM: 100),
      isNull,
    );
  });

  test('crossing times at every 10 m', () {
    final times = crossingTimes(
      tMs: const [0, 1000, 2000, 3000],
      distM: const [0, 5, 20, 30],
      stepM: 10,
    );
    // 10 m between 5 m@1 s and 20 m@2 s → 1.333 s; 20 m at 2 s; 30 m at 3 s.
    expect(times, [1333, 2000, 3000]);
  });
}
