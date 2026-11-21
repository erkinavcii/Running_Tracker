import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/pictogram.dart';
import '../../../data/database.dart';
import '../../../data/effort_labels.dart';
import '../../../data/records.dart';
import '../../../data/run_repository.dart';
import '../../history/screens/run_detail_screen.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordsProvider);
    final miles = ref.watch(profileProvider).valueOrNull?.useMiles ?? false;

    return SafeArea(
      child: records.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (r) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          children: [
            const PageTitle('Records'),
            const SizedBox(height: 20),
            if (r.best.isEmpty)
              const EmptyState(
                picto: Picto.finish,
                title: 'No records yet',
                body: 'Finish a sprint with GPS to set your first 100 m time '
                    'and top speed.',
              )
            else ...[
              const SectionLabel('Sprint'),
              const SizedBox(height: 10),
              for (final k in sprintKinds) ...[
                _RecordTile(kind: k, summary: r, miles: miles),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 14),
              const SectionLabel('Endurance'),
              const SizedBox(height: 10),
              for (final k in enduranceKinds) ...[
                _RecordTile(kind: k, summary: r, miles: miles),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final EffortKind kind;
  final RecordsSummary summary;
  final bool miles;

  const _RecordTile({
    required this.kind,
    required this.summary,
    required this.miles,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final best = summary.best[kind];
    final history = summary.progression[kind] ?? const [];

    return SurfaceCard(
      onTap: best == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RunDetailScreen(runId: best.runId),
                ),
              ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effortLabel(kind),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: best == null ? c.muted : c.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  best == null
                      ? 'Not set yet'
                      : '${formatRunDate(best.runStartedAt)}'
                          '${history.length > 1 ? ' · improved ${history.length - 1}×' : ''}',
                  style: TextStyle(fontSize: 12.5, color: c.muted),
                ),
              ],
            ),
          ),
          if (history.length > 1) ...[
            SizedBox(
              width: 64,
              height: 30,
              child: _Sparkline(entries: history, color: c.accent),
            ),
            const SizedBox(width: 14),
          ],
          Text(
            best == null ? '–' : formatEffort(kind, best.value, miles: miles),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: best == null ? c.line : c.accent,
              fontFeatures: tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiny progression line; always drawn so "up" means better.
class _Sparkline extends StatelessWidget {
  final List<EffortEntry> entries;
  final Color color;

  const _Sparkline({required this.entries, required this.color});

  @override
  Widget build(BuildContext context) {
    final sign = lowerIsBetter(entries.first.kind) ? -1.0 : 1.0;
    return LineChart(
      LineChartData(
        lineTouchData: const LineTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < entries.length; i++)
                FlSpot(i.toDouble(), sign * entries[i].value),
            ],
            color: color,
            barWidth: 2.2,
            isCurved: false,
            dotData: FlDotData(
              getDotPainter: (spot, _, __, i) => FlDotCirclePainter(
                radius: i == entries.length - 1 ? 3 : 0,
                color: color,
                strokeWidth: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
