// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sprint Tracker';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get sprint => 'Sprint';

  @override
  String get run => 'Run';

  @override
  String get distance => 'Distance';

  @override
  String get time => 'Time';

  @override
  String get pace => 'Pace';

  @override
  String get avgPace => 'Avg pace';

  @override
  String get speed => 'Speed';

  @override
  String get avgSpeed => 'Avg speed';

  @override
  String get averageSpeed => 'Average speed';

  @override
  String get topSpeed => 'Top speed';

  @override
  String get calories => 'Calories';

  @override
  String get elevation => 'Elevation';

  @override
  String get movingTime => 'Moving time';

  @override
  String get elapsed => 'Elapsed';

  @override
  String kcalApprox(int kcal) {
    return '≈ $kcal kcal';
  }

  @override
  String get gpsLost => 'GPS lost';

  @override
  String get gpsSearching => 'Searching';

  @override
  String get gpsNoFix => 'No fix';

  @override
  String get openSettings => 'Open settings';

  @override
  String get tryAgain => 'Try again';

  @override
  String dbError(String error) {
    return 'Could not open the database.\n$error';
  }

  @override
  String get unfinishedTitle => 'Unfinished run found';

  @override
  String get unfinishedBody =>
      'Tracking stopped unexpectedly. Continue it, save it as it is, or discard it?';

  @override
  String get discard => 'Discard';

  @override
  String get continueRun => 'Continue';

  @override
  String get tabRun => 'Run';

  @override
  String get tabHistory => 'History';

  @override
  String get tabRecords => 'Records';

  @override
  String get tabProfile => 'Profile';

  @override
  String get chooseMode => 'Choose a mode';

  @override
  String get homeSubtitle =>
      'Raw GNSS Doppler speed, filtered with the accelerometer.';

  @override
  String get sprintSubtitle => '100 m dash · auto start & finish';

  @override
  String get endurance => 'Endurance';

  @override
  String get enduranceSubtitle =>
      'Pocket-friendly · controls in the notification';

  @override
  String get tipSky => 'Stand outside with a clear view of the sky.';

  @override
  String get tipHold => 'Hold the phone firmly or use an armband.';

  @override
  String get runPaused => 'Run paused';

  @override
  String get runInProgress => 'Run in progress';

  @override
  String get runDeleted => 'Run deleted';

  @override
  String get sprintDeleted => 'Sprint deleted';

  @override
  String get undo => 'UNDO';

  @override
  String get noRunsTitle => 'No runs yet';

  @override
  String get noRunsBody => 'Finished sprints are saved here automatically.';

  @override
  String get last8Weeks => 'Last 8 weeks';

  @override
  String get swipeToDelete => 'Swipe left to delete.';

  @override
  String runsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count runs',
      one: '1 run',
    );
    return '$_temp0';
  }

  @override
  String get thisWeek => 'This week';

  @override
  String get lastWeek => 'Last week';

  @override
  String topSpeedShort(String speed) {
    return 'top $speed';
  }

  @override
  String get prBadge => 'PR';

  @override
  String get noRecordsTitle => 'No records yet';

  @override
  String get noRecordsBody =>
      'Finish a sprint with GPS to set your first 100 m time and top speed.';

  @override
  String get notSetYet => 'Not set yet';

  @override
  String improvedTimes(int count) {
    return 'improved $count×';
  }

  @override
  String get effortSprint100 => '100 m sprint';

  @override
  String get effortHalf => 'Half marathon';

  @override
  String get effortLongest => 'Longest run';

  @override
  String get enterWeight => 'Enter your weight';

  @override
  String get enterNumber => 'Enter a number';

  @override
  String get weightRange => 'Between 30 and 250 kg';

  @override
  String get wholeCm => 'Whole centimetres';

  @override
  String get heightRange => 'Between 100 and 250 cm';

  @override
  String get enterYear => 'Enter a year';

  @override
  String yearRange(int max) {
    return 'Between 1920 and $max';
  }

  @override
  String get welcome => 'Welcome to\nSprint Tracker';

  @override
  String get onboardingBody =>
      'What is your weight? It is only used to estimate calories and never leaves this phone. You can change it later in Profile.';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String get birthYear => 'Birth year';

  @override
  String get continueCaps => 'CONTINUE';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profile => 'Profile';

  @override
  String get profileSubtitle =>
      'Used to estimate calories. Stays on this phone.';

  @override
  String get body => 'Body';

  @override
  String get female => 'Female';

  @override
  String get male => 'Male';

  @override
  String get other => 'Other';

  @override
  String get saveCaps => 'SAVE';

  @override
  String get units => 'Units';

  @override
  String get enduranceRuns => 'Endurance runs';

  @override
  String get audioCues => 'Audio cues';

  @override
  String get audioCuesSubtitle => 'Time and pace every kilometre';

  @override
  String get autoPause => 'Auto-pause';

  @override
  String get autoPauseSubtitle => 'Pause when you stop moving';

  @override
  String get keepScreenOn => 'Keep screen on';

  @override
  String get keepScreenOnSubtitle => 'While the live run screen is open';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get appliesNextRun => 'Run settings apply from the next run.';

  @override
  String get runWasDeleted => 'This run was deleted.';

  @override
  String get exportGpx => 'Export GPX';

  @override
  String get noGpsToExport => 'This run has no GPS points to export.';

  @override
  String get editNote => 'Edit note';

  @override
  String get note => 'Note';

  @override
  String get noteHint => 'Track, wind, shoes, how it felt…';

  @override
  String get addNote => 'Add a note';

  @override
  String targetTime(int meters) {
    return '$meters m time';
  }

  @override
  String get noGpsNote =>
      'Recorded without GPS. Speed and distance are not measured, so this run does not count for records.';

  @override
  String get weakGpsNote =>
      'Recorded with a weak GPS signal. Values may be off.';

  @override
  String get speedEvery10m => 'Speed every 10 m';

  @override
  String get splits => 'Splits';

  @override
  String get route => 'Route';

  @override
  String get slow => 'slow';

  @override
  String get fast => 'fast';

  @override
  String get locationNeeded =>
      'Location permission is needed to track the run.';

  @override
  String get noNotificationTitle => 'No notification';

  @override
  String get noNotificationBody =>
      'Without notification permission you can\'t see or control the run from the lock screen. Start anyway?';

  @override
  String get startAnyway => 'START ANYWAY';

  @override
  String get batteryTitle => 'Keep tracking with the screen off';

  @override
  String get batteryBody =>
      'Some phones (Samsung especially) stop apps in the background to save battery. Allow Sprint Tracker to run unrestricted so a run in your pocket is never cut short.';

  @override
  String get allow => 'ALLOW';

  @override
  String get notNow => 'Not now';

  @override
  String get couldNotStart => 'Could not start tracking. Try again.';

  @override
  String get runDiscardedNoGps => 'Run discarded: no GPS fix was recorded.';

  @override
  String get readyTitle => 'Ready when you are';

  @override
  String get readyBody =>
      'Put the phone in your pocket. Distance, time and pace stay in the notification, and you can pause from the lock screen.';

  @override
  String get startRun => 'START RUN';

  @override
  String get autoPausedCaps => 'AUTO-PAUSED';

  @override
  String get pausedCaps => 'PAUSED';

  @override
  String get resumesWhenRunning => 'Resumes when you start running';

  @override
  String liveFooter(String elapsed, int climb, int fixes) {
    return 'Elapsed $elapsed · Climb $climb m · $fixes GPS fixes · swipe left for the map';
  }

  @override
  String get resumeCaps => 'RESUME';

  @override
  String get holdToFinish => 'HOLD TO FINISH';

  @override
  String get pauseCaps => 'PAUSE';

  @override
  String get waitingForPoints => 'Waiting for the first GPS points…';

  @override
  String get followMe => 'Follow me';

  @override
  String get sprintTitle => '100 m Sprint';

  @override
  String get issuePermissionTitle => 'Location permission needed';

  @override
  String get issuePermissionBody =>
      'Allow precise location so speed and distance can be measured.';

  @override
  String get issueDisabledTitle => 'Location is turned off';

  @override
  String get issueDisabledBody =>
      'Turn on location (GPS) in the system settings to start.';

  @override
  String get issueNoFixTitle => 'No GPS signal';

  @override
  String issueNoFixBody(int seconds) {
    return 'No satellite fix after $seconds s. Move outside, away from buildings. The timer will run, but speed and distance will stay at zero.';
  }

  @override
  String get issueWeakTitle => 'Weak GPS signal';

  @override
  String issueWeakBody(String meters) {
    return 'Accuracy is only ±$meters m. Results may be off by several metres.';
  }

  @override
  String get issueLostTitle => 'GPS signal lost';

  @override
  String get issueLostBody => 'Speed fades out until the signal returns.';

  @override
  String get newPr => 'New personal record!';

  @override
  String get stateCalibrating => 'Calibrating GPS';

  @override
  String get stateCalibratingBody =>
      'Stand still outside until the fix settles.';

  @override
  String get stateReady => 'Ready';

  @override
  String get stateReadyBody => 'Take your mark: 3-second countdown.';

  @override
  String get stateSet => 'Set…';

  @override
  String get stateSetBody => 'Hold still.';

  @override
  String get stateGo => 'Go!';

  @override
  String get stateGoBody => 'Stops automatically at the finish line.';

  @override
  String get stateFinished => 'Finished';

  @override
  String get stateSaved => 'Saved to your history.';

  @override
  String get stateInterpolated =>
      'Finish time is interpolated between GPS fixes.';

  @override
  String get startingIn => 'Starting in';

  @override
  String get progress => 'Progress';

  @override
  String metersToGo(int meters) {
    return '$meters m to go';
  }

  @override
  String get telemetry => 'Telemetry';

  @override
  String get tryAgainCaps => 'TRY AGAIN';

  @override
  String get waitingForGps => 'WAITING FOR GPS';

  @override
  String get startSprint => 'START SPRINT';

  @override
  String get cancelCaps => 'CANCEL';

  @override
  String get runAgain => 'RUN AGAIN';
}
