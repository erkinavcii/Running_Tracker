import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/location_service.dart';
import 'core/services/sensor_fusion_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/sprint/providers/demo_sprint_controller.dart';
import 'features/sprint/providers/sprint_controller.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
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
      home: const HomeScreen(),
    );
  }
}
