/// GPX 1.1 export, accepted by Strava, Garmin Connect and most map tools.
library;

class GpxPoint {
  final DateTime time;
  final double lat;
  final double lon;
  final double? ele;
  final int segment;

  const GpxPoint({
    required this.time,
    required this.lat,
    required this.lon,
    this.ele,
    this.segment = 0,
  });
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _iso(DateTime t) {
  // Whole-second UTC timestamps: "2026-11-21T09:30:05Z".
  final s = t.toUtc().toIso8601String();
  final dot = s.indexOf('.');
  return dot < 0 ? s : '${s.substring(0, dot)}Z';
}

/// One `<trkseg>` per pause segment, so importers don't draw (or count)
/// a straight line across a pause.
String buildGpx({
  required String name,
  required DateTime startedAt,
  required List<GpxPoint> points,
  String type = 'running',
  String? description,
}) {
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<gpx version="1.1" creator="Sprint Tracker" '
      'xmlns="http://www.topografix.com/GPX/1/1" '
      'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
      'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 '
      'http://www.topografix.com/GPX/1/1/gpx.xsd">',
    )
    ..writeln('  <metadata>')
    ..writeln('    <name>${_esc(name)}</name>')
    ..writeln('    <time>${_iso(startedAt)}</time>')
    ..writeln('  </metadata>')
    ..writeln('  <trk>')
    ..writeln('    <name>${_esc(name)}</name>');
  if (description != null && description.isNotEmpty) {
    b.writeln('    <desc>${_esc(description)}</desc>');
  }
  b.writeln('    <type>$type</type>');

  int? seg;
  for (final p in points) {
    if (p.segment != seg) {
      if (seg != null) b.writeln('    </trkseg>');
      b.writeln('    <trkseg>');
      seg = p.segment;
    }
    b.write(
      '      <trkpt lat="${p.lat.toStringAsFixed(7)}" '
      'lon="${p.lon.toStringAsFixed(7)}">',
    );
    if (p.ele != null) b.write('<ele>${p.ele!.toStringAsFixed(1)}</ele>');
    b.writeln('<time>${_iso(p.time)}</time></trkpt>');
  }
  if (seg != null) b.writeln('    </trkseg>');
  b
    ..writeln('  </trk>')
    ..writeln('</gpx>');
  return b.toString();
}

/// "sprint-tracker-2026-11-21-0930.gpx"
String gpxFileName(DateTime startedAt) {
  final l = startedAt.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return 'sprint-tracker-${l.year}-${two(l.month)}-${two(l.day)}-'
      '${two(l.hour)}${two(l.minute)}.gpx';
}
