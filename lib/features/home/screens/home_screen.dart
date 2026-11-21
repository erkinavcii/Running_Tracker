import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pictogram.dart';
import '../../sprint/screens/sprint_active_screen.dart';
import '../../tracking/screens/live_run_screen.dart';
import '../../tracking/tracking_engine.dart';
import '../../tracking/tracking_service.dart';
import '../../../core/l10n.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openRun(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LiveRunScreen()),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final active = ref.watch(trackingProvider).snapshot;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Pictogram(Picto.sprint, size: 28, color: c.onAccent),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sprint Tracker',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: c.ink,
                  ),
                ),
              ],
            ),
            if (active != null) ...[
              const SizedBox(height: 20),
              _ActiveRunBanner(snap: active, onTap: () => _openRun(context)),
            ],
            const SizedBox(height: 36),
            Text(
              context.l10n.chooseMode,
              style: TextStyle(
                fontSize: 30,
                height: 1.15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: c.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.homeSubtitle,
              style: TextStyle(fontSize: 15, height: 1.4, color: c.muted),
            ),
            const SizedBox(height: 28),
            _ModeCard(
              picto: Picto.sprint,
              title: context.l10n.sprint,
              subtitle: context.l10n.sprintSubtitle,
              tag: '100 m',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SprintActiveScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _ModeCard(
              picto: Picto.jog,
              title: context.l10n.endurance,
              subtitle: context.l10n.enduranceSubtitle,
              tag: context.l10n.run,
              enabled: true,
              onTap: () => _openRun(context),
            ),
            const SizedBox(height: 32),
            _InfoRow(
              icon: Icons.satellite_alt_outlined,
              text: context.l10n.tipSky,
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.front_hand_outlined,
              text: context.l10n.tipHold,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final Picto picto;
  final String title;
  final String subtitle;
  final String tag;
  final bool enabled;
  final VoidCallback? onTap;

  const _ModeCard({
    required this.picto,
    required this.title,
    required this.subtitle,
    required this.tag,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fg = enabled ? c.ink : c.muted;

    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: c.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: enabled ? c.accent : c.line,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Pictogram(
                  picto,
                  size: 46,
                  color: enabled ? c.onAccent : c.muted,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: fg,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Tag(text: tag, highlighted: enabled),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: c.muted),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: enabled ? c.ink : c.line,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool highlighted;

  const _Tag({required this.text, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: highlighted ? c.accent : c.line),
      ),
      child: Text(
        context.upper(text),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: highlighted ? c.accent : c.muted,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: c.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 13.5, color: c.muted)),
        ),
      ],
    );
  }
}

class _ActiveRunBanner extends StatelessWidget {
  final TrackingSnapshot snap;
  final VoidCallback onTap;

  const _ActiveRunBanner({required this.snap, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final paused = snap.status == TrackingStatus.paused;
    return Material(
      color: c.accent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              Icon(
                paused ? Icons.pause_circle_rounded : Icons.directions_run_rounded,
                color: c.onAccent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${paused ? context.l10n.runPaused : context.l10n.runInProgress} · '
                  '${formatDistance(snap.distanceM)} · '
                  '${formatClock(Duration(milliseconds: snap.movingMs))}',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: c.onAccent,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.onAccent),
            ],
          ),
        ),
      ),
    );
  }
}
