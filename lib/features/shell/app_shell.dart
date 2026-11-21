import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/theme/app_theme.dart';
import '../../data/run_repository.dart';
import '../history/screens/history_screen.dart';
import '../history/screens/run_detail_screen.dart';
import '../home/screens/home_screen.dart';
import '../profile/screens/onboarding_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../records/screens/records_screen.dart';
import '../tracking/screens/live_run_screen.dart';
import '../tracking/tracking_service.dart';
import '../../core/l10n.dart';

/// Shows onboarding once, then the tabbed app.
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return profile.when(
      data: (p) => p.onboarded ? const AppShell() : const OnboardingScreen(),
      loading: () => const Scaffold(),
      error: (e, _) => Scaffold(
        body: Center(child: Text(context.l10n.dbError('$e'))),
      ),
    );
  }
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Keep the tracking controller alive so a running service reconnects.
    ref.read(trackingProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUnfinished());
  }

  /// A run whose service died (phone reboot, force stop, crash).
  Future<void> _checkUnfinished() async {
    if (await isTrackingServiceRunning()) return;
    final repo = ref.read(runRepositoryProvider);
    final run = await repo.getUnfinishedRun();
    if (run == null || !mounted) return;

    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.unfinishedTitle),
        content: Text(
          '${formatRunDate(run.startedAt)}\n'
          '${formatDistance(run.distanceM)} · '
          '${formatClock(Duration(milliseconds: run.movingMs))}\n\n'
          '${context.l10n.unfinishedBody}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: Text(context.l10n.discard),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: Text(context.l10n.save),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
            onPressed: () => Navigator.pop(ctx, 'resume'),
            child: Text(context.l10n.continueRun),
          ),
        ],
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case 'resume':
        await ref.read(trackingProvider.notifier).start();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LiveRunScreen()),
        );
      case 'save':
        final id = await repo.finishEndurance(
          run.id,
          endedAt: run.startedAt.add(Duration(milliseconds: run.elapsedMs)),
          elapsedMs: run.elapsedMs,
          movingMs: run.movingMs,
          kcal: run.kcal,
        );
        if (!mounted) return;
        if (id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RunDetailScreen(runId: id)),
          );
        }
      case 'discard':
        await repo.deleteRun(run.id);
    }
  }

  static const _pages = [
    HomeScreen(),
    HistoryScreen(),
    RecordsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.line)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.directions_run_outlined),
              selectedIcon: Icon(Icons.directions_run_rounded),
              label: context.l10n.tabRun,
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: context.l10n.tabHistory,
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events_rounded),
              label: context.l10n.tabRecords,
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: context.l10n.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}
