/// Display formatting shared by all screens.
library;

import 'package:intl/intl.dart';

const double metersPerMile = 1609.344;

/// 9.84 · 1:02.34 (sprint style, centiseconds).
String formatSprintTime(Duration d) {
  final cs = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
  if (d.inMinutes > 0) {
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inMinutes}:$s.$cs';
  }
  return '${d.inSeconds}.$cs';
}

/// 4:05 · 1:02:03 (endurance style).
String formatClock(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$s';
  return '$m:$s';
}

/// "5.24 km" / "3.26 mi"; short runs in metres: "100 m".
String formatDistance(double meters, {bool miles = false}) {
  if (!miles && meters < 1000) return '${meters.toStringAsFixed(0)} m';
  final v = miles ? meters / metersPerMile : meters / 1000;
  return '${v.toStringAsFixed(2)} ${miles ? 'mi' : 'km'}';
}

/// "31.4 km/h" / "19.5 mph".
String formatSpeed(double mps, {bool miles = false}) {
  final v = miles ? mps * 3600 / metersPerMile : mps * 3.6;
  return '${v.toStringAsFixed(1)} ${miles ? 'mph' : 'km/h'}';
}

/// "5:23 /km"; "–" when not moving.
String formatPace(double mps, {bool miles = false}) {
  if (mps < 0.3) return '–';
  // Round the total first so 5:59.6 becomes 6:00, not 5:60.
  final total = ((miles ? metersPerMile : 1000) / mps).round();
  final m = total ~/ 60;
  final s = (total % 60).toString().padLeft(2, '0');
  return '$m:$s /${miles ? 'mi' : 'km'}';
}

/// "Sat, 21 Nov · 09:30" / "Cmt, 21 Kas · 09:30" in the app language.
String formatRunDate(DateTime t) {
  final l = t.toLocal();
  return '${DateFormat('EEE, d MMM').format(l)} · ${DateFormat('HH:mm').format(l)}';
}
