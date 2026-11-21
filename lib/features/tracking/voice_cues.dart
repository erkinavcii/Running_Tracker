import 'tracking_engine.dart';

/// Spoken phrases in Turkish or English.
class CuePhrases {
  final bool turkish;
  final bool miles;

  const CuePhrases({required this.turkish, this.miles = false});

  String get started => turkish ? 'Koşu başladı' : 'Run started';
  String get paused => turkish ? 'Duraklatıldı' : 'Paused';
  String get autoPaused =>
      turkish ? 'Otomatik duraklatıldı' : 'Auto-paused';
  String get resumed => turkish ? 'Devam ediliyor' : 'Resumed';
  String get gpsLost => turkish ? 'GPS sinyali kayboldu' : 'GPS signal lost';
  String get gpsBack => turkish ? 'GPS sinyali geri geldi' : 'GPS signal back';

  String _unit(int n) => turkish
      ? (miles ? 'mil' : 'kilometre')
      : (miles ? (n == 1 ? 'mile' : 'miles')
               : (n == 1 ? 'kilometer' : 'kilometers'));

  /// "16 dakika 2 saniye" / "1 hour 2 minutes 5 seconds".
  String duration(int ms) {
    final total = (ms / 1000).round();
    final h = total ~/ 3600, m = (total % 3600) ~/ 60, s = total % 60;
    String part(int v, String tr, String en) =>
        turkish ? '$v $tr' : '$v $en${v == 1 ? '' : 's'}';
    return [
      if (h > 0) part(h, 'saat', 'hour'),
      if (m > 0) part(m, 'dakika', 'minute'),
      if (s > 0 || (h == 0 && m == 0)) part(s, 'saniye', 'second'),
    ].join(' ');
  }

  /// "3 kilometre. Süre 16 dakika 2 saniye. Son kilometre 5 dakika 21 saniye."
  String split(int n, int movingMs, int splitMs) {
    final unit = _unit(n);
    final one = _unit(1);
    return turkish
        ? '$n $unit. Süre ${duration(movingMs)}. '
            'Son $one ${duration(splitMs)}.'
        : '$n $unit. Time ${duration(movingMs)}. '
            'Last $one ${duration(splitMs)}.';
  }
}

/// Turns the stream of snapshots into things to say: unit splits, pause and
/// resume confirmations, GPS lost and back. Pure, so it is unit-tested.
class VoiceCues {
  final CuePhrases phrases;
  TrackingStatus? _status;
  bool _gpsLost = false;
  bool _saidLost = false;
  int _announced = 0;
  int _lastSplitMovingMs = 0;

  VoiceCues(this.phrases);

  double get _unitM => phrases.miles ? 1609.344 : 1000;

  List<String> update(TrackingSnapshot s) {
    final units = (s.distanceM / _unitM).floor();
    if (_status == null) {
      // First snapshot is the baseline (also after recovering a run).
      _status = s.status;
      _gpsLost = s.gpsLost;
      _announced = units;
      _lastSplitMovingMs = s.movingMs;
      return const [];
    }

    final out = <String>[];
    if (_status == TrackingStatus.running &&
        s.status == TrackingStatus.paused) {
      out.add(s.autoPaused ? phrases.autoPaused : phrases.paused);
    } else if (_status == TrackingStatus.paused &&
        s.status == TrackingStatus.running) {
      out.add(phrases.resumed);
    }
    _status = s.status;

    // "Back" only follows a "lost" we said, not the first fix of the run.
    if (s.gpsLost && !_gpsLost) {
      out.add(phrases.gpsLost);
      _saidLost = true;
    }
    if (!s.gpsLost && _saidLost && s.status != TrackingStatus.finished) {
      out.add(phrases.gpsBack);
      _saidLost = false;
    }
    _gpsLost = s.gpsLost;

    if (units > _announced) {
      final per = (s.movingMs - _lastSplitMovingMs) ~/ (units - _announced);
      out.add(phrases.split(units, s.movingMs, per));
      _announced = units;
      _lastSplitMovingMs = s.movingMs;
    }
    return out;
  }
}
