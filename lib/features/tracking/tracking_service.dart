import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/location_service.dart';
import '../../data/run_repository.dart';
import 'tracking_engine.dart';
import 'tracking_task.dart';

const _serviceId = 4711;

/// isRunningService, but false when the platform side is missing (tests,
/// unsupported platforms) instead of throwing.
Future<bool> isTrackingServiceRunning() async {
  try {
    return await FlutterForegroundTask.isRunningService;
  } catch (_) {
    return false;
  }
}

const _batteryAskedKey = 'battery_optimization_asked';

/// Must run once before runApp (main isolate).
void initTrackingService() {
  FlutterForegroundTask.initCommunicationPort();
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'active_run',
      channelName: 'Active run',
      channelDescription: 'Live distance, time and pace while you run.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      onlyAlertOnce: true,
      visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(1000),
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: false,
      allowWakeLock: true,
      allowWifiLock: false,
    ),
  );
}

enum StartBlocker { location, notifications, failed }

class TrackingState {
  final TrackingSnapshot? snapshot; // null while not running
  final int? finishedRunId; // set once when a run was saved
  final bool finishedEmpty; // finished without any GPS fix

  const TrackingState({
    this.snapshot,
    this.finishedRunId,
    this.finishedEmpty = false,
  });

  bool get isActive => snapshot != null;
}

final trackingProvider = NotifierProvider<TrackingController, TrackingState>(
  TrackingController.new,
);

class TrackingController extends Notifier<TrackingState> {
  @override
  TrackingState build() {
    FlutterForegroundTask.addTaskDataCallback(_onData);
    ref.onDispose(() => FlutterForegroundTask.removeTaskDataCallback(_onData));
    _attachIfRunning();
    return const TrackingState();
  }

  /// After an app restart, reconnect to a run that is still going.
  Future<void> _attachIfRunning() async {
    if (await isTrackingServiceRunning()) {
      FlutterForegroundTask.sendDataToTask(TrackingCmd.snapshot);
    }
  }

  void _onData(Object data) {
    if (data is! Map) return;
    switch (data['type']) {
      case 'snapshot':
        state = TrackingState(snapshot: TrackingSnapshot.fromMap(data));
      case 'finished':
        final id = (data['runId'] as num?)?.toInt();
        // The service wrote through its own connection.
        ref.read(runRepositoryProvider).notifyExternalChanges();
        state = TrackingState(finishedRunId: id, finishedEmpty: id == null);
    }
  }

  /// Location → notifications. Returns what blocks the start, or null.
  Future<StartBlocker?> ensurePermissions() async {
    if (!await ref.read(locationServiceProvider).handlePermissions()) {
      return StartBlocker.location;
    }
    var n = await FlutterForegroundTask.checkNotificationPermission();
    if (n != NotificationPermission.granted) {
      n = await FlutterForegroundTask.requestNotificationPermission();
    }
    // The run still works without the notification, but it can't be
    // controlled from the lock screen; the UI explains that.
    if (n != NotificationPermission.granted) return StartBlocker.notifications;
    return null;
  }

  /// True if we should explain and ask for the battery exemption (once).
  Future<bool> shouldAskBatteryExemption() async {
    if (await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      return false;
    }
    final asked = await FlutterForegroundTask.getData<bool>(
      key: _batteryAskedKey,
    );
    return asked != true;
  }

  /// Remember that we explained it, whatever the answer, so the dialog
  /// doesn't come back before every run.
  Future<void> markBatteryAsked() =>
      FlutterForegroundTask.saveData(key: _batteryAskedKey, value: true);

  Future<void> requestBatteryExemption() =>
      FlutterForegroundTask.requestIgnoreBatteryOptimization();

  /// Starts (or resumes) the tracking service.
  Future<bool> start() async {
    if (await isTrackingServiceRunning()) {
      FlutterForegroundTask.sendDataToTask(TrackingCmd.snapshot);
      return true;
    }
    final result = await FlutterForegroundTask.startService(
      serviceId: _serviceId,
      serviceTypes: [ForegroundServiceTypes.location],
      notificationTitle: 'Running · 0 m',
      notificationText: 'Waiting for GPS…',
      notificationButtons: trackingButtons(TrackingStatus.running),
      callback: startTrackingCallback,
    );
    return result is ServiceRequestSuccess;
  }

  void pause() => FlutterForegroundTask.sendDataToTask(TrackingCmd.pause);

  void resume() => FlutterForegroundTask.sendDataToTask(TrackingCmd.resume);

  void finish() => FlutterForegroundTask.sendDataToTask(TrackingCmd.finish);

  /// Clears the one-shot "finished" result after the UI handled it.
  void acknowledgeFinished() => state = const TrackingState();
}
