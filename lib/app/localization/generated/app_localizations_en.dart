// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'motionfit - workout coach';

  @override
  String get navSquat => 'Squat';

  @override
  String get navWorkout => 'Workout';

  @override
  String get navChallenge => 'Challenge';

  @override
  String get navRecords => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get challengeTitle => 'My squat challenge';

  @override
  String get challengeSubtitle =>
      'Choose a challenge that fits your goal and keep moving consistently.';

  @override
  String get challengeChooseTitle => 'Choose a challenge';

  @override
  String get challengeSevenDayTitle => '7-day starter challenge';

  @override
  String get challengeSevenDayDescription =>
      'A step-by-step program for beginners';

  @override
  String get challengeSevenDaySummary =>
      'Follow a level-based goal that increases each day for 7 days.';

  @override
  String get challengeSevenDayEveryDay =>
      'Continue every day for 7 days without recovery days';

  @override
  String challengeDurationDays(int days) {
    return '$days days';
  }

  @override
  String get challengeLevelGoals => 'Goals tailored to your level';

  @override
  String get challengeRecoveryIncluded => 'Recovery days included';

  @override
  String get challengeDailyGoal => 'Daily rep goals';

  @override
  String get challengeSevenDayStart => 'Start 7-day challenge';

  @override
  String get challengeSevenDaySettings => 'Set your 7-day goal';

  @override
  String get challengeSevenDaySettingsDescription =>
      'Choose day 1. The goal increases by 5 reps each day.';

  @override
  String get challengeFirstDayGoal => 'Day 1 target reps';

  @override
  String challengeSevenDayPreview(int first, int last) {
    return 'Day 1: $first reps → Day 7: $last reps';
  }

  @override
  String get challengeWeeklyTitle => '3 times a week challenge';

  @override
  String get challengeWeeklyDescription =>
      'A habit challenge for people who do not want to work out every day';

  @override
  String get challengeWeeklySummary =>
      'Work out 3 selected days each week for 4 weeks.';

  @override
  String challengeDurationWeeks(int weeks) {
    return '$weeks weeks';
  }

  @override
  String get challengeThreePerWeek => '3 workouts each week';

  @override
  String get challengeChooseWeekdays => 'Choose 3 workout days';

  @override
  String get challengeWorkoutDaysCount => 'Progress is based on workout days';

  @override
  String get challengeWeeklyStart => 'Start weekly challenge';

  @override
  String get challengeCumulativeTitle => 'Total reps challenge';

  @override
  String get challengeCumulativeDescription =>
      'Reach a total squat target on a schedule that works for you';

  @override
  String get challengeCumulativeSummary =>
      'Choose a duration and total target; rest days keep your progress.';

  @override
  String get challengePreset200 => '200 squats in 7 days';

  @override
  String get challengePreset500 => '500 squats in 14 days';

  @override
  String get challengeCustomGoal => 'Choose your own duration and goal';

  @override
  String get challengeRestWithoutReset => 'Rest days do not reset progress';

  @override
  String get challengeCumulativeStart => 'Start total reps challenge';

  @override
  String get challengeHistoryTitle => 'Past challenges';

  @override
  String get challengeHistoryEmpty =>
      'Your completed and ended challenges will appear here.';

  @override
  String get challengeRecommended => 'Recommended for you';

  @override
  String challengeRecommendationFromWorkout(int reps) {
    return 'Recommended from your first workout of $reps reps.';
  }

  @override
  String get challengeRecommendationDefault =>
      'A gentle 7-day start is recommended for your first challenge.';

  @override
  String get challengeActive => 'Active challenge';

  @override
  String get challengeNext => 'Next';

  @override
  String challengeDayNumber(int day) {
    return 'Day $day';
  }

  @override
  String get challengeRecoveryDay => 'Recovery day';

  @override
  String challengeTodayProgress(int current, int target) {
    return 'Today $current / $target reps';
  }

  @override
  String get challengeRestToday => 'Take time to recover today.';

  @override
  String get challengeTodayCompleted =>
      'Today’s goal is complete · Continue tomorrow';

  @override
  String challengeRepsRemaining(int reps) {
    return '$reps reps to go';
  }

  @override
  String challengeWeekNumber(int week) {
    return 'Week $week';
  }

  @override
  String challengeThisWeekProgress(int current, int target) {
    return 'This week $current / $target workouts';
  }

  @override
  String challengeOverallDays(int current, int target) {
    return 'Overall $current / $target days';
  }

  @override
  String challengeRepsProgress(int current, int target) {
    return '$current / $target reps';
  }

  @override
  String challengeDaysRemaining(int days) {
    return '$days days left';
  }

  @override
  String challengeTodaySuggested(int reps) {
    return 'Suggested for today: $reps reps';
  }

  @override
  String challengePercent(int percent) {
    return '$percent% complete';
  }

  @override
  String get challengeSquatStart => 'Start squats';

  @override
  String get challengeTodayWorkoutStart => 'Start today’s workout';

  @override
  String get challengeViewDetails => 'View details';

  @override
  String get challengeRestart => 'Start again';

  @override
  String get challengeDeleteHistory => 'Delete from history';

  @override
  String get challengeCumulativeSettings => 'Set your total goal';

  @override
  String get challengeDurationLabel => 'Duration';

  @override
  String get challengeGoalLabel => 'Target reps';

  @override
  String get challengeNotFound => 'This challenge is no longer available.';

  @override
  String get challengePeriod => 'Period';

  @override
  String get challengeStatus => 'Status';

  @override
  String get challengeTotalReps => 'Total squats';

  @override
  String get challengeWorkoutDays => 'Workout days';

  @override
  String challengeDaysCount(int days) {
    return '$days days';
  }

  @override
  String get challengeTotalTime => 'Total workout time';

  @override
  String get challengeSchedule => 'Schedule and progress';

  @override
  String get challengeNotifications => 'Challenge reminders';

  @override
  String get challengeNotificationsDescription =>
      'Keep reminder preferences with this challenge.';

  @override
  String get challengeReminderNotificationTitle =>
      'Your squat challenge is waiting';

  @override
  String get challengeReminderNotificationBody =>
      'Open MotionFit and make progress toward today’s challenge goal.';

  @override
  String get challengeSelectedWeekdays => 'Selected workout days';

  @override
  String get challengeNoProgressYet => 'No challenge workouts yet.';

  @override
  String get challengeCancel => 'End challenge';

  @override
  String get challengeCancelTitle => 'End this challenge?';

  @override
  String get challengeCancelDescription =>
      'Your workout records will stay saved. This challenge will move to history.';

  @override
  String get challengeStatusActive => 'In progress';

  @override
  String get challengeStatusCompleted => 'Completed';

  @override
  String get challengeStatusEnded => 'Ended';

  @override
  String get challengeStatusCancelled => 'Cancelled';

  @override
  String get challengeProgressUpdated =>
      'Your challenge progress has been updated.';

  @override
  String get challengeCheck => 'View challenge';

  @override
  String get commonDone => 'Done';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonBack => 'Back';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonStart => 'Start';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonOn => 'On';

  @override
  String get commonOff => 'Off';

  @override
  String get commonEnabled => 'Enabled';

  @override
  String get commonDisabled => 'Disabled';

  @override
  String get commonNotAvailable => 'Not available';

  @override
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get commonLoading => 'Loading…';

  @override
  String unitSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
      zero: '0 sets',
    );
    return '$_temp0';
  }

  @override
  String unitReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reps',
      one: '1 rep',
      zero: '0 reps',
    );
    return '$_temp0';
  }

  @override
  String unitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
      zero: '0 seconds',
    );
    return '$_temp0';
  }

  @override
  String unitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
      zero: '0 minutes',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes min $seconds sec';
  }

  @override
  String get homeGreeting => 'Ready to move?';

  @override
  String get homeTodayTitle => 'Today’s record';

  @override
  String get homeTodayNoWorkout =>
      'No squats yet today. A short set is a great start.';

  @override
  String homeTodaySummary(int reps, int sets) {
    return '$reps squats across $sets';
  }

  @override
  String get homeViewResult => 'View result';

  @override
  String get homeTodaySets => 'Sets today';

  @override
  String get homeTodayReps => 'Done today';

  @override
  String get streakLabel => 'Streak';

  @override
  String streakDays(int days) {
    return '$days days';
  }

  @override
  String get homeWorkoutSetup => 'Next workout';

  @override
  String get homeSetsLabel => 'Sets';

  @override
  String get homeRepsPerSetLabel => 'Reps per set';

  @override
  String get homeRestTimeLabel => 'Rest time';

  @override
  String get homeDirectInputHint => 'Enter a number';

  @override
  String get homeStartWorkout => 'Start workout';

  @override
  String get homeLastSettingsRestored =>
      'Your last workout settings are ready.';

  @override
  String get validationNumberRequired => 'Enter a number.';

  @override
  String validationRange(num min, num max) {
    return 'Choose a value from $min to $max.';
  }

  @override
  String get guideTitle => 'Set up your camera';

  @override
  String get guideSubtitle =>
      'MotionFit can measure squats from shoulders through knees without ankles.';

  @override
  String get guideWholeBody =>
      'Keep your shoulders, hips, and knees visible when possible.';

  @override
  String get guideStableCamera => 'Place your phone somewhere stable.';

  @override
  String get guideOnePerson => 'Make sure only one person is in frame.';

  @override
  String get guideCameraAngle =>
      'Use a side or slightly angled side view when possible.';

  @override
  String get guideLighting => 'Avoid dark rooms and strong backlighting.';

  @override
  String get guidePrivacy =>
      'Video stays on this device and is saved only when Rep Video Review is on.';

  @override
  String get guideContinue => 'I’m in position';

  @override
  String get permissionCameraTitle => 'Camera access is needed';

  @override
  String get permissionCameraBody =>
      'MotionFit uses the camera to count squats. Video is saved only on this device when you turn on Rep Video Review.';

  @override
  String get permissionCameraRequest => 'Continue';

  @override
  String get permissionCameraDenied =>
      'Camera access was denied. You can still view records and settings.';

  @override
  String get permissionCameraPermanentlyDenied =>
      'Allow camera access in system settings to start a workout.';

  @override
  String get permissionOpenSettings => 'Open settings';

  @override
  String get permissionNotificationTitle => 'Allow workout reminders?';

  @override
  String get permissionNotificationBody =>
      'Notifications are used only for reminders you schedule.';

  @override
  String get permissionNotificationRequest => 'Allow notifications';

  @override
  String get permissionNotificationDenied =>
      'Notifications are off. Turn them on in system settings to receive reminders.';

  @override
  String get countdownGetReady => 'Get ready';

  @override
  String countdownBeginsIn(int seconds) {
    return 'Starting in $seconds';
  }

  @override
  String get calibrationTitle => 'Finding your standing position';

  @override
  String get calibrationBody =>
      'Stand tall with your shoulders through knees in view.';

  @override
  String get calibrationStayStill => 'Hold still for a moment';

  @override
  String get calibrationComplete => 'All set';

  @override
  String get calibrationFailed => 'We could not get a clear standing position.';

  @override
  String get calibrationRetry => 'Recalibrate';

  @override
  String workoutSetProgress(int current, int total) {
    return 'Set $current of $total';
  }

  @override
  String workoutRepProgress(int current, int target) {
    return '$current of $target';
  }

  @override
  String workoutTotalReps(int count) {
    return 'Total $count';
  }

  @override
  String get workoutElapsed => 'Elapsed time';

  @override
  String get workoutPause => 'Pause';

  @override
  String get workoutResume => 'Resume workout';

  @override
  String get workoutEnd => 'Stop for now';

  @override
  String get workoutBackToSetup => 'Back to setup';

  @override
  String get workoutEndDialogTitle => 'Stop for now?';

  @override
  String get workoutEndDialogBody =>
      'Your progress will be saved so you can continue from the home screen.';

  @override
  String get workoutEndDialogConfirm => 'Save and leave';

  @override
  String get workoutPauseReasonBackground =>
      'Workout paused while the app was in the background.';

  @override
  String get workoutPauseReasonInterruption =>
      'Workout paused after a system interruption.';

  @override
  String get workoutStateReady => 'Ready';

  @override
  String get workoutStateDescending => 'Going down';

  @override
  String get workoutStateBottom => 'At the bottom';

  @override
  String get workoutStateAscending => 'Coming up';

  @override
  String get workoutStateCompleted => 'Nice rep';

  @override
  String get workoutStateTrackingLost => 'Still detecting';

  @override
  String get workoutStatePaused => 'Paused';

  @override
  String get workoutTrackingGood => 'Joints detected';

  @override
  String get workoutCameraSwitch => 'Switch camera';

  @override
  String get workoutSkeletonToggle => 'Show pose guide';

  @override
  String get restTitle => 'Rest';

  @override
  String restNextSet(int set, int total) {
    return 'Next: set $set of $total';
  }

  @override
  String get restCompletedSets => 'Completed sets';

  @override
  String get restTotalReps => 'Squats so far';

  @override
  String get restSkip => 'Skip rest';

  @override
  String get restAddFifteenSeconds => 'Add 15 seconds';

  @override
  String get restEndWorkout => 'Stop for now';

  @override
  String get restAlmostDone => 'Almost ready';

  @override
  String get restReady => 'Time for the next set';

  @override
  String get completeTitle => 'Workout complete';

  @override
  String get completeSubtitle =>
      'Strong work. Here is your session at a glance.';

  @override
  String get workoutInterruptedSubtitle =>
      'Review what you recorded before ending early.';

  @override
  String get completeTotalReps => 'Total squats';

  @override
  String get completeCompletedSets => 'Sets completed';

  @override
  String get completeActiveTime => 'Active time';

  @override
  String get completeRestTime => 'Rest time';

  @override
  String get completeTotalTime => 'Total time';

  @override
  String get completeAverageRepTime => 'Average rep time';

  @override
  String get completeFormSummary => 'Form summary';

  @override
  String get todayCoaching => 'Today\'s coaching';

  @override
  String coachingIssueFrequency(int total, int count, String issue) {
    return 'In $count of $total reps,\n$issue';
  }

  @override
  String get completeTopImprovement => 'Focus for next time';

  @override
  String get completeStrengths => 'What went well';

  @override
  String get completeSaved => 'Workout saved on this device';

  @override
  String get completeSaveFailed =>
      'The workout could not be saved. Try again before leaving.';

  @override
  String get completeNoFormData =>
      'There was not enough visible movement for a form summary.';

  @override
  String get completeFinish => 'Finish';

  @override
  String get postWorkoutReminderTitle => 'Keep the momentum going';

  @override
  String postWorkoutReminderBody(String time) {
    return 'Would you like a daily reminder at $time, starting tomorrow?';
  }

  @override
  String get postWorkoutReminderEnable => 'Remind me';

  @override
  String get postWorkoutReminderLater => 'Maybe later';

  @override
  String get postWorkoutReminderEnabled => 'Your reminder is set.';

  @override
  String get recordsTitle => 'Progress';

  @override
  String get recordsWeeklySummary => 'This week';

  @override
  String recordsWorkoutCount(int count) {
    return '$count workouts';
  }

  @override
  String recordsAverageForm(int score) {
    return 'Average form $score';
  }

  @override
  String recordsWorkoutTime(String time) {
    return 'Time $time';
  }

  @override
  String get recordsFirstWeek => 'This is your first record this week';

  @override
  String recordsMoreThanLastWeek(int count) {
    return '$count more reps than last week';
  }

  @override
  String recordsLessThanLastWeek(int count) {
    return '$count fewer reps than last week';
  }

  @override
  String get recordsSameAsLastWeek => 'Same volume as last week';

  @override
  String get recordsTrendEmpty =>
      'Complete more workouts to see your form trend.';

  @override
  String get recordsFirstFormScore => 'First form score';

  @override
  String recordsRecentAverage(int count, int score) {
    return 'Last $count average $score';
  }

  @override
  String get recordsStrength => 'Strength';

  @override
  String get recordsFocus => 'Focus';

  @override
  String get recordsTodayPoint => 'Today\'s focus';

  @override
  String get recordsToday => 'Today';

  @override
  String get recordsRecentWorkouts => 'Recent workouts';

  @override
  String get recordsCalendarTitle => 'Workout calendar';

  @override
  String get recordsFormTrend => 'Form trend';

  @override
  String get recordsViewCalendar => 'Calendar';

  @override
  String get recordsViewList => 'List';

  @override
  String get recordsViewStats => 'Stats';

  @override
  String get recordsCalendarPreviousMonth => 'Previous month';

  @override
  String get recordsCalendarNextMonth => 'Next month';

  @override
  String get recordsCalendarWorkoutDay => 'Workout day';

  @override
  String get recordsCalendarNoWorkoutSelected =>
      'Select a workout day to see its sessions.';

  @override
  String get recordsDayTotal => 'Daily total';

  @override
  String recordsSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
      zero: 'No sessions',
    );
    return '$_temp0';
  }

  @override
  String recordsSessionTitle(int number) {
    return 'Session $number';
  }

  @override
  String get recordsListNewest => 'Newest first';

  @override
  String get recordsOpenDetail => 'View details';

  @override
  String get recordsEmptyTitle => 'No workouts yet';

  @override
  String get recordsEmptyBody =>
      'Complete your first squat workout and it will appear here.';

  @override
  String get recordsStartWorkout => 'Start a workout';

  @override
  String get recordsLoading => 'Loading your workouts…';

  @override
  String get recordsLoadError => 'We could not load your workout records.';

  @override
  String get statsPeriod => 'Period';

  @override
  String get statsPeriod7Days => '7 days';

  @override
  String get statsPeriod30Days => '30 days';

  @override
  String get statsPeriodThisMonth => 'This month';

  @override
  String get statsPeriodAll => 'All time';

  @override
  String get statsPeriodCustom => 'Custom';

  @override
  String get statsCustomRange => 'Choose date range';

  @override
  String get statsTotalReps => 'Total squats';

  @override
  String get statsWorkoutDays => 'Workout days';

  @override
  String get statsTotalActiveTime => 'Active time';

  @override
  String get statsAverageSets => 'Average sets';

  @override
  String get statsAverageReps => 'Average squats';

  @override
  String get statsDailyReps => 'Squats by day';

  @override
  String get statsTrend => 'Change over time';

  @override
  String get statsFrequentImprovements => 'Frequent focus areas';

  @override
  String get statsNoData => 'No workouts in this period.';

  @override
  String statsTrendUp(num percent) {
    return 'Up $percent%';
  }

  @override
  String statsTrendDown(num percent) {
    return 'Down $percent%';
  }

  @override
  String get statsTrendFlat => 'No change';

  @override
  String get detailTitle => 'Workout details';

  @override
  String get detailStartTime => 'Started';

  @override
  String get detailEndTime => 'Ended';

  @override
  String get detailActiveTime => 'Active time';

  @override
  String get detailRestTime => 'Rest time';

  @override
  String get detailTotalTime => 'Total time';

  @override
  String get detailSets => 'Sets';

  @override
  String get detailSetBreakdown => 'Reps by set';

  @override
  String get detailTotalReps => 'Total squats';

  @override
  String get detailAverageRep => 'Average rep time';

  @override
  String get detailFormSummary => 'Form summary';

  @override
  String get detailImprovements => 'Improvement points';

  @override
  String get detailStrengths => 'Strengths';

  @override
  String get detailInterrupted => 'Ended early';

  @override
  String get detailCompleted => 'Completed';

  @override
  String detailSetRow(int set, int reps) {
    return 'Set $set: $reps reps';
  }

  @override
  String detailSessionOn(String date, String time) {
    return '$date at $time';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsRateApp => 'Rate this app';

  @override
  String get settingsRateAppSubtitle => 'Rate MotionFit';

  @override
  String get settingsRateAppError =>
      'Unable to open the store. Please try again.';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionCoaching => 'Voice coaching';

  @override
  String get settingsSectionReminder => 'Workout reminders';

  @override
  String get settingsSectionCamera => 'Camera';

  @override
  String get settingsSectionPrivacy => 'Privacy and data';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDisplayTheme => 'Screen theme';

  @override
  String get settingsColorTheme => 'Color theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themePureBlack => 'Pure Black';

  @override
  String get themeSystem => 'System';

  @override
  String get colorThemeByeokcheong => 'Byeokcheong Blue';

  @override
  String get colorThemeChuhyang => 'Chuhyang Beige';

  @override
  String get colorThemeJangdan => 'Jangdan Red';

  @override
  String get colorThemeCheonghyeon => 'Cheonghyeon Blue';

  @override
  String get colorThemeHaenghwang => 'Haenghwang Apricot';

  @override
  String get colorThemeChunyu => 'Chunyu Green';

  @override
  String get colorThemeSeolbaek => 'Seolbaek White';

  @override
  String get colorThemeByeokja => 'Byeokja Purple';

  @override
  String get colorThemeChwiram => 'Chwiram Mint';

  @override
  String get languageSystem => 'Use device language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageChineseTraditional => '繁體中文';

  @override
  String get languageChanged => 'Language updated';

  @override
  String get voiceCoachingEnabled => 'Voice coaching';

  @override
  String get voiceRepCountEnabled => 'Speak rep count';

  @override
  String get voiceFormEnabled => 'Form tips';

  @override
  String get voiceEncouragementEnabled => 'Encouragement';

  @override
  String get voiceRate => 'Speech speed';

  @override
  String get voiceRateSlow => 'Slow';

  @override
  String get voiceRateNormal => 'Normal';

  @override
  String get voiceRateFast => 'Fast';

  @override
  String get voiceTest => 'Test voice';

  @override
  String get voiceTestPhrase => 'Great. Your voice coach is ready.';

  @override
  String get voiceUnavailable =>
      'No compatible offline voice is installed for this language.';

  @override
  String get reminderTitle => 'Workout reminders';

  @override
  String get reminderSubtitle =>
      'Choose a time for each day you want to train.';

  @override
  String get reminderEnabled => 'Reminder enabled';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get reminderCopyTime => 'Copy this time';

  @override
  String reminderCopyFromDay(String day) {
    return 'Copy time from $day';
  }

  @override
  String get reminderApplyAll => 'Apply to every day';

  @override
  String reminderNext(String dateTime) {
    return 'Next reminder: $dateTime';
  }

  @override
  String get reminderNoneScheduled => 'No reminders scheduled';

  @override
  String get reminderPermissionNeeded =>
      'Allow notifications to turn on reminders.';

  @override
  String get reminderSaved => 'Reminder schedule saved';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get weekdayMondayShort => 'Mon';

  @override
  String get weekdayTuesdayShort => 'Tue';

  @override
  String get weekdayWednesdayShort => 'Wed';

  @override
  String get weekdayThursdayShort => 'Thu';

  @override
  String get weekdayFridayShort => 'Fri';

  @override
  String get weekdaySaturdayShort => 'Sat';

  @override
  String get weekdaySundayShort => 'Sun';

  @override
  String get cameraFront => 'Front camera';

  @override
  String get cameraRear => 'Rear camera';

  @override
  String get cameraMirrorPreview => 'Mirror front preview';

  @override
  String get cameraPoseOverlay => 'Pose guide overlay';

  @override
  String get cameraKeepScreenAwake => 'Keep screen awake during workouts';

  @override
  String get settingsHaptics => 'Haptic feedback';

  @override
  String get privacyTitle => 'How your data is handled';

  @override
  String get privacyLocalProcessing => 'Pose analysis runs on this device.';

  @override
  String get privacyNoVideoStorage =>
      'Workout video is stored only on this device when Rep Video Review is enabled.';

  @override
  String get privacyNoUpload => 'Camera frames are not uploaded to a server.';

  @override
  String get privacyStoredData => 'Data stored on this device';

  @override
  String get privacyStoredDataDescription =>
      'MotionFit saves workout times, sets, reps, and form results so you can review your progress.';

  @override
  String get privacyDeleteData => 'Delete all workout data';

  @override
  String get privacyDeleteConfirmTitle => 'Delete all workout data?';

  @override
  String get privacyDeleteConfirmBody =>
      'This permanently removes your workout history from this device. This cannot be undone.';

  @override
  String get privacyDeleteConfirmAction => 'Delete all data';

  @override
  String get privacyDeleteSuccess => 'Workout data deleted';

  @override
  String get privacyDeleteFailure => 'Workout data could not be deleted.';

  @override
  String get appInfoTitle => 'App information';

  @override
  String appInfoVersion(String version) {
    return 'Version $version';
  }

  @override
  String get appInfoLicenses => 'Open-source licenses';

  @override
  String get appInfoPrivacyPolicy => 'Privacy policy';

  @override
  String get appInfoDescription =>
      'MotionFit counts squats and offers private, on-device form guidance.';

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get errorGenericBody =>
      'Please try again. Your existing workout records are safe.';

  @override
  String get errorCameraInit => 'The camera could not start.';

  @override
  String get errorCameraInUse => 'The camera may be in use by another app.';

  @override
  String get errorPoseModelLoad => 'The pose model could not be loaded.';

  @override
  String get errorNoPerson => 'No person detected. Step into view.';

  @override
  String get errorWholeBody => 'Checking for a shoulder, hip, and knee chain.';

  @override
  String get errorMultiplePeople =>
      'More than one person is in view. Keep only one person in frame.';

  @override
  String get errorTrackingLost =>
      'The workout continues while detection keeps trying.';

  @override
  String get errorDatabaseSave => 'Your workout could not be saved.';

  @override
  String get errorTtsVoiceMissing =>
      'A speech voice is not installed on this device.';

  @override
  String get errorTtsLocaleUnsupported =>
      'Voice coaching is not supported for the selected language on this device.';

  @override
  String get emptyNoFormIssues => 'No repeated form issues were detected.';

  @override
  String get emptyNotEnoughData => 'Not enough data yet';

  @override
  String get loadingCamera => 'Starting camera…';

  @override
  String get loadingPoseModel => 'Preparing movement detection…';

  @override
  String get loadingSavingWorkout => 'Saving workout…';

  @override
  String get formScore => 'Form score';

  @override
  String get formShort => 'Form';

  @override
  String formScoreValue(int score) {
    return '$score pts';
  }

  @override
  String get formIssueDepth => 'Squat depth';

  @override
  String get formIssueTorsoLean => 'Upper-body stability';

  @override
  String get formIssueHeelLift => 'Heel contact';

  @override
  String get formIssueKneeAlignment => 'Knee alignment';

  @override
  String get formIssueBalance => 'Left–right balance';

  @override
  String get formIssueDescentSpeed => 'Descent speed';

  @override
  String get formIssueAscentSpeed => 'Ascent speed';

  @override
  String get formIssueControl => 'Movement control';

  @override
  String get formIssueStandingCompletion => 'Standing finish';

  @override
  String get formIssueNotObservable => 'Not assessable from this camera angle';

  @override
  String get formStrengthDepth => 'Consistent depth';

  @override
  String get formStrengthControl => 'Controlled movement';

  @override
  String get formStrengthBalance => 'Steady balance';

  @override
  String get coachTrackingLost1 =>
      'Your workout is still running while I keep detecting.';

  @override
  String get coachTrackingLost2 =>
      'A brief occlusion will not pause your workout.';

  @override
  String get coachWholeBody1 =>
      'I can measure when a shoulder, hip, and knee are visible.';

  @override
  String get coachWholeBody2 =>
      'Keep exercising even when your ankles are out of frame.';

  @override
  String get coachMultiplePeople1 =>
      'Keep just one person in frame so I can track you.';

  @override
  String get coachReady1 => 'You’re in position. Let’s begin.';

  @override
  String get coachReady2 => 'Great position. Get ready for your first squat.';

  @override
  String coachStartSet(int set) {
    return 'Set $set. Let’s go.';
  }

  @override
  String coachSevenDayChallengeStart(int day) {
    return 'Starting day $day of the seven-day challenge.';
  }

  @override
  String coachCumulativeChallengeStart(int completed, int remaining) {
    return 'Starting the cumulative reps challenge. You have completed $completed reps, with $remaining remaining.';
  }

  @override
  String coachRepCount(int count) {
    return '$count';
  }

  @override
  String get coachDepth1 => 'Next rep, try going a little lower.';

  @override
  String get coachDepth2 => 'Give the next squat a little more depth.';

  @override
  String get coachTorso1 => 'Keep your upper body a little steadier.';

  @override
  String get coachTorso2 =>
      'On the next rep, keep your chest comfortably lifted.';

  @override
  String get coachHeel1 => 'Try to keep your heels on the floor.';

  @override
  String get coachHeel2 => 'Press through your whole foot on the next rep.';

  @override
  String get coachKnees1 => 'Let your knees follow the direction of your toes.';

  @override
  String get coachKnees2 => 'On the next rep, keep your knees gently aligned.';

  @override
  String get coachBalance1 => 'Keep your weight even on both sides.';

  @override
  String get coachBalance2 => 'Find an even, steady stance for the next rep.';

  @override
  String get coachDescendSlow1 =>
      'Try lowering a little more slowly next time.';

  @override
  String get coachDescendSlow2 => 'Control the way down on your next rep.';

  @override
  String get coachDescendFaster1 =>
      'Move through the descent a little faster next time.';

  @override
  String get coachDescendFaster2 =>
      'Keep the next descent moving without pausing.';

  @override
  String get coachAscendControlled1 => 'Come up smoothly and stay in control.';

  @override
  String get coachAscendControlled2 => 'Use a steady pace as you stand.';

  @override
  String get coachAscendFaster1 => 'Drive up a little more confidently.';

  @override
  String get coachAscendFaster2 =>
      'Stand up with a little more momentum on the next rep.';

  @override
  String get coachControl1 => 'Make the next rep smooth from start to finish.';

  @override
  String get coachControl2 => 'Stay controlled through the whole movement.';

  @override
  String get coachStandTall1 => 'Finish by standing a little taller.';

  @override
  String get coachStandTall2 =>
      'Come all the way back to your standing position.';

  @override
  String get coachGood1 => 'Nice. Keep that rhythm.';

  @override
  String get coachGood2 => 'Good control. Keep it going.';

  @override
  String get coachGood3 => 'Strong rep. Do that again.';

  @override
  String get coachLastTwo => 'Last two. Stay strong!';

  @override
  String get coachLastOne => 'Last one. Finish strong!';

  @override
  String coachSetComplete(int set) {
    return 'Great. Set $set is complete.';
  }

  @override
  String coachRestStart(int seconds) {
    return 'Rest for $seconds seconds. Breathe and reset.';
  }

  @override
  String get coachRestTenSeconds => 'Ten seconds of rest left.';

  @override
  String get coachRestComplete => 'Rest is over. Get ready for the next set.';

  @override
  String coachWorkoutComplete(int reps) {
    return 'Workout complete. You finished $reps squats.';
  }

  @override
  String get notificationReminderTitle => 'Time for today’s squats';

  @override
  String get notificationReminderBody =>
      'Even a short session counts. Open MotionFit when you’re ready.';

  @override
  String get notificationReminderBodyVariant2 =>
      'A few focused squats can make today’s movement count.';

  @override
  String notificationStreakReminderBody(int days) {
    return 'Keep your $days-day streak alive with a short session today.';
  }

  @override
  String get semanticsIncrease => 'Increase';

  @override
  String get semanticsDecrease => 'Decrease';

  @override
  String semanticsSelectedTab(String tab) {
    return 'Selected tab: $tab';
  }

  @override
  String semanticsCalendarWorkoutDate(String date) {
    return '$date, workout recorded';
  }

  @override
  String semanticsCalendarEmptyDate(String date) {
    return '$date, no workout';
  }

  @override
  String semanticsCurrentRep(int current, int target) {
    return 'Current repetition $current of $target';
  }

  @override
  String get repVideoReviewTitle => 'Rep Video Review';

  @override
  String get repVideoReviewDescription =>
      'Save workout videos on this device to review individual reps.';

  @override
  String get repVideoLocalOnly => 'Local only · Never uploaded';

  @override
  String get formReviewTitle => 'Form review';

  @override
  String get formReviewMainIssue => 'Main issue';

  @override
  String get viewRepTimeline => 'View rep timeline';

  @override
  String get repTimelineTitle => 'Rep review';

  @override
  String get repTimelineAll => 'All';

  @override
  String get repTimelineImprove => 'Improve';

  @override
  String get repTimelineNoImprovement => 'No reps need improvement.';

  @override
  String repSetNumber(int number) {
    return 'Set $number';
  }

  @override
  String repNumber(int number) {
    return 'Rep $number';
  }

  @override
  String get repResultGood => 'Good form';

  @override
  String get repResultNeedsAttention => 'Needs attention';

  @override
  String get repResultImproved => 'Better than the previous rep';

  @override
  String get repResultNotAssessed => 'Hard to assess';

  @override
  String get repIssueShallowDepth => 'Try a little more depth';

  @override
  String get repIssueForwardLean => 'Upper body leaned forward';

  @override
  String get repIssueKneesInward => 'Knees moved inward';

  @override
  String get repVideoNotSaved => 'Video not saved';

  @override
  String get repReplay => 'Replay';

  @override
  String get repWhatHappened => 'What happened';

  @override
  String get repHowToImprove => 'How to improve';

  @override
  String get repWhatWentWell => 'What went well';

  @override
  String get repPrevious => 'Previous rep';

  @override
  String get repNext => 'Next rep';

  @override
  String get repFeedbackGood =>
      'This rep stayed within the form ranges MotionFit could assess.';

  @override
  String get repFeedbackDepth =>
      'You did not reach your usual squat depth. Try lowering a little more while keeping your chest stable.';

  @override
  String get repFeedbackTorso =>
      'Your upper body leaned too far during this rep. Keep your chest more upright.';

  @override
  String get repFeedbackKnees =>
      'Your knees moved inward during this rep. Keep them aligned with your toes.';

  @override
  String repFeedbackGeneric(String area) {
    return 'This rep needs attention in $area.';
  }

  @override
  String get deleteWorkoutVideo => 'Delete workout video';

  @override
  String get deleteWorkoutVideoTitle => 'Delete this workout video?';

  @override
  String get deleteWorkoutVideoBody =>
      'Only the local video will be deleted. Rep analysis and workout records will stay.';

  @override
  String get workoutVideoDeleted => 'Workout video deleted';
}
