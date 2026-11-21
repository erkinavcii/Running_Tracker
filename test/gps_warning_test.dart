import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/l10n/app_localizations.dart';

import 'package:sprint_tracker/core/services/location_service.dart';
import 'package:sprint_tracker/core/services/sensor_fusion_service.dart';
import 'package:sprint_tracker/core/theme/app_theme.dart';
import 'package:sprint_tracker/features/sprint/providers/sprint_controller.dart';
import 'package:sprint_tracker/features/sprint/screens/sprint_active_screen.dart';

/// Controller with a fixed state; never touches GPS.
class _FixedController extends SprintController {
  _FixedController(super.fusion, super.location, SprintData data) {
    state = data;
  }

  @override
  Future<void> startCalibration() async {}

  @override
  void stopRunning() {}
}

Future<void> _pump(WidgetTester tester, SprintData data) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);

  final location = LocationService();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sprintControllerProvider.overrideWith(
          (ref) => _FixedController(
            SensorFusionService(location),
            location,
            data,
          ),
        ),
      ],
      child: MaterialApp(
        theme: buildTheme(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SprintActiveScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('no fix after calibration shows warning and START ANYWAY',
      (tester) async {
    await _pump(
      tester,
      SprintData(state: SprintState.ready, gpsIssue: GpsIssue.noFix),
    );

    expect(find.text('No GPS signal'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('START ANYWAY'), findsOneWidget);
    expect(find.text('No fix'), findsOneWidget); // GPS chip
  });

  testWidgets('permission denied offers settings and retry', (tester) async {
    await _pump(
      tester,
      SprintData(
        state: SprintState.calibrating,
        gpsIssue: GpsIssue.permissionDenied,
      ),
    );

    expect(find.text('Location permission needed'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
    expect(find.text('TRY AGAIN'), findsOneWidget);
  });

  testWidgets('GPS lost while running shows a warning without actions',
      (tester) async {
    await _pump(
      tester,
      SprintData(state: SprintState.running, gpsLost: true, gpsAccuracy: 4),
    );

    expect(find.text('GPS signal lost'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('good fix shows no warning', (tester) async {
    await _pump(
      tester,
      SprintData(state: SprintState.ready, gpsAccuracy: 3.2),
    );

    expect(find.text('No GPS signal'), findsNothing);
    expect(find.text('START SPRINT'), findsOneWidget);
  });
}
