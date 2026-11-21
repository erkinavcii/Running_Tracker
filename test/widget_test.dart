import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sprint_tracker/data/database.dart';
import 'package:sprint_tracker/data/run_repository.dart';
import 'package:sprint_tracker/main.dart';

void main() {
  testWidgets('first launch shows onboarding, skip opens the tabs',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const SprintTrackerApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Skip for now'), findsOneWidget);

    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(find.text('Sprint'), findsOneWidget);
    expect(find.text('Endurance'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('No runs yet'), findsOneWidget);

    // Unmount so drift's stream queries are cancelled before teardown.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
