import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

enum RunType { sprint, endurance }

enum RunStatus { active, paused, finished, recovered }

enum GpsQuality { good, weak, none }

enum Sex { male, female, other }

/// Personal records are derived from these (MIN/MAX per kind), never stored
/// separately, so they can't drift out of sync with the runs.
enum EffortKind {
  sprint100m, // valueMs
  topSpeed, // valueMps
  best400m,
  best1k,
  best5k,
  best10k,
  bestHalf, // valueMs
  longest, // valueM
}

/// Single-row table (id = 1).
class Profiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  RealColumn get weightKg => real().nullable()();
  IntColumn get heightCm => integer().nullable()();
  IntColumn get birthYear => integer().nullable()();
  TextColumn get sex => textEnum<Sex>().nullable()();
  BoolColumn get useMiles => boolean().withDefault(const Constant(false))();
  BoolColumn get audioCues => boolean().withDefault(const Constant(true))();
  BoolColumn get autoPause => boolean().withDefault(const Constant(true))();
  BoolColumn get onboarded => boolean().withDefault(const Constant(false))();
  // v2: null = follow the phone's language; otherwise 'en' or 'tr'.
  TextColumn get language => text().nullable()();
  BoolColumn get keepScreenOn =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Runs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => textEnum<RunType>()();
  TextColumn get status => textEnum<RunStatus>()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get elapsedMs => integer().withDefault(const Constant(0))();
  IntColumn get movingMs => integer().withDefault(const Constant(0))();
  RealColumn get distanceM => real().withDefault(const Constant(0))();
  RealColumn get avgSpeedMps => real().withDefault(const Constant(0))();
  RealColumn get maxSpeedMps => real().withDefault(const Constant(0))();
  RealColumn get kcal => real().nullable()();
  RealColumn get elevGainM => real().nullable()();
  IntColumn get sprintTimeMs => integer().nullable()();
  RealColumn get targetDistanceM => real().nullable()();
  TextColumn get gpsQuality => textEnum<GpsQuality>()();
  TextColumn get note => text().nullable()();
}

@TableIndex(name: 'track_points_run', columns: {#runId, #seq})
class TrackPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runId =>
      integer().references(Runs, #id, onDelete: KeyAction.cascade)();
  IntColumn get seq => integer()();
  IntColumn get tMs => integer()(); // since run start
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  RealColumn get speedMps => real()();
  RealColumn get speedAccMps => real().nullable()();
  RealColumn get accM => real()();
  RealColumn get altM => real().nullable()();
  IntColumn get segment => integer().withDefault(const Constant(0))();
}

class Splits extends Table {
  IntColumn get runId =>
      integer().references(Runs, #id, onDelete: KeyAction.cascade)();
  IntColumn get idx => integer()();
  RealColumn get distanceM => real()();
  IntColumn get durationMs => integer()();
  RealColumn get avgSpeedMps => real()();
  RealColumn get elevDeltaM => real().nullable()();

  @override
  Set<Column> get primaryKey => {runId, idx};
}

@TableIndex(name: 'best_efforts_kind', columns: {#kind})
class BestEfforts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runId =>
      integer().references(Runs, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<EffortKind>()();
  IntColumn get valueMs => integer().nullable()();
  RealColumn get valueMps => real().nullable()();
  RealColumn get valueM => real().nullable()();
  IntColumn get startSeq => integer().nullable()();
  IntColumn get endSeq => integer().nullable()();
}

@DriftDatabase(tables: [Profiles, Runs, TrackPoints, Splits, BestEfforts])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'sprint_tracker'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(profiles).insert(ProfilesCompanion.insert());
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(profiles, profiles.language);
            await m.addColumn(profiles, profiles.keepScreenOn);
          }
        },
        beforeOpen: (details) async {
          // SQLite ignores ON DELETE CASCADE unless this is on.
          await customStatement('PRAGMA foreign_keys = ON');
          // The tracking service writes through its own connection while
          // the UI reads: WAL lets them overlap, busy_timeout waits instead
          // of failing with "database is locked".
          await customStatement('PRAGMA busy_timeout = 5000');
          // journal_mode returns a row, so it must run as a select.
          await customSelect('PRAGMA journal_mode = WAL').get();
        },
      );
}
