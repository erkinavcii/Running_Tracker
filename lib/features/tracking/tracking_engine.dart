import 'dart:collection';
import 'dart:math' as math;

import '../../core/calories.dart';
import '../../core/elevation.dart';
import '../../core/format.dart';
import '../../core/track_math.dart';

enum TrackingStatus { running, paused, finished }

/// What the UI and the notification show; sent across isolates as a map.
class TrackingSnapshot {
  final int runId;
  final TrackingStatus status;
  final bool autoPaused; // paused by the engine, resumes on its own
  final int elapsedMs; // wall time since start
  final int movingMs; // excluding pauses
  final double distanceM;
  final double currentSpeedMps; // ~15 s rolling average
  final double avgSpeedMps; // distance / moving time
  final double maxSpeedMps;
  final double? kcal;
  final double elevGainM;
  final double? gpsAccuracyM;
  final bool gpsLost;
  final int fixCount;

  const TrackingSnapshot({
    required this.runId,
    required this.status,
    this.autoPaused = false,
    required this.elapsedMs,
    required this.movingMs,
    required this.distanceM,
    required this.currentSpeedMps,
    required this.avgSpeedMps,
    required this.maxSpeedMps,
    required this.kcal,
    this.elevGainM = 0,
    required this.gpsAccuracyM,
    required this.gpsLost,
    required this.fixCount,
  });

  Map<String, Object?> toMap() => {
    'type': 'snapshot',
    'runId': runId,
    'status': status.name,
    'autoPaused': autoPaused,
    'elapsedMs': elapsedMs,
    'movingMs': movingMs,
    'distanceM': distanceM,
    'currentSpeedMps': currentSpeedMps,
    'avgSpeedMps': avgSpeedMps,
    'maxSpeedMps': maxSpeedMps,
    'kcal': kcal,
    'elevGainM': elevGainM,
    'gpsAccuracyM': gpsAccuracyM,
    'gpsLost': gpsLost,
    'fixCount': fixCount,
  };

  factory TrackingSnapshot.fromMap(Map m) => TrackingSnapshot(
    runId: (m['runId'] as num).toInt(),
    status: TrackingStatus.values.byName(m['status'] as String),
    autoPaused: m['autoPaused'] == true,
    elapsedMs: (m['elapsedMs'] as num).toInt(),
    movingMs: (m['movingMs'] as num).toInt(),
    distanceM: (m['distanceM'] as num).toDouble(),
    currentSpeedMps: (m['currentSpeedMps'] as num).toDouble(),
    avgSpeedMps: (m['avgSpeedMps'] as num).toDouble(),
    maxSpeedMps: (m['maxSpeedMps'] as num).toDouble(),
    kcal: (m['kcal'] as num?)?.toDouble(),
    elevGainM: (m['elevGainM'] as num?)?.toDouble() ?? 0,
    gpsAccuracyM: (m['gpsAccuracyM'] as num?)?.toDouble(),
    gpsLost: m['gpsLost'] == true,
    fixCount: (m['fixCount'] as num).toInt(),
  );

  /// "Running · 5.24 km" for the notification title.
  String notificationTitle({bool miles = false}) {
    final prefix = switch (status) {
      TrackingStatus.paused => autoPaused ? 'Auto-paused' : 'Paused',
      TrackingStatus.finished => 'Finished',
      TrackingStatus.running => 'Running',
    };
    return '$prefix · ${formatDistance(distanceM, miles: miles)}';
  }

  /// "28:13 · 5:23 /km · ≈ 412 kcal" for the notification body.
  String notificationText({bool miles = false}) => [
    formatClock(Duration(milliseconds: movingMs)),
    formatPace(
      status == TrackingStatus.running ? currentSpeedMps : avgSpeedMps,
      miles: miles,
    ),
    if (kcal != null) '≈ ${kcal!.round()} kcal',
    if (gpsLost) 'GPS lost',
  ].join(' · ');
}

/// A point accepted by the engine, ready to be stored.
class EnginePoint extends TrackPointLike {
  final double? speedAccMps;
  final double accM;
  final double? altM;

  const EnginePoint({
    required super.tMs,
    required super.lat,
    required super.lon,
    required super.speedMps,
    required super.segment,
    required this.accM,
    this.speedAccMps,
    this.altM,
  });

  EnginePoint withSegment(int s) => EnginePoint(
    tMs: tMs,
    lat: lat,
    lon: lon,
    speedMps: speedMps,
    segment: s,
    accM: accM,
    speedAccMps: speedAccMps,
    altM: altM,
  );
}

/// Platform-free endurance tracking: feed it fixes and commands with
/// timestamps, read snapshots. Fully deterministic, so it is unit-tested
/// and can be replayed from recorded tracks.
class TrackingEngine {
  final int runId;
  final DateTime startedAt;
  final double? weightKg;
  final bool autoPause;

  // Fix filters (endurance is more lenient than sprint).
  static const double maxAccuracyM = 30;
  static const double maxSpeedAccMps = 3;
  static const double maxPlausibleSpeedMps = 12.5; // 45 km/h on foot
  static const int gpsLostAfterMs = 10000;
  static const int speedWindowMs = 15000;

  // Auto-pause hysteresis: stop below 0.8 m/s for 5 s, go again above
  // 1.5 m/s for 2 s, so waiting at a crossing doesn't flicker.
  static const double autoPauseBelowMps = 0.8;
  static const int autoPauseAfterMs = 5000;
  static const double autoResumeAboveMps = 1.5;
  static const int autoResumeAfterMs = 2000;

  TrackingStatus _status = TrackingStatus.running;
  bool _autoPaused = false;
  int _segment;
  int _movingMs;
  int _lastTickMs = 0; // last time movingMs was advanced
  double _distanceM;
  double _maxSpeedMps;
  double _kcal;
  final ElevationGain _elev;
  EnginePoint? _last;
  int? _lastFixAtMs;
  double? _lastAccuracy;
  int _fixCount = 0;
  int? _slowSinceMs;
  final List<EnginePoint> _resumeBuf = []; // fast fixes while auto-paused
  final _window = Queue<EnginePoint>();
  final List<EnginePoint> _pending = []; // not yet persisted

  /// [resume*] restore state of a recovered run.
  TrackingEngine({
    required this.runId,
    required this.startedAt,
    this.weightKg,
    this.autoPause = false,
    int resumeSegment = 0,
    int resumeMovingMs = 0,
    double resumeDistanceM = 0,
    double resumeMaxSpeedMps = 0,
    double resumeKcal = 0,
    double resumeElevGainM = 0,
    int? nowMs,
  }) : _segment = resumeSegment,
       _movingMs = resumeMovingMs,
       _distanceM = resumeDistanceM,
       _maxSpeedMps = resumeMaxSpeedMps,
       _kcal = resumeKcal,
       _elev = ElevationGain(gainM: resumeElevGainM) {
    _lastTickMs = nowMs ?? 0;
  }

  TrackingStatus get status => _status;
  bool get autoPaused => _autoPaused;
  int get segment => _segment;
  double get distanceM => _distanceM;

  /// Advances the moving-time clock to [nowMs] (ms since run start).
  void tick(int nowMs) {
    if (nowMs < _lastTickMs) return;
    if (_status == TrackingStatus.running) _movingMs += nowMs - _lastTickMs;
    _lastTickMs = nowMs;
  }

  /// Adds a fix taken at [nowMs] (ms since run start). Returns true if it
  /// was accepted into the track.
  bool addFix({
    required int nowMs,
    required double lat,
    required double lon,
    required double speedMps,
    required double accuracyM,
    double? speedAccMps,
    double? altM,
    bool mocked = false,
  }) {
    tick(nowMs);
    final listening =
        _status == TrackingStatus.running ||
        (_status == TrackingStatus.paused && _autoPaused);
    if (!listening) return false;
    if (mocked || accuracyM <= 0 || accuracyM > maxAccuracyM) return false;
    if (speedAccMps != null && speedAccMps > maxSpeedAccMps) return false;
    final speed = speedMps.clamp(0.0, maxPlausibleSpeedMps);
    _lastFixAtMs = nowMs;
    _lastAccuracy = accuracyM;
    _fixCount++;

    final p = EnginePoint(
      tMs: nowMs,
      lat: lat,
      lon: lon,
      speedMps: speed,
      segment: _segment,
      accM: accuracyM,
      speedAccMps: speedAccMps,
      altM: altM,
    );

    if (_autoPaused) return _watchForResume(p, nowMs);

    _accept(p);
    if (autoPause) {
      if (speed < autoPauseBelowMps) {
        final since = _slowSinceMs ??= nowMs;
        if (nowMs - since >= autoPauseAfterMs) _autoPauseFrom(since);
      } else {
        _slowSinceMs = null;
      }
    }
    return true;
  }

  bool _watchForResume(EnginePoint p, int nowMs) {
    if (p.speedMps < autoResumeAboveMps) {
      _resumeBuf.clear();
      return false;
    }
    _resumeBuf.add(p);
    final since = _resumeBuf.first.tMs;
    if (nowMs - since < autoResumeAfterMs) return false;

    // Moving again: the run restarts where the speed first picked up, so
    // those seconds and metres are not lost.
    _status = TrackingStatus.running;
    _autoPaused = false;
    _segment++;
    _movingMs += nowMs - since;
    for (final b in _resumeBuf) {
      _accept(b.withSegment(_segment));
    }
    _resumeBuf.clear();
    return true;
  }

  void _accept(EnginePoint p) {
    final prev = _last;
    if (prev != null) {
      _distanceM += stepDistance(prev, p);
      final w = weightKg;
      if (w != null && prev.segment == p.segment) {
        _kcal += kcalForInterval(
          speedMps: (prev.speedMps + p.speedMps) / 2,
          durationS: (p.tMs - prev.tMs) / 1000,
          weightKg: w,
        );
      }
    }
    final alt = p.altM;
    if (alt != null) _elev.add(alt);
    _maxSpeedMps = math.max(_maxSpeedMps, p.speedMps);
    _last = p;
    _pending.add(p);
    _window.add(p);
    while (_window.isNotEmpty && p.tMs - _window.first.tMs > speedWindowMs) {
      _window.removeFirst();
    }
  }

  /// The runner has been standing since [sinceMs]: those seconds don't count
  /// as moving time.
  void _autoPauseFrom(int sinceMs) {
    _movingMs = math.max(0, _movingMs - (_lastTickMs - sinceMs));
    _status = TrackingStatus.paused;
    _autoPaused = true;
    _slowSinceMs = null;
    _resumeBuf.clear();
    _window.clear();
  }

  void pause(int nowMs) {
    tick(nowMs);
    if (_status == TrackingStatus.finished) return;
    // A manual pause also turns an auto-pause into a manual one, so it
    // won't resume by itself.
    _autoPaused = false;
    _resumeBuf.clear();
    if (_status != TrackingStatus.running) return;
    _status = TrackingStatus.paused;
    _slowSinceMs = null;
    _window.clear();
  }

  void resume(int nowMs) {
    tick(nowMs);
    if (_status != TrackingStatus.paused) return;
    _status = TrackingStatus.running;
    _autoPaused = false;
    _resumeBuf.clear();
    _segment++; // the route breaks here; no distance across the pause
  }

  void finish(int nowMs) {
    tick(nowMs);
    _status = TrackingStatus.finished;
    _autoPaused = false;
  }

  /// Points accepted since the last call (for batched DB writes).
  List<EnginePoint> takePending() {
    final out = List.of(_pending);
    _pending.clear();
    return out;
  }

  TrackingSnapshot snapshot(int nowMs) {
    tick(nowMs);
    final current =
        _window.isEmpty
            ? 0.0
            : _window.fold(0.0, (s, p) => s + p.speedMps) / _window.length;
    final listening = _status == TrackingStatus.running || _autoPaused;
    final lost =
        listening &&
        (_lastFixAtMs == null || nowMs - _lastFixAtMs! > gpsLostAfterMs);
    return TrackingSnapshot(
      runId: runId,
      status: _status,
      autoPaused: _autoPaused,
      elapsedMs: nowMs,
      movingMs: _movingMs,
      distanceM: _distanceM,
      currentSpeedMps:
          lost || _status != TrackingStatus.running ? 0 : current,
      avgSpeedMps: _movingMs > 0 ? _distanceM / (_movingMs / 1000) : 0,
      maxSpeedMps: _maxSpeedMps,
      kcal: weightKg == null ? null : _kcal,
      elevGainM: _elev.gainM,
      gpsAccuracyM: _lastAccuracy,
      gpsLost: lost,
      fixCount: _fixCount,
    );
  }
}
