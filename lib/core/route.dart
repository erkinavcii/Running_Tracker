import 'dart:math' as math;

import 'track_math.dart';

/// Route geometry for maps and previews. Pure Dart, unit-tested.

class LatLon {
  final double lat;
  final double lon;

  const LatLon(this.lat, this.lon);

  @override
  String toString() => '($lat, $lon)';
}

/// One drawable piece of the route: consecutive points in the same pause
/// segment and the same speed band.
class RouteLine {
  final List<LatLon> points;
  final int band; // 0 = slowest … bands-1 = fastest
  const RouteLine(this.points, this.band);
}

/// Speed band edges from quantiles, so every run uses its full colour range
/// whatever its pace (an easy jog still shows its faster stretches).
List<double> bandEdges(List<double> speeds, {int bands = 5}) {
  final moving = [
    for (final s in speeds)
      if (s > 0.5) s,
  ]..sort();
  if (moving.isEmpty) return List.filled(bands - 1, double.infinity);
  return [
    for (var i = 1; i < bands; i++)
      moving[((moving.length - 1) * i / bands).round()],
  ];
}

int bandOf(double speed, List<double> edges) {
  var b = 0;
  while (b < edges.length && speed > edges[b]) {
    b++;
  }
  return b;
}

/// Splits the track into lines by segment (pauses break the line) and by
/// speed band. Neighbouring lines share their boundary point so the drawn
/// route has no gaps.
List<RouteLine> speedLines(List<TrackPointLike> pts, {int bands = 5}) {
  if (pts.length < 2) return const [];
  // Smooth speeds a little so the colour doesn't flicker every second.
  final smooth = movingAverage([for (final p in pts) p.speedMps], 5);
  final edges = bandEdges(smooth, bands: bands);
  final out = <RouteLine>[];
  var current = <LatLon>[LatLon(pts[0].lat, pts[0].lon)];
  var band = bandOf(smooth[0], edges);
  for (var i = 1; i < pts.length; i++) {
    final p = LatLon(pts[i].lat, pts[i].lon);
    if (pts[i].segment != pts[i - 1].segment) {
      if (current.length > 1) out.add(RouteLine(current, band));
      current = [p];
      band = bandOf(smooth[i], edges);
      continue;
    }
    final b = bandOf(smooth[i], edges);
    current.add(p);
    if (b != band) {
      out.add(RouteLine(current, band));
      current = [p];
      band = b;
    }
  }
  if (current.length > 1) out.add(RouteLine(current, band));
  return out;
}

List<double> movingAverage(List<double> v, int window) {
  if (window <= 1 || v.isEmpty) return List.of(v);
  final half = window ~/ 2;
  return [
    for (var i = 0; i < v.length; i++)
      () {
        final a = (i - half).clamp(0, v.length - 1);
        final b = (i + half).clamp(0, v.length - 1);
        var s = 0.0;
        for (var j = a; j <= b; j++) {
          s += v[j];
        }
        return s / (b - a + 1);
      }(),
  ];
}

/// Positions where the cumulative distance crosses every [stepM].
List<LatLon> distanceMarkers(
  List<TrackPointLike> pts,
  List<double> distM,
  double stepM,
) {
  final out = <LatLon>[];
  var next = stepM;
  for (var i = 1; i < pts.length; i++) {
    while (distM[i] >= next) {
      final span = distM[i] - distM[i - 1];
      final f = span <= 0 ? 1.0 : (next - distM[i - 1]) / span;
      out.add(
        LatLon(
          pts[i - 1].lat + (pts[i].lat - pts[i - 1].lat) * f,
          pts[i - 1].lon + (pts[i].lon - pts[i - 1].lon) * f,
        ),
      );
      next += stepM;
    }
  }
  return out;
}

/// Index of the first point at or beyond [d] metres (binary search).
int indexAtDistance(List<double> distM, double d) {
  var lo = 0, hi = distM.length - 1;
  if (hi < 0) return -1;
  while (lo < hi) {
    final mid = (lo + hi) ~/ 2;
    if (distM[mid] < d) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  return lo;
}

/// At most [maxPoints] points per route for small previews, keeping pause
/// breaks: returns one list per segment.
List<List<LatLon>> previewPolylines(
  List<TrackPointLike> pts, {
  int maxPoints = 80,
}) {
  if (pts.isEmpty) return const [];
  final stride = (pts.length / maxPoints).ceil().clamp(1, 1 << 30);
  final out = <List<LatLon>>[];
  var current = <LatLon>[];
  for (var i = 0; i < pts.length; i++) {
    final newSeg = i > 0 && pts[i].segment != pts[i - 1].segment;
    if (newSeg) {
      if (current.length > 1) out.add(current);
      current = [];
    }
    final last = i == pts.length - 1 || pts[i + 1].segment != pts[i].segment;
    if (newSeg || i % stride == 0 || last) {
      current.add(LatLon(pts[i].lat, pts[i].lon));
    }
  }
  if (current.length > 1) out.add(current);
  return out;
}

double _mercY(double lat) {
  final s = math.sin(lat * math.pi / 180);
  return 0.5 - math.log((1 + s) / (1 - s)) / (4 * math.pi);
}

/// Web-Mercator zoom at which all [points] fit a [width]×[height] view
/// (logical pixels, 256 px tiles) with [padding] on every side.
double fitZoom(
  List<LatLon> points, {
  required double width,
  required double height,
  double padding = 32,
  double maxZoom = 17,
}) {
  if (points.isEmpty || width <= 2 * padding || height <= 2 * padding) {
    return maxZoom;
  }
  var minLat = points.first.lat, maxLat = minLat;
  var minLon = points.first.lon, maxLon = minLon;
  for (final p in points) {
    minLat = math.min(minLat, p.lat);
    maxLat = math.max(maxLat, p.lat);
    minLon = math.min(minLon, p.lon);
    maxLon = math.max(maxLon, p.lon);
  }
  final dx = (maxLon - minLon) / 360; // world fraction
  final dy = (_mercY(minLat) - _mercY(maxLat)).abs();
  double zoomFor(double frac, double px) =>
      frac <= 0 ? maxZoom : math.log(px / (frac * 256)) / math.ln2;
  return math.min(
    maxZoom,
    math.min(
      zoomFor(dx, width - 2 * padding),
      zoomFor(dy, height - 2 * padding),
    ),
  );
}

/// Centre of the bounding box of [points].
LatLon boundsCenter(List<LatLon> points) {
  var minLat = points.first.lat, maxLat = minLat;
  var minLon = points.first.lon, maxLon = minLon;
  for (final p in points) {
    minLat = math.min(minLat, p.lat);
    maxLat = math.max(maxLat, p.lat);
    minLon = math.min(minLon, p.lon);
    maxLon = math.max(maxLon, p.lon);
  }
  return LatLon((minLat + maxLat) / 2, (minLon + maxLon) / 2);
}
