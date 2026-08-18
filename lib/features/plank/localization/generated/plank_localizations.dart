import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'plank_localizations_ar.dart';
import 'plank_localizations_de.dart';
import 'plank_localizations_en.dart';
import 'plank_localizations_es.dart';
import 'plank_localizations_fr.dart';
import 'plank_localizations_ja.dart';
import 'plank_localizations_ko.dart';
import 'plank_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of PlankLocalizations
/// returned by `PlankLocalizations.of(context)`.
///
/// Applications need to include `PlankLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/plank_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: PlankLocalizations.localizationsDelegates,
///   supportedLocales: PlankLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the PlankLocalizations.supportedLocales
/// property.
abstract class PlankLocalizations {
  PlankLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static PlankLocalizations of(BuildContext context) {
    return Localizations.of<PlankLocalizations>(context, PlankLocalizations)!;
  }

  static const LocalizationsDelegate<PlankLocalizations> delegate =
      _PlankLocalizationsDelegate();

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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MotionFit - Plank'**
  String get appName;

  /// No description provided for @navSquat.
  ///
  /// In en, this message translates to:
  /// **'Plank'**
  String get navSquat;

  /// No description provided for @navChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get navChallenge;

  /// No description provided for @navRecords.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navRecords;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @challengeTitle.
  ///
  /// In en, this message translates to:
  /// **'My plank challenge'**
  String get challengeTitle;

  /// No description provided for @challengeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a challenge that fits your goal and keep moving consistently.'**
  String get challengeSubtitle;

  /// No description provided for @challengeChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a challenge'**
  String get challengeChooseTitle;

  /// No description provided for @challengeSevenDayTitle.
  ///
  /// In en, this message translates to:
  /// **'7-day starter challenge'**
  String get challengeSevenDayTitle;

  /// No description provided for @challengeSevenDayDescription.
  ///
  /// In en, this message translates to:
  /// **'A step-by-step program for beginners'**
  String get challengeSevenDayDescription;

  /// No description provided for @challengeSevenDaySummary.
  ///
  /// In en, this message translates to:
  /// **'Follow a level-based goal that increases each day for 7 days.'**
  String get challengeSevenDaySummary;

  /// No description provided for @challengeSevenDayEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Continue every day for 7 days without recovery days'**
  String get challengeSevenDayEveryDay;

  /// No description provided for @challengeDurationDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String challengeDurationDays(int days);

  /// No description provided for @challengeLevelGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals tailored to your level'**
  String get challengeLevelGoals;

  /// No description provided for @challengeRecoveryIncluded.
  ///
  /// In en, this message translates to:
  /// **'Recovery days included'**
  String get challengeRecoveryIncluded;

  /// No description provided for @challengeDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily second goals'**
  String get challengeDailyGoal;

  /// No description provided for @challengeSevenDayStart.
  ///
  /// In en, this message translates to:
  /// **'Start 7-day challenge'**
  String get challengeSevenDayStart;

  /// No description provided for @challengeSevenDaySettings.
  ///
  /// In en, this message translates to:
  /// **'Set your 7-day goal'**
  String get challengeSevenDaySettings;

  /// No description provided for @challengeSevenDaySettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose day 1. The goal increases by 5 seconds each day.'**
  String get challengeSevenDaySettingsDescription;

  /// No description provided for @challengeFirstDayGoal.
  ///
  /// In en, this message translates to:
  /// **'Day 1 target seconds'**
  String get challengeFirstDayGoal;

  /// No description provided for @challengeSevenDayPreview.
  ///
  /// In en, this message translates to:
  /// **'Day 1: {first} seconds → Day 7: {last} seconds'**
  String challengeSevenDayPreview(int first, int last);

  /// No description provided for @challengeWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'3 times a week challenge'**
  String get challengeWeeklyTitle;

  /// No description provided for @challengeWeeklyDescription.
  ///
  /// In en, this message translates to:
  /// **'A habit challenge for people who do not want to work out every day'**
  String get challengeWeeklyDescription;

  /// No description provided for @challengeWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Work out 3 selected days each week for 4 weeks.'**
  String get challengeWeeklySummary;

  /// No description provided for @challengeDurationWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks'**
  String challengeDurationWeeks(int weeks);

  /// No description provided for @challengeThreePerWeek.
  ///
  /// In en, this message translates to:
  /// **'3 workouts each week'**
  String get challengeThreePerWeek;

  /// No description provided for @challengeChooseWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Choose 3 workout days'**
  String get challengeChooseWeekdays;

  /// No description provided for @challengeWorkoutDaysCount.
  ///
  /// In en, this message translates to:
  /// **'Progress is based on workout days'**
  String get challengeWorkoutDaysCount;

  /// No description provided for @challengeWeeklyStart.
  ///
  /// In en, this message translates to:
  /// **'Start weekly challenge'**
  String get challengeWeeklyStart;

  /// No description provided for @challengeCumulativeTitle.
  ///
  /// In en, this message translates to:
  /// **'Total seconds challenge'**
  String get challengeCumulativeTitle;

  /// No description provided for @challengeCumulativeDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach a total plank target on a schedule that works for you'**
  String get challengeCumulativeDescription;

  /// No description provided for @challengeCumulativeSummary.
  ///
  /// In en, this message translates to:
  /// **'Choose a duration and total target; rest days keep your progress.'**
  String get challengeCumulativeSummary;

  /// No description provided for @challengePreset200.
  ///
  /// In en, this message translates to:
  /// **'200 plank seconds in 7 days'**
  String get challengePreset200;

  /// No description provided for @challengePreset500.
  ///
  /// In en, this message translates to:
  /// **'500 plank seconds in 14 days'**
  String get challengePreset500;

  /// No description provided for @challengeCustomGoal.
  ///
  /// In en, this message translates to:
  /// **'Choose your own duration and goal'**
  String get challengeCustomGoal;

  /// No description provided for @challengeRestWithoutReset.
  ///
  /// In en, this message translates to:
  /// **'Rest days do not reset progress'**
  String get challengeRestWithoutReset;

  /// No description provided for @challengeCumulativeStart.
  ///
  /// In en, this message translates to:
  /// **'Start total seconds challenge'**
  String get challengeCumulativeStart;

  /// No description provided for @challengeHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Past challenges'**
  String get challengeHistoryTitle;

  /// No description provided for @challengeHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your completed and ended challenges will appear here.'**
  String get challengeHistoryEmpty;

  /// No description provided for @challengeRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get challengeRecommended;

  /// No description provided for @challengeRecommendationFromWorkout.
  ///
  /// In en, this message translates to:
  /// **'Recommended from your first workout of {reps} seconds.'**
  String challengeRecommendationFromWorkout(int reps);

  /// No description provided for @challengeRecommendationDefault.
  ///
  /// In en, this message translates to:
  /// **'A gentle 7-day start is recommended for your first challenge.'**
  String get challengeRecommendationDefault;

  /// No description provided for @challengeActive.
  ///
  /// In en, this message translates to:
  /// **'Active challenge'**
  String get challengeActive;

  /// No description provided for @challengeNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get challengeNext;

  /// No description provided for @challengeDayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String challengeDayNumber(int day);

  /// No description provided for @challengeRecoveryDay.
  ///
  /// In en, this message translates to:
  /// **'Recovery day'**
  String get challengeRecoveryDay;

  /// No description provided for @challengeTodayProgress.
  ///
  /// In en, this message translates to:
  /// **'Today {current} / {target} seconds'**
  String challengeTodayProgress(int current, int target);

  /// No description provided for @challengeRestToday.
  ///
  /// In en, this message translates to:
  /// **'Take time to recover today.'**
  String get challengeRestToday;

  /// No description provided for @challengeTodayCompleted.
  ///
  /// In en, this message translates to:
  /// **'Today’s goal is complete · Continue tomorrow'**
  String get challengeTodayCompleted;

  /// No description provided for @challengeRepsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{reps} seconds to go'**
  String challengeRepsRemaining(int reps);

  /// No description provided for @challengeWeekNumber.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String challengeWeekNumber(int week);

  /// No description provided for @challengeThisWeekProgress.
  ///
  /// In en, this message translates to:
  /// **'This week {current} / {target} workouts'**
  String challengeThisWeekProgress(int current, int target);

  /// No description provided for @challengeOverallDays.
  ///
  /// In en, this message translates to:
  /// **'Overall {current} / {target} days'**
  String challengeOverallDays(int current, int target);

  /// No description provided for @challengeRepsProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target} seconds'**
  String challengeRepsProgress(int current, int target);

  /// No description provided for @challengeDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String challengeDaysRemaining(int days);

  /// No description provided for @challengeTodaySuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested for today: {reps} seconds'**
  String challengeTodaySuggested(int reps);

  /// No description provided for @challengePercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String challengePercent(int percent);

  /// No description provided for @challengeSquatStart.
  ///
  /// In en, this message translates to:
  /// **'Start plank'**
  String get challengeSquatStart;

  /// No description provided for @challengeTodayWorkoutStart.
  ///
  /// In en, this message translates to:
  /// **'Start today’s workout'**
  String get challengeTodayWorkoutStart;

  /// No description provided for @challengeViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get challengeViewDetails;

  /// No description provided for @challengeRestart.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get challengeRestart;

  /// No description provided for @challengeDeleteHistory.
  ///
  /// In en, this message translates to:
  /// **'Delete from history'**
  String get challengeDeleteHistory;

  /// No description provided for @challengeCumulativeSettings.
  ///
  /// In en, this message translates to:
  /// **'Set your total goal'**
  String get challengeCumulativeSettings;

  /// No description provided for @challengeDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get challengeDurationLabel;

  /// No description provided for @challengeGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Target seconds'**
  String get challengeGoalLabel;

  /// No description provided for @challengeNotFound.
  ///
  /// In en, this message translates to:
  /// **'This challenge is no longer available.'**
  String get challengeNotFound;

  /// No description provided for @challengePeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get challengePeriod;

  /// No description provided for @challengeStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get challengeStatus;

  /// No description provided for @challengeTotalReps.
  ///
  /// In en, this message translates to:
  /// **'Total plank seconds'**
  String get challengeTotalReps;

  /// No description provided for @challengeWorkoutDays.
  ///
  /// In en, this message translates to:
  /// **'Workout days'**
  String get challengeWorkoutDays;

  /// No description provided for @challengeDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String challengeDaysCount(int days);

  /// No description provided for @challengeTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total workout time'**
  String get challengeTotalTime;

  /// No description provided for @challengeSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule and progress'**
  String get challengeSchedule;

  /// No description provided for @challengeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Challenge reminders'**
  String get challengeNotifications;

  /// No description provided for @challengeNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep reminder preferences with this challenge.'**
  String get challengeNotificationsDescription;

  /// No description provided for @challengeReminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your plank challenge is waiting'**
  String get challengeReminderNotificationTitle;

  /// No description provided for @challengeReminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Open MotionFit and make progress toward today’s challenge goal.'**
  String get challengeReminderNotificationBody;

  /// No description provided for @challengeSelectedWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Selected workout days'**
  String get challengeSelectedWeekdays;

  /// No description provided for @challengeNoProgressYet.
  ///
  /// In en, this message translates to:
  /// **'No challenge workouts yet.'**
  String get challengeNoProgressYet;

  /// No description provided for @challengeCancel.
  ///
  /// In en, this message translates to:
  /// **'End challenge'**
  String get challengeCancel;

  /// No description provided for @challengeCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'End this challenge?'**
  String get challengeCancelTitle;

  /// No description provided for @challengeCancelDescription.
  ///
  /// In en, this message translates to:
  /// **'Your workout records will stay saved. This challenge will move to history.'**
  String get challengeCancelDescription;

  /// No description provided for @challengeStatusActive.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get challengeStatusActive;

  /// No description provided for @challengeStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get challengeStatusCompleted;

  /// No description provided for @challengeStatusEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get challengeStatusEnded;

  /// No description provided for @challengeStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get challengeStatusCancelled;

  /// No description provided for @challengeProgressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your challenge progress has been updated.'**
  String get challengeProgressUpdated;

  /// No description provided for @challengeCheck.
  ///
  /// In en, this message translates to:
  /// **'View challenge'**
  String get challengeCheck;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get commonStart;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get commonOn;

  /// No description provided for @commonOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get commonOff;

  /// No description provided for @commonEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get commonEnabled;

  /// No description provided for @commonDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get commonDisabled;

  /// No description provided for @commonNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get commonNotAvailable;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @unitSets.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {0 sets} =1 {1 set} other {{count} sets}}'**
  String unitSets(int count);

  /// No description provided for @unitReps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {0 seconds} =1 {1 second} other {{count} seconds}}'**
  String unitReps(int count);

  /// No description provided for @unitSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {0 seconds} =1 {1 second} other {{count} seconds}}'**
  String unitSeconds(int count);

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {0 minutes} =1 {1 minute} other {{count} minutes}}'**
  String unitMinutes(int count);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min {seconds} sec'**
  String durationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Ready to move?'**
  String get homeGreeting;

  /// No description provided for @homeTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s record'**
  String get homeTodayTitle;

  /// No description provided for @homeTodayNoWorkout.
  ///
  /// In en, this message translates to:
  /// **'No plank seconds yet today. A short set is a great start.'**
  String get homeTodayNoWorkout;

  /// No description provided for @homeTodaySummary.
  ///
  /// In en, this message translates to:
  /// **'{reps} plank seconds across {sets}'**
  String homeTodaySummary(int reps, int sets);

  /// No description provided for @homeViewResult.
  ///
  /// In en, this message translates to:
  /// **'View result'**
  String get homeViewResult;

  /// No description provided for @homeTodaySets.
  ///
  /// In en, this message translates to:
  /// **'Sets today'**
  String get homeTodaySets;

  /// No description provided for @homeTodayReps.
  ///
  /// In en, this message translates to:
  /// **'Seconds today'**
  String get homeTodayReps;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String streakDays(int days);

  /// No description provided for @homeWorkoutSetup.
  ///
  /// In en, this message translates to:
  /// **'Next workout'**
  String get homeWorkoutSetup;

  /// No description provided for @homeSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get homeSetsLabel;

  /// No description provided for @homeRepsPerSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Seconds per set'**
  String get homeRepsPerSetLabel;

  /// No description provided for @homeRestTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest time'**
  String get homeRestTimeLabel;

  /// No description provided for @homeDirectInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get homeDirectInputHint;

  /// No description provided for @homeStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get homeStartWorkout;

  /// No description provided for @homeLastSettingsRestored.
  ///
  /// In en, this message translates to:
  /// **'Your last workout settings are ready.'**
  String get homeLastSettingsRestored;

  /// No description provided for @validationNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a number.'**
  String get validationNumberRequired;

  /// No description provided for @validationRange.
  ///
  /// In en, this message translates to:
  /// **'Choose a value from {min} to {max}.'**
  String validationRange(num min, num max);

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your camera'**
  String get guideTitle;

  /// No description provided for @guideLandscapeTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn your phone sideways'**
  String get guideLandscapeTitle;

  /// No description provided for @guideLandscapeBody.
  ///
  /// In en, this message translates to:
  /// **'Plank tracking uses landscape mode. Place your phone horizontally before you get into position.'**
  String get guideLandscapeBody;

  /// No description provided for @countdownLandscapePrompt.
  ///
  /// In en, this message translates to:
  /// **'Keep your phone sideways in landscape mode'**
  String get countdownLandscapePrompt;

  /// No description provided for @guideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your shoulders, hips, knees, and ankles visible so MotionFit can measure your plank.'**
  String get guideSubtitle;

  /// No description provided for @guideWholeBody.
  ///
  /// In en, this message translates to:
  /// **'Place the camera to the side and keep your full body visible.'**
  String get guideWholeBody;

  /// No description provided for @guideStableCamera.
  ///
  /// In en, this message translates to:
  /// **'Place your phone somewhere stable.'**
  String get guideStableCamera;

  /// No description provided for @guideOnePerson.
  ///
  /// In en, this message translates to:
  /// **'Make sure only one person is in frame.'**
  String get guideOnePerson;

  /// No description provided for @guideCameraAngle.
  ///
  /// In en, this message translates to:
  /// **'Use a side or slightly angled side view.'**
  String get guideCameraAngle;

  /// No description provided for @guideLighting.
  ///
  /// In en, this message translates to:
  /// **'Avoid dark rooms and strong backlighting.'**
  String get guideLighting;

  /// No description provided for @guidePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Video stays on this device and is saved only when Hold Video Review is on.'**
  String get guidePrivacy;

  /// No description provided for @guideContinue.
  ///
  /// In en, this message translates to:
  /// **'I’m in position'**
  String get guideContinue;

  /// No description provided for @permissionCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed'**
  String get permissionCameraTitle;

  /// No description provided for @permissionCameraBody.
  ///
  /// In en, this message translates to:
  /// **'MotionFit uses the camera to count plank seconds. Video is saved only on this device when you turn on Hold Video Review.'**
  String get permissionCameraBody;

  /// No description provided for @permissionCameraRequest.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get permissionCameraRequest;

  /// No description provided for @permissionCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access was denied. You can still view records and settings.'**
  String get permissionCameraDenied;

  /// No description provided for @permissionCameraPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access in system settings to start a workout.'**
  String get permissionCameraPermanentlyDenied;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permissionOpenSettings;

  /// No description provided for @permissionNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow workout reminders?'**
  String get permissionNotificationTitle;

  /// No description provided for @permissionNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are used only for reminders you schedule.'**
  String get permissionNotificationBody;

  /// No description provided for @permissionNotificationRequest.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get permissionNotificationRequest;

  /// No description provided for @permissionNotificationDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off. Turn them on in system settings to receive reminders.'**
  String get permissionNotificationDenied;

  /// No description provided for @countdownGetReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get countdownGetReady;

  /// No description provided for @countdownBeginsIn.
  ///
  /// In en, this message translates to:
  /// **'Starting in {seconds}'**
  String countdownBeginsIn(int seconds);

  /// No description provided for @calibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Finding your plank position'**
  String get calibrationTitle;

  /// No description provided for @calibrationBody.
  ///
  /// In en, this message translates to:
  /// **'Hold a straight plank with your full body in view.'**
  String get calibrationBody;

  /// No description provided for @calibrationStayStill.
  ///
  /// In en, this message translates to:
  /// **'Keep your body straight for a moment'**
  String get calibrationStayStill;

  /// No description provided for @calibrationComplete.
  ///
  /// In en, this message translates to:
  /// **'All set'**
  String get calibrationComplete;

  /// No description provided for @calibrationFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not detect a clear plank position.'**
  String get calibrationFailed;

  /// No description provided for @calibrationRetry.
  ///
  /// In en, this message translates to:
  /// **'Recalibrate'**
  String get calibrationRetry;

  /// No description provided for @workoutSetProgress.
  ///
  /// In en, this message translates to:
  /// **'Set {current} of {total}'**
  String workoutSetProgress(int current, int total);

  /// No description provided for @workoutRepProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {target}'**
  String workoutRepProgress(int current, int target);

  /// No description provided for @workoutTotalReps.
  ///
  /// In en, this message translates to:
  /// **'Total {count}'**
  String workoutTotalReps(int count);

  /// No description provided for @workoutElapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed time'**
  String get workoutElapsed;

  /// No description provided for @workoutPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get workoutPause;

  /// No description provided for @workoutResume.
  ///
  /// In en, this message translates to:
  /// **'Resume workout'**
  String get workoutResume;

  /// No description provided for @workoutEnd.
  ///
  /// In en, this message translates to:
  /// **'Stop for now'**
  String get workoutEnd;

  /// No description provided for @workoutBackToSetup.
  ///
  /// In en, this message translates to:
  /// **'Back to setup'**
  String get workoutBackToSetup;

  /// No description provided for @workoutEndDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop for now?'**
  String get workoutEndDialogTitle;

  /// No description provided for @workoutEndDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be saved so you can continue from the home screen.'**
  String get workoutEndDialogBody;

  /// No description provided for @workoutEndDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Save and leave'**
  String get workoutEndDialogConfirm;

  /// No description provided for @workoutPauseReasonBackground.
  ///
  /// In en, this message translates to:
  /// **'Workout paused while the app was in the background.'**
  String get workoutPauseReasonBackground;

  /// No description provided for @workoutPauseReasonInterruption.
  ///
  /// In en, this message translates to:
  /// **'Workout paused after a system interruption.'**
  String get workoutPauseReasonInterruption;

  /// No description provided for @workoutStateReady.
  ///
  /// In en, this message translates to:
  /// **'Get into position'**
  String get workoutStateReady;

  /// No description provided for @workoutStateDescending.
  ///
  /// In en, this message translates to:
  /// **'Checking alignment'**
  String get workoutStateDescending;

  /// No description provided for @workoutStateBottom.
  ///
  /// In en, this message translates to:
  /// **'Hold steady'**
  String get workoutStateBottom;

  /// No description provided for @workoutStateAscending.
  ///
  /// In en, this message translates to:
  /// **'Realign your body'**
  String get workoutStateAscending;

  /// No description provided for @workoutStateCompleted.
  ///
  /// In en, this message translates to:
  /// **'One second held'**
  String get workoutStateCompleted;

  /// No description provided for @workoutStateTrackingLost.
  ///
  /// In en, this message translates to:
  /// **'Still detecting'**
  String get workoutStateTrackingLost;

  /// No description provided for @workoutStatePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get workoutStatePaused;

  /// No description provided for @workoutTrackingGood.
  ///
  /// In en, this message translates to:
  /// **'Joints detected'**
  String get workoutTrackingGood;

  /// No description provided for @workoutCameraSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get workoutCameraSwitch;

  /// No description provided for @workoutSkeletonToggle.
  ///
  /// In en, this message translates to:
  /// **'Show pose guide'**
  String get workoutSkeletonToggle;

  /// No description provided for @restTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get restTitle;

  /// No description provided for @restNextSet.
  ///
  /// In en, this message translates to:
  /// **'Next: set {set} of {total}'**
  String restNextSet(int set, int total);

  /// No description provided for @restCompletedSets.
  ///
  /// In en, this message translates to:
  /// **'Completed sets'**
  String get restCompletedSets;

  /// No description provided for @restTotalReps.
  ///
  /// In en, this message translates to:
  /// **'Plank time so far'**
  String get restTotalReps;

  /// No description provided for @restSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip rest'**
  String get restSkip;

  /// No description provided for @restAddFifteenSeconds.
  ///
  /// In en, this message translates to:
  /// **'Add 15 seconds'**
  String get restAddFifteenSeconds;

  /// No description provided for @restEndWorkout.
  ///
  /// In en, this message translates to:
  /// **'Stop for now'**
  String get restEndWorkout;

  /// No description provided for @restAlmostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost ready'**
  String get restAlmostDone;

  /// No description provided for @restReady.
  ///
  /// In en, this message translates to:
  /// **'Time for the next set'**
  String get restReady;

  /// No description provided for @completeTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout complete'**
  String get completeTitle;

  /// No description provided for @completeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Strong work. Here is your session at a glance.'**
  String get completeSubtitle;

  /// No description provided for @workoutInterruptedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review what you recorded before ending early.'**
  String get workoutInterruptedSubtitle;

  /// No description provided for @completeTotalReps.
  ///
  /// In en, this message translates to:
  /// **'Total plank seconds'**
  String get completeTotalReps;

  /// No description provided for @completeCompletedSets.
  ///
  /// In en, this message translates to:
  /// **'Sets completed'**
  String get completeCompletedSets;

  /// No description provided for @completeActiveTime.
  ///
  /// In en, this message translates to:
  /// **'Active time'**
  String get completeActiveTime;

  /// No description provided for @completeRestTime.
  ///
  /// In en, this message translates to:
  /// **'Rest time'**
  String get completeRestTime;

  /// No description provided for @completeTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get completeTotalTime;

  /// No description provided for @completeAverageRepTime.
  ///
  /// In en, this message translates to:
  /// **'Average hold checkpoint'**
  String get completeAverageRepTime;

  /// No description provided for @completeFormSummary.
  ///
  /// In en, this message translates to:
  /// **'Form summary'**
  String get completeFormSummary;

  /// No description provided for @todayCoaching.
  ///
  /// In en, this message translates to:
  /// **'Today\'\'s coaching'**
  String get todayCoaching;

  /// No description provided for @coachingIssueFrequency.
  ///
  /// In en, this message translates to:
  /// **'In {count} of {total} seconds,\n{issue}'**
  String coachingIssueFrequency(int total, int count, String issue);

  /// No description provided for @completeTopImprovement.
  ///
  /// In en, this message translates to:
  /// **'Focus for next time'**
  String get completeTopImprovement;

  /// No description provided for @completeStrengths.
  ///
  /// In en, this message translates to:
  /// **'What went well'**
  String get completeStrengths;

  /// No description provided for @completeSaved.
  ///
  /// In en, this message translates to:
  /// **'Workout saved on this device'**
  String get completeSaved;

  /// No description provided for @completeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The workout could not be saved. Try again before leaving.'**
  String get completeSaveFailed;

  /// No description provided for @completeNoFormData.
  ///
  /// In en, this message translates to:
  /// **'There was not enough visible movement for a form summary.'**
  String get completeNoFormData;

  /// No description provided for @completeFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get completeFinish;

  /// No description provided for @postWorkoutReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the momentum going'**
  String get postWorkoutReminderTitle;

  /// No description provided for @postWorkoutReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Would you like a daily reminder at {time}, starting tomorrow?'**
  String postWorkoutReminderBody(String time);

  /// No description provided for @postWorkoutReminderEnable.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get postWorkoutReminderEnable;

  /// No description provided for @postWorkoutReminderLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get postWorkoutReminderLater;

  /// No description provided for @postWorkoutReminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Your reminder is set.'**
  String get postWorkoutReminderEnabled;

  /// No description provided for @recordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get recordsTitle;

  /// No description provided for @recordsWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get recordsWeeklySummary;

  /// No description provided for @recordsWorkoutCount.
  ///
  /// In en, this message translates to:
  /// **'{count} workouts'**
  String recordsWorkoutCount(int count);

  /// No description provided for @recordsAverageForm.
  ///
  /// In en, this message translates to:
  /// **'Average form {score}'**
  String recordsAverageForm(int score);

  /// No description provided for @recordsWorkoutTime.
  ///
  /// In en, this message translates to:
  /// **'Time {time}'**
  String recordsWorkoutTime(String time);

  /// No description provided for @recordsFirstWeek.
  ///
  /// In en, this message translates to:
  /// **'This is your first record this week'**
  String get recordsFirstWeek;

  /// No description provided for @recordsMoreThanLastWeek.
  ///
  /// In en, this message translates to:
  /// **'{count} more seconds than last week'**
  String recordsMoreThanLastWeek(int count);

  /// No description provided for @recordsLessThanLastWeek.
  ///
  /// In en, this message translates to:
  /// **'{count} fewer seconds than last week'**
  String recordsLessThanLastWeek(int count);

  /// No description provided for @recordsSameAsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Same volume as last week'**
  String get recordsSameAsLastWeek;

  /// No description provided for @recordsTrendEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete more workouts to see your form trend.'**
  String get recordsTrendEmpty;

  /// No description provided for @recordsFirstFormScore.
  ///
  /// In en, this message translates to:
  /// **'First form score'**
  String get recordsFirstFormScore;

  /// No description provided for @recordsRecentAverage.
  ///
  /// In en, this message translates to:
  /// **'Last {count} average {score}'**
  String recordsRecentAverage(int count, int score);

  /// No description provided for @recordsStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get recordsStrength;

  /// No description provided for @recordsFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get recordsFocus;

  /// No description provided for @recordsTodayPoint.
  ///
  /// In en, this message translates to:
  /// **'Today\'\'s focus'**
  String get recordsTodayPoint;

  /// No description provided for @recordsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get recordsToday;

  /// No description provided for @recordsRecentWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts'**
  String get recordsRecentWorkouts;

  /// No description provided for @recordsCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout calendar'**
  String get recordsCalendarTitle;

  /// No description provided for @recordsFormTrend.
  ///
  /// In en, this message translates to:
  /// **'Form trend'**
  String get recordsFormTrend;

  /// No description provided for @recordsViewCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get recordsViewCalendar;

  /// No description provided for @recordsViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get recordsViewList;

  /// No description provided for @recordsViewStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get recordsViewStats;

  /// No description provided for @recordsCalendarPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get recordsCalendarPreviousMonth;

  /// No description provided for @recordsCalendarNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get recordsCalendarNextMonth;

  /// No description provided for @recordsCalendarWorkoutDay.
  ///
  /// In en, this message translates to:
  /// **'Workout day'**
  String get recordsCalendarWorkoutDay;

  /// No description provided for @recordsCalendarNoWorkoutSelected.
  ///
  /// In en, this message translates to:
  /// **'Select a workout day to see its sessions.'**
  String get recordsCalendarNoWorkoutSelected;

  /// No description provided for @recordsDayTotal.
  ///
  /// In en, this message translates to:
  /// **'Daily total'**
  String get recordsDayTotal;

  /// No description provided for @recordsSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No sessions} =1 {1 session} other {{count} sessions}}'**
  String recordsSessionsCount(int count);

  /// No description provided for @recordsSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session {number}'**
  String recordsSessionTitle(int number);

  /// No description provided for @recordsListNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get recordsListNewest;

  /// No description provided for @recordsOpenDetail.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get recordsOpenDetail;

  /// No description provided for @recordsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get recordsEmptyTitle;

  /// No description provided for @recordsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Complete your first plank workout and it will appear here.'**
  String get recordsEmptyBody;

  /// No description provided for @recordsStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start a workout'**
  String get recordsStartWorkout;

  /// No description provided for @recordsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your workouts…'**
  String get recordsLoading;

  /// No description provided for @recordsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We could not load your workout records.'**
  String get recordsLoadError;

  /// No description provided for @statsPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get statsPeriod;

  /// No description provided for @statsPeriod7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get statsPeriod7Days;

  /// No description provided for @statsPeriod30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get statsPeriod30Days;

  /// No description provided for @statsPeriodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get statsPeriodThisMonth;

  /// No description provided for @statsPeriodAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get statsPeriodAll;

  /// No description provided for @statsPeriodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get statsPeriodCustom;

  /// No description provided for @statsCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Choose date range'**
  String get statsCustomRange;

  /// No description provided for @statsTotalReps.
  ///
  /// In en, this message translates to:
  /// **'Total plank seconds'**
  String get statsTotalReps;

  /// No description provided for @statsWorkoutDays.
  ///
  /// In en, this message translates to:
  /// **'Workout days'**
  String get statsWorkoutDays;

  /// No description provided for @statsTotalActiveTime.
  ///
  /// In en, this message translates to:
  /// **'Active time'**
  String get statsTotalActiveTime;

  /// No description provided for @statsAverageSets.
  ///
  /// In en, this message translates to:
  /// **'Average sets'**
  String get statsAverageSets;

  /// No description provided for @statsAverageReps.
  ///
  /// In en, this message translates to:
  /// **'Average plank seconds'**
  String get statsAverageReps;

  /// No description provided for @statsDailyReps.
  ///
  /// In en, this message translates to:
  /// **'Plank time by day'**
  String get statsDailyReps;

  /// No description provided for @statsTrend.
  ///
  /// In en, this message translates to:
  /// **'Change over time'**
  String get statsTrend;

  /// No description provided for @statsFrequentImprovements.
  ///
  /// In en, this message translates to:
  /// **'Frequent focus areas'**
  String get statsFrequentImprovements;

  /// No description provided for @statsNoData.
  ///
  /// In en, this message translates to:
  /// **'No workouts in this period.'**
  String get statsNoData;

  /// No description provided for @statsTrendUp.
  ///
  /// In en, this message translates to:
  /// **'Up {percent}%'**
  String statsTrendUp(num percent);

  /// No description provided for @statsTrendDown.
  ///
  /// In en, this message translates to:
  /// **'Down {percent}%'**
  String statsTrendDown(num percent);

  /// No description provided for @statsTrendFlat.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get statsTrendFlat;

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout details'**
  String get detailTitle;

  /// No description provided for @detailStartTime.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get detailStartTime;

  /// No description provided for @detailEndTime.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get detailEndTime;

  /// No description provided for @detailActiveTime.
  ///
  /// In en, this message translates to:
  /// **'Active time'**
  String get detailActiveTime;

  /// No description provided for @detailRestTime.
  ///
  /// In en, this message translates to:
  /// **'Rest time'**
  String get detailRestTime;

  /// No description provided for @detailTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get detailTotalTime;

  /// No description provided for @detailSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get detailSets;

  /// No description provided for @detailSetBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Seconds by set'**
  String get detailSetBreakdown;

  /// No description provided for @detailTotalReps.
  ///
  /// In en, this message translates to:
  /// **'Total plank seconds'**
  String get detailTotalReps;

  /// No description provided for @detailAverageRep.
  ///
  /// In en, this message translates to:
  /// **'Average hold checkpoint'**
  String get detailAverageRep;

  /// No description provided for @detailFormSummary.
  ///
  /// In en, this message translates to:
  /// **'Form summary'**
  String get detailFormSummary;

  /// No description provided for @detailImprovements.
  ///
  /// In en, this message translates to:
  /// **'Improvement points'**
  String get detailImprovements;

  /// No description provided for @detailStrengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get detailStrengths;

  /// No description provided for @detailInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Ended early'**
  String get detailInterrupted;

  /// No description provided for @detailCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get detailCompleted;

  /// No description provided for @detailSetRow.
  ///
  /// In en, this message translates to:
  /// **'Set {set}: {reps} seconds'**
  String detailSetRow(int set, int reps);

  /// No description provided for @detailSessionOn.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String detailSessionOn(String date, String time);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate this app'**
  String get settingsRateApp;

  /// No description provided for @settingsRateAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rate MotionFit'**
  String get settingsRateAppSubtitle;

  /// No description provided for @settingsRateAppError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the store. Please try again.'**
  String get settingsRateAppError;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionCoaching.
  ///
  /// In en, this message translates to:
  /// **'Voice coaching'**
  String get settingsSectionCoaching;

  /// No description provided for @settingsSectionReminder.
  ///
  /// In en, this message translates to:
  /// **'Workout reminders'**
  String get settingsSectionReminder;

  /// No description provided for @settingsSectionCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get settingsSectionCamera;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy and data'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsDisplayTheme.
  ///
  /// In en, this message translates to:
  /// **'Screen theme'**
  String get settingsDisplayTheme;

  /// No description provided for @settingsColorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get settingsColorTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themePureBlack.
  ///
  /// In en, this message translates to:
  /// **'Pure Black'**
  String get themePureBlack;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @colorThemeByeokcheong.
  ///
  /// In en, this message translates to:
  /// **'Byeokcheong Blue'**
  String get colorThemeByeokcheong;

  /// No description provided for @colorThemeChuhyang.
  ///
  /// In en, this message translates to:
  /// **'Chuhyang Beige'**
  String get colorThemeChuhyang;

  /// No description provided for @colorThemeJangdan.
  ///
  /// In en, this message translates to:
  /// **'Jangdan Red'**
  String get colorThemeJangdan;

  /// No description provided for @colorThemeCheonghyeon.
  ///
  /// In en, this message translates to:
  /// **'Cheonghyeon Blue'**
  String get colorThemeCheonghyeon;

  /// No description provided for @colorThemeHaenghwang.
  ///
  /// In en, this message translates to:
  /// **'Haenghwang Apricot'**
  String get colorThemeHaenghwang;

  /// No description provided for @colorThemeChunyu.
  ///
  /// In en, this message translates to:
  /// **'Chunyu Green'**
  String get colorThemeChunyu;

  /// No description provided for @colorThemeSeolbaek.
  ///
  /// In en, this message translates to:
  /// **'Seolbaek White'**
  String get colorThemeSeolbaek;

  /// No description provided for @colorThemeByeokja.
  ///
  /// In en, this message translates to:
  /// **'Byeokja Purple'**
  String get colorThemeByeokja;

  /// No description provided for @colorThemeChwiram.
  ///
  /// In en, this message translates to:
  /// **'Chwiram Mint'**
  String get colorThemeChwiram;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChineseSimplified;

  /// No description provided for @languageChineseTraditional.
  ///
  /// In en, this message translates to:
  /// **'繁體中文'**
  String get languageChineseTraditional;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageChanged;

  /// No description provided for @voiceCoachingEnabled.
  ///
  /// In en, this message translates to:
  /// **'Voice coaching'**
  String get voiceCoachingEnabled;

  /// No description provided for @voiceRepCountEnabled.
  ///
  /// In en, this message translates to:
  /// **'Speak second count'**
  String get voiceRepCountEnabled;

  /// No description provided for @voiceFormEnabled.
  ///
  /// In en, this message translates to:
  /// **'Form tips'**
  String get voiceFormEnabled;

  /// No description provided for @voiceEncouragementEnabled.
  ///
  /// In en, this message translates to:
  /// **'Encouragement'**
  String get voiceEncouragementEnabled;

  /// No description provided for @voiceRate.
  ///
  /// In en, this message translates to:
  /// **'Speech speed'**
  String get voiceRate;

  /// No description provided for @voiceRateSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get voiceRateSlow;

  /// No description provided for @voiceRateNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get voiceRateNormal;

  /// No description provided for @voiceRateFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get voiceRateFast;

  /// No description provided for @voiceTest.
  ///
  /// In en, this message translates to:
  /// **'Test voice'**
  String get voiceTest;

  /// No description provided for @voiceTestPhrase.
  ///
  /// In en, this message translates to:
  /// **'Great. Your voice coach is ready.'**
  String get voiceTestPhrase;

  /// No description provided for @voiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No compatible offline voice is installed for this language.'**
  String get voiceUnavailable;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout reminders'**
  String get reminderTitle;

  /// No description provided for @reminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a time for each day you want to train.'**
  String get reminderSubtitle;

  /// No description provided for @reminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Reminder enabled'**
  String get reminderEnabled;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @reminderCopyTime.
  ///
  /// In en, this message translates to:
  /// **'Copy this time'**
  String get reminderCopyTime;

  /// No description provided for @reminderCopyFromDay.
  ///
  /// In en, this message translates to:
  /// **'Copy time from {day}'**
  String reminderCopyFromDay(String day);

  /// No description provided for @reminderApplyAll.
  ///
  /// In en, this message translates to:
  /// **'Apply to every day'**
  String get reminderApplyAll;

  /// No description provided for @reminderNext.
  ///
  /// In en, this message translates to:
  /// **'Next reminder: {dateTime}'**
  String reminderNext(String dateTime);

  /// No description provided for @reminderNoneScheduled.
  ///
  /// In en, this message translates to:
  /// **'No reminders scheduled'**
  String get reminderNoneScheduled;

  /// No description provided for @reminderPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications to turn on reminders.'**
  String get reminderPermissionNeeded;

  /// No description provided for @reminderSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminder schedule saved'**
  String get reminderSaved;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @weekdayMondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMondayShort;

  /// No description provided for @weekdayTuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTuesdayShort;

  /// No description provided for @weekdayWednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWednesdayShort;

  /// No description provided for @weekdayThursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThursdayShort;

  /// No description provided for @weekdayFridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFridayShort;

  /// No description provided for @weekdaySaturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySaturdayShort;

  /// No description provided for @weekdaySundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySundayShort;

  /// No description provided for @cameraFront.
  ///
  /// In en, this message translates to:
  /// **'Front camera'**
  String get cameraFront;

  /// No description provided for @cameraRear.
  ///
  /// In en, this message translates to:
  /// **'Rear camera'**
  String get cameraRear;

  /// No description provided for @cameraMirrorPreview.
  ///
  /// In en, this message translates to:
  /// **'Mirror front preview'**
  String get cameraMirrorPreview;

  /// No description provided for @cameraPoseOverlay.
  ///
  /// In en, this message translates to:
  /// **'Pose guide overlay'**
  String get cameraPoseOverlay;

  /// No description provided for @cameraKeepScreenAwake.
  ///
  /// In en, this message translates to:
  /// **'Keep screen awake during workouts'**
  String get cameraKeepScreenAwake;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get settingsHaptics;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'How your data is handled'**
  String get privacyTitle;

  /// No description provided for @privacyLocalProcessing.
  ///
  /// In en, this message translates to:
  /// **'Pose analysis runs on this device.'**
  String get privacyLocalProcessing;

  /// No description provided for @privacyNoVideoStorage.
  ///
  /// In en, this message translates to:
  /// **'Workout video is stored only on this device when Hold Video Review is enabled.'**
  String get privacyNoVideoStorage;

  /// No description provided for @privacyNoUpload.
  ///
  /// In en, this message translates to:
  /// **'Camera frames are not uploaded to a server.'**
  String get privacyNoUpload;

  /// No description provided for @privacyStoredData.
  ///
  /// In en, this message translates to:
  /// **'Data stored on this device'**
  String get privacyStoredData;

  /// No description provided for @privacyStoredDataDescription.
  ///
  /// In en, this message translates to:
  /// **'MotionFit stores workout times, sets, held seconds, and form results so you can review your progress.'**
  String get privacyStoredDataDescription;

  /// No description provided for @privacyDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete all workout data'**
  String get privacyDeleteData;

  /// No description provided for @privacyDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all workout data?'**
  String get privacyDeleteConfirmTitle;

  /// No description provided for @privacyDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes your workout history from this device. This cannot be undone.'**
  String get privacyDeleteConfirmBody;

  /// No description provided for @privacyDeleteConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get privacyDeleteConfirmAction;

  /// No description provided for @privacyDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Workout data deleted'**
  String get privacyDeleteSuccess;

  /// No description provided for @privacyDeleteFailure.
  ///
  /// In en, this message translates to:
  /// **'Workout data could not be deleted.'**
  String get privacyDeleteFailure;

  /// No description provided for @appInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get appInfoTitle;

  /// No description provided for @appInfoVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appInfoVersion(String version);

  /// No description provided for @appInfoLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get appInfoLicenses;

  /// No description provided for @appInfoPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get appInfoPrivacyPolicy;

  /// No description provided for @appInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'MotionFit times planks and offers private, on-device body-alignment guidance.'**
  String get appInfoDescription;

  /// No description provided for @errorGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericBody.
  ///
  /// In en, this message translates to:
  /// **'Please try again. Your existing workout records are safe.'**
  String get errorGenericBody;

  /// No description provided for @errorCameraInit.
  ///
  /// In en, this message translates to:
  /// **'The camera could not start.'**
  String get errorCameraInit;

  /// No description provided for @errorCameraInUse.
  ///
  /// In en, this message translates to:
  /// **'The camera may be in use by another app.'**
  String get errorCameraInUse;

  /// No description provided for @errorPoseModelLoad.
  ///
  /// In en, this message translates to:
  /// **'The pose model could not be loaded.'**
  String get errorPoseModelLoad;

  /// No description provided for @errorNoPerson.
  ///
  /// In en, this message translates to:
  /// **'No person detected. Step into view.'**
  String get errorNoPerson;

  /// No description provided for @errorWholeBody.
  ///
  /// In en, this message translates to:
  /// **'Checking for a shoulder, hip, and knee chain.'**
  String get errorWholeBody;

  /// No description provided for @errorMultiplePeople.
  ///
  /// In en, this message translates to:
  /// **'More than one person is in view. Keep only one person in frame.'**
  String get errorMultiplePeople;

  /// No description provided for @errorTrackingLost.
  ///
  /// In en, this message translates to:
  /// **'The workout continues while detection keeps trying.'**
  String get errorTrackingLost;

  /// No description provided for @errorDatabaseSave.
  ///
  /// In en, this message translates to:
  /// **'Your workout could not be saved.'**
  String get errorDatabaseSave;

  /// No description provided for @errorTtsVoiceMissing.
  ///
  /// In en, this message translates to:
  /// **'A speech voice is not installed on this device.'**
  String get errorTtsVoiceMissing;

  /// No description provided for @errorTtsLocaleUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Voice coaching is not supported for the selected language on this device.'**
  String get errorTtsLocaleUnsupported;

  /// No description provided for @emptyNoFormIssues.
  ///
  /// In en, this message translates to:
  /// **'No repeated form issues were detected.'**
  String get emptyNoFormIssues;

  /// No description provided for @emptyNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get emptyNotEnoughData;

  /// No description provided for @loadingCamera.
  ///
  /// In en, this message translates to:
  /// **'Starting camera…'**
  String get loadingCamera;

  /// No description provided for @loadingPoseModel.
  ///
  /// In en, this message translates to:
  /// **'Preparing movement detection…'**
  String get loadingPoseModel;

  /// No description provided for @loadingSavingWorkout.
  ///
  /// In en, this message translates to:
  /// **'Saving workout…'**
  String get loadingSavingWorkout;

  /// No description provided for @formScore.
  ///
  /// In en, this message translates to:
  /// **'Form score'**
  String get formScore;

  /// No description provided for @formShort.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get formShort;

  /// No description provided for @formScoreValue.
  ///
  /// In en, this message translates to:
  /// **'{score} pts'**
  String formScoreValue(int score);

  /// No description provided for @formIssueDepth.
  ///
  /// In en, this message translates to:
  /// **'Hip alignment'**
  String get formIssueDepth;

  /// No description provided for @formIssueTorsoLean.
  ///
  /// In en, this message translates to:
  /// **'Body line'**
  String get formIssueTorsoLean;

  /// No description provided for @formIssueHeelLift.
  ///
  /// In en, this message translates to:
  /// **'Foot stability'**
  String get formIssueHeelLift;

  /// No description provided for @formIssueKneeAlignment.
  ///
  /// In en, this message translates to:
  /// **'Leg extension'**
  String get formIssueKneeAlignment;

  /// No description provided for @formIssueBalance.
  ///
  /// In en, this message translates to:
  /// **'Body stability'**
  String get formIssueBalance;

  /// No description provided for @formIssueDescentSpeed.
  ///
  /// In en, this message translates to:
  /// **'Position control'**
  String get formIssueDescentSpeed;

  /// No description provided for @formIssueAscentSpeed.
  ///
  /// In en, this message translates to:
  /// **'Position control'**
  String get formIssueAscentSpeed;

  /// No description provided for @formIssueControl.
  ///
  /// In en, this message translates to:
  /// **'Hold stability'**
  String get formIssueControl;

  /// No description provided for @formIssueStandingCompletion.
  ///
  /// In en, this message translates to:
  /// **'Straight body line'**
  String get formIssueStandingCompletion;

  /// No description provided for @formIssueNotObservable.
  ///
  /// In en, this message translates to:
  /// **'Not assessable from this camera angle'**
  String get formIssueNotObservable;

  /// No description provided for @formStrengthDepth.
  ///
  /// In en, this message translates to:
  /// **'Aligned hips'**
  String get formStrengthDepth;

  /// No description provided for @formStrengthControl.
  ///
  /// In en, this message translates to:
  /// **'Steady hold'**
  String get formStrengthControl;

  /// No description provided for @formStrengthBalance.
  ///
  /// In en, this message translates to:
  /// **'Stable body line'**
  String get formStrengthBalance;

  /// No description provided for @coachTrackingLost1.
  ///
  /// In en, this message translates to:
  /// **'Your workout is still running while I keep detecting.'**
  String get coachTrackingLost1;

  /// No description provided for @coachTrackingLost2.
  ///
  /// In en, this message translates to:
  /// **'A brief occlusion will not pause your workout.'**
  String get coachTrackingLost2;

  /// No description provided for @coachWholeBody1.
  ///
  /// In en, this message translates to:
  /// **'Keep your shoulders, hips, knees, and ankles visible.'**
  String get coachWholeBody1;

  /// No description provided for @coachWholeBody2.
  ///
  /// In en, this message translates to:
  /// **'Move sideways so I can see your full plank.'**
  String get coachWholeBody2;

  /// No description provided for @coachMultiplePeople1.
  ///
  /// In en, this message translates to:
  /// **'Keep just one person in frame so I can track you.'**
  String get coachMultiplePeople1;

  /// No description provided for @coachReady1.
  ///
  /// In en, this message translates to:
  /// **'You’re in position. Let’s begin.'**
  String get coachReady1;

  /// No description provided for @coachReady2.
  ///
  /// In en, this message translates to:
  /// **'Great position. Hold your plank.'**
  String get coachReady2;

  /// No description provided for @coachStartSet.
  ///
  /// In en, this message translates to:
  /// **'Set {set}. Let’s go.'**
  String coachStartSet(int set);

  /// No description provided for @coachSevenDayChallengeStart.
  ///
  /// In en, this message translates to:
  /// **'Starting day {day} of the seven-day challenge.'**
  String coachSevenDayChallengeStart(int day);

  /// No description provided for @coachCumulativeChallengeStart.
  ///
  /// In en, this message translates to:
  /// **'Starting the cumulative seconds challenge. You have completed {completed} seconds, with {remaining} remaining.'**
  String coachCumulativeChallengeStart(int completed, int remaining);

  /// No description provided for @coachRepCount.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String coachRepCount(int count);

  /// No description provided for @coachDepth1.
  ///
  /// In en, this message translates to:
  /// **'Align your hips with your shoulders.'**
  String get coachDepth1;

  /// No description provided for @coachDepth2.
  ///
  /// In en, this message translates to:
  /// **'Keep your hips in one straight body line.'**
  String get coachDepth2;

  /// No description provided for @coachTorso1.
  ///
  /// In en, this message translates to:
  /// **'Brace your core and keep your back straight.'**
  String get coachTorso1;

  /// No description provided for @coachTorso2.
  ///
  /// In en, this message translates to:
  /// **'Keep your shoulders and hips level.'**
  String get coachTorso2;

  /// No description provided for @coachHeel1.
  ///
  /// In en, this message translates to:
  /// **'Press back through your heels.'**
  String get coachHeel1;

  /// No description provided for @coachHeel2.
  ///
  /// In en, this message translates to:
  /// **'Keep your feet stable.'**
  String get coachHeel2;

  /// No description provided for @coachKnees1.
  ///
  /// In en, this message translates to:
  /// **'Straighten your legs gently.'**
  String get coachKnees1;

  /// No description provided for @coachKnees2.
  ///
  /// In en, this message translates to:
  /// **'Keep your knees extended, not locked.'**
  String get coachKnees2;

  /// No description provided for @coachBalance1.
  ///
  /// In en, this message translates to:
  /// **'Keep your weight centered.'**
  String get coachBalance1;

  /// No description provided for @coachBalance2.
  ///
  /// In en, this message translates to:
  /// **'Stay steady without shifting side to side.'**
  String get coachBalance2;

  /// No description provided for @coachDescendSlow1.
  ///
  /// In en, this message translates to:
  /// **'Set your plank position with control.'**
  String get coachDescendSlow1;

  /// No description provided for @coachDescendSlow2.
  ///
  /// In en, this message translates to:
  /// **'Move smoothly into alignment.'**
  String get coachDescendSlow2;

  /// No description provided for @coachDescendFaster1.
  ///
  /// In en, this message translates to:
  /// **'Return to a straight plank.'**
  String get coachDescendFaster1;

  /// No description provided for @coachDescendFaster2.
  ///
  /// In en, this message translates to:
  /// **'Reset your alignment and keep holding.'**
  String get coachDescendFaster2;

  /// No description provided for @coachAscendControlled1.
  ///
  /// In en, this message translates to:
  /// **'Lower your hips slightly and stay controlled.'**
  String get coachAscendControlled1;

  /// No description provided for @coachAscendControlled2.
  ///
  /// In en, this message translates to:
  /// **'Keep your hips level with your shoulders.'**
  String get coachAscendControlled2;

  /// No description provided for @coachAscendFaster1.
  ///
  /// In en, this message translates to:
  /// **'Lift your hips slightly into line.'**
  String get coachAscendFaster1;

  /// No description provided for @coachAscendFaster2.
  ///
  /// In en, this message translates to:
  /// **'Bring your hips back into alignment.'**
  String get coachAscendFaster2;

  /// No description provided for @coachControl1.
  ///
  /// In en, this message translates to:
  /// **'Stay steady and keep breathing.'**
  String get coachControl1;

  /// No description provided for @coachControl2.
  ///
  /// In en, this message translates to:
  /// **'Brace your core and minimize movement.'**
  String get coachControl2;

  /// No description provided for @coachStandTall1.
  ///
  /// In en, this message translates to:
  /// **'Lengthen your body from shoulders to heels.'**
  String get coachStandTall1;

  /// No description provided for @coachStandTall2.
  ///
  /// In en, this message translates to:
  /// **'Keep your legs and back in one line.'**
  String get coachStandTall2;

  /// No description provided for @coachGood1.
  ///
  /// In en, this message translates to:
  /// **'Good hold. Keep breathing.'**
  String get coachGood1;

  /// No description provided for @coachGood2.
  ///
  /// In en, this message translates to:
  /// **'Strong alignment. Keep holding.'**
  String get coachGood2;

  /// No description provided for @coachGood3.
  ///
  /// In en, this message translates to:
  /// **'Steady plank. Keep it up.'**
  String get coachGood3;

  /// No description provided for @coachLastTwo.
  ///
  /// In en, this message translates to:
  /// **'Two seconds left. Stay strong!'**
  String get coachLastTwo;

  /// No description provided for @coachLastOne.
  ///
  /// In en, this message translates to:
  /// **'One second left. Finish strong!'**
  String get coachLastOne;

  /// No description provided for @coachSetComplete.
  ///
  /// In en, this message translates to:
  /// **'Great. Set {set} is complete.'**
  String coachSetComplete(int set);

  /// No description provided for @coachRestStart.
  ///
  /// In en, this message translates to:
  /// **'Rest for {seconds} seconds. Breathe and reset.'**
  String coachRestStart(int seconds);

  /// No description provided for @coachRestTenSeconds.
  ///
  /// In en, this message translates to:
  /// **'Ten seconds of rest left.'**
  String get coachRestTenSeconds;

  /// No description provided for @coachRestComplete.
  ///
  /// In en, this message translates to:
  /// **'Rest is over. Get ready for the next set.'**
  String get coachRestComplete;

  /// No description provided for @coachWorkoutComplete.
  ///
  /// In en, this message translates to:
  /// **'Workout complete. You held plank for {reps} seconds.'**
  String coachWorkoutComplete(int reps);

  /// No description provided for @notificationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for today’s plank'**
  String get notificationReminderTitle;

  /// No description provided for @notificationReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Even a short session counts. Open MotionFit when you’re ready.'**
  String get notificationReminderBody;

  /// No description provided for @notificationReminderBodyVariant2.
  ///
  /// In en, this message translates to:
  /// **'A short focused plank can make today’s movement count.'**
  String get notificationReminderBodyVariant2;

  /// No description provided for @notificationStreakReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Keep your {days}-day streak alive with a short session today.'**
  String notificationStreakReminderBody(int days);

  /// No description provided for @semanticsIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get semanticsIncrease;

  /// No description provided for @semanticsDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get semanticsDecrease;

  /// No description provided for @semanticsSelectedTab.
  ///
  /// In en, this message translates to:
  /// **'Selected tab: {tab}'**
  String semanticsSelectedTab(String tab);

  /// No description provided for @semanticsCalendarWorkoutDate.
  ///
  /// In en, this message translates to:
  /// **'{date}, workout recorded'**
  String semanticsCalendarWorkoutDate(String date);

  /// No description provided for @semanticsCalendarEmptyDate.
  ///
  /// In en, this message translates to:
  /// **'{date}, no workout'**
  String semanticsCalendarEmptyDate(String date);

  /// No description provided for @semanticsCurrentRep.
  ///
  /// In en, this message translates to:
  /// **'Current repetition {current} of {target}'**
  String semanticsCurrentRep(int current, int target);

  /// No description provided for @repVideoReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Plank Video Review'**
  String get repVideoReviewTitle;

  /// No description provided for @repVideoReviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Save this workout video on your device to review each hold segment.'**
  String get repVideoReviewDescription;

  /// No description provided for @repVideoLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Local only · Never uploaded'**
  String get repVideoLocalOnly;

  /// No description provided for @formReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Form review'**
  String get formReviewTitle;

  /// No description provided for @formReviewMainIssue.
  ///
  /// In en, this message translates to:
  /// **'Main issue'**
  String get formReviewMainIssue;

  /// No description provided for @viewRepTimeline.
  ///
  /// In en, this message translates to:
  /// **'View hold timeline'**
  String get viewRepTimeline;

  /// No description provided for @repTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Plank review'**
  String get repTimelineTitle;

  /// No description provided for @repTimelineAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get repTimelineAll;

  /// No description provided for @repTimelineImprove.
  ///
  /// In en, this message translates to:
  /// **'Improve'**
  String get repTimelineImprove;

  /// No description provided for @repTimelineNoImprovement.
  ///
  /// In en, this message translates to:
  /// **'No hold segments need improvement.'**
  String get repTimelineNoImprovement;

  /// No description provided for @repSetNumber.
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String repSetNumber(int number);

  /// No description provided for @repNumber.
  ///
  /// In en, this message translates to:
  /// **'Second {number}'**
  String repNumber(int number);

  /// No description provided for @repResultGood.
  ///
  /// In en, this message translates to:
  /// **'Good form'**
  String get repResultGood;

  /// No description provided for @repResultNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get repResultNeedsAttention;

  /// No description provided for @repResultImproved.
  ///
  /// In en, this message translates to:
  /// **'Better than the previous segment'**
  String get repResultImproved;

  /// No description provided for @repResultNotAssessed.
  ///
  /// In en, this message translates to:
  /// **'Hard to assess'**
  String get repResultNotAssessed;

  /// No description provided for @repIssueShallowDepth.
  ///
  /// In en, this message translates to:
  /// **'Align your hips with your shoulders'**
  String get repIssueShallowDepth;

  /// No description provided for @repIssueForwardLean.
  ///
  /// In en, this message translates to:
  /// **'Body line moved out of alignment'**
  String get repIssueForwardLean;

  /// No description provided for @repIssueKneesInward.
  ///
  /// In en, this message translates to:
  /// **'Legs were not fully extended'**
  String get repIssueKneesInward;

  /// No description provided for @repVideoNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Video not saved'**
  String get repVideoNotSaved;

  /// No description provided for @repReplay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get repReplay;

  /// No description provided for @repWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get repWhatHappened;

  /// No description provided for @repHowToImprove.
  ///
  /// In en, this message translates to:
  /// **'How to improve'**
  String get repHowToImprove;

  /// No description provided for @repWhatWentWell.
  ///
  /// In en, this message translates to:
  /// **'What went well'**
  String get repWhatWentWell;

  /// No description provided for @repPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous segment'**
  String get repPrevious;

  /// No description provided for @repNext.
  ///
  /// In en, this message translates to:
  /// **'Next segment'**
  String get repNext;

  /// No description provided for @repFeedbackGood.
  ///
  /// In en, this message translates to:
  /// **'Your body stayed within the plank alignment ranges MotionFit could assess.'**
  String get repFeedbackGood;

  /// No description provided for @repFeedbackDepth.
  ///
  /// In en, this message translates to:
  /// **'Your hips moved out of line. Keep your shoulders, hips, and heels aligned.'**
  String get repFeedbackDepth;

  /// No description provided for @repFeedbackTorso.
  ///
  /// In en, this message translates to:
  /// **'Your body line shifted. Brace your core and keep your back straight.'**
  String get repFeedbackTorso;

  /// No description provided for @repFeedbackKnees.
  ///
  /// In en, this message translates to:
  /// **'Your knees bent during the hold. Lengthen your legs gently.'**
  String get repFeedbackKnees;

  /// No description provided for @repFeedbackGeneric.
  ///
  /// In en, this message translates to:
  /// **'This second needs attention in {area}.'**
  String repFeedbackGeneric(String area);

  /// No description provided for @deleteWorkoutVideo.
  ///
  /// In en, this message translates to:
  /// **'Delete workout video'**
  String get deleteWorkoutVideo;

  /// No description provided for @deleteWorkoutVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this workout video?'**
  String get deleteWorkoutVideoTitle;

  /// No description provided for @deleteWorkoutVideoBody.
  ///
  /// In en, this message translates to:
  /// **'Only the local video will be deleted. Hold analysis and workout records will stay.'**
  String get deleteWorkoutVideoBody;

  /// No description provided for @workoutVideoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Workout video deleted'**
  String get workoutVideoDeleted;
}

class _PlankLocalizationsDelegate
    extends LocalizationsDelegate<PlankLocalizations> {
  const _PlankLocalizationsDelegate();

  @override
  Future<PlankLocalizations> load(Locale locale) {
    return SynchronousFuture<PlankLocalizations>(
      lookupPlankLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_PlankLocalizationsDelegate old) => false;
}

PlankLocalizations lookupPlankLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return PlankLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return PlankLocalizationsAr();
    case 'de':
      return PlankLocalizationsDe();
    case 'en':
      return PlankLocalizationsEn();
    case 'es':
      return PlankLocalizationsEs();
    case 'fr':
      return PlankLocalizationsFr();
    case 'ja':
      return PlankLocalizationsJa();
    case 'ko':
      return PlankLocalizationsKo();
    case 'zh':
      return PlankLocalizationsZh();
  }

  throw FlutterError(
    'PlankLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
