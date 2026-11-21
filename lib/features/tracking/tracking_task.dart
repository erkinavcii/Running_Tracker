import 'dart:async';
import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:raw_gnss/raw_gnss.dart';

import '../../data/database.dart';
import '../../data/run_repository.dart';
import 'tracking_engine.dart';
import 'voice_cues.dart';

/// Commands and notification button ids shared by UI and service.
abstract final class TrackingCmd {
  static const pause = 'pause';
  static const resume = 'resume';
  static const finish = 'finish';
  static const snapshot = 'snapshot';
}

/// Entry point of the foreground service isolate.
@pragma('vm:entry-point')
void startTrackingCallback() {
  FlutterForegroundTask.setTaskHandler(TrackingTaskHandler());
}

/// Runs inside the foreground service (its own Flutter engine), so it keeps
/// going with the screen off or the app swiped away. It owns the run:
/// GPS → engine → database, plus the notification.
class TrackingTaskHandler extends TaskHandler {
  static const _flushEveryTicks = 5;

  AppDatabase? _db;
  RunRepository? _repo;
  TrackingEngine? _engine;
  StreamSubscription<GnssFix>? _gps;
  DateTime _startedAt = DateTime.now();
  int _nextSeq = 0;
  int _ticks = 0;
  bool _miles = false;
  bool _finishing = false;
  TrackingStatus? _shownStatus;
  VoiceCues? _cues;
  FlutterTts? _tts;

  int _nowMs() => DateTime.now().difference(_startedAt).inMilliseconds;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final db = AppDatabase();
    final repo = RunRepository(db);
    _db = db;
    _repo = repo;

    final profile = await repo.getProfile();
    _miles = profile.useMiles;

    // Continue an unfinished run (service restarted by the system or
    // resumed after a crash), otherwise start a new one.
    final existing = await repo.getUnfinishedRun();
    if (existing != null) {
      _startedAt = existing.startedAt;
      final last = await repo.lastPoint(existing.id);
      _nextSeq = (last?.seq ?? -1) + 1;
      _engine = TrackingEngine(
        runId: existing.id,
        startedAt: existing.startedAt,
        weightKg: profile.weightKg,
        // New segment: no distance is invented across the gap.
        resumeSegment: (last?.segment ?? -1) + 1,
        resumeMovingMs: existing.movingMs,
        resumeDistanceM: existing.distanceM,
        resumeMaxSpeedMps: existing.maxSpeedMps,
        resumeKcal: existing.kcal ?? 0,
        resumeElevGainM: existing.elevGainM ?? 0,
        autoPause: profile.autoPause,
        nowMs: _nowMs(),
      );
      if (existing.status == RunStatus.paused) _engine!.pause(_nowMs());
    } else {
      _startedAt = DateTime.now();
      final id = await repo.createEnduranceRun(_startedAt);
      _engine = TrackingEngine(
        runId: id,
        startedAt: _startedAt,
        weightKg: profile.weightKg,
        autoPause: profile.autoPause,
      );
    }

    if (profile.audioCues) {
      await _initVoice(fresh: existing == null);
    }

    _gps = RawGnss.fixes().listen(
      (f) => _engine?.addFix(
        nowMs: _nowMs(),
        lat: f.latitude,
        lon: f.longitude,
        speedMps: f.speed,
        accuracyM: f.accuracy,
        speedAccMps: f.speedAccuracy > 0 ? f.speedAccuracy : null,
        altM: f.altitude != 0 ? f.altitude : null,
        mocked: f.isMocked,
      ),
      // GPS off or permission revoked: keep the run; the snapshot reports
      // "GPS lost" until fixes come back.
      onError: (Object _) {},
    );

    _publish();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    if (_engine == null || _finishing) return;
    _publish();
    if (++_ticks % _flushEveryTicks == 0) _flush();
  }

  @override
  void onReceiveData(Object data) {
    if (data is String) _handle(data);
  }

  @override
  void onNotificationButtonPressed(String id) => _handle(id);

  @override
  void onNotificationPressed() => FlutterForegroundTask.launchApp();

  void _handle(String cmd) {
    final engine = _engine;
    if (engine == null || _finishing) return;
    switch (cmd) {
      case TrackingCmd.pause:
        engine.pause(_nowMs());
      case TrackingCmd.resume:
        engine.resume(_nowMs());
      case TrackingCmd.finish:
        _finish();
        return;
      case TrackingCmd.snapshot:
        break;
    }
    _publish();
    _flush();
  }

  /// Sets up text-to-speech in the device language (Turkish or English).
  Future<void> _initVoice({required bool fresh}) async {
    try {
      final tts = FlutterTts();
      var turkish = Platform.localeName.toLowerCase().startsWith('tr');
      if (turkish && await tts.isLanguageAvailable('tr-TR') != true) {
        turkish = false;
      }
      await tts.setLanguage(turkish ? 'tr-TR' : 'en-US');
      await tts.setSpeechRate(0.5);
      await tts.setQueueMode(1); // add, don't cut the previous cue
      _tts = tts;
      final phrases = CuePhrases(turkish: turkish, miles: _miles);
      _cues = VoiceCues(phrases);
      if (fresh) _say(phrases.started);
    } catch (_) {
      // No TTS engine: run silently.
      _tts = null;
      _cues = null;
    }
  }

  /// Speaks with transient audio focus so music ducks instead of stopping.
  void _say(String text) {
    _tts?.speak(text, focus: true);
  }

  /// Sends the snapshot to the UI and refreshes the notification.
  void _publish() {
    final engine = _engine;
    if (engine == null) return;
    final snap = engine.snapshot(_nowMs());
    FlutterForegroundTask.sendDataToMain(snap.toMap());
    _cues?.update(snap).forEach(_say);

    final statusChanged = _shownStatus != snap.status;
    _shownStatus = snap.status;
    FlutterForegroundTask.updateService(
      notificationTitle: snap.notificationTitle(miles: _miles),
      notificationText: snap.notificationText(miles: _miles),
      // Buttons only change with the status. "Finish" is offered only
      // while paused so a phone in a pocket can't end the run by accident.
      notificationButtons: statusChanged ? trackingButtons(snap.status) : null,
    );
  }

  Future<void> _flush() async {
    final engine = _engine;
    final repo = _repo;
    if (engine == null || repo == null) return;
    final pts = engine.takePending();
    final snap = engine.snapshot(_nowMs());
    final firstSeq = _nextSeq;
    _nextSeq += pts.length;
    await repo.saveProgress(
      engine.runId,
      firstSeq,
      [
        for (final p in pts)
          StoredPoint(
            tMs: p.tMs,
            lat: p.lat,
            lon: p.lon,
            speedMps: p.speedMps,
            speedAccMps: p.speedAccMps,
            accM: p.accM,
            altM: p.altM,
            segment: p.segment,
          ),
      ],
      RunProgress(
        status:
            snap.status == TrackingStatus.paused
                ? RunStatus.paused
                : RunStatus.active,
        elapsedMs: snap.elapsedMs,
        movingMs: snap.movingMs,
        distanceM: snap.distanceM,
        maxSpeedMps: snap.maxSpeedMps,
        kcal: snap.kcal,
        elevGainM: snap.elevGainM,
      ),
    );
  }

  Future<void> _finish() async {
    final engine = _engine;
    final repo = _repo;
    if (engine == null || repo == null) return;
    _finishing = true;
    engine.finish(_nowMs());
    await _gps?.cancel();
    _gps = null;
    await _flush();
    final snap = engine.snapshot(_nowMs());
    final savedId = await repo.finishEndurance(
      engine.runId,
      endedAt: DateTime.now(),
      elapsedMs: snap.elapsedMs,
      movingMs: snap.movingMs,
      kcal: snap.kcal,
    );
    FlutterForegroundTask.sendDataToMain({
      'type': 'finished',
      'runId': savedId,
    });
    await FlutterForegroundTask.stopService();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _gps?.cancel();
    await _tts?.stop();
    // Killed mid-run: keep everything so the app can offer recovery.
    if (!_finishing) await _flush();
    await _db?.close();
  }
}

List<NotificationButton> trackingButtons(TrackingStatus status) =>
    switch (status) {
      TrackingStatus.running => const [
        NotificationButton(id: TrackingCmd.pause, text: 'Pause'),
      ],
      TrackingStatus.paused => const [
        NotificationButton(id: TrackingCmd.resume, text: 'Resume'),
        NotificationButton(id: TrackingCmd.finish, text: 'Finish'),
      ],
      TrackingStatus.finished => const [],
    };
