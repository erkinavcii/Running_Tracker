import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:sprint_tracker/core/elevation.dart';
import 'package:sprint_tracker/features/tracking/tracking_engine.dart';
import 'package:sprint_tracker/features/tracking/voice_cues.dart';

/// One fix per second at the given speeds, moving north.
int run(TrackingEngine e, int fromMs, List<double> speeds) {
  var t = fromMs;
  var lat = 41.0 + fromMs / 1e9;
  for (final v in speeds) {
    e.addFix(
      nowMs: t,
      lat: lat,
      lon: 29,
      speedMps: v,
      accuracyM: 4,
      speedAccMps: 0.3,
    );
    lat += v / 111195;
    t += 1000;
  }
  return t;
}

List<double> secs(int n, double v) => List.filled(n, v);

TrackingSnapshot snap({
  TrackingStatus status = TrackingStatus.running,
  bool auto = false,
  double dist = 0,
  int moving = 0,
  bool lost = false,
}) => TrackingSnapshot(
  runId: 1,
  status: status,
  autoPaused: auto,
  elapsedMs: moving,
  movingMs: moving,
  distanceM: dist,
  currentSpeedMps: 3,
  avgSpeedMps: 3,
  maxSpeedMps: 3,
  kcal: null,
  gpsAccuracyM: 4,
  gpsLost: lost,
  fixCount: 0,
);

void main() {
  group('auto-pause', () {
    test('stops after 5 s standing and resumes after 2 s running', () {
      final e = TrackingEngine(
        runId: 1,
        startedAt: DateTime(2026),
        autoPause: true,
      );
      var t = run(e, 0, secs(60, 3)); // 0..59 s running
      t = run(e, t, secs(3, 0.2)); // standing, not yet paused
      expect(e.status, TrackingStatus.running);
      t = run(e, t, secs(30, 0.2)); // waiting at a crossing
      expect(e.status, TrackingStatus.paused);
      expect(e.autoPaused, isTrue);
      final paused = e.snapshot(t);
      // Moving time excludes the standing seconds (from 60 s on).
      expect(paused.movingMs, inInclusiveRange(59000, 61000));
      expect(paused.notificationTitle(), startsWith('Auto-paused'));

      t = run(e, t, secs(1, 3)); // one step is not enough
      expect(e.status, TrackingStatus.paused);
      t = run(e, t, secs(20, 3)); // running again
      expect(e.status, TrackingStatus.running);
      expect(e.segment, 1);
      final s = e.snapshot(t - 1000);
      // ~80 s of running in total, nothing counted for the wait.
      expect(s.movingMs, inInclusiveRange(78000, 82000));
      expect(s.distanceM, closeTo(240, 8));
    });

    test('a slow jog never triggers it, and it can be off', () {
      final on = TrackingEngine(runId: 1, startedAt: DateTime(2026),
          autoPause: true);
      run(on, 0, secs(60, 1.2)); // brisk walk
      expect(on.status, TrackingStatus.running);

      final off = TrackingEngine(runId: 1, startedAt: DateTime(2026));
      run(off, 0, secs(30, 0));
      expect(off.status, TrackingStatus.running);
    });

    test('manual pause during auto-pause stays paused', () {
      final e = TrackingEngine(runId: 1, startedAt: DateTime(2026),
          autoPause: true);
      var t = run(e, 0, secs(10, 3));
      t = run(e, t, secs(10, 0));
      expect(e.autoPaused, isTrue);
      e.pause(t);
      expect(e.autoPaused, isFalse);
      run(e, t, secs(10, 3));
      expect(e.status, TrackingStatus.paused);
    });
  });

  group('elevation', () {
    test('GPS jitter on flat ground adds little', () {
      final rnd = math.Random(7);
      final alts = [for (var i = 0; i < 600; i++) 50 + (rnd.nextDouble() - 0.5) * 6];
      expect(ElevationGain.of(alts), lessThan(6));
    });

    test('a real climb is counted', () {
      final alts = [
        for (var i = 0; i < 100; i++) 10.0 + i * 0.3, // +30 m
        for (var i = 0; i < 100; i++) 40.0 - i * 0.3, // back down
      ];
      expect(ElevationGain.of(alts), closeTo(30, 4));
    });
  });

  group('voice cues', () {
    test('Turkish split phrase', () {
      const p = CuePhrases(turkish: true);
      expect(p.split(3, 962000, 321000),
          '3 kilometre. Süre 16 dakika 2 saniye. Son kilometre 5 dakika 21 saniye.');
    });

    test('English plurals and hours', () {
      const p = CuePhrases(turkish: false);
      expect(p.duration(3725000), '1 hour 2 minutes 5 seconds');
      expect(p.split(1, 300000, 300000),
          '1 kilometer. Time 5 minutes. Last kilometer 5 minutes.');
    });

    test('announces splits, pauses and GPS changes once', () {
      final cues = VoiceCues(const CuePhrases(turkish: false));
      expect(cues.update(snap(dist: 10)), isEmpty); // baseline
      expect(cues.update(snap(dist: 990, moving: 300000)), isEmpty);
      expect(cues.update(snap(dist: 1003, moving: 301000)),
          ['1 kilometer. Time 5 minutes 1 second. Last kilometer 5 minutes 1 second.']);
      expect(cues.update(snap(dist: 1010, moving: 303000)), isEmpty);
      expect(
        cues.update(snap(status: TrackingStatus.paused, auto: true,
            dist: 1010, moving: 303000)),
        ['Auto-paused'],
      );
      expect(cues.update(snap(dist: 1020, moving: 304000)), ['Resumed']);
      expect(cues.update(snap(dist: 1020, moving: 315000, lost: true)),
          ['GPS signal lost']);
      expect(cues.update(snap(dist: 1020, moving: 316000, lost: true)),
          isEmpty);
      expect(cues.update(snap(dist: 1030, moving: 317000)),
          ['GPS signal back']);
    });

    test('the first fix of a run is not announced as GPS back', () {
      final cues = VoiceCues(const CuePhrases(turkish: false));
      expect(cues.update(snap(lost: true)), isEmpty);
      expect(cues.update(snap(dist: 3, moving: 1000)), isEmpty);
    });

    test('a recovered run does not re-announce old splits', () {
      final cues = VoiceCues(const CuePhrases(turkish: true));
      expect(cues.update(snap(dist: 4200, moving: 1300000)), isEmpty);
      expect(cues.update(snap(dist: 4900, moving: 1500000)), isEmpty);
      expect(cues.update(snap(dist: 5001, moving: 1530000)).single,
          startsWith('5 kilometre.'));
    });
  });
}
