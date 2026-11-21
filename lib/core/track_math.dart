import 'dart:math' as math;

/// Minimal point shape shared by the live engine and run finalisation, so
/// both compute exactly the same distance.
class TrackPointLike {
  final int tMs; // wall-clock ms since run start
  final double lat;
  final double lon;
  final double speedMps;
  final int segment; // increases after every pause

  const TrackPointLike({
    required this.tMs,
    required this.lat,
    required this.lon,
    required this.speedMps,
    required this.segment,
  });
}

/// Gaps longer than this use the straight-line distance instead of the
/// Doppler speed integral (GPS dropped out for a while).
const int maxDopplerGapMs = 5000;

double haversineM(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final p1 = lat1 * math.pi / 180, p2 = lat2 * math.pi / 180;
  final dp = (lat2 - lat1) * math.pi / 180;
  final dl = (lon2 - lon1) * math.pi / 180;
  final a = math.sin(dp / 2) * math.sin(dp / 2) +
      math.cos(p1) * math.cos(p2) * math.sin(dl / 2) * math.sin(dl / 2);
  return 2 * r * math.asin(math.min(1.0, math.sqrt(a)));
}

/// Distance covered between two consecutive accepted fixes.
///
/// Within a segment: trapezoid integral of the chip's Doppler speed — far
/// less noisy than position differences (±0.1–0.5 m/s vs ±3–5 m). Across a
/// pause (segment change): 0. Long gaps fall back to the straight line.
double stepDistance(TrackPointLike a, TrackPointLike b) {
  if (a.segment != b.segment) return 0;
  final dtMs = b.tMs - a.tMs;
  if (dtMs <= 0) return 0;
  if (dtMs > maxDopplerGapMs) return haversineM(a.lat, a.lon, b.lat, b.lon);
  return (a.speedMps + b.speedMps) / 2 * dtMs / 1000;
}

/// Cumulative distance for a whole track (same rule as the live engine).
List<double> cumulativeDistance(List<TrackPointLike> pts) {
  final out = List<double>.filled(pts.length, 0);
  for (var i = 1; i < pts.length; i++) {
    out[i] = out[i - 1] + stepDistance(pts[i - 1], pts[i]);
  }
  return out;
}
