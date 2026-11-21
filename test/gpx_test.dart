import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/core/gpx.dart';

void main() {
  test('one trkseg per pause segment, UTC times, escaped name', () {
    final t0 = DateTime.utc(2026, 11, 21, 9, 30);
    final gpx = buildGpx(
      name: 'Run <easy> & slow',
      startedAt: t0,
      points: [
        GpxPoint(time: t0, lat: 41, lon: 29, ele: 12.34),
        GpxPoint(time: t0.add(const Duration(seconds: 1)), lat: 41.00003, lon: 29),
        GpxPoint(
            time: t0.add(const Duration(seconds: 90, milliseconds: 400)),
            lat: 41.001, lon: 29, segment: 1),
      ],
    );
    expect('<trkseg>'.allMatches(gpx).length, 2);
    expect('</trkseg>'.allMatches(gpx).length, 2);
    expect(gpx, contains('<name>Run &lt;easy&gt; &amp; slow</name>'));
    expect(gpx, contains('<time>2026-11-21T09:31:30Z</time>'));
    expect(gpx, contains('<ele>12.3</ele>'));
    expect(gpx, contains('lat="41.0000300" lon="29.0000000"'));
    expect(gpx.trim(), endsWith('</gpx>'));
  });

  test('file name', () {
    expect(gpxFileName(DateTime(2026, 11, 21, 9, 5)),
        'sprint-tracker-2026-11-21-0905.gpx');
  });
}
