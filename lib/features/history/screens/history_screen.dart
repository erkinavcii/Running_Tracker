import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/pictogram.dart';
import '../../../data/database.dart';
import '../../../data/run_repository.dart';

/// Basic run list. Weekly grouping, detail view and charts come in phase B.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runs = ref.watch(runsProvider);
    final miles = ref.watch(profileProvider).valueOrNull?.useMiles ?? false;

    return SafeArea(
      child: runs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          children: [
            PageTitle(
              'History',
              subtitle: list.isEmpty
                  ? null
                  : '${list.length} ${list.length == 1 ? 'run' : 'runs'}',
            ),
            const SizedBox(height: 20),
            if (list.isEmpty)
              const EmptyState(
                picto: Picto.jog,
                title: 'No runs yet',
                body: 'Finished sprints are saved here automatically.',
              )
            else
              for (final run in list) ...[
                _RunCard(run: run, miles: miles),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _RunCard extends StatelessWidget {
  final Run run;
  final bool miles;

  const _RunCard({required this.run, required this.miles});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final sprint = run.type == RunType.sprint;
    final main = sprint
        ? '${formatSprintTime(Duration(milliseconds: run.sprintTimeMs ?? run.elapsedMs))} s'
        : formatDistance(run.distanceM, miles: miles);
    final details = <String>[
      if (sprint) formatDistance(run.distanceM, miles: miles),
      if (!sprint) formatClock(Duration(milliseconds: run.movingMs)),
      if (sprint) 'top ${formatSpeed(run.maxSpeedMps, miles: miles)}',
      if (!sprint) formatPace(run.avgSpeedMps, miles: miles),
      if (run.kcal != null) '≈ ${run.kcal!.round()} kcal',
    ];

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.line),
            ),
            alignment: Alignment.center,
            child: Pictogram(
              sprint ? Picto.sprint : Picto.jog,
              size: 34,
              color: c.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      sprint ? 'Sprint' : 'Run',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                      ),
                    ),
                    if (run.gpsQuality != GpsQuality.good) ...[
                      const SizedBox(width: 8),
                      Icon(
                        run.gpsQuality == GpsQuality.none
                            ? Icons.gps_off_rounded
                            : Icons.gps_not_fixed_rounded,
                        size: 15,
                        color: c.warn,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  formatRunDate(run.startedAt),
                  style: TextStyle(fontSize: 12.5, color: c.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  details.join(' · '),
                  style: TextStyle(
                    fontSize: 13,
                    color: c.muted,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ],
            ),
          ),
          Text(
            main,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: c.ink,
              fontFeatures: tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}
