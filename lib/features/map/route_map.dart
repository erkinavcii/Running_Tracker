import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/format.dart';
import '../../core/route.dart';
import '../../core/theme/app_theme.dart';
import '../../core/track_math.dart';
import '../../data/database.dart';
import '../../core/l10n.dart';

/// OpenStreetMap tiles. The policy asks for an app-specific user agent and
/// visible attribution. Tests turn tiles off (no network there).
bool mapTilesEnabled = true;
const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _userAgentPackage = 'com.example.sprint_tracker';

List<TrackPointLike> trackLike(List<TrackPoint> pts) => [
  for (final p in pts)
    TrackPointLike(
      tMs: p.tMs,
      lat: p.lat,
      lon: p.lon,
      speedMps: p.speedMps,
      segment: p.segment,
    ),
];

LatLng _ll(LatLon p) => LatLng(p.lat, p.lon);

/// Colour of speed band [band] of [bands]: slow is a cool grey-blue,
/// fast is the track orange.
Color bandColor(BuildContext context, int band, {int bands = 5}) {
  final c = AppColors.of(context);
  const slow = Color(0xFF7D8DA6);
  return Color.lerp(slow, c.accent, bands <= 1 ? 1 : band / (bands - 1))!;
}

TileLayer osmTiles() => TileLayer(
  urlTemplate: _tileUrl,
  userAgentPackageName: _userAgentPackage,
  maxNativeZoom: 19,
);

Widget osmAttribution() =>
    const SimpleAttributionWidget(source: Text('OpenStreetMap contributors'));

/// Route on an OSM map, coloured by speed, broken at pauses, with start,
/// finish and distance markers. [highlight] (a track index) shows a dot,
/// used to sync with the chart.
class RouteMap extends StatelessWidget {
  final List<TrackPoint> track;
  final List<double> distM;
  final bool miles;
  final int? highlight;
  final double? height; // null: fill the parent
  final bool interactive;

  const RouteMap({
    super.key,
    required this.track,
    required this.distM,
    required this.miles,
    this.highlight,
    this.height = 260,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final like = trackLike(track);
    final lines = speedLines(like);
    final step = miles ? metersPerMile : 1000.0;
    final markers = distanceMarkers(like, distM, step);
    final all = [for (final p in track) LatLng(p.lat, p.lon)];
    final coords = [for (final p in track) LatLon(p.lat, p.lon)];
    final h = highlight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder:
              (context, box) => FlutterMap(
                // Fit computed from the real size (CameraFit could zoom in too far
                // on a first layout inside a scrolling page).
                key: ValueKey(box.biggest),
                options: MapOptions(
                  initialCenter: _ll(boundsCenter(coords)),
                  initialZoom: fitZoom(
                    coords,
                    width: box.maxWidth,
                    height: box.maxHeight,
                    padding: 48, // room for markers and the attribution
                  ),
                  backgroundColor: c.surface,
                  // Inside a scrolling page the map must not steal drags.
                  interactionOptions: InteractionOptions(
                    flags:
                        interactive
                            ? InteractiveFlag.all & ~InteractiveFlag.rotate
                            : InteractiveFlag.none,
                  ),
                ),
                children: [
                  if (mapTilesEnabled) osmTiles(),
                  PolylineLayer(
                    polylines: [
                      for (final l in lines)
                        Polyline(
                          points: [for (final p in l.points) _ll(p)],
                          strokeWidth: 5,
                          color: bandColor(context, l.band),
                          borderStrokeWidth: 1.5,
                          borderColor: Colors.white.withValues(alpha: 0.8),
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      for (var i = 0; i < markers.length; i++)
                        Marker(
                          point: _ll(markers[i]),
                          width: 22,
                          height: 22,
                          child: _Badge(text: '${i + 1}', color: c.ink),
                        ),
                      Marker(
                        point: all.first,
                        width: 18,
                        height: 18,
                        child: _Dot(color: const Color(0xFF2E9E5B)),
                      ),
                      Marker(
                        point: all.last,
                        width: 18,
                        height: 18,
                        child: _Dot(color: c.ink),
                      ),
                      if (h != null && h >= 0 && h < all.length)
                        Marker(
                          point: all[h],
                          width: 22,
                          height: 22,
                          child: _Dot(color: c.accent, big: true),
                        ),
                    ],
                  ),
                  if (mapTilesEnabled) osmAttribution(),
                ],
              ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final bool big;

  const _Dot({required this.color, this.big = false});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: big ? 3 : 2.5),
      boxShadow: const [BoxShadow(blurRadius: 3, color: Color(0x40000000))],
    ),
  );
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: color, width: 1.5),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    ),
  );
}

/// Legend for the speed colours: "slow ▬▬▬▬▬ fast" with paces.
class SpeedLegend extends StatelessWidget {
  final List<double> speeds;
  final bool miles;

  const SpeedLegend({super.key, required this.speeds, required this.miles});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final edges = bandEdges(movingAverage(speeds, 5));
    final style = TextStyle(
      fontSize: 11.5,
      color: c.muted,
      fontFeatures: tabularFigures,
    );
    final finite = edges.where((e) => e.isFinite).toList();
    return Row(
      children: [
        Text(
          finite.isEmpty
              ? context.l10n.slow
              : formatPace(finite.first, miles: miles),
          style: style,
        ),
        const SizedBox(width: 8),
        for (var b = 0; b < 5; b++)
          Expanded(
            child: Container(
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: bandColor(context, b),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        const SizedBox(width: 8),
        Text(
          finite.isEmpty
              ? context.l10n.fast
              : formatPace(finite.last, miles: miles),
          style: style,
        ),
      ],
    );
  }
}

/// Full-screen, pannable version of the route.
class RouteMapPage extends StatelessWidget {
  final List<TrackPoint> track;
  final List<double> distM;
  final bool miles;
  final int? highlight;

  const RouteMapPage({
    super.key,
    required this.track,
    required this.distM,
    required this.miles,
    this.highlight,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.route)),
    body: Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          Expanded(
            child: RouteMap(
              track: track,
              distM: distM,
              miles: miles,
              highlight: highlight,
              height: null,
            ),
          ),
          const SizedBox(height: 10),
          SpeedLegend(
            speeds: [for (final p in track) p.speedMps],
            miles: miles,
          ),
        ],
      ),
    ),
  );
}
