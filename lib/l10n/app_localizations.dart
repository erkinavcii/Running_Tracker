import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sprint Tracker'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @sprint.
  ///
  /// In en, this message translates to:
  /// **'Sprint'**
  String get sprint;

  /// No description provided for @run.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get run;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @pace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get pace;

  /// No description provided for @avgPace.
  ///
  /// In en, this message translates to:
  /// **'Avg pace'**
  String get avgPace;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @avgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Avg speed'**
  String get avgSpeed;

  /// No description provided for @averageSpeed.
  ///
  /// In en, this message translates to:
  /// **'Average speed'**
  String get averageSpeed;

  /// No description provided for @topSpeed.
  ///
  /// In en, this message translates to:
  /// **'Top speed'**
  String get topSpeed;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @elevation.
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get elevation;

  /// No description provided for @movingTime.
  ///
  /// In en, this message translates to:
  /// **'Moving time'**
  String get movingTime;

  /// No description provided for @elapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed'**
  String get elapsed;

  /// No description provided for @kcalApprox.
  ///
  /// In en, this message translates to:
  /// **'≈ {kcal} kcal'**
  String kcalApprox(int kcal);

  /// No description provided for @gpsLost.
  ///
  /// In en, this message translates to:
  /// **'GPS lost'**
  String get gpsLost;

  /// No description provided for @gpsSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get gpsSearching;

  /// No description provided for @gpsNoFix.
  ///
  /// In en, this message translates to:
  /// **'No fix'**
  String get gpsNoFix;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @dbError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the database.\n{error}'**
  String dbError(String error);

  /// No description provided for @unfinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unfinished run found'**
  String get unfinishedTitle;

  /// No description provided for @unfinishedBody.
  ///
  /// In en, this message translates to:
  /// **'Tracking stopped unexpectedly. Continue it, save it as it is, or discard it?'**
  String get unfinishedBody;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @continueRun.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueRun;

  /// No description provided for @tabRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get tabRun;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get tabRecords;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @chooseMode.
  ///
  /// In en, this message translates to:
  /// **'Choose a mode'**
  String get chooseMode;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Raw GNSS Doppler speed, filtered with the accelerometer.'**
  String get homeSubtitle;

  /// No description provided for @sprintSubtitle.
  ///
  /// In en, this message translates to:
  /// **'100 m dash · auto start & finish'**
  String get sprintSubtitle;

  /// No description provided for @endurance.
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get endurance;

  /// No description provided for @enduranceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pocket-friendly · controls in the notification'**
  String get enduranceSubtitle;

  /// No description provided for @tipSky.
  ///
  /// In en, this message translates to:
  /// **'Stand outside with a clear view of the sky.'**
  String get tipSky;

  /// No description provided for @tipHold.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone firmly or use an armband.'**
  String get tipHold;

  /// No description provided for @runPaused.
  ///
  /// In en, this message translates to:
  /// **'Run paused'**
  String get runPaused;

  /// No description provided for @runInProgress.
  ///
  /// In en, this message translates to:
  /// **'Run in progress'**
  String get runInProgress;

  /// No description provided for @runDeleted.
  ///
  /// In en, this message translates to:
  /// **'Run deleted'**
  String get runDeleted;

  /// No description provided for @sprintDeleted.
  ///
  /// In en, this message translates to:
  /// **'Sprint deleted'**
  String get sprintDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @noRunsTitle.
  ///
  /// In en, this message translates to:
  /// **'No runs yet'**
  String get noRunsTitle;

  /// No description provided for @noRunsBody.
  ///
  /// In en, this message translates to:
  /// **'Finished sprints are saved here automatically.'**
  String get noRunsBody;

  /// No description provided for @last8Weeks.
  ///
  /// In en, this message translates to:
  /// **'Last 8 weeks'**
  String get last8Weeks;

  /// No description provided for @swipeToDelete.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to delete.'**
  String get swipeToDelete;

  /// No description provided for @runsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 run} other{{count} runs}}'**
  String runsCount(int count);

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get lastWeek;

  /// No description provided for @topSpeedShort.
  ///
  /// In en, this message translates to:
  /// **'top {speed}'**
  String topSpeedShort(String speed);

  /// No description provided for @prBadge.
  ///
  /// In en, this message translates to:
  /// **'PR'**
  String get prBadge;

  /// No description provided for @noRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecordsTitle;

  /// No description provided for @noRecordsBody.
  ///
  /// In en, this message translates to:
  /// **'Finish a sprint with GPS to set your first 100 m time and top speed.'**
  String get noRecordsBody;

  /// No description provided for @notSetYet.
  ///
  /// In en, this message translates to:
  /// **'Not set yet'**
  String get notSetYet;

  /// No description provided for @improvedTimes.
  ///
  /// In en, this message translates to:
  /// **'improved {count}×'**
  String improvedTimes(int count);

  /// No description provided for @effortSprint100.
  ///
  /// In en, this message translates to:
  /// **'100 m sprint'**
  String get effortSprint100;

  /// No description provided for @effortHalf.
  ///
  /// In en, this message translates to:
  /// **'Half marathon'**
  String get effortHalf;

  /// No description provided for @effortLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest run'**
  String get effortLongest;

  /// No description provided for @enterWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your weight'**
  String get enterWeight;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get enterNumber;

  /// No description provided for @weightRange.
  ///
  /// In en, this message translates to:
  /// **'Between 30 and 250 kg'**
  String get weightRange;

  /// No description provided for @wholeCm.
  ///
  /// In en, this message translates to:
  /// **'Whole centimetres'**
  String get wholeCm;

  /// No description provided for @heightRange.
  ///
  /// In en, this message translates to:
  /// **'Between 100 and 250 cm'**
  String get heightRange;

  /// No description provided for @enterYear.
  ///
  /// In en, this message translates to:
  /// **'Enter a year'**
  String get enterYear;

  /// No description provided for @yearRange.
  ///
  /// In en, this message translates to:
  /// **'Between 1920 and {max}'**
  String yearRange(int max);

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nSprint Tracker'**
  String get welcome;

  /// No description provided for @onboardingBody.
  ///
  /// In en, this message translates to:
  /// **'What is your weight? It is only used to estimate calories and never leaves this phone. You can change it later in Profile.'**
  String get onboardingBody;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @birthYear.
  ///
  /// In en, this message translates to:
  /// **'Birth year'**
  String get birthYear;

  /// No description provided for @continueCaps.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueCaps;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used to estimate calories. Stays on this phone.'**
  String get profileSubtitle;

  /// No description provided for @body.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @saveCaps.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get saveCaps;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @enduranceRuns.
  ///
  /// In en, this message translates to:
  /// **'Endurance runs'**
  String get enduranceRuns;

  /// No description provided for @audioCues.
  ///
  /// In en, this message translates to:
  /// **'Audio cues'**
  String get audioCues;

  /// No description provided for @audioCuesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time and pace every kilometre'**
  String get audioCuesSubtitle;

  /// No description provided for @autoPause.
  ///
  /// In en, this message translates to:
  /// **'Auto-pause'**
  String get autoPause;

  /// No description provided for @autoPauseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pause when you stop moving'**
  String get autoPauseSubtitle;

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get keepScreenOn;

  /// No description provided for @keepScreenOnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'While the live run screen is open'**
  String get keepScreenOnSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @appliesNextRun.
  ///
  /// In en, this message translates to:
  /// **'Run settings apply from the next run.'**
  String get appliesNextRun;

  /// No description provided for @runWasDeleted.
  ///
  /// In en, this message translates to:
  /// **'This run was deleted.'**
  String get runWasDeleted;

  /// No description provided for @exportGpx.
  ///
  /// In en, this message translates to:
  /// **'Export GPX'**
  String get exportGpx;

  /// No description provided for @noGpsToExport.
  ///
  /// In en, this message translates to:
  /// **'This run has no GPS points to export.'**
  String get noGpsToExport;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Track, wind, shoes, how it felt…'**
  String get noteHint;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get addNote;

  /// No description provided for @targetTime.
  ///
  /// In en, this message translates to:
  /// **'{meters} m time'**
  String targetTime(int meters);

  /// No description provided for @noGpsNote.
  ///
  /// In en, this message translates to:
  /// **'Recorded without GPS. Speed and distance are not measured, so this run does not count for records.'**
  String get noGpsNote;

  /// No description provided for @weakGpsNote.
  ///
  /// In en, this message translates to:
  /// **'Recorded with a weak GPS signal. Values may be off.'**
  String get weakGpsNote;

  /// No description provided for @speedEvery10m.
  ///
  /// In en, this message translates to:
  /// **'Speed every 10 m'**
  String get speedEvery10m;

  /// No description provided for @splits.
  ///
  /// In en, this message translates to:
  /// **'Splits'**
  String get splits;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @slow.
  ///
  /// In en, this message translates to:
  /// **'slow'**
  String get slow;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'fast'**
  String get fast;

  /// No description provided for @locationNeeded.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to track the run.'**
  String get locationNeeded;

  /// No description provided for @noNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'No notification'**
  String get noNotificationTitle;

  /// No description provided for @noNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Without notification permission you can\'t see or control the run from the lock screen. Start anyway?'**
  String get noNotificationBody;

  /// No description provided for @startAnyway.
  ///
  /// In en, this message translates to:
  /// **'START ANYWAY'**
  String get startAnyway;

  /// No description provided for @batteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep tracking with the screen off'**
  String get batteryTitle;

  /// No description provided for @batteryBody.
  ///
  /// In en, this message translates to:
  /// **'Some phones (Samsung especially) stop apps in the background to save battery. Allow Sprint Tracker to run unrestricted so a run in your pocket is never cut short.'**
  String get batteryBody;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'ALLOW'**
  String get allow;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @couldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Could not start tracking. Try again.'**
  String get couldNotStart;

  /// No description provided for @runDiscardedNoGps.
  ///
  /// In en, this message translates to:
  /// **'Run discarded: no GPS fix was recorded.'**
  String get runDiscardedNoGps;

  /// No description provided for @readyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready when you are'**
  String get readyTitle;

  /// No description provided for @readyBody.
  ///
  /// In en, this message translates to:
  /// **'Put the phone in your pocket. Distance, time and pace stay in the notification, and you can pause from the lock screen.'**
  String get readyBody;

  /// No description provided for @startRun.
  ///
  /// In en, this message translates to:
  /// **'START RUN'**
  String get startRun;

  /// No description provided for @autoPausedCaps.
  ///
  /// In en, this message translates to:
  /// **'AUTO-PAUSED'**
  String get autoPausedCaps;

  /// No description provided for @pausedCaps.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get pausedCaps;

  /// No description provided for @resumesWhenRunning.
  ///
  /// In en, this message translates to:
  /// **'Resumes when you start running'**
  String get resumesWhenRunning;

  /// No description provided for @liveFooter.
  ///
  /// In en, this message translates to:
  /// **'Elapsed {elapsed} · Climb {climb} m · {fixes} GPS fixes · swipe left for the map'**
  String liveFooter(String elapsed, int climb, int fixes);

  /// No description provided for @resumeCaps.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resumeCaps;

  /// No description provided for @holdToFinish.
  ///
  /// In en, this message translates to:
  /// **'HOLD TO FINISH'**
  String get holdToFinish;

  /// No description provided for @pauseCaps.
  ///
  /// In en, this message translates to:
  /// **'PAUSE'**
  String get pauseCaps;

  /// No description provided for @waitingForPoints.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the first GPS points…'**
  String get waitingForPoints;

  /// No description provided for @followMe.
  ///
  /// In en, this message translates to:
  /// **'Follow me'**
  String get followMe;

  /// No description provided for @sprintTitle.
  ///
  /// In en, this message translates to:
  /// **'100 m Sprint'**
  String get sprintTitle;

  /// No description provided for @issuePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission needed'**
  String get issuePermissionTitle;

  /// No description provided for @issuePermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow precise location so speed and distance can be measured.'**
  String get issuePermissionBody;

  /// No description provided for @issueDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off'**
  String get issueDisabledTitle;

  /// No description provided for @issueDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on location (GPS) in the system settings to start.'**
  String get issueDisabledBody;

  /// No description provided for @issueNoFixTitle.
  ///
  /// In en, this message translates to:
  /// **'No GPS signal'**
  String get issueNoFixTitle;

  /// No description provided for @issueNoFixBody.
  ///
  /// In en, this message translates to:
  /// **'No satellite fix after {seconds} s. Move outside, away from buildings. The timer will run, but speed and distance will stay at zero.'**
  String issueNoFixBody(int seconds);

  /// No description provided for @issueWeakTitle.
  ///
  /// In en, this message translates to:
  /// **'Weak GPS signal'**
  String get issueWeakTitle;

  /// No description provided for @issueWeakBody.
  ///
  /// In en, this message translates to:
  /// **'Accuracy is only ±{meters} m. Results may be off by several metres.'**
  String issueWeakBody(String meters);

  /// No description provided for @issueLostTitle.
  ///
  /// In en, this message translates to:
  /// **'GPS signal lost'**
  String get issueLostTitle;

  /// No description provided for @issueLostBody.
  ///
  /// In en, this message translates to:
  /// **'Speed fades out until the signal returns.'**
  String get issueLostBody;

  /// No description provided for @newPr.
  ///
  /// In en, this message translates to:
  /// **'New personal record!'**
  String get newPr;

  /// No description provided for @stateCalibrating.
  ///
  /// In en, this message translates to:
  /// **'Calibrating GPS'**
  String get stateCalibrating;

  /// No description provided for @stateCalibratingBody.
  ///
  /// In en, this message translates to:
  /// **'Stand still outside until the fix settles.'**
  String get stateCalibratingBody;

  /// No description provided for @stateReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get stateReady;

  /// No description provided for @stateReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Take your mark: 3-second countdown.'**
  String get stateReadyBody;

  /// No description provided for @stateSet.
  ///
  /// In en, this message translates to:
  /// **'Set…'**
  String get stateSet;

  /// No description provided for @stateSetBody.
  ///
  /// In en, this message translates to:
  /// **'Hold still.'**
  String get stateSetBody;

  /// No description provided for @stateGo.
  ///
  /// In en, this message translates to:
  /// **'Go!'**
  String get stateGo;

  /// No description provided for @stateGoBody.
  ///
  /// In en, this message translates to:
  /// **'Stops automatically at the finish line.'**
  String get stateGoBody;

  /// No description provided for @stateFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get stateFinished;

  /// No description provided for @stateSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to your history.'**
  String get stateSaved;

  /// No description provided for @stateInterpolated.
  ///
  /// In en, this message translates to:
  /// **'Finish time is interpolated between GPS fixes.'**
  String get stateInterpolated;

  /// No description provided for @startingIn.
  ///
  /// In en, this message translates to:
  /// **'Starting in'**
  String get startingIn;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @metersToGo.
  ///
  /// In en, this message translates to:
  /// **'{meters} m to go'**
  String metersToGo(int meters);

  /// No description provided for @telemetry.
  ///
  /// In en, this message translates to:
  /// **'Telemetry'**
  String get telemetry;

  /// No description provided for @tryAgainCaps.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get tryAgainCaps;

  /// No description provided for @waitingForGps.
  ///
  /// In en, this message translates to:
  /// **'WAITING FOR GPS'**
  String get waitingForGps;

  /// No description provided for @startSprint.
  ///
  /// In en, this message translates to:
  /// **'START SPRINT'**
  String get startSprint;

  /// No description provided for @cancelCaps.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelCaps;

  /// No description provided for @runAgain.
  ///
  /// In en, this message translates to:
  /// **'RUN AGAIN'**
  String get runAgain;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
