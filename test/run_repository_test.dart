import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/data/database.dart';
import 'package:sprint_tracker/data/run_repository.dart';

void main() {
  late AppDatabase db;
  late RunRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = RunRepository(db);
  });
  tearDown(() => db.close());

  SprintResult sprint({GpsQuality q = GpsQuality.good, int ms = 12480}) =>
      SprintResult(
        startedAt: DateTime.utc(2026, 11, 21, 9, 30),
        time: Duration(milliseconds: ms),
        distanceM: 100,
        maxSpeedMps: 9.2,
        gpsQuality: q,
        kcal: 9.5,
        splitTimesMs: const [1800, 3000, 4100, 5150, 6200, 7250, 8300, 9350, 10400, 11450],
        track: const [
          TrackSample(tMs: 0, lat: 1, lon: 2, speedMps: 0, accM: 3),
          TrackSample(tMs: 1000, lat: 1.0001, lon: 2, speedMps: 4, accM: 3),
        ],
      );

  test('fresh database has a default, not-onboarded profile', () async {
    final p = await repo.getProfile();
    expect(p.onboarded, isFalse);
    expect(p.weightKg, isNull);
    expect(p.autoPause, isTrue);

    await repo.updateProfile(const ProfilesCompanion(
      weightKg: Value(72.5),
      onboarded: Value(true),
    ));
    final updated = await repo.getProfile();
    expect(updated.weightKg, 72.5);
    expect(updated.onboarded, isTrue);
  });

  test('saveSprint stores run, track and best efforts', () async {
    final id = await repo.saveSprint(sprint());
    final run = (await repo.getRun(id))!;
    expect(run.type, RunType.sprint);
    expect(run.status, RunStatus.finished);
    expect(run.sprintTimeMs, 12480);
    expect(run.avgSpeedMps, closeTo(100 / 12.48, 1e-9));
    expect(run.kcal, 9.5);
    expect((await repo.getTrack(id)).map((t) => t.seq), [0, 1]);

    final efforts = await db.select(db.bestEfforts).get();
    expect(
      efforts.map((e) => e.kind),
      containsAll([EffortKind.sprint100m, EffortKind.topSpeed]),
    );
  });

  test('a sprint without GPS is saved but sets no records', () async {
    await repo.saveSprint(sprint(q: GpsQuality.none));
    expect(await db.select(db.bestEfforts).get(), isEmpty);
    expect(await repo.watchRuns().first, hasLength(1));
  });

  test('deleting a run cascades to track and efforts', () async {
    final id = await repo.saveSprint(sprint());
    await repo.deleteRun(id);
    expect(await repo.getTrack(id), isEmpty);
    expect(await db.select(db.bestEfforts).get(), isEmpty);
  });

  test('runs are listed newest first', () async {
    await repo.saveSprint(sprint(ms: 13000));
    await repo.saveSprint(SprintResult(
      startedAt: DateTime.utc(2026, 11, 22),
      time: const Duration(seconds: 12),
      distanceM: 100,
      maxSpeedMps: 9,
      gpsQuality: GpsQuality.good,
      track: const [],
    ));
    final runs = await repo.watchRuns().first;
    expect(runs.first.startedAt.isAfter(runs.last.startedAt), isTrue);
  });

  test('sprint splits are stored as 10 m segments', () async {
    final id = await repo.saveSprint(sprint());
    final splits = await repo.watchSplits(id).first;
    expect(splits, hasLength(10));
    expect(splits.first.durationMs, 1800);
    expect(splits[1].durationMs, 1200);
    expect(splits[1].avgSpeedMps, closeTo(10 / 1.2, 1e-9));
  });

  test('records stream marks the improving runs', () async {
    final slow = await repo.saveSprint(sprint(ms: 13500));
    final fast = await repo.saveSprint(SprintResult(
      startedAt: DateTime.utc(2026, 11, 22),
      time: const Duration(milliseconds: 12100),
      distanceM: 100,
      maxSpeedMps: 9.6,
      gpsQuality: GpsQuality.good,
      track: const [],
    ));
    final r = await repo.watchRecords().first;
    expect(r.best[EffortKind.sprint100m]!.runId, fast);
    expect(r.isPr(slow), isTrue); // first run is always a PR
    expect(r.isPr(fast), isTrue);

    await repo.deleteRun(fast);
    final after = await repo.watchRecords().first;
    expect(after.best[EffortKind.sprint100m]!.runId, slow);
  });

  test('notes are trimmed and cleared when empty', () async {
    final id = await repo.saveSprint(sprint());
    await repo.updateNote(id, '  windy  ');
    expect((await repo.getRun(id))!.note, 'windy');
    await repo.updateNote(id, '   ');
    expect((await repo.getRun(id))!.note, isNull);
  });
}
