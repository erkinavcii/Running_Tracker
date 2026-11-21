import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/pictogram.dart';
import '../../../data/database.dart';
import '../../map/route_preview.dart';
import '../../../core/l10n.dart';

class RunCard extends StatelessWidget {
  final Run run;
  final bool miles;
  final bool isPr;
  final VoidCallback? onTap;

  const RunCard({
    super.key,
    required this.run,
    required this.miles,
    this.isPr = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final sprint = run.type == RunType.sprint;
    final main = sprint
        ? '${formatSprintTime(Duration(milliseconds: run.sprintTimeMs ?? run.elapsedMs))} s'
        : formatDistance(run.distanceM, miles: miles);
    final details = <String>[
      if (!sprint) formatClock(Duration(milliseconds: run.movingMs)),
      if (sprint)
        context.l10n.topSpeedShort(formatSpeed(run.maxSpeedMps, miles: miles)),
      if (!sprint) formatPace(run.avgSpeedMps, miles: miles),
      if (run.kcal != null) context.l10n.kcalApprox(run.kcal!.round()),
    ];

    return SurfaceCard(
      onTap: onTap,
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
            child: sprint
                ? Pictogram(Picto.sprint, size: 34, color: c.accent)
                : RoutePreview(
                    runId: run.id,
                    color: c.accent,
                    fallback: Pictogram(Picto.jog, size: 34, color: c.accent),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      sprint ? context.l10n.sprint : context.l10n.run,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                      ),
                    ),
                    if (isPr) const PrBadge(),
                    if (run.gpsQuality != GpsQuality.good)
                      Icon(
                        run.gpsQuality == GpsQuality.none
                            ? Icons.gps_off_rounded
                            : Icons.gps_not_fixed_rounded,
                        size: 15,
                        color: c.warn,
                      ),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: c.muted,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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

/// Small "PR" marker for runs that set a personal record.
class PrBadge extends StatelessWidget {
  final String text;

  const PrBadge({super.key, this.text = 'PR'});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.accent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 11, color: c.onAccent),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: c.onAccent,
            ),
          ),
        ],
      ),
    );
  }
}
