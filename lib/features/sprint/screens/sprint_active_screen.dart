import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pictogram.dart';
import '../../../data/effort_labels.dart';
import '../../../data/run_repository.dart';
import '../providers/sprint_controller.dart';
import '../../../core/l10n.dart';

class SprintActiveScreen extends ConsumerStatefulWidget {
  const SprintActiveScreen({super.key});

  @override
  ConsumerState<SprintActiveScreen> createState() => _SprintActiveScreenState();
}

class _SprintActiveScreenState extends ConsumerState<SprintActiveScreen> {
  late final SprintController _controller;
  bool _showTelemetry = true;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(sprintControllerProvider.notifier);
    // Start calibration as soon as we enter the screen
    Future.microtask(_controller.startCalibration);
  }

  @override
  void dispose() {
    // Make sure GPS and sensors stop when leaving the screen
    Future.microtask(_controller.stopRunning);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(sprintControllerProvider);
    final c = AppColors.of(context);
    final target = _controller.targetDistance;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.sprintTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _GpsChip(accuracy: data.gpsAccuracy, lost: data.gpsLost),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _StatusHeader(data: data),
                  if (data.savedRunId != null) _NewPrBanner(runId: data.savedRunId!),
                  if (_GpsWarning.visibleFor(data)) ...[
                    const SizedBox(height: 16),
                    _GpsWarning(data: data, controller: _controller),
                  ],
                  const SizedBox(height: 20),
                  _TimeDisplay(data: data),
                  const SizedBox(height: 28),
                  _TrackProgress(distance: data.distanceRun, target: target),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: context.l10n.speed,
                          value: (data.currentSpeed * 3.6).toStringAsFixed(1),
                          unit: 'km/h',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricTile(
                          label: context.l10n.topSpeed,
                          value: (data.maxSpeed * 3.6).toStringAsFixed(1),
                          unit: 'km/h',
                          emphasized: data.maxSpeed > 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricTile(
                          label: context.l10n.distance,
                          value: data.distanceRun.toStringAsFixed(1),
                          unit: 'm',
                        ),
                      ),
                    ],
                  ),
                  if (data.state == SprintState.finished &&
                      data.elapsed > Duration.zero) ...[
                    const SizedBox(height: 10),
                    _MetricTile(
                      label: context.l10n.averageSpeed,
                      value: (data.distanceRun /
                              (data.elapsed.inMilliseconds / 1000) *
                              3.6)
                          .toStringAsFixed(1),
                      unit: 'km/h',
                      wide: true,
                    ),
                  ],
                  if (data.debugLog.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _Telemetry(
                      text: data.debugLog,
                      expanded: _showTelemetry,
                      onToggle: () =>
                          setState(() => _showTelemetry = !_showTelemetry),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: _ActionButton(data: data, controller: _controller),
            ),
          ],
        ),
      ),
      backgroundColor: c.background,
    );
  }
}

// ---------------------------------------------------------------------------

class _GpsChip extends StatelessWidget {
  final double? accuracy;
  final bool lost;

  const _GpsChip({required this.accuracy, required this.lost});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final acc = accuracy;
    final Color dot;
    final String text;
    if (lost) {
      dot = c.warn;
      text = context.l10n.gpsLost;
    } else if (acc == null) {
      dot = c.muted;
      text = context.l10n.gpsNoFix;
    } else {
      dot = acc <= 5 ? c.ok : (acc <= 15 ? c.warn : c.accent);
      text = '±${acc.toStringAsFixed(acc < 10 ? 1 : 0)} m';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.satellite_alt_rounded, size: 15, color: c.muted),
          const SizedBox(width: 6),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: c.ink,
              fontFeatures: tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}

/// Explains why GPS can't be trusted and offers a fix.
class _GpsWarning extends StatelessWidget {
  final SprintData data;
  final SprintController controller;

  const _GpsWarning({required this.data, required this.controller});

  static bool visibleFor(SprintData d) =>
      d.gpsIssue != GpsIssue.none ||
      (d.gpsLost && d.state == SprintState.running);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final acc = data.gpsAccuracy;
    final l = context.l10n;

    final (IconData icon, String title, String body, bool settings) =
        switch (data.gpsIssue) {
      GpsIssue.permissionDenied => (
          Icons.location_disabled_rounded,
          l.issuePermissionTitle,
          l.issuePermissionBody,
          true,
        ),
      GpsIssue.disabled => (
          Icons.location_off_rounded,
          l.issueDisabledTitle,
          l.issueDisabledBody,
          true,
        ),
      GpsIssue.noFix => (
          Icons.gps_off_rounded,
          l.issueNoFixTitle,
          l.issueNoFixBody(SprintController.calibrationTimeout.inSeconds),
          false,
        ),
      GpsIssue.weak => (
          Icons.gps_not_fixed_rounded,
          l.issueWeakTitle,
          l.issueWeakBody(acc?.toStringAsFixed(0) ?? '?'),
          false,
        ),
      GpsIssue.none => (
          Icons.gps_off_rounded,
          l.issueLostTitle,
          l.issueLostBody,
          false,
        ),
    };

    final canRetry = data.state == SprintState.ready ||
        data.state == SprintState.calibrating;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: c.warn.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.warn.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: c.warn, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: TextStyle(fontSize: 13.5, height: 1.35, color: c.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (canRetry && data.gpsIssue != GpsIssue.none)
            Padding(
              padding: const EdgeInsets.only(left: 22),
              child: Wrap(
                alignment: WrapAlignment.end,
                children: [
                  if (settings)
                    TextButton(
                      onPressed: controller.openGpsSettings,
                      style: TextButton.styleFrom(foregroundColor: c.ink),
                      child: Text(context.l10n.openSettings),
                    ),
                  TextButton(
                    onPressed: controller.startCalibration,
                    style: TextButton.styleFrom(foregroundColor: c.warn),
                    child: Text(context.l10n.tryAgain),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}

/// Shown on the result screen when the saved sprint set a record.
class _NewPrBanner extends ConsumerWidget {
  final int runId;

  const _NewPrBanner({required this.runId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kinds =
        ref.watch(recordsProvider).valueOrNull?.prsByRun[runId] ?? const {};
    if (kinds.isEmpty) return const SizedBox.shrink();
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: c.onAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.newPr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: c.onAccent,
                    ),
                  ),
                  Text(
                    kinds.map(effortLabel).join(' · '),
                    style: TextStyle(fontSize: 13.5, color: c.onAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final SprintData data;

  const _StatusHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l = context.l10n;
    final (Picto picto, String title, String hint) = switch (data.state) {
      SprintState.calibrating => (
          Picto.start,
          l.stateCalibrating,
          l.stateCalibratingBody,
        ),
      SprintState.ready => (
          Picto.start,
          l.stateReady,
          l.stateReadyBody,
        ),
      SprintState.countdown => (Picto.start, l.stateSet, l.stateSetBody),
      SprintState.running => (
          Picto.sprint,
          l.stateGo,
          l.stateGoBody,
        ),
      SprintState.finished => (
          Picto.finish,
          l.stateFinished,
          data.savedRunId != null
              ? l.stateSaved
              : l.stateInterpolated,
        ),
    };

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.line),
          ),
          alignment: Alignment.center,
          child: Pictogram(picto, size: 40, color: c.accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: c.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(hint, style: TextStyle(fontSize: 13.5, color: c.muted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final SprintData data;

  const _TimeDisplay({required this.data});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isCountdown = data.state == SprintState.countdown;
    final finished = data.state == SprintState.finished;

    final big = TextStyle(
      fontSize: 84,
      height: 1.0,
      fontWeight: FontWeight.w800,
      letterSpacing: -2,
      color: finished ? c.accent : c.ink,
      fontFeatures: tabularFigures,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(isCountdown ? context.l10n.startingIn : context.l10n.time),
          const SizedBox(height: 10),
          if (isCountdown)
            Text('${data.countdown}', style: big.copyWith(color: c.accent))
          else
            // Shrinks on narrow screens or long times like 1:02.34.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(_format(data.elapsed), style: big),
                  const SizedBox(width: 6),
                  Text(
                    's',
                    style: TextStyle(
                      fontSize: 24,
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

  static String _format(Duration d) {
    final cs = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    if (d.inMinutes > 0) {
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '${d.inMinutes}:$s.$cs';
    }
    return '${d.inSeconds}.$cs';
  }
}

/// A single running lane: tick marks every 25 m and a runner pictogram that
/// moves along with the distance covered.
class _TrackProgress extends StatelessWidget {
  final double distance;
  final double target;

  const _TrackProgress({required this.distance, required this.target});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final p = (distance / target).clamp(0.0, 1.0);
    const runnerSize = 30.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Label(context.l10n.progress),
            const Spacer(),
            Text(
              context.l10n.metersToGo((target - distance).clamp(0, target).round()),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: c.muted,
                fontFeatures: tabularFigures,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            return SizedBox(
              height: runnerSize + 14,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: (w - runnerSize) * p,
                    top: 0,
                    child: Pictogram(Picto.sprint, size: runnerSize, color: c.ink),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: c.line,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      height: 10,
                      width: w * p,
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final m in [0, 25, 50, 75, 100])
              Text(
                '$m',
                style: TextStyle(
                  fontSize: 11.5,
                  color: c.muted,
                  fontFeatures: tabularFigures,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool emphasized;
  final bool wide;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
    this.emphasized = false,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final valueText = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: emphasized ? c.accent : c.ink,
            fontFeatures: tabularFigures,
          ),
        ),
        const SizedBox(width: 3),
        Text(unit, style: TextStyle(fontSize: 12.5, color: c.muted)),
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: wide
          ? Row(children: [_Label(label), const Spacer(), valueText])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(label),
                const SizedBox(height: 6),
                // Fixed height so tiles stay equal when long values shrink.
                SizedBox(
                  height: 34,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: valueText,
                  ),
                ),
              ],
            ),
    );
  }
}

class _Telemetry extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  const _Telemetry({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: c.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sensors_rounded, size: 16, color: c.muted),
                  const SizedBox(width: 8),
                  _Label(context.l10n.telemetry),
                  const Spacer(),
                  Icon(
                    expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 20,
                    color: c.muted,
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.45,
                    color: c.ink,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final SprintData data;
  final SprintController controller;

  const _ActionButton({required this.data, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    switch (data.state) {
      case SprintState.calibrating
          when data.gpsIssue == GpsIssue.permissionDenied ||
              data.gpsIssue == GpsIssue.disabled:
        return OutlinedButton.icon(
          onPressed: controller.startCalibration,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(context.l10n.tryAgainCaps),
        );
      case SprintState.calibrating:
        return OutlinedButton.icon(
          onPressed: null,
          icon: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: c.muted),
          ),
          label: Text(context.l10n.waitingForGps),
        );
      case SprintState.ready:
        return FilledButton.icon(
          onPressed: controller.startCountdown,
          icon: const Icon(Icons.flag_rounded),
          label: Text(
            data.gpsIssue == GpsIssue.none
                ? context.l10n.startSprint
                : context.l10n.startAnyway,
          ),
        );
      case SprintState.countdown:
      case SprintState.running:
        return OutlinedButton.icon(
          onPressed: controller.cancelRun,
          icon: const Icon(Icons.close_rounded),
          label: Text(context.l10n.cancelCaps),
        );
      case SprintState.finished:
        return FilledButton.icon(
          onPressed: controller.startCalibration,
          icon: const Icon(Icons.replay_rounded),
          label: Text(context.l10n.runAgain),
        );
    }
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      context.upper(text),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: AppColors.of(context).muted,
      ),
    );
  }
}
