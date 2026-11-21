import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';

import '../../data/database.dart';
import '../../data/run_repository.dart';

/// In-memory database filled with plausible sprints for demo builds and
/// screenshots. Never touches the real on-device database.
Future<AppDatabase> buildDemoDatabase({int seed = 7}) async {
  final db = AppDatabase(NativeDatabase.memory());
  final repo = RunRepository(db);
  final r = Random(seed);

  await repo.updateProfile(const ProfilesCompanion(
    onboarded: Value(true),
    weightKg: Value(72),
  ));

  final now = DateTime.now();
  // Three sessions a week for five weeks, slowly getting faster.
  var base = 13.6;
  for (var week = 4; week >= 0; week--) {
    for (final day in [1, 3, 5]) {
      final startedAt = now.subtract(Duration(
        days: week * 7 + (6 - day),
        hours: r.nextInt(3),
        minutes: r.nextInt(50),
      ));
      if (startedAt.isAfter(now)) continue;
      base -= 0.04 + r.nextDouble() * 0.05;
      final seconds = base + (r.nextDouble() - 0.4) * 0.35;
      final ms = (seconds * 1000).round();
      final top = 100 / seconds * (1.16 + r.nextDouble() * 0.05);

      // Speed profile: fast acceleration, then near-constant.
      final splits = <int>[];
      var t = 0.0;
      for (var i = 1; i <= 10; i++) {
        final share = i == 1 ? 0.155 : (i == 2 ? 0.108 : 0.0921);
        t += seconds * share;
        splits.add((t * 1000).round());
      }
      splits[9] = ms;

      await repo.saveSprint(SprintResult(
        startedAt: startedAt,
        time: Duration(milliseconds: ms),
        distanceM: 100,
        maxSpeedMps: top,
        gpsQuality: r.nextDouble() < 0.12 ? GpsQuality.weak : GpsQuality.good,
        kcal: 7 + r.nextDouble() * 2,
        splitTimesMs: splits,
        track: const [],
      ));
    }
  }
  return db;
}
