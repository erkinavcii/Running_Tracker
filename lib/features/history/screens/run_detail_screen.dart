import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/database.dart';
import '../../../data/effort_labels.dart';
import '../../../data/records.dart';
import '../../../data/run_repository.dart';
import '../widgets/run_card.dart';
import 'history_screen.dart';

class RunDetailScreen extends ConsumerWidget {
  final int runId;

  const RunDetailScreen({super.key, required this.runId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runAsync = ref.watch(runProvider(runId));
    final miles = ref.watch(profileProvider).valueOrNull?.useMiles ?? false;
    final records =
        ref.watch(recordsProvider).valueOrNull ?? RecordsSummary.empty;

    return runAsync.when(
      loading: () => const Scaffold(),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (run) {
        if (run == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This run was deleted.')),
          );
        }
        final sprint = run.type == RunType.sprint;
        final prs = records.prsByRun[run.id] ?? const {};

        return Scaffold(
          appBar: AppBar(
            title: Text(sprint ? 'Sprint' : 'Run'),
            actions: [
              IconButton(
                tooltip: 'Edit note',
                icon: const Icon(Icons.edit_note_rounded),
                onPressed: () => _editNote(context, ref, run),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () {
                  deleteRunWithUndo(context, ref, run);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              Text(
                formatRunDate(run.startedAt),
                style: TextStyle(fontSize: 14, color: AppColors.of(context).muted),
              ),
              const SizedBox(height: 14),
              _Hero(run: run, miles: miles),
              if (prs.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final k in prs) PrBadge(text: effortLabel(k).toUpperCase()),
                  ],
                ),
              ],
              if (run.gpsQuality != GpsQuality.good) ...[
                const SizedBox(height: 12),
                _GpsNote(quality: run.gpsQuality),
              ],
              const SizedBox(height: 16),
              _StatsGrid(run: run, miles: miles),
              const SizedBox(height: 24),
              if (sprint)
                _SprintSplits(runId: run.id, miles: miles)
              else
                _KmSplits(runId: run.id, miles: miles),
              const SizedBox(height: 24),
              _NoteCard(run: run, onEdit: () => _editNote(context, ref, run)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editNote(BuildContext context, WidgetRef ref, Run run) async {
    final controller = TextEditingController(text: run.note ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          minLines: 2,
          decoration: const InputDecoration(
            hintText: 'Track, wind, shoes, how it felt…',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null) {
      await ref.read(runRepositoryProvider).updateNote(run.id, result);
    }
  }
}

class _Hero extends StatelessWidget {
  final Run run;
  final bool miles;

  const _Hero({required this.run, required this.miles});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final sprint = run.type == RunType.sprint;
    final value = sprint
        ? formatSprintTime(Duration(milliseconds: run.sprintTimeMs ?? run.elapsedMs))
        : formatDistance(run.distanceM, miles: miles).split(' ').first;
    final unit = sprint ? 's' : (miles ? 'mi' : (run.distanceM < 1000 ? 'm' : 'km'));

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(sprint
              ? '${run.targetDistanceM?.round() ?? 100} m time'
              : 'Distance'),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 64,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    color: c.accent,
                    fontFeatures: tabularFigures,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: c.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Run run;
  final bool miles;

  const _StatsGrid({required this.run, required this.miles});

  @override
  Widget build(BuildContext context) {
    final sprint = run.type == RunType.sprint;
    final stats = <(String, String)>[
      if (sprint) ('Distance', formatDistance(run.distanceM, miles: miles)),
      if (!sprint) ('Moving time', formatClock(Duration(milliseconds: run.movingMs))),
      if (!sprint && run.elapsedMs != run.movingMs)
        ('Elapsed', formatClock(Duration(milliseconds: run.elapsedMs))),
      if (sprint) ('Avg speed', formatSpeed(run.avgSpeedMps, miles: miles)),
      if (!sprint) ('Avg pace', formatPace(run.avgSpeedMps, miles: miles)),
      ('Top speed', formatSpeed(run.maxSpeedMps, miles: miles)),
      ('Calories', run.kcal == null ? '–' : '≈ ${run.kcal!.round()} kcal'),
      if (run.elevGainM != null) ('Elevation', '${run.elevGainM!.round()} m'),
    ];

    return LayoutBuilder(builder: (context, box) {
      final w = (box.maxWidth - 10) / 2;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final s in stats)
            SizedBox(width: w, child: _Stat(label: s.$1, value: s.$2)),
        ],
      );
    });
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: c.ink,
                fontFeatures: tabularFigures,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsNote extends StatelessWidget {
  final GpsQuality quality;

  const _GpsNote({required this.quality});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final none = quality == GpsQuality.none;
    return Row(
      children: [
        Icon(none ? Icons.gps_off_rounded : Icons.gps_not_fixed_rounded,
            size: 18, color: c.warn),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            none
                ? 'Recorded without GPS. Speed and distance are not measured, '
                    'so this run does not count for records.'
                : 'Recorded with a weak GPS signal. Values may be off.',
            style: TextStyle(fontSize: 13, height: 1.35, color: c.muted),
          ),
        ),
      ],
    );
  }
}

/// Speed per 10 m segment plus cumulative times.
class _SprintSplits extends ConsumerWidget {
  final int runId;
  final bool miles;

  const _SprintSplits({required this.runId, required this.miles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final splits = ref.watch(splitsProvider(runId)).valueOrNull ?? const [];
    if (splits.isEmpty) return const SizedBox.shrink();

    final factor = miles ? 3600 / metersPerMile : 3.6;
    final speeds = [for (final s in splits) s.avgSpeedMps * factor];
    final maxV = speeds.fold(0.0, (m, v) => v > m ? v : m);
    var cumulative = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Speed every 10 m'),
        const SizedBox(height: 12),
        SurfaceCard(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          child: SizedBox(
            height: 170,
            child: BarChart(
              BarChartData(
                maxY: (maxV * 1.15).ceilToDouble(),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: c.line, strokeWidth: 1),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => c.ink,
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '${rod.toY.toStringAsFixed(1)} ${miles ? 'mph' : 'km/h'}',
                      TextStyle(color: c.background, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, meta) => Text(
                        v.toStringAsFixed(0),
                        style: TextStyle(fontSize: 10.5, color: c.muted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, meta) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${(v.toInt() + 1) * 10}',
                          style: TextStyle(fontSize: 10.5, color: c.muted),
                        ),
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < speeds.length; i++)
                    BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: speeds[i],
                        width: 14,
                        color: speeds[i] == maxV ? c.accent : c.muted,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ]),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              for (final s in splits)
                () {
                  cumulative += s.durationMs;
                  return _SplitRow(
                    label: '${(s.idx + 1) * 10} m',
                    time: '${formatSprintTime(Duration(milliseconds: cumulative))} s',
                    detail: '+${(s.durationMs / 1000).toStringAsFixed(2)} s',
                  );
                }(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kilometre splits for endurance runs.
class _KmSplits extends ConsumerWidget {
  final int runId;
  final bool miles;

  const _KmSplits({required this.runId, required this.miles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splits = ref.watch(splitsProvider(runId)).valueOrNull ?? const [];
    if (splits.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Splits'),
        const SizedBox(height: 12),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              for (final s in splits)
                _SplitRow(
                  label: '${s.idx + 1} ${miles ? 'mi' : 'km'}',
                  time: formatClock(Duration(milliseconds: s.durationMs)),
                  detail: formatPace(s.avgSpeedMps, miles: miles),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SplitRow extends StatelessWidget {
  final String label;
  final String time;
  final String detail;

  const _SplitRow({
    required this.label,
    required this.time,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final num = TextStyle(
      fontSize: 14.5,
      color: c.ink,
      fontWeight: FontWeight.w600,
      fontFeatures: tabularFigures,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(label, style: TextStyle(fontSize: 13.5, color: c.muted)),
          ),
          Expanded(child: Text(time, style: num)),
          Text(detail, style: num.copyWith(color: c.muted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Run run;
  final VoidCallback onEdit;

  const _NoteCard({required this.run, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final note = run.note;
    return SurfaceCard(
      onTap: onEdit,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notes_rounded, size: 18, color: c.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              note ?? 'Add a note',
              style: TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: note == null ? c.muted : c.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
