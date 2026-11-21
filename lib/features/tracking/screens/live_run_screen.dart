import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format.dart';
import '../../../core/route.dart';
import '../../../core/services/screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/pictogram.dart';
import '../../../data/database.dart';
import '../../../data/run_repository.dart';
import '../../map/route_map.dart';
import '../../history/screens/run_detail_screen.dart';
import '../tracking_engine.dart';
import '../tracking_service.dart';
import '../widgets/hold_button.dart';
import '../../../core/l10n.dart';

/// Endurance run: start screen before the run, live stats during it.
/// Closing this screen does not stop the run — the service keeps going.
class LiveRunScreen extends ConsumerStatefulWidget {
  const LiveRunScreen({super.key});

  @override
  ConsumerState<LiveRunScreen> createState() => _LiveRunScreenState();
}

class _LiveRunScreenState extends ConsumerState<LiveRunScreen> {
  bool _starting = false;
  String? _error;
  bool _wake = false;

  /// Keeps the display on while a run is shown, if the profile asks for it.
  void _syncWakelock(bool want) {
    if (want == _wake) return;
    _wake = want;
    keepScreenOn(want);
  }

  @override
  void dispose() {
    if (_wake) keepScreenOn(false);
    super.dispose();
  }

  Future<void> _start() async {
    final ctrl = ref.read(trackingProvider.notifier);
    setState(() {
      _starting = true;
      _error = null;
    });

    final blocker = await ctrl.ensurePermissions();
    if (!mounted) return;
    if (blocker == StartBlocker.location) {
      setState(() {
        _starting = false;
        _error = context.l10n.locationNeeded;
      });
      return;
    }
    if (blocker == StartBlocker.notifications) {
      final go = await _confirm(
        title: context.l10n.noNotificationTitle,
        body: context.l10n.noNotificationBody,
        ok: context.l10n.startAnyway,
      );
      if (!mounted) return;
      if (go != true) {
        setState(() => _starting = false);
        return;
      }
    }

    if (await ctrl.shouldAskBatteryExemption()) {
      if (!mounted) return;
      final ok = await _confirm(
        title: context.l10n.batteryTitle,
        body: context.l10n.batteryBody,
        ok: context.l10n.allow,
        cancel: context.l10n.notNow,
      );
      await ctrl.markBatteryAsked();
      if (ok == true) await ctrl.requestBatteryExemption();
    }

    final started = await ctrl.start();
    if (!mounted) return;
    setState(() {
      _starting = false;
      if (!started) _error = context.l10n.couldNotStart;
    });
  }

  Future<bool?> _confirm({
    required String title,
    required String body,
    required String ok,
    String cancel = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(ok),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(trackingProvider);
    final profile = ref.watch(profileProvider).valueOrNull;
    final miles = profile?.useMiles ?? false;
    _syncWakelock(tracking.isActive && (profile?.keepScreenOn ?? true));

    // The service saved the run: show it.
    ref.listen(trackingProvider, (_, next) {
      if (next.finishedRunId != null) {
        final id = next.finishedRunId!;
        ref.read(trackingProvider.notifier).acknowledgeFinished();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RunDetailScreen(runId: id)),
        );
      } else if (next.finishedEmpty) {
        ref.read(trackingProvider.notifier).acknowledgeFinished();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.runDiscardedNoGps),
          ),
        );
        Navigator.pop(context);
      }
    });

    final snap = tracking.snapshot;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.run),
        actions: [
          if (snap != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _GpsChip(snap: snap),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child:
            snap == null
                ? _StartView(
                  starting: _starting,
                  error: _error,
                  onStart: _start,
                )
                : _LiveView(snap: snap, miles: miles),
      ),
    );
  }
}

class _StartView extends StatelessWidget {
  final bool starting;
  final String? error;
  final VoidCallback onStart;

  const _StartView({
    required this.starting,
    required this.error,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Center(child: Pictogram(Picto.jog, size: 120, color: c.accent)),
          const SizedBox(height: 24),
          Text(
            context.l10n.readyTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.readyBody,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.45, color: c.muted),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: c.warn),
            ),
          ],
          const Spacer(),
          FilledButton.icon(
            onPressed: starting ? null : onStart,
            icon:
                starting
                    ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.onAccent,
                      ),
                    )
                    : const Icon(Icons.play_arrow_rounded),
            label: Text(context.l10n.startRun),
          ),
        ],
      ),
    );
  }
}

class _LiveView extends ConsumerWidget {
  final TrackingSnapshot snap;
  final bool miles;

  const _LiveView({required this.snap, required this.miles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final ctrl = ref.read(trackingProvider.notifier);
    final paused = snap.status == TrackingStatus.paused;
    final dist = formatDistance(snap.distanceM, miles: miles).split(' ');

    return Column(
      children: [
        Expanded(
          child: PageView(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  if (paused)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: c.warn.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            snap.autoPaused ? context.l10n.autoPausedCaps : context.l10n.pausedCaps,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: c.warn,
                            ),
                          ),
                          if (snap.autoPaused)
                            Text(
                              context.l10n.resumesWhenRunning,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: c.muted),
                            ),
                        ],
                      ),
                    ),
                  SurfaceCard(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionLabel(context.l10n.distance),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                dist.first,
                                style: TextStyle(
                                  fontSize: 88,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -2,
                                  color: c.ink,
                                  fontFeatures: tabularFigures,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                dist.last,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: c.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _Tile(
                          label: context.l10n.time,
                          value: formatClock(
                            Duration(milliseconds: snap.movingMs),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Tile(
                          label: context.l10n.pace,
                          value:
                              formatPace(
                                snap.currentSpeedMps,
                                miles: miles,
                              ).split(' ').first,
                          accent: !paused,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _Tile(
                          label: context.l10n.avgPace,
                          value:
                              formatPace(
                                snap.avgSpeedMps,
                                miles: miles,
                              ).split(' ').first,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Tile(
                          label: context.l10n.calories,
                          value:
                              snap.kcal == null ? '–' : '${snap.kcal!.round()}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.l10n.liveFooter(
                      formatClock(Duration(milliseconds: snap.elapsedMs)),
                      snap.elevGainM.round(),
                      snap.fixCount,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: c.muted,
                      fontFeatures: tabularFigures,
                    ),
                  ),
                ],
              ),
              _LiveMap(runId: snap.runId, miles: miles),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child:
              paused
                  ? Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: ctrl.resume,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(context.l10n.resumeCaps),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: HoldButton(
                          label: context.l10n.holdToFinish,
                          onComplete: ctrl.finish,
                        ),
                      ),
                    ],
                  )
                  : OutlinedButton.icon(
                    onPressed: ctrl.pause,
                    icon: const Icon(Icons.pause_rounded),
                    label: Text(context.l10n.pauseCaps),
                  ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _Tile({required this.label, required this.value, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label),
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: accent ? c.accent : c.ink,
                  fontFeatures: tabularFigures,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsChip extends StatelessWidget {
  final TrackingSnapshot snap;

  const _GpsChip({required this.snap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final acc = snap.gpsAccuracyM;
    final (Color dot, String text) =
        snap.gpsLost
            ? (c.warn, acc == null ? context.l10n.gpsSearching : context.l10n.gpsLost)
            : (acc == null
                ? (c.muted, context.l10n.gpsNoFix)
                : (acc <= 8 ? c.ok : c.warn, '±${acc.toStringAsFixed(0)} m'));
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
            ),
          ),
        ],
      ),
    );
  }
}

/// Live route on the second page. Loads the stored track every 5 s, and
/// only while this page is shown, so no tiles are fetched otherwise.
class _LiveMap extends ConsumerStatefulWidget {
  final int runId;
  final bool miles;

  const _LiveMap({required this.runId, required this.miles});

  @override
  ConsumerState<_LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends ConsumerState<_LiveMap> {
  final _map = MapController();
  Timer? _timer;
  List<TrackPoint> _track = const [];
  bool _follow = true;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _map.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final t = await ref.read(runRepositoryProvider).getTrack(widget.runId);
    if (!mounted) return;
    setState(() => _track = t);
    if (_follow && _ready && t.isNotEmpty) {
      _map.move(LatLng(t.last.lat, t.last.lon), _map.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    if (_track.isEmpty) {
      return Center(
        child: Text(
          context.l10n.waitingForPoints,
          style: TextStyle(color: c.muted),
        ),
      );
    }
    final last = LatLng(_track.last.lat, _track.last.lon);
    final lines = speedLines(trackLike(_track));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: last,
                initialZoom: 16,
                backgroundColor: c.surface,
                onMapReady: () => _ready = true,
                onPositionChanged: (_, hasGesture) {
                  if (hasGesture && _follow) setState(() => _follow = false);
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                if (mapTilesEnabled) osmTiles(),
                PolylineLayer(
                  polylines: [
                    for (final l in lines)
                      Polyline(
                        points: [
                          for (final p in l.points) LatLng(p.lat, p.lon),
                        ],
                        strokeWidth: 5,
                        color: bandColor(context, l.band),
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: last,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
                if (mapTilesEnabled) osmAttribution(),
              ],
            ),
            if (!_follow)
              Positioned(
                right: 12,
                top: 12,
                child: FloatingActionButton.small(
                  tooltip: context.l10n.followMe,
                  onPressed: () {
                    setState(() => _follow = true);
                    _map.move(last, _map.camera.zoom);
                  },
                  child: const Icon(Icons.my_location_rounded),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
