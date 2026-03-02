import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/screens/home_screen.dart';

void main() {
  runApp(
    // Wrap the app with ProviderScope for Riverpod
    const ProviderScope(
      child: SprintTrackerApp(),
    ),
  );
}

class SprintTrackerApp extends StatelessWidget {
  const SprintTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprint Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
