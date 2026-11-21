import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/weeks.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/pictogram.dart';
import '../../../data/database.dart';
import '../../../data/records.dart';
import '../../../data/run_repository.dart';
import '../widgets/run_card.dart';
import '../widgets/weekly_bars.dart';
import 'run_detail_screen.dart';
import '../../../core/l10n.dart';

/// Runs swiped away but still undoable; deleted for real when the
/// snackbar closes without "Undo".
final pendingDeletesProvider = StateProvider<Set<int>>((ref) => {});

/// Removes a run with an undo window. Shared by the list and detail views.
void deleteRunWithUndo(BuildContext context, WidgetRef ref, Run run) {
  // Captured now: the calling screen (e.g. detail) may be gone when the
  // snackbar closes.
  final pending = ref.read(pendingDeletesProvider.notifier);
  final repo = ref.read(runRepositoryProvider);
  pending.update((s) => {...s, run.id});

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger
      .showSnackBar(SnackBar(
        content: Text(
          run.type == RunType.sprint
              ? context.l10n.sprintDeleted
              : context.l10n.runDeleted,
        ),
        action: SnackBarAction(label: context.l10n.undo, onPressed: () {}),
        duration: const Duration(seconds: 5),
      ))
      .closed
      .then((reason) async {
    if (reason != SnackBarClosedReason.action) {
      await repo.deleteRun(run.id);
    }
    pending.update((s) => {...s}..remove(run.id));
  });
}

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runs = ref.watch(runsProvider);
    final pending = ref.watch(pendingDeletesProvider);
    final records = ref.watch(recordsProvider).valueOrNull ?? RecordsSummary.empty;
    final miles = ref.watch(profileProvider).valueOrNull?.useMiles ?? false;

    return SafeArea(
      child: runs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (all) {
          final list = all.where((r) => !pending.contains(r.id)).toList();
          final now = DateTime.now();
          final weeks = groupByWeek(
            list,
            startedAt: (Run r) => r.startedAt,
            distanceM: (Run r) => r.distanceM,
            moving: (Run r) => Duration(milliseconds: r.movingMs),
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            children: [
              PageTitle(context.l10n.tabHistory),
              const SizedBox(height: 20),
              if (list.isEmpty)
                EmptyState(
                  picto: Picto.jog,
                  title: context.l10n.noRunsTitle,
                  body: context.l10n.noRunsBody,
                )
              else ...[
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel(context.l10n.last8Weeks),
                      const SizedBox(height: 12),
                      WeeklyBars(
                        weeks: weeklyTotals(
                          list,
                          now: now,
                          startedAt: (Run r) => r.startedAt,
                          distanceM: (Run r) => r.distanceM,
                        ),
                        miles: miles,
                      ),
                    ],
                  ),
                ),
                for (final w in weeks) ...[
                  const SizedBox(height: 24),
                  _WeekHeader(group: w, now: now, miles: miles),
                  const SizedBox(height: 10),
                  for (final run in w.items) ...[
                    Dismissible(
                      key: ValueKey('run-${run.id}'),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      onDismissed: (_) => deleteRunWithUndo(context, ref, run),
                      child: RunCard(
                        run: run,
                        miles: miles,
                        isPr: records.isPr(run.id),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RunDetailScreen(runId: run.id),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
                const SizedBox(height: 4),
                Text(
                  context.l10n.swipeToDelete,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.of(context).muted,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final WeekGroup<Run> group;
  final DateTime now;
  final bool miles;

  const _WeekHeader({
    required this.group,
    required this.now,
    required this.miles,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final n = group.items.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          weekLabel(
            group.start,
            now: now,
            thisWeek: context.l10n.thisWeek,
            lastWeek: context.l10n.lastWeek,
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${formatDistance(group.distanceM, miles: miles)} · '
            '${formatClock(group.moving)} · ${context.l10n.runsCount(n)}',
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: c.muted,
              fontFeatures: tabularFigures,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: c.warn.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.delete_outline_rounded, color: c.warn),
    );
  }
}
