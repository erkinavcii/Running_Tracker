import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/location_service.dart';
import 'core/services/sensor_fusion_service.dart';
import 'core/theme/app_theme.dart';
import 'data/run_repository.dart';
import 'features/demo/demo_data.dart';
import 'features/shell/app_shell.dart';
import 'features/tracking/tracking_service.dart';
import 'features/sprint/providers/demo_sprint_controller.dart';
import 'features/sprint/providers/sprint_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initTrackingService();
  // Demo builds use a seeded in-memory database, never the real one.
  final demoDb = demoMode.isEmpty ? null : await buildDemoDatabase();

  runApp(
    ProviderScope(
      overrides: [
        if (demoDb != null) appDatabaseProvider.overrideWithValue(demoDb),
        if (demoMode.isNotEmpty)
          sprintControllerProvider.overrideWith(
            (ref) => DemoSprintController(
              ref.watch(sensorFusionServiceProvider),
              ref.watch(locationServiceProvider),
            ),
          ),
      ],
      child: const SprintTrackerApp(),
    ),
  );
}

class SprintTrackerApp extends StatelessWidget {
  const SprintTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprint Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const RootGate(),
    );
  }
}
