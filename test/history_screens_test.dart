import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sprint_tracker/data/database.dart';
import 'package:sprint_tracker/data/run_repository.dart';
import 'package:sprint_tracker/main.dart';

Future<(AppDatabase, RunRepository)> _seed() async {
  final db = AppDatabase(NativeDatabase.memory());
  final repo = RunRepository(db);
  await repo.updateProfile(const ProfilesCompanion(onboarded: Value(true)));
  final now = DateTime.now();
  for (final (daysAgo, ms) in [(1, 13200), (0, 12480)]) {
    await repo.saveSprint(SprintResult(
      startedAt: now.subtract(Duration(days: daysAgo, minutes: 5)),
      time: Duration(milliseconds: ms),
      distanceM: 100,
      maxSpeedMps: 9.0 + (13200 - ms) / 1000,
      gpsQuality: GpsQuality.good,
      splitTimesMs: [for (var i = 1; i <= 10; i++) (ms * i / 10).round()],
      track: const [],
    ));
  }
  return (db, repo);
}

Future<void> _pumpApp(WidgetTester tester, AppDatabase db) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: const SprintTrackerApp(),
  ));
  await tester.pumpAndSettle();
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 10));
}

void main() {
  testWidgets('history groups runs, marks PRs and opens the detail',
      (tester) async {
    final (db, _) = (await tester.runAsync(_seed))!;
    addTearDown(() => tester.runAsync(db.close));
    await _pumpApp(tester, db);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('LAST 8 WEEKS'), findsOneWidget);
    expect(find.text('12.48 s'), findsOneWidget);
    expect(find.text('13.20 s'), findsOneWidget);
    // Both runs improved the record when they were run.
    expect(find.text('PR'), findsNWidgets(2));

    await tester.tap(find.text('12.48 s'));
    await tester.pumpAndSettle();
    expect(find.text('SPEED EVERY 10 M'), findsOneWidget);
    expect(find.text('100 M SPRINT'), findsOneWidget); // PR chip
    await tester.scrollUntilVisible(find.text('Add a note'), 300);
    expect(find.text('Add a note'), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('swipe to delete can be undone', (tester) async {
    final (db, repo) = (await tester.runAsync(_seed))!;
    addTearDown(() => tester.runAsync(db.close));
    await _pumpApp(tester, db);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    await tester.drag(find.text('13.20 s'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('13.20 s'), findsNothing);
    expect(find.text('Sprint deleted'), findsOneWidget);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect(find.text('13.20 s'), findsOneWidget);
    final runs = await tester.runAsync(() => repo.watchRuns().first);
    expect(runs, hasLength(2));

    await _unmount(tester);
  });

  testWidgets('records screen shows best 100 m and top speed', (tester) async {
    final (db, _) = (await tester.runAsync(_seed))!;
    addTearDown(() => tester.runAsync(db.close));
    await _pumpApp(tester, db);

    await tester.tap(find.text('Records'));
    await tester.pumpAndSettle();
    expect(find.text('100 m sprint'), findsOneWidget);
    expect(find.text('12.48 s'), findsOneWidget);
    expect(find.text('35.0 km/h'), findsOneWidget); // 9.72 m/s
    expect(find.text('Not set yet'), findsNWidgets(6)); // endurance kinds

    await _unmount(tester);
  });
}
