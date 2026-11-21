import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/core/track_math.dart';
import 'package:sprint_tracker/features/tracking/tracking_engine.dart';

/// Feeds a straight northward run at [speed] m/s, one fix per second.
int feed(TrackingEngine e, {required int fromMs, required int seconds,
    double speed = 3, double lat0 = 41.0, double acc = 4}) {
  var t = fromMs;
  for (var i = 0; i < seconds; i++) {
    t = fromMs + i * 1000;
    // ~speed m per second northwards (1° lat ≈ 111 195 m).
    e.addFix(
      nowMs: t,
      lat: lat0 + speed * i / 111195,
      lon: 29.0,
      speedMps: speed,
      accuracyM: acc,
      speedAccMps: 0.3,
    );
  }
  return t;
}

void main() {
  test('distance is the Doppler integral, not position noise', () {
    final e = TrackingEngine(runId: 1, startedAt: DateTime(2026), weightKg: 70);
    feed(e, fromMs: 0, seconds: 101, speed: 3);
    final s = e.snapshot(100000);
    expect(s.distanceM, closeTo(300, 0.01)); // 100 s × 3 m/s
    expect(s.movingMs, 100000);
    expect(s.avgSpeedMps, closeTo(3, 0.001));
    expect(s.currentSpeedMps, closeTo(3, 0.001));
    expect(s.kcal, greaterThan(0));
  });

  test('pause stops time and distance; resume starts a new segment', () {
    final e = TrackingEngine(runId: 1, startedAt: DateTime(2026));
    feed(e, fromMs: 0, seconds: 11, speed: 3); // 0..10 s → 30 m
    e.pause(10000);
    // Fixes while paused are ignored.
    expect(
      e.addFix(nowMs: 20000, lat: 41.1, lon: 29, speedMps: 3, accuracyM: 4),
      isFalse,
    );
    e.resume(70000); // paused for 60 s
    feed(e, fromMs: 70000, seconds: 11, speed: 3, lat0: 41.2); // +30 m
    final s = e.snapshot(80000);
    expect(s.distanceM, closeTo(60, 0.01)); // nothing across the pause
    expect(s.movingMs, 20000);
    expect(s.elapsedMs, 80000);
    expect(e.segment, 1);

    final pts = e.takePending();
    expect(pts.map((p) => p.segment).toSet(), {0, 1});
    expect(e.takePending(), isEmpty);
  });

  test('bad fixes are rejected and speed is clamped', () {
    final e = TrackingEngine(runId: 1, startedAt: DateTime(2026));
    expect(e.addFix(nowMs: 0, lat: 41, lon: 29, speedMps: 3, accuracyM: 80),
        isFalse);
    expect(
        e.addFix(nowMs: 0, lat: 41, lon: 29, speedMps: 3, accuracyM: 4,
            mocked: true),
        isFalse);
    expect(
        e.addFix(nowMs: 0, lat: 41, lon: 29, speedMps: 3, accuracyM: 4,
            speedAccMps: 9),
        isFalse);
    expect(e.addFix(nowMs: 0, lat: 41, lon: 29, speedMps: 40, accuracyM: 4),
        isTrue);
    expect(e.snapshot(0).maxSpeedMps, TrackingEngine.maxPlausibleSpeedMps);
  });

  test('GPS lost after 10 s without fixes', () {
    final e = TrackingEngine(runId: 1, startedAt: DateTime(2026));
    feed(e, fromMs: 0, seconds: 3);
    expect(e.snapshot(5000).gpsLost, isFalse);
    final lost = e.snapshot(13000);
    expect(lost.gpsLost, isTrue);
    expect(lost.currentSpeedMps, 0);
  });

  test('recovered run continues totals in a new segment', () {
    final e = TrackingEngine(
      runId: 9,
      startedAt: DateTime(2026),
      resumeSegment: 3,
      resumeMovingMs: 600000,
      resumeDistanceM: 1800,
      nowMs: 900000,
    );
    feed(e, fromMs: 900000, seconds: 11, speed: 3);
    final s = e.snapshot(910000);
    expect(s.distanceM, closeTo(1830, 0.01));
    expect(s.movingMs, 610000);
    expect(e.takePending().first.segment, 3);
  });

  test('snapshot survives the isolate map round trip', () {
    final e = TrackingEngine(runId: 5, startedAt: DateTime(2026), weightKg: 60);
    feed(e, fromMs: 0, seconds: 5);
    final s = e.snapshot(4000);
    final back = TrackingSnapshot.fromMap(s.toMap());
    expect(back.runId, 5);
    expect(back.distanceM, s.distanceM);
    expect(back.status, TrackingStatus.running);
    expect(back.kcal, s.kcal);
  });

  test('notification text', () {
    const s = TrackingSnapshot(
      runId: 1,
      status: TrackingStatus.running,
      elapsedMs: 1693000,
      movingMs: 1693000,
      distanceM: 5240,
      currentSpeedMps: 1000 / 323,
      avgSpeedMps: 3,
      maxSpeedMps: 4,
      kcal: 412.4,
      gpsAccuracyM: 4,
      gpsLost: false,
      fixCount: 1693,
    );
    expect(s.notificationTitle(), 'Running · 5.24 km');
    expect(s.notificationText(), '28:13 · 5:23 /km · ≈ 412 kcal');
  });

  test('long GPS gaps fall back to the straight line', () {
    const a = TrackPointLike(tMs: 0, lat: 41, lon: 29, speedMps: 3, segment: 0);
    const b = TrackPointLike(
        tMs: 20000, lat: 41 + 100 / 111195, lon: 29, speedMps: 3, segment: 0);
    expect(stepDistance(a, b), closeTo(100, 0.5)); // not 60 m from speed
    const c = TrackPointLike(
        tMs: 20000, lat: 41.01, lon: 29, speedMps: 3, segment: 1);
    expect(stepDistance(a, c), 0); // across a pause
  });
}
