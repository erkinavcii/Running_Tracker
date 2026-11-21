import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/core/route.dart';
import 'package:sprint_tracker/core/track_math.dart';

List<TrackPointLike> straight(List<double> speeds, {List<int>? segments}) {
  var lat = 41.0;
  return [
    for (var i = 0; i < speeds.length; i++)
      () {
        final p = TrackPointLike(
          tMs: i * 1000,
          lat: lat,
          lon: 29,
          speedMps: speeds[i],
          segment: segments?[i] ?? 0,
        );
        lat += speeds[i] / 111195;
        return p;
      }(),
  ];
}

void main() {
  test('speed lines split by band and share boundary points', () {
    final pts = straight([...List.filled(30, 2.0), ...List.filled(30, 5.0)]);
    final lines = speedLines(pts);
    expect(lines.length, greaterThanOrEqualTo(2));
    expect(lines.first.band, lessThan(lines.last.band));
    // Continuous: each line starts where the previous ended.
    for (var i = 1; i < lines.length; i++) {
      expect(lines[i].points.first.lat, lines[i - 1].points.last.lat);
    }
    final drawn = lines.fold(0, (n, l) => n + l.points.length) -
        (lines.length - 1);
    expect(drawn, pts.length);
  });

  test('pauses break the line', () {
    final pts = straight(
      List.filled(20, 3.0),
      segments: [...List.filled(10, 0), ...List.filled(10, 1)],
    );
    final lines = speedLines(pts);
    // No line joins point 9 (segment 0) and point 10 (segment 1).
    for (final l in lines) {
      final has9 = l.points.any((p) => p.lat == pts[9].lat);
      final has10 = l.points.any((p) => p.lat == pts[10].lat);
      expect(has9 && has10, isFalse);
    }
    expect(previewPolylines(pts).length, 2);
  });

  test('distance markers are interpolated', () {
    final pts = straight(List.filled(1001, 3.0)); // 3000 m
    final dist = cumulativeDistance(pts);
    final m = distanceMarkers(pts, dist, 1000);
    expect(m.length, 3);
    expect((m.first.lat - 41.0) * 111195, closeTo(1000, 1));
  });

  test('index lookup and preview size', () {
    final pts = straight(List.filled(3600, 3.0));
    final dist = cumulativeDistance(pts);
    expect(indexAtDistance(dist, 0), 0);
    expect(indexAtDistance(dist, 1500), 500);
    expect(indexAtDistance(dist, 1e9), dist.length - 1);
    final prev = previewPolylines(pts);
    expect(prev.single.length, lessThanOrEqualTo(81));
    expect(prev.single.last.lat, pts.last.lat);
  });

  test('band edges ignore standing still', () {
    final e = bandEdges([0, 0, 0, 3, 3, 3, 3]);
    expect(e.every((x) => x == 3), isTrue);
    expect(bandOf(0.2, e), 0);
  });

  test('fit zoom matches the Web-Mercator scale', () {
    // 1/1024 of the world wide at the equator → zoom 10 fills 256 px.
    final pts = [const LatLon(0, 0), const LatLon(0, 360 / 1024)];
    expect(fitZoom(pts, width: 256 + 60, height: 400, padding: 30, maxZoom: 20),
        closeTo(10, 1e-9));
    // A single point uses the max zoom.
    expect(fitZoom([const LatLon(41, 29)], width: 300, height: 300), 17);
  });
}
