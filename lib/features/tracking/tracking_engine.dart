import 'dart:collection';
import 'dart:math' as math;

import '../../core/calories.dart';
import '../../core/format.dart';
import '../../core/track_math.dart';

enum TrackingStatus { running, paused, finished }

/// What the UI and the notification show; sent across isolates as a map.
class TrackingSnapshot {
  final int runId;
  final TrackingStatus status;
  final int elapsedMs; // wall time since start
  final int movingMs; // excluding pauses
  final double distanceM;
  final double currentSpeedMps; // ~15 s rolling average
  final double avgSpeedMps; // distance / moving time
  final double maxSpeedMps;
  final double? kcal;
  final double? gpsAccuracyM;
  final bool gpsLost;
  final int fixCount;

  const TrackingSnapshot({
    required this.runId,
    required this.status,
    required this.elapsedMs,
    required this.movingMs,
    required this.distanceM,
    required this.currentSpeedMps,
    required this.avgSpeedMps,
    required this.maxSpeedMps,
    required this.kcal,
    required this.gpsAccuracyM,
    required this.gpsLost,
    required this.fixCount,
  });

  Map<String, Object?> toMap() => {
    'type': 'snapshot',
    'runId': runId,
    'status': status.name,
    'elapsedMs': elapsedMs,
    'movingMs': movingMs,
    'distanceM': distanceM,
    'currentSpeedMps': currentSpeedMps,
    'avgSpeedMps': avgSpeedMps,
    'maxSpeedMps': maxSpeedMps,
    'kcal': kcal,
    'gpsAccuracyM': gpsAccuracyM,
    'gpsLost': gpsLost,
    'fixCount': fixCount,
  };

  factory TrackingSnapshot.fromMap(Map m) => TrackingSnapshot(
    runId: (m['runId'] as num).toInt(),
    status: TrackingStatus.values.byName(m['status'] as String),
    elapsedMs: (m['elapsedMs'] as num).toInt(),
    movingMs: (m['movingMs'] as num).toInt(),
    distanceM: (m['distanceM'] as num).toDouble(),
    currentSpeedMps: (m['currentSpeedMps'] as num).toDouble(),
    avgSpeedMps: (m['avgSpeedMps'] as num).toDouble(),
    maxSpeedMps: (m['maxSpeedMps'] as num).toDouble(),
    kcal: (m['kcal'] as num?)?.toDouble(),
    gpsAccuracyM: (m['gpsAccuracyM'] as num?)?.toDouble(),
    gpsLost: m['gpsLost'] == true,
    fixCount: (m['fixCount'] as num).toInt(),
  );

  /// "5.24 km · 28:13" for the notification title.
  String notificationTitle({bool miles = false}) {
    final prefix = switch (status) {
      TrackingStatus.paused => 'Paused',
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
}

/// Platform-free endurance tracking: feed it fixes and commands with
/// timestamps, read snapshots. Fully deterministic, so it is unit-tested
/// and can be replayed from recorded tracks.
class TrackingEngine {
  final int runId;
  final DateTime startedAt;
  final double? weightKg;

  // Fix filters (endurance is more lenient than sprint).
  static const double maxAccuracyM = 30;
  static const double maxSpeedAccMps = 3;
  static const double maxPlausibleSpeedMps = 12.5; // 45 km/h on foot
  static const int gpsLostAfterMs = 10000;
  static const int speedWindowMs = 15000;

  TrackingStatus _status = TrackingStatus.running;
  int _segment;
  int _movingMs;
  int _lastTickMs = 0; // last time movingMs was advanced
  double _distanceM;
  double _maxSpeedMps;
  double _kcal;
  EnginePoint? _last;
  int? _lastFixAtMs;
  double? _lastAccuracy;
  int _fixCount = 0;
  final _window = Queue<EnginePoint>();
  final List<EnginePoint> _pending = []; // not yet persisted

  /// [resume*] restore state of a recovered run.
  TrackingEngine({
    required this.runId,
    required this.startedAt,
    this.weightKg,
    int resumeSegment = 0,
    int resumeMovingMs = 0,
    double resumeDistanceM = 0,
    double resumeMaxSpeedMps = 0,
    double resumeKcal = 0,
    int? nowMs,
  }) : _segment = resumeSegment,
       _movingMs = resumeMovingMs,
       _distanceM = resumeDistanceM,
       _maxSpeedMps = resumeMaxSpeedMps,
       _kcal = resumeKcal {
    _lastTickMs = nowMs ?? 0;
  }

  TrackingStatus get status => _status;
  int get segment => _segment;
  double get distanceM => _distanceM;

  /// Advances the moving-time clock to [nowMs] (ms since run start).
  void tick(int nowMs) {
    if (nowMs < _lastTickMs) return;
    if (_status == TrackingStatus.running) _movingMs += nowMs - _lastTickMs;
    _lastTickMs = nowMs;
  }

  /// Adds a fix taken at [nowMs] (ms since run start). Returns true if it
  /// was accepted.
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
    if (_status != TrackingStatus.running) return false;
    if (mocked || accuracyM <= 0 || accuracyM > maxAccuracyM) return false;
    if (speedAccMps != null && speedAccMps > maxSpeedAccMps) return false;
    final speed = speedMps.clamp(0.0, maxPlausibleSpeedMps);

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
    final prev = _last;
    if (prev != null) {
      final d = stepDistance(prev, p);
      _distanceM += d;
      final w = weightKg;
      if (w != null && prev.segment == p.segment) {
        _kcal += kcalForInterval(
          speedMps: (prev.speedMps + p.speedMps) / 2,
          durationS: (p.tMs - prev.tMs) / 1000,
          weightKg: w,
        );
      }
    }
    _maxSpeedMps = math.max(_maxSpeedMps, speed);
    _last = p;
    _lastFixAtMs = nowMs;
    _lastAccuracy = accuracyM;
    _fixCount++;
    _pending.add(p);
    _window.add(p);
    while (_window.isNotEmpty && nowMs - _window.first.tMs > speedWindowMs) {
      _window.removeFirst();
    }
    return true;
  }

  void pause(int nowMs) {
    tick(nowMs);
    if (_status != TrackingStatus.running) return;
    _status = TrackingStatus.paused;
    _window.clear();
  }

  void resume(int nowMs) {
    tick(nowMs);
    if (_status != TrackingStatus.paused) return;
    _status = TrackingStatus.running;
    _segment++; // the route breaks here; no distance across the pause
  }

  void finish(int nowMs) {
    tick(nowMs);
    _status = TrackingStatus.finished;
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
    final lost =
        _status == TrackingStatus.running &&
        (_lastFixAtMs == null || nowMs - _lastFixAtMs! > gpsLostAfterMs);
    return TrackingSnapshot(
      runId: runId,
      status: _status,
      elapsedMs: nowMs,
      movingMs: _movingMs,
      distanceM: _distanceM,
      currentSpeedMps: lost ? 0 : current,
      avgSpeedMps: _movingMs > 0 ? _distanceM / (_movingMs / 1000) : 0,
      maxSpeedMps: _maxSpeedMps,
      kcal: weightKg == null ? null : _kcal,
      gpsAccuracyM: _lastAccuracy,
      gpsLost: lost,
      fixCount: _fixCount,
    );
  }
}
