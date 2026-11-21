import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/l10n.dart';

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
  await initializeDateFormatting();
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

class SprintTrackerApp extends ConsumerWidget {
  const SprintTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chosen = ref.watch(profileProvider).valueOrNull?.language;
    return MaterialApp(
      onGenerateTitle: (c) => c.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      // null = follow the phone (falls back to English).
      locale: chosen == null ? null : Locale(chosen),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Dates formatted outside widgets (formatRunDate) follow the UI.
        Intl.defaultLocale = Localizations.localeOf(context).languageCode;
        return child!;
      },
      home: const RootGate(),
    );
  }
}
