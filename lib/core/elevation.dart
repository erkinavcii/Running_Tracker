/// Accumulates elevation gain from noisy GPS altitudes.
///
/// GPS altitude jitters by several metres, so summing raw rises would count
/// noise as climbing. The altitude is first smoothed (EMA), then only rises
/// of at least [threshold] above the last reference count (hysteresis); a
/// drop of the same size moves the reference down.
class ElevationGain {
  final double threshold;
  final double alpha;
  double gainM;
  double? _smooth;
  double? _ref;

  ElevationGain({this.gainM = 0, this.threshold = 3, this.alpha = 0.25});

  void add(double altM) {
    final s = _smooth == null ? altM : _smooth! + alpha * (altM - _smooth!);
    _smooth = s;
    final ref = _ref;
    if (ref == null) {
      _ref = s;
    } else if (s - ref >= threshold) {
      gainM += s - ref;
      _ref = s;
    } else if (ref - s >= threshold) {
      _ref = s;
    }
  }

  static double of(Iterable<double?> alts) {
    final e = ElevationGain();
    for (final a in alts) {
      if (a != null) e.add(a);
    }
    return e.gainM;
  }
}
