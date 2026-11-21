import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/best_efforts.dart';
import '../core/elevation.dart';
import '../core/track_math.dart';
import 'database.dart';
import 'records.dart';
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

final recordsProvider = StreamProvider<RecordsSummary>((ref) {
  return ref.watch(runRepositoryProvider).watchRecords();
});

final runProvider = StreamProvider.family<Run?, int>((ref, id) {
  return ref.watch(runRepositoryProvider).watchRun(id);
});

final splitsProvider = StreamProvider.family<List<Split>, int>((ref, runId) {
  return ref.watch(runRepositoryProvider).watchSplits(runId);
});

final trackProvider = FutureProvider.family<List<TrackPoint>, int>((ref, id) {
  return ref.watch(runRepositoryProvider).getTrack(id);
});

class SprintResult {
  final DateTime startedAt;
  final Duration time;
  final double distanceM;
  final double maxSpeedMps;
  final GpsQuality gpsQuality;
  final double? kcal;
  final List<TrackSample> track;

  /// Cumulative times (ms) at 10, 20 … 100 m.
  final List<int> splitTimesMs;

  const SprintResult({
    required this.startedAt,
    required this.time,
    required this.distanceM,
    required this.maxSpeedMps,
    required this.gpsQuality,
    required this.track,
    this.kcal,
    this.splitTimesMs = const [],
  });
}

/// One point accepted by the live tracker, ready to store.
class StoredPoint {
  final int tMs;
  final double lat;
  final double lon;
  final double speedMps;
  final double? speedAccMps;
  final double accM;
  final double? altM;
  final int segment;

  const StoredPoint({
    required this.tMs,
    required this.lat,
    required this.lon,
    required this.speedMps,
    required this.accM,
    required this.segment,
    this.speedAccMps,
    this.altM,
  });
}

/// Running totals written while an endurance run is in progress.
class RunProgress {
  final RunStatus status;
  final int elapsedMs;
  final int movingMs;
  final double distanceM;
  final double maxSpeedMps;
  final double? kcal;
  final double? elevGainM;

  const RunProgress({
    required this.status,
    required this.elapsedMs,
    required this.movingMs,
    required this.distanceM,
    required this.maxSpeedMps,
    this.kcal,
    this.elevGainM,
  });
}

const enduranceEffortTargets = {
  EffortKind.best400m: 400.0,
  EffortKind.best1k: 1000.0,
  EffortKind.best5k: 5000.0,
  EffortKind.best10k: 10000.0,
  EffortKind.bestHalf: 21097.5,
};

class RunRepository {
  final AppDatabase _db;

  RunRepository(this._db);

  /// Re-runs the UI's stream queries after another isolate (the tracking
  /// service) wrote to the database through its own connection.
  void notifyExternalChanges() {
    _db.notifyUpdates({
      TableUpdate.onTable(_db.runs),
      TableUpdate.onTable(_db.trackPoints),
      TableUpdate.onTable(_db.splits),
      TableUpdate.onTable(_db.bestEfforts),
    });
  }

  // -------------------------------------------------------- endurance runs

  Future<int> createEnduranceRun(DateTime startedAt) =>
      _db.into(_db.runs).insert(RunsCompanion.insert(
            type: RunType.endurance,
            status: RunStatus.active,
            startedAt: startedAt,
            gpsQuality: GpsQuality.good,
          ));

  /// The unfinished endurance run, if the app or service died mid-run.
  Future<Run?> getUnfinishedRun() => (_db.select(_db.runs)
        ..where((r) =>
            r.type.equalsValue(RunType.endurance) &
            r.status.isInValues([RunStatus.active, RunStatus.paused]))
        ..orderBy([(r) => OrderingTerm.desc(r.startedAt)])
        ..limit(1))
      .getSingleOrNull();

  Future<TrackPoint?> lastPoint(int runId) => (_db.select(_db.trackPoints)
        ..where((t) => t.runId.equals(runId))
        ..orderBy([(t) => OrderingTerm.desc(t.seq)])
        ..limit(1))
      .getSingleOrNull();

  /// Appends points (seq continues from [firstSeq]) and writes the running
  /// totals in one transaction, so a crash never leaves them out of sync.
  Future<void> saveProgress(
    int runId,
    int firstSeq,
    List<StoredPoint> points,
    RunProgress p,
  ) {
    return _db.transaction(() async {
      if (points.isNotEmpty) {
        await _db.batch((b) {
          b.insertAll(_db.trackPoints, [
            for (var i = 0; i < points.length; i++)
              TrackPointsCompanion.insert(
                runId: runId,
                seq: firstSeq + i,
                tMs: points[i].tMs,
                lat: points[i].lat,
                lon: points[i].lon,
                speedMps: points[i].speedMps,
                speedAccMps: Value(points[i].speedAccMps),
                accM: points[i].accM,
                altM: Value(points[i].altM),
                segment: Value(points[i].segment),
              ),
          ]);
        });
      }
      await (_db.update(_db.runs)..where((r) => r.id.equals(runId))).write(
        RunsCompanion(
          status: Value(p.status),
          elapsedMs: Value(p.elapsedMs),
          movingMs: Value(p.movingMs),
          distanceM: Value(p.distanceM),
          maxSpeedMps: Value(p.maxSpeedMps),
          avgSpeedMps: Value(
            p.movingMs > 0 ? p.distanceM / (p.movingMs / 1000) : 0,
          ),
          kcal: Value(p.kcal),
          elevGainM: Value(p.elevGainM),
        ),
      );
    });
  }

  /// Turns an active run into a finished one: recomputes distance from the
  /// stored track (same rule as the live engine), then writes km splits and
  /// best efforts on a moving-time axis (pauses excluded).
  /// Runs with fewer than two fixes are deleted; returns null in that case.
  Future<int?> finishEndurance(
    int runId, {
    required DateTime endedAt,
    required int elapsedMs,
    required int movingMs,
    double? kcal,
  }) {
    return _db.transaction(() async {
      final pts = await getTrack(runId);
      if (pts.length < 2) {
        await deleteRun(runId);
        return null;
      }

      final like = [
        for (final p in pts)
          TrackPointLike(
            tMs: p.tMs,
            lat: p.lat,
            lon: p.lon,
            speedMps: p.speedMps,
            segment: p.segment,
          ),
      ];
      final dist = cumulativeDistance(like);
      // Moving-time axis: time only advances inside a segment.
      final moving = List<int>.filled(pts.length, 0);
      for (var i = 1; i < pts.length; i++) {
        final same = pts[i].segment == pts[i - 1].segment;
        moving[i] = moving[i - 1] + (same ? pts[i].tMs - pts[i - 1].tMs : 0);
      }

      final total = dist.last;
      final maxSpeed =
          pts.fold(0.0, (m, p) => p.speedMps > m ? p.speedMps : m);
      final moveMs = movingMs > 0 ? movingMs : moving.last;

      await (_db.update(_db.runs)..where((r) => r.id.equals(runId))).write(
        RunsCompanion(
          status: const Value(RunStatus.finished),
          endedAt: Value(endedAt),
          elapsedMs: Value(elapsedMs),
          movingMs: Value(moveMs),
          distanceM: Value(total),
          maxSpeedMps: Value(maxSpeed),
          avgSpeedMps: Value(moveMs > 0 ? total / (moveMs / 1000) : 0),
          kcal: Value(kcal),
          elevGainM: Value(ElevationGain.of(pts.map((p) => p.altM))),
        ),
      );

      // Kilometre splits on the moving-time axis.
      final crossings = crossingTimes(tMs: moving, distM: dist, stepM: 1000);
      await _insertSplits(runId, crossings, 1000);

      // Best efforts, top speed and longest run.
      final efforts = <BestEffortsCompanion>[
        BestEffortsCompanion.insert(
          runId: runId,
          kind: EffortKind.longest,
          valueM: Value(total),
        ),
        BestEffortsCompanion.insert(
          runId: runId,
          kind: EffortKind.topSpeed,
          valueMps: Value(maxSpeed),
        ),
      ];
      for (final e in enduranceEffortTargets.entries) {
        final best = bestEffort(tMs: moving, distM: dist, targetM: e.value);
        if (best == null) continue;
        efforts.add(BestEffortsCompanion.insert(
          runId: runId,
          kind: e.key,
          valueMs: Value(best.durationMs),
          startSeq: Value(pts[best.startIndex].seq),
          endSeq: Value(pts[best.endIndex].seq),
        ));
      }
      await _db.batch((b) => b.insertAll(_db.bestEfforts, efforts));
      return runId;
    });
  }

  // ---------------------------------------------------------------- profile

  Stream<Profile> watchProfile() =>
      (_db.select(_db.profiles)..where((p) => p.id.equals(1))).watchSingle();

  Future<Profile> getProfile() =>
      (_db.select(_db.profiles)..where((p) => p.id.equals(1))).getSingle();

  Future<void> updateProfile(ProfilesCompanion changes) =>
      (_db.update(_db.profiles)..where((p) => p.id.equals(1))).write(changes);

  // ------------------------------------------------------------------- runs

  Stream<List<Run>> watchRuns() => (_db.select(_db.runs)
        // Unfinished runs (active or paused) are not history yet.
        ..where((r) =>
            r.status.isInValues([RunStatus.active, RunStatus.paused]).not())
        ..orderBy([(r) => OrderingTerm.desc(r.startedAt)]))
      .watch();

  Stream<Run?> watchRun(int id) =>
      (_db.select(_db.runs)..where((r) => r.id.equals(id)))
          .watchSingleOrNull();

  Stream<List<Split>> watchSplits(int runId) => (_db.select(_db.splits)
        ..where((s) => s.runId.equals(runId))
        ..orderBy([(s) => OrderingTerm.asc(s.idx)]))
      .watch();

  Future<void> updateNote(int runId, String? note) =>
      (_db.update(_db.runs)..where((r) => r.id.equals(runId))).write(
        RunsCompanion(
          note: Value(note == null || note.trim().isEmpty ? null : note.trim()),
        ),
      );

  /// All efforts of finished runs, folded into records and PR history.
  Stream<RecordsSummary> watchRecords() {
    final q = _db.select(_db.bestEfforts).join([
      innerJoin(_db.runs, _db.runs.id.equalsExp(_db.bestEfforts.runId)),
    ])
      ..where(_db.runs.status.equalsValue(RunStatus.finished));
    return q.watch().map((rows) => RecordsSummary.fromEntries(rows.map((r) {
          final e = r.readTable(_db.bestEfforts);
          final run = r.readTable(_db.runs);
          return EffortEntry(
            kind: e.kind,
            runId: run.id,
            runStartedAt: run.startedAt,
            value: (e.valueMs?.toDouble() ?? e.valueMps ?? e.valueM ?? 0),
          );
        })));
  }

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
      await _insertSplits(runId, r.splitTimesMs, 10);

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

  /// [cumulativeMs] are crossing times of every [stepM] mark.
  Future<void> _insertSplits(
    int runId,
    List<int> cumulativeMs,
    double stepM,
  ) async {
    if (cumulativeMs.isEmpty) return;
    await _db.batch((b) {
      b.insertAll(_db.splits, [
        for (var k = 0; k < cumulativeMs.length; k++)
          () {
            final dur = cumulativeMs[k] - (k == 0 ? 0 : cumulativeMs[k - 1]);
            return SplitsCompanion.insert(
              runId: runId,
              idx: k,
              distanceM: stepM,
              durationMs: dur,
              avgSpeedMps: dur > 0 ? stepM / (dur / 1000) : 0,
            );
          }(),
      ]);
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
