import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';
import 'track_sample.dart';

export 'track_sample.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final runRepositoryProvider = Provider<RunRepository>((ref) {
  return RunRepository(ref.watch(appDatabaseProvider));
});

final profileProvider = StreamProvider<Profile>((ref) {
  return ref.watch(runRepositoryProvider).watchProfile();
});

final runsProvider = StreamProvider<List<Run>>((ref) {
  return ref.watch(runRepositoryProvider).watchRuns();
});

class SprintResult {
  final DateTime startedAt;
  final Duration time;
  final double distanceM;
  final double maxSpeedMps;
  final GpsQuality gpsQuality;
  final double? kcal;
  final List<TrackSample> track;

  const SprintResult({
    required this.startedAt,
    required this.time,
    required this.distanceM,
    required this.maxSpeedMps,
    required this.gpsQuality,
    required this.track,
    this.kcal,
  });
}

class RunRepository {
  final AppDatabase _db;

  RunRepository(this._db);

  // ---------------------------------------------------------------- profile

  Stream<Profile> watchProfile() =>
      (_db.select(_db.profiles)..where((p) => p.id.equals(1))).watchSingle();

  Future<Profile> getProfile() =>
      (_db.select(_db.profiles)..where((p) => p.id.equals(1))).getSingle();

  Future<void> updateProfile(ProfilesCompanion changes) =>
      (_db.update(_db.profiles)..where((p) => p.id.equals(1))).write(changes);

  // ------------------------------------------------------------------- runs

  Stream<List<Run>> watchRuns() => (_db.select(_db.runs)
        ..where((r) => r.status.equalsValue(RunStatus.active).not())
        ..orderBy([(r) => OrderingTerm.desc(r.startedAt)]))
      .watch();

  Future<Run?> getRun(int id) =>
      (_db.select(_db.runs)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<List<TrackPoint>> getTrack(int runId) => (_db.select(_db.trackPoints)
        ..where((t) => t.runId.equals(runId))
        ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
      .get();

  /// Deletes a run with its track, splits and efforts (FK cascade).
  Future<void> deleteRun(int id) =>
      (_db.delete(_db.runs)..where((r) => r.id.equals(id))).go();

  /// Stores a finished sprint with its track and best efforts in one
  /// transaction. Returns the new run id.
  Future<int> saveSprint(SprintResult r) {
    return _db.transaction(() async {
      final timeMs = r.time.inMilliseconds;
      final runId = await _db.into(_db.runs).insert(RunsCompanion.insert(
            type: RunType.sprint,
            status: RunStatus.finished,
            startedAt: r.startedAt,
            endedAt: Value(r.startedAt.add(r.time)),
            elapsedMs: Value(timeMs),
            movingMs: Value(timeMs),
            distanceM: Value(r.distanceM),
            avgSpeedMps: Value(timeMs > 0 ? r.distanceM / (timeMs / 1000) : 0),
            maxSpeedMps: Value(r.maxSpeedMps),
            kcal: Value(r.kcal),
            sprintTimeMs: Value(timeMs),
            targetDistanceM: Value(r.distanceM),
            gpsQuality: r.gpsQuality,
          ));

      await _insertTrack(runId, r.track);

      // A run without GPS can't set records: its numbers are not measured.
      if (r.gpsQuality != GpsQuality.none) {
        await _db.batch((b) {
          b.insertAll(_db.bestEfforts, [
            BestEffortsCompanion.insert(
              runId: runId,
              kind: EffortKind.sprint100m,
              valueMs: Value(timeMs),
            ),
            BestEffortsCompanion.insert(
              runId: runId,
              kind: EffortKind.topSpeed,
              valueMps: Value(r.maxSpeedMps),
            ),
          ]);
        });
      }
      return runId;
    });
  }

  Future<void> _insertTrack(int runId, List<TrackSample> track) async {
    if (track.isEmpty) return;
    await _db.batch((b) {
      b.insertAll(_db.trackPoints, [
        for (var i = 0; i < track.length; i++)
          TrackPointsCompanion.insert(
            runId: runId,
            seq: i,
            tMs: track[i].tMs,
            lat: track[i].lat,
            lon: track[i].lon,
            speedMps: track[i].speedMps,
            speedAccMps: Value(track[i].speedAccMps),
            accM: track[i].accM,
            altM: Value(track[i].altM),
            segment: Value(track[i].segment),
          ),
      ]);
    });
  }
}
