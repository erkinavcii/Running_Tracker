import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/route.dart';
import '../../data/run_repository.dart';
import 'route_map.dart';

/// Simplified route of a run for list previews (≤ 80 points per run).
final routePreviewProvider = FutureProvider.family<List<List<LatLon>>, int>((
  ref,
  runId,
) async {
  final track = await ref.watch(runRepositoryProvider).getTrack(runId);
  return previewPolylines(trackLike(track));
});

/// Tile-free route thumbnail drawn with a painter; shows [fallback] until
/// the route is loaded or if the run has none.
class RoutePreview extends ConsumerWidget {
  final int runId;
  final Color color;
  final Widget fallback;

  const RoutePreview({
    super.key,
    required this.runId,
    required this.color,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(routePreviewProvider(runId)).valueOrNull;
    if (lines == null || lines.isEmpty) return fallback;
    return CustomPaint(
      painter: RoutePainter(lines, color),
      size: Size.infinite,
    );
  }
}

class RoutePainter extends CustomPainter {
  final List<List<LatLon>> lines;
  final Color color;

  RoutePainter(this.lines, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final all = lines.expand((l) => l).toList();
    if (all.isEmpty) return;
    var minLat = all.first.lat, maxLat = minLat;
    var minLon = all.first.lon, maxLon = minLon;
    for (final p in all) {
      minLat = math.min(minLat, p.lat);
      maxLat = math.max(maxLat, p.lat);
      minLon = math.min(minLon, p.lon);
      maxLon = math.max(maxLon, p.lon);
    }
    // Local equirectangular projection: x scaled by cos(latitude).
    final k = math.cos((minLat + maxLat) / 2 * math.pi / 180);
    final w = math.max((maxLon - minLon) * k, 1e-9);
    final h = math.max(maxLat - minLat, 1e-9);
    const pad = 7.0;
    final scale = math.min(
      (size.width - 2 * pad) / w,
      (size.height - 2 * pad) / h,
    );
    final ox = (size.width - w * scale) / 2;
    final oy = (size.height - h * scale) / 2;
    Offset at(LatLon p) => Offset(
      ox + (p.lon - minLon) * k * scale,
      oy + (maxLat - p.lat) * scale,
    );

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    for (final l in lines) {
      final path = Path()..moveTo(at(l.first).dx, at(l.first).dy);
      for (final p in l.skip(1)) {
        final o = at(p);
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, paint);
    }
    canvas.drawCircle(at(all.last), 2.6, Paint()..color = color);
  }

  @override
  bool shouldRepaint(RoutePainter old) =>
      old.lines != lines || old.color != color;
}
