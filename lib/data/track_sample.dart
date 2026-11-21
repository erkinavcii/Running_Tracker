/// One accepted GNSS fix, relative to the run start.
class TrackSample {
  final int tMs;
  final double lat;
  final double lon;
  final double speedMps;
  final double? speedAccMps;
  final double accM;
  final double? altM;
  final int segment;

  const TrackSample({
    required this.tMs,
    required this.lat,
    required this.lon,
    required this.speedMps,
    required this.accM,
    this.speedAccMps,
    this.altM,
    this.segment = 0,
  });
}
