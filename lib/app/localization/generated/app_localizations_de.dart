// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'motionfit - workout coach';

  @override
  String get navSquat => 'Kniebeugen';

  @override
  String get navWorkout => 'Training';

  @override
  String get navChallenge => 'Challenge';

  @override
  String get navRecords => 'Fortschritt';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get challengeTitle => 'Meine Kniebeugen-Challenge';

  @override
  String get challengeSubtitle =>
      'Wähle eine Challenge passend zu deinem Ziel und trainiere regelmäßig.';

  @override
  String get challengeChooseTitle => 'Challenge auswählen';

  @override
  String get challengeSevenDayTitle => '7-Tage-Einstiegs-Challenge';

  @override
  String get challengeSevenDayDescription =>
      'Ein schrittweises Programm für Einsteiger';

  @override
  String get challengeSevenDaySummary =>
      '7 Tage lang jeden Tag ein steigendes Ziel passend zu deinem Niveau.';

  @override
  String get challengeSevenDayEveryDay => '7 Tage täglich ohne Erholungstag';

  @override
  String challengeDurationDays(int days) {
    return '$days Tage';
  }

  @override
  String get challengeLevelGoals => 'Ziele passend zu deinem Niveau';

  @override
  String get challengeRecoveryIncluded => 'Mit Erholungstagen';

  @override
  String get challengeDailyGoal => 'Tägliche Wiederholungsziele';

  @override
  String get challengeSevenDayStart => '7-Tage-Challenge starten';

  @override
  String get challengeSevenDaySettings => '7-Tage-Ziel festlegen';

  @override
  String get challengeSevenDaySettingsDescription =>
      'Lege Tag 1 fest. Das Ziel steigt täglich um 5 Wiederholungen.';

  @override
  String get challengeFirstDayGoal => 'Zielwiederholungen an Tag 1';

  @override
  String challengeSevenDayPreview(int first, int last) {
    return 'Tag 1: $first → Tag 7: $last Wiederholungen';
  }

  @override
  String get challengeWeeklyTitle => '3-mal-pro-Woche-Challenge';

  @override
  String get challengeWeeklyDescription =>
      'Eine Gewohnheits-Challenge, wenn tägliches Training zu viel ist';

  @override
  String get challengeWeeklySummary =>
      'Trainiere 4 Wochen lang an 3 gewählten Tagen pro Woche.';

  @override
  String challengeDurationWeeks(int weeks) {
    return '$weeks Wochen';
  }

  @override
  String get challengeThreePerWeek => '3 Trainings pro Woche';

  @override
  String get challengeChooseWeekdays => '3 Trainingstage auswählen';

  @override
  String get challengeWorkoutDaysCount => 'Fortschritt nach Trainingstagen';

  @override
  String get challengeWeeklyStart => 'Wochen-Challenge starten';

  @override
  String get challengeCumulativeTitle => 'Gesamtwiederholungs-Challenge';

  @override
  String get challengeCumulativeDescription =>
      'Erreiche dein Kniebeugen-Ziel in deinem eigenen Zeitplan';

  @override
  String get challengeCumulativeSummary =>
      'Wähle Dauer und Gesamtziel; Pausentage erhalten deinen Fortschritt.';

  @override
  String get challengePreset200 => '200 Kniebeugen in 7 Tagen';

  @override
  String get challengePreset500 => '500 Kniebeugen in 14 Tagen';

  @override
  String get challengeCustomGoal => 'Dauer und Ziel selbst wählen';

  @override
  String get challengeRestWithoutReset =>
      'Pausentage setzen den Fortschritt nicht zurück';

  @override
  String get challengeCumulativeStart => 'Gesamtziel starten';

  @override
  String get challengeHistoryTitle => 'Vergangene Challenges';

  @override
  String get challengeHistoryEmpty =>
      'Abgeschlossene und beendete Challenges erscheinen hier.';

  @override
  String get challengeRecommended => 'Für dich empfohlen';

  @override
  String challengeRecommendationFromWorkout(int reps) {
    return 'Empfohlen anhand deines ersten Trainings mit $reps Wiederholungen.';
  }

  @override
  String get challengeRecommendationDefault =>
      'Für deine erste Challenge empfehlen wir einen sanften 7-Tage-Start.';

  @override
  String get challengeActive => 'Aktive Challenge';

  @override
  String get challengeNext => 'Als Nächstes';

  @override
  String challengeDayNumber(int day) {
    return 'Tag $day';
  }

  @override
  String get challengeRecoveryDay => 'Erholungstag';

  @override
  String challengeTodayProgress(int current, int target) {
    return 'Heute $current / $target Wiederholungen';
  }

  @override
  String get challengeRestToday => 'Erhole dich heute ausreichend.';

  @override
  String get challengeTodayCompleted =>
      'Heutiges Ziel erreicht · Morgen geht es weiter';

  @override
  String challengeRepsRemaining(int reps) {
    return 'Noch $reps Wiederholungen';
  }

  @override
  String challengeWeekNumber(int week) {
    return 'Woche $week';
  }

  @override
  String challengeThisWeekProgress(int current, int target) {
    return 'Diese Woche $current / $target Trainings';
  }

  @override
  String challengeOverallDays(int current, int target) {
    return 'Gesamt $current / $target Tage';
  }

  @override
  String challengeRepsProgress(int current, int target) {
    return '$current / $target Wiederholungen';
  }

  @override
  String challengeDaysRemaining(int days) {
    return 'Noch $days Tage';
  }

  @override
  String challengeTodaySuggested(int reps) {
    return 'Heutige Empfehlung: $reps Wiederholungen';
  }

  @override
  String challengePercent(int percent) {
    return '$percent % abgeschlossen';
  }

  @override
  String get challengeSquatStart => 'Kniebeugen starten';

  @override
  String get challengeTodayWorkoutStart => 'Heutiges Training starten';

  @override
  String get challengeViewDetails => 'Details anzeigen';

  @override
  String get challengeRestart => 'Erneut starten';

  @override
  String get challengeDeleteHistory => 'Aus Verlauf löschen';

  @override
  String get challengeCumulativeSettings => 'Gesamtziel festlegen';

  @override
  String get challengeDurationLabel => 'Dauer';

  @override
  String get challengeGoalLabel => 'Zielwiederholungen';

  @override
  String get challengeNotFound => 'Diese Challenge ist nicht mehr verfügbar.';

  @override
  String get challengePeriod => 'Zeitraum';

  @override
  String get challengeStatus => 'Status';

  @override
  String get challengeTotalReps => 'Kniebeugen gesamt';

  @override
  String get challengeWorkoutDays => 'Trainingstage';

  @override
  String challengeDaysCount(int days) {
    return '$days Tage';
  }

  @override
  String get challengeTotalTime => 'Gesamte Trainingszeit';

  @override
  String get challengeSchedule => 'Plan und Fortschritt';

  @override
  String get challengeNotifications => 'Challenge-Erinnerungen';

  @override
  String get challengeNotificationsDescription =>
      'Erinnerungseinstellung für diese Challenge speichern.';

  @override
  String get challengeReminderNotificationTitle =>
      'Deine Kniebeugen-Challenge wartet';

  @override
  String get challengeReminderNotificationBody =>
      'Öffne MotionFit und arbeite an deinem heutigen Challenge-Ziel.';

  @override
  String get challengeSelectedWeekdays => 'Ausgewählte Trainingstage';

  @override
  String get challengeNoProgressYet => 'Noch keine Challenge-Trainings.';

  @override
  String get challengeCancel => 'Challenge beenden';

  @override
  String get challengeCancelTitle => 'Diese Challenge beenden?';

  @override
  String get challengeCancelDescription =>
      'Deine Trainingsdaten bleiben erhalten. Die Challenge wird in den Verlauf verschoben.';

  @override
  String get challengeStatusActive => 'In Bearbeitung';

  @override
  String get challengeStatusCompleted => 'Abgeschlossen';

  @override
  String get challengeStatusEnded => 'Beendet';

  @override
  String get challengeStatusCancelled => 'Abgebrochen';

  @override
  String get challengeProgressUpdated =>
      'Dein Challenge-Fortschritt wurde aktualisiert.';

  @override
  String get challengeCheck => 'Challenge anzeigen';

  @override
  String get commonDone => 'Fertig';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonConfirm => 'Bestätigen';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get commonStart => 'Starten';

  @override
  String get commonSkip => 'Überspringen';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonOn => 'Ein';

  @override
  String get commonOff => 'Aus';

  @override
  String get commonEnabled => 'Aktiviert';

  @override
  String get commonDisabled => 'Deaktiviert';

  @override
  String get commonNotAvailable => 'Nicht verfügbar';

  @override
  String get commonToday => 'Heute';

  @override
  String get commonYesterday => 'Gestern';

  @override
  String get commonLoading => 'Wird geladen…';

  @override
  String unitSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sätze',
      one: '1 Satz',
      zero: '0 Sätze',
    );
    return '$_temp0';
  }

  @override
  String unitReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wiederholungen',
      one: '1 Wiederholung',
      zero: '0 Wiederholungen',
    );
    return '$_temp0';
  }

  @override
  String unitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sekunden',
      one: '1 Sekunde',
      zero: '0 Sekunden',
    );
    return '$_temp0';
  }

  @override
  String unitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minuten',
      one: '1 Minute',
      zero: '0 Minuten',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes Min. $seconds Sek.';
  }

  @override
  String get homeGreeting => 'Bereit für Bewegung?';

  @override
  String get homeTodayTitle => 'Heutiger Stand';

  @override
  String get homeTodayNoWorkout =>
      'Heute noch keine Kniebeugen. Ein kurzer Satz ist ein guter Anfang.';

  @override
  String homeTodaySummary(int reps, int sets) {
    return 'Kniebeugen: $reps · Sätze: $sets';
  }

  @override
  String get homeViewResult => 'Ergebnis';

  @override
  String get homeTodaySets => 'Sätze heute';

  @override
  String get homeTodayReps => 'Heute geschafft';

  @override
  String get streakLabel => 'Serie';

  @override
  String streakDays(int days) {
    return '$days Tage';
  }

  @override
  String get homeWorkoutSetup => 'Nächstes Training';

  @override
  String get homeSetsLabel => 'Sätze';

  @override
  String get homeRepsPerSetLabel => 'Wiederholungen pro Satz';

  @override
  String get homeRestTimeLabel => 'Pausenzeit';

  @override
  String get homeDirectInputHint => 'Zahl eingeben';

  @override
  String get homeStartWorkout => 'Training starten';

  @override
  String get homeLastSettingsRestored =>
      'Deine letzten Trainingseinstellungen sind bereit.';

  @override
  String get validationNumberRequired => 'Gib eine Zahl ein.';

  @override
  String validationRange(num min, num max) {
    return 'Wähle einen Wert zwischen $min und $max.';
  }

  @override
  String get guideTitle => 'Kamera einrichten';

  @override
  String get guideSubtitle =>
      'Eine klare Ganzkörperansicht hilft MotionFit, zuverlässig zu zählen.';

  @override
  String get guideWholeBody =>
      'Achte darauf, dass dein ganzer Körper von Kopf bis Fuß sichtbar ist.';

  @override
  String get guideStableCamera =>
      'Stelle dein Smartphone an einem stabilen Ort auf.';

  @override
  String get guideOnePerson =>
      'Achte darauf, dass nur eine Person im Bild ist.';

  @override
  String get guideCameraAngle =>
      'Nutze möglichst eine Seitenansicht oder eine leicht schräge Seitenansicht.';

  @override
  String get guideLighting => 'Vermeide dunkle Räume und starkes Gegenlicht.';

  @override
  String get guidePrivacy =>
      'Das Video bleibt auf diesem Gerät und wird nur bei aktivierter Wiederholungsanalyse gespeichert.';

  @override
  String get guideContinue => 'Ich bin in Position';

  @override
  String get permissionCameraTitle => 'Kamerazugriff erforderlich';

  @override
  String get permissionCameraBody =>
      'MotionFit nutzt die Kamera zum Zählen. Videos werden nur bei aktivierter Wiederholungsanalyse auf diesem Gerät gespeichert.';

  @override
  String get permissionCameraRequest => 'Weiter';

  @override
  String get permissionCameraDenied =>
      'Der Kamerazugriff wurde abgelehnt. Du kannst weiterhin Verlauf und Einstellungen ansehen.';

  @override
  String get permissionCameraPermanentlyDenied =>
      'Erlaube den Kamerazugriff in den Systemeinstellungen, um ein Training zu starten.';

  @override
  String get permissionOpenSettings => 'Einstellungen öffnen';

  @override
  String get permissionNotificationTitle => 'Trainingserinnerungen erlauben?';

  @override
  String get permissionNotificationBody =>
      'Benachrichtigungen werden nur für deine geplanten Erinnerungen verwendet.';

  @override
  String get permissionNotificationRequest => 'Benachrichtigungen erlauben';

  @override
  String get permissionNotificationDenied =>
      'Benachrichtigungen sind deaktiviert. Aktiviere sie in den Systemeinstellungen, um Erinnerungen zu erhalten.';

  @override
  String get countdownGetReady => 'Mach dich bereit';

  @override
  String countdownBeginsIn(int seconds) {
    return 'Start in $seconds';
  }

  @override
  String get calibrationTitle => 'Deine Standposition wird erfasst';

  @override
  String get calibrationBody =>
      'Stehe aufrecht und bleibe mit dem ganzen Körper im Bild.';

  @override
  String get calibrationStayStill => 'Halte einen Moment still';

  @override
  String get calibrationComplete => 'Alles bereit';

  @override
  String get calibrationFailed =>
      'Deine Standposition konnte nicht eindeutig erfasst werden.';

  @override
  String get calibrationRetry => 'Neu kalibrieren';

  @override
  String workoutSetProgress(int current, int total) {
    return 'Satz $current von $total';
  }

  @override
  String workoutRepProgress(int current, int target) {
    return '$current von $target';
  }

  @override
  String workoutTotalReps(int count) {
    return 'Gesamt: $count';
  }

  @override
  String get workoutElapsed => 'Verstrichene Zeit';

  @override
  String get workoutPause => 'Pause';

  @override
  String get workoutResume => 'Training fortsetzen';

  @override
  String get workoutEnd => 'Training pausieren';

  @override
  String get workoutBackToSetup => 'Zurück zur Einrichtung';

  @override
  String get workoutEndDialogTitle => 'Training vorerst pausieren?';

  @override
  String get workoutEndDialogBody =>
      'Dein Fortschritt wird gespeichert, damit du vom Startbildschirm aus fortfahren kannst.';

  @override
  String get workoutEndDialogConfirm => 'Speichern und verlassen';

  @override
  String get workoutPauseReasonBackground =>
      'Das Training wurde pausiert, während die App im Hintergrund war.';

  @override
  String get workoutPauseReasonInterruption =>
      'Das Training wurde nach einer Systemunterbrechung pausiert.';

  @override
  String get workoutStateReady => 'Bereit';

  @override
  String get workoutStateDescending => 'Nach unten';

  @override
  String get workoutStateBottom => 'Tiefste Position';

  @override
  String get workoutStateAscending => 'Nach oben';

  @override
  String get workoutStateCompleted => 'Gute Wiederholung';

  @override
  String get workoutStateTrackingLost => 'Geh zurück ins Bild';

  @override
  String get workoutStatePaused => 'Pausiert';

  @override
  String get workoutTrackingGood => 'Körper im Bild';

  @override
  String get workoutCameraSwitch => 'Kamera wechseln';

  @override
  String get workoutSkeletonToggle => 'Positionshilfe anzeigen';

  @override
  String get restTitle => 'Pause';

  @override
  String restNextSet(int set, int total) {
    return 'Als Nächstes: Satz $set von $total';
  }

  @override
  String get restCompletedSets => 'Abgeschlossene Sätze';

  @override
  String get restTotalReps => 'Bisherige Kniebeugen';

  @override
  String get restSkip => 'Pause überspringen';

  @override
  String get restAddFifteenSeconds => '15 Sekunden hinzufügen';

  @override
  String get restEndWorkout => 'Training pausieren';

  @override
  String get restAlmostDone => 'Gleich geht es weiter';

  @override
  String get restReady => 'Zeit für den nächsten Satz';

  @override
  String get completeTitle => 'Training abgeschlossen';

  @override
  String get completeSubtitle =>
      'Starke Leistung. Hier siehst du dein Training auf einen Blick.';

  @override
  String get workoutInterruptedSubtitle =>
      'Sieh dir die Aufzeichnung bis zum vorzeitigen Ende an.';

  @override
  String get completeTotalReps => 'Kniebeugen gesamt';

  @override
  String get completeCompletedSets => 'Abgeschlossene Sätze';

  @override
  String get completeActiveTime => 'Aktive Zeit';

  @override
  String get completeRestTime => 'Pausenzeit';

  @override
  String get completeTotalTime => 'Gesamtzeit';

  @override
  String get completeAverageRepTime => 'Ø Wiederholungszeit';

  @override
  String get completeFormSummary => 'Technikübersicht';

  @override
  String get todayCoaching => 'Heutiges Coaching';

  @override
  String coachingIssueFrequency(int total, int count, String issue) {
    return 'Bei $count von $total Wiederholungen:\n$issue';
  }

  @override
  String get completeTopImprovement => 'Fokus fürs nächste Mal';

  @override
  String get completeStrengths => 'Das lief gut';

  @override
  String get completeSaved => 'Training auf diesem Gerät gespeichert';

  @override
  String get completeSaveFailed =>
      'Das Training konnte nicht gespeichert werden. Versuche es erneut, bevor du die Seite verlässt.';

  @override
  String get completeNoFormData =>
      'Für eine Technikübersicht war nicht genug Bewegung sichtbar.';

  @override
  String get completeFinish => 'Fertig';

  @override
  String get postWorkoutReminderTitle => 'Bleib in Bewegung';

  @override
  String postWorkoutReminderBody(String time) {
    return 'Möchtest du ab morgen täglich um $time erinnert werden?';
  }

  @override
  String get postWorkoutReminderEnable => 'Erinnere mich';

  @override
  String get postWorkoutReminderLater => 'Vielleicht später';

  @override
  String get postWorkoutReminderEnabled => 'Deine Erinnerung ist eingerichtet.';

  @override
  String get recordsTitle => 'Fortschritt';

  @override
  String get recordsWeeklySummary => 'Diese Woche';

  @override
  String recordsWorkoutCount(int count) {
    return '$count Trainings';
  }

  @override
  String recordsAverageForm(int score) {
    return 'Ø Technik $score';
  }

  @override
  String recordsWorkoutTime(String time) {
    return 'Zeit $time';
  }

  @override
  String get recordsFirstWeek => 'Dein erster Eintrag diese Woche';

  @override
  String recordsMoreThanLastWeek(int count) {
    return '$count Wiederholungen mehr als letzte Woche';
  }

  @override
  String recordsLessThanLastWeek(int count) {
    return '$count Wiederholungen weniger als letzte Woche';
  }

  @override
  String get recordsSameAsLastWeek => 'Gleiches Volumen wie letzte Woche';

  @override
  String get recordsTrendEmpty =>
      'Mit weiteren Trainings wird dein Techniktrend sichtbar.';

  @override
  String get recordsFirstFormScore => 'Erster Technikwert';

  @override
  String recordsRecentAverage(int count, int score) {
    return 'Durchschnitt der letzten $count: $score';
  }

  @override
  String get recordsStrength => 'Stärke';

  @override
  String get recordsFocus => 'Fokus';

  @override
  String get recordsTodayPoint => 'Heutiger Fokus';

  @override
  String get recordsToday => 'Heute';

  @override
  String get recordsRecentWorkouts => 'Letzte Trainings';

  @override
  String get recordsCalendarTitle => 'Trainingskalender';

  @override
  String get recordsFormTrend => 'Formtrend';

  @override
  String get recordsViewCalendar => 'Kalender';

  @override
  String get recordsViewList => 'Liste';

  @override
  String get recordsViewStats => 'Statistik';

  @override
  String get recordsCalendarPreviousMonth => 'Vorheriger Monat';

  @override
  String get recordsCalendarNextMonth => 'Nächster Monat';

  @override
  String get recordsCalendarWorkoutDay => 'Trainingstag';

  @override
  String get recordsCalendarNoWorkoutSelected =>
      'Wähle einen Trainingstag aus, um die Einheiten anzuzeigen.';

  @override
  String get recordsDayTotal => 'Tagessumme';

  @override
  String recordsSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einheiten',
      one: '1 Einheit',
      zero: 'Keine Einheiten',
    );
    return '$_temp0';
  }

  @override
  String recordsSessionTitle(int number) {
    return 'Einheit $number';
  }

  @override
  String get recordsListNewest => 'Neueste zuerst';

  @override
  String get recordsOpenDetail => 'Details anzeigen';

  @override
  String get recordsEmptyTitle => 'Noch keine Trainings';

  @override
  String get recordsEmptyBody =>
      'Schließe dein erstes Kniebeugentraining ab. Danach erscheint es hier.';

  @override
  String get recordsStartWorkout => 'Training starten';

  @override
  String get recordsLoading => 'Deine Trainings werden geladen…';

  @override
  String get recordsLoadError =>
      'Dein Trainingsverlauf konnte nicht geladen werden.';

  @override
  String get statsPeriod => 'Zeitraum';

  @override
  String get statsPeriod7Days => '7 Tage';

  @override
  String get statsPeriod30Days => '30 Tage';

  @override
  String get statsPeriodThisMonth => 'Dieser Monat';

  @override
  String get statsPeriodAll => 'Gesamter Zeitraum';

  @override
  String get statsPeriodCustom => 'Benutzerdefiniert';

  @override
  String get statsCustomRange => 'Datumsbereich wählen';

  @override
  String get statsTotalReps => 'Kniebeugen gesamt';

  @override
  String get statsWorkoutDays => 'Trainingstage';

  @override
  String get statsTotalActiveTime => 'Aktive Zeit';

  @override
  String get statsAverageSets => 'Ø Sätze';

  @override
  String get statsAverageReps => 'Ø Kniebeugen';

  @override
  String get statsDailyReps => 'Kniebeugen pro Tag';

  @override
  String get statsTrend => 'Verlauf';

  @override
  String get statsFrequentImprovements => 'Häufige Schwerpunkte';

  @override
  String get statsNoData => 'Keine Trainings in diesem Zeitraum.';

  @override
  String statsTrendUp(num percent) {
    return 'Plus $percent %';
  }

  @override
  String statsTrendDown(num percent) {
    return 'Minus $percent %';
  }

  @override
  String get statsTrendFlat => 'Keine Veränderung';

  @override
  String get detailTitle => 'Trainingsdetails';

  @override
  String get detailStartTime => 'Beginn';

  @override
  String get detailEndTime => 'Ende';

  @override
  String get detailActiveTime => 'Aktive Zeit';

  @override
  String get detailRestTime => 'Pausenzeit';

  @override
  String get detailTotalTime => 'Gesamtzeit';

  @override
  String get detailSets => 'Sätze';

  @override
  String get detailSetBreakdown => 'Wiederholungen pro Satz';

  @override
  String get detailTotalReps => 'Kniebeugen gesamt';

  @override
  String get detailAverageRep => 'Ø Wiederholungszeit';

  @override
  String get detailFormSummary => 'Technikübersicht';

  @override
  String get detailImprovements => 'Verbesserungspunkte';

  @override
  String get detailStrengths => 'Stärken';

  @override
  String get detailInterrupted => 'Vorzeitig beendet';

  @override
  String get detailCompleted => 'Abgeschlossen';

  @override
  String detailSetRow(int set, int reps) {
    return 'Satz $set: $reps Wdh.';
  }

  @override
  String detailSessionOn(String date, String time) {
    return '$date um $time';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsRateApp => 'Diese App bewerten';

  @override
  String get settingsRateAppSubtitle => 'MotionFit bewerten';

  @override
  String get settingsRateAppError =>
      'Der Store konnte nicht geöffnet werden. Bitte versuche es erneut.';

  @override
  String get settingsSectionGeneral => 'Allgemein';

  @override
  String get settingsSectionCoaching => 'Sprachcoaching';

  @override
  String get settingsSectionReminder => 'Trainingserinnerungen';

  @override
  String get settingsSectionCamera => 'Kamera';

  @override
  String get settingsSectionPrivacy => 'Datenschutz und Daten';

  @override
  String get settingsSectionAbout => 'Über die App';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsDisplayTheme => 'Bildschirmdesign';

  @override
  String get settingsColorTheme => 'Farbdesign';

  @override
  String get themeLight => 'Hell';

  @override
  String get themePureBlack => 'Reines Schwarz';

  @override
  String get themeSystem => 'System';

  @override
  String get colorThemeByeokcheong => 'Byeokcheong-Blau';

  @override
  String get colorThemeChuhyang => 'Chuhyang-Beige';

  @override
  String get colorThemeJangdan => 'Jangdan-Rot';

  @override
  String get colorThemeCheonghyeon => 'Cheonghyeon-Blau';

  @override
  String get colorThemeHaenghwang => 'Haenghwang-Aprikose';

  @override
  String get colorThemeChunyu => 'Chunyu-Grün';

  @override
  String get colorThemeSeolbaek => 'Seolbaek-Weiß';

  @override
  String get colorThemeByeokja => 'Byeokja-Violett';

  @override
  String get colorThemeChwiram => 'Chwiram-Mint';

  @override
  String get languageSystem => 'Gerätesprache verwenden';

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
  String get languageChanged => 'Sprache aktualisiert';

  @override
  String get voiceCoachingEnabled => 'Sprachcoaching';

  @override
  String get voiceRepCountEnabled => 'Wiederholungen ansagen';

  @override
  String get voiceFormEnabled => 'Techniktipps';

  @override
  String get voiceEncouragementEnabled => 'Motivation';

  @override
  String get voiceRate => 'Sprechgeschwindigkeit';

  @override
  String get voiceRateSlow => 'Langsam';

  @override
  String get voiceRateNormal => 'Normal';

  @override
  String get voiceRateFast => 'Schnell';

  @override
  String get voiceTest => 'Stimme testen';

  @override
  String get voiceTestPhrase => 'Super. Dein Sprachcoach ist bereit.';

  @override
  String get voiceUnavailable =>
      'Für diese Sprache ist keine kompatible Offline-Stimme installiert.';

  @override
  String get reminderTitle => 'Trainingserinnerungen';

  @override
  String get reminderSubtitle =>
      'Wähle für jeden gewünschten Trainingstag eine Uhrzeit aus.';

  @override
  String get reminderEnabled => 'Erinnerung aktiviert';

  @override
  String get reminderTime => 'Uhrzeit der Erinnerung';

  @override
  String get reminderCopyTime => 'Diese Uhrzeit kopieren';

  @override
  String reminderCopyFromDay(String day) {
    return 'Uhrzeit von $day kopieren';
  }

  @override
  String get reminderApplyAll => 'Auf alle Tage anwenden';

  @override
  String reminderNext(String dateTime) {
    return 'Nächste Erinnerung: $dateTime';
  }

  @override
  String get reminderNoneScheduled => 'Keine Erinnerungen geplant';

  @override
  String get reminderPermissionNeeded =>
      'Erlaube Benachrichtigungen, um Erinnerungen zu aktivieren.';

  @override
  String get reminderSaved => 'Erinnerungsplan gespeichert';

  @override
  String get weekdayMonday => 'Montag';

  @override
  String get weekdayTuesday => 'Dienstag';

  @override
  String get weekdayWednesday => 'Mittwoch';

  @override
  String get weekdayThursday => 'Donnerstag';

  @override
  String get weekdayFriday => 'Freitag';

  @override
  String get weekdaySaturday => 'Samstag';

  @override
  String get weekdaySunday => 'Sonntag';

  @override
  String get weekdayMondayShort => 'Mo';

  @override
  String get weekdayTuesdayShort => 'Di';

  @override
  String get weekdayWednesdayShort => 'Mi';

  @override
  String get weekdayThursdayShort => 'Do';

  @override
  String get weekdayFridayShort => 'Fr';

  @override
  String get weekdaySaturdayShort => 'Sa';

  @override
  String get weekdaySundayShort => 'So';

  @override
  String get cameraFront => 'Frontkamera';

  @override
  String get cameraRear => 'Rückkamera';

  @override
  String get cameraMirrorPreview => 'Frontkamera spiegeln';

  @override
  String get cameraPoseOverlay => 'Positionshilfe einblenden';

  @override
  String get cameraKeepScreenAwake =>
      'Bildschirm beim Training eingeschaltet lassen';

  @override
  String get settingsHaptics => 'Haptisches Feedback';

  @override
  String get privacyTitle => 'So werden deine Daten verarbeitet';

  @override
  String get privacyLocalProcessing =>
      'Die Körperhaltungsanalyse erfolgt auf diesem Gerät.';

  @override
  String get privacyNoVideoStorage =>
      'Trainingsvideos werden nur bei aktivierter Wiederholungsanalyse auf diesem Gerät gespeichert.';

  @override
  String get privacyNoUpload =>
      'Kamerabilder werden nicht auf einen Server hochgeladen.';

  @override
  String get privacyStoredData => 'Auf diesem Gerät gespeicherte Daten';

  @override
  String get privacyStoredDataDescription =>
      'MotionFit speichert Trainingszeiten, Sätze, Wiederholungen und Technikergebnisse, damit du deinen Fortschritt verfolgen kannst.';

  @override
  String get privacyDeleteData => 'Alle Trainingsdaten löschen';

  @override
  String get privacyDeleteConfirmTitle => 'Alle Trainingsdaten löschen?';

  @override
  String get privacyDeleteConfirmBody =>
      'Dadurch wird dein Trainingsverlauf dauerhaft von diesem Gerät gelöscht. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get privacyDeleteConfirmAction => 'Alle Daten löschen';

  @override
  String get privacyDeleteSuccess => 'Trainingsdaten gelöscht';

  @override
  String get privacyDeleteFailure =>
      'Die Trainingsdaten konnten nicht gelöscht werden.';

  @override
  String get appInfoTitle => 'App-Informationen';

  @override
  String appInfoVersion(String version) {
    return 'Version $version';
  }

  @override
  String get appInfoLicenses => 'Open-Source-Lizenzen';

  @override
  String get appInfoPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get appInfoDescription =>
      'MotionFit zählt Kniebeugen und bietet private Technikhilfen direkt auf deinem Gerät.';

  @override
  String get errorGenericTitle => 'Etwas ist schiefgelaufen';

  @override
  String get errorGenericBody =>
      'Versuche es bitte erneut. Deine vorhandenen Trainingsdaten sind sicher.';

  @override
  String get errorCameraInit => 'Die Kamera konnte nicht gestartet werden.';

  @override
  String get errorCameraInUse =>
      'Die Kamera wird möglicherweise von einer anderen App verwendet.';

  @override
  String get errorPoseModelLoad =>
      'Das Modell zur Körpererkennung konnte nicht geladen werden.';

  @override
  String get errorNoPerson => 'Keine Person erkannt. Geh ins Bild.';

  @override
  String get errorWholeBody =>
      'Dein Körper ist nicht vollständig sichtbar. Geh etwas weiter zurück.';

  @override
  String get errorMultiplePeople =>
      'Mehr als eine Person ist im Bild. Es darf nur eine Person zu sehen sein.';

  @override
  String get errorTrackingLost =>
      'Die Erfassung ist pausiert, bis dein Körper wieder sichtbar ist.';

  @override
  String get errorDatabaseSave =>
      'Dein Training konnte nicht gespeichert werden.';

  @override
  String get errorTtsVoiceMissing =>
      'Auf diesem Gerät ist keine Sprachausgabe installiert.';

  @override
  String get errorTtsLocaleUnsupported =>
      'Sprachcoaching wird auf diesem Gerät für die ausgewählte Sprache nicht unterstützt.';

  @override
  String get emptyNoFormIssues =>
      'Keine wiederkehrenden Technikprobleme erkannt.';

  @override
  String get emptyNotEnoughData => 'Noch nicht genügend Daten';

  @override
  String get loadingCamera => 'Kamera wird gestartet…';

  @override
  String get loadingPoseModel => 'Bewegungserkennung wird vorbereitet…';

  @override
  String get loadingSavingWorkout => 'Training wird gespeichert…';

  @override
  String get formScore => 'Technikbewertung';

  @override
  String get formShort => 'Form';

  @override
  String formScoreValue(int score) {
    return '$score Pkt.';
  }

  @override
  String get formIssueDepth => 'Kniebeugentiefe';

  @override
  String get formIssueTorsoLean => 'Oberkörperstabilität';

  @override
  String get formIssueHeelLift => 'Fersenkontakt';

  @override
  String get formIssueKneeAlignment => 'Knieausrichtung';

  @override
  String get formIssueBalance => 'Links-rechts-Balance';

  @override
  String get formIssueDescentSpeed => 'Abwärtsgeschwindigkeit';

  @override
  String get formIssueAscentSpeed => 'Aufwärtsgeschwindigkeit';

  @override
  String get formIssueControl => 'Bewegungskontrolle';

  @override
  String get formIssueStandingCompletion => 'Aufrechter Abschluss';

  @override
  String get formIssueNotObservable =>
      'Aus diesem Kamerawinkel nicht beurteilbar';

  @override
  String get formStrengthDepth => 'Gleichmäßige Tiefe';

  @override
  String get formStrengthControl => 'Kontrollierte Bewegung';

  @override
  String get formStrengthBalance => 'Stabiles Gleichgewicht';

  @override
  String get coachTrackingLost1 =>
      'Geh zurück ins Bild, dann machen wir weiter.';

  @override
  String get coachTrackingLost2 =>
      'Ich kann dich nicht mehr sehen. Stell dich so hin, dass dein ganzer Körper sichtbar ist.';

  @override
  String get coachWholeBody1 =>
      'Geh einen Schritt zurück, damit dein ganzer Körper sichtbar ist.';

  @override
  String get coachWholeBody2 =>
      'Achte darauf, dass ich dich von Kopf bis Fuß sehen kann.';

  @override
  String get coachMultiplePeople1 =>
      'Es darf nur eine Person im Bild sein, damit ich dich erfassen kann.';

  @override
  String get coachReady1 => 'Du bist in Position. Los geht’s.';

  @override
  String get coachReady2 =>
      'Gute Position. Mach dich bereit für deine erste Kniebeuge.';

  @override
  String coachStartSet(int set) {
    return 'Satz $set. Los geht’s.';
  }

  @override
  String coachSevenDayChallengeStart(int day) {
    return 'Tag $day der Sieben-Tage-Challenge beginnt.';
  }

  @override
  String coachCumulativeChallengeStart(int completed, int remaining) {
    return 'Die Wiederholungs-Challenge beginnt. Du hast $completed Wiederholungen geschafft, noch $remaining verbleiben.';
  }

  @override
  String coachRepCount(int count) {
    return '$count';
  }

  @override
  String get coachDepth1 =>
      'Versuche bei der nächsten Wiederholung etwas tiefer zu gehen.';

  @override
  String get coachDepth2 => 'Geh bei der nächsten Kniebeuge etwas tiefer.';

  @override
  String get coachTorso1 => 'Halte deinen Oberkörper etwas stabiler.';

  @override
  String get coachTorso2 =>
      'Halte bei der nächsten Wiederholung die Brust entspannt aufrecht.';

  @override
  String get coachHeel1 => 'Versuche, deine Fersen auf dem Boden zu lassen.';

  @override
  String get coachHeel2 =>
      'Drücke dich bei der nächsten Wiederholung über den ganzen Fuß ab.';

  @override
  String get coachKnees1 => 'Führe deine Knie in Richtung deiner Zehen.';

  @override
  String get coachKnees2 =>
      'Halte deine Knie bei der nächsten Wiederholung sanft ausgerichtet.';

  @override
  String get coachBalance1 =>
      'Verteile dein Gewicht gleichmäßig auf beide Seiten.';

  @override
  String get coachBalance2 =>
      'Finde für die nächste Wiederholung einen gleichmäßigen, stabilen Stand.';

  @override
  String get coachDescendSlow1 =>
      'Versuche, dich beim nächsten Mal etwas langsamer abzusenken.';

  @override
  String get coachDescendSlow2 =>
      'Senke dich bei der nächsten Wiederholung kontrolliert ab.';

  @override
  String get coachDescendFaster1 =>
      'Senke dich bei der nächsten Wiederholung etwas zügiger ab.';

  @override
  String get coachDescendFaster2 =>
      'Bleib bei der nächsten Abwärtsbewegung in Bewegung, ohne innezuhalten.';

  @override
  String get coachAscendControlled1 =>
      'Komm gleichmäßig nach oben und behalte die Kontrolle.';

  @override
  String get coachAscendControlled2 =>
      'Stehe in einem gleichmäßigen Tempo auf.';

  @override
  String get coachAscendFaster1 => 'Drücke dich etwas kraftvoller nach oben.';

  @override
  String get coachAscendFaster2 =>
      'Stehe bei der nächsten Wiederholung etwas zügiger auf.';

  @override
  String get coachControl1 =>
      'Führe die nächste Wiederholung von Anfang bis Ende gleichmäßig aus.';

  @override
  String get coachControl2 =>
      'Bleib während der gesamten Bewegung kontrolliert.';

  @override
  String get coachStandTall1 => 'Richte dich zum Abschluss etwas weiter auf.';

  @override
  String get coachStandTall2 =>
      'Kehre vollständig in deine Standposition zurück.';

  @override
  String get coachGood1 => 'Gut. Halte diesen Rhythmus.';

  @override
  String get coachGood2 => 'Gute Kontrolle. Weiter so.';

  @override
  String get coachGood3 => 'Starke Wiederholung. Gleich noch einmal.';

  @override
  String get coachLastTwo => 'Noch zwei. Bleib stark!';

  @override
  String get coachLastOne => 'Noch eine. Stark abschließen!';

  @override
  String coachSetComplete(int set) {
    return 'Super. Satz $set ist geschafft.';
  }

  @override
  String coachRestStart(int seconds) {
    return 'Ruhe dich $seconds Sekunden aus. Atme durch und sammle dich.';
  }

  @override
  String get coachRestTenSeconds => 'Noch zehn Sekunden Pause.';

  @override
  String get coachRestComplete =>
      'Die Pause ist vorbei. Mach dich bereit für den nächsten Satz.';

  @override
  String coachWorkoutComplete(int reps) {
    return 'Training abgeschlossen. Du hast $reps Kniebeugen geschafft.';
  }

  @override
  String get notificationReminderTitle => 'Zeit für deine heutigen Kniebeugen';

  @override
  String get notificationReminderBody =>
      'Auch eine kurze Einheit zählt. Öffne MotionFit, wenn du bereit bist.';

  @override
  String get notificationReminderBodyVariant2 =>
      'Ein paar konzentrierte Kniebeugen bringen heute Bewegung in deinen Tag.';

  @override
  String notificationStreakReminderBody(int days) {
    return 'Halte deine $days-Tage-Serie heute mit einer kurzen Einheit am Leben.';
  }

  @override
  String get semanticsIncrease => 'Erhöhen';

  @override
  String get semanticsDecrease => 'Verringern';

  @override
  String semanticsSelectedTab(String tab) {
    return 'Ausgewählter Tab: $tab';
  }

  @override
  String semanticsCalendarWorkoutDate(String date) {
    return '$date, Training aufgezeichnet';
  }

  @override
  String semanticsCalendarEmptyDate(String date) {
    return '$date, kein Training';
  }

  @override
  String semanticsCurrentRep(int current, int target) {
    return 'Aktuelle Wiederholung $current von $target';
  }

  @override
  String get repVideoReviewTitle => 'Videoanalyse je Wiederholung';

  @override
  String get repVideoReviewDescription =>
      'Speichere dieses Trainingsvideo auf dem Gerät, um einzelne Wiederholungen später anzusehen.';

  @override
  String get repVideoLocalOnly => 'Nur lokal · Kein Upload';

  @override
  String get formReviewTitle => 'Technikanalyse';

  @override
  String get formReviewMainIssue => 'Hauptproblem';

  @override
  String get viewRepTimeline => 'Wiederholungen ansehen';

  @override
  String get repTimelineTitle => 'Wiederholungsanalyse';

  @override
  String get repTimelineAll => 'Alle';

  @override
  String get repTimelineImprove => 'Verbessern';

  @override
  String get repTimelineNoImprovement =>
      'Keine Wiederholung muss verbessert werden.';

  @override
  String repSetNumber(int number) {
    return 'Satz $number';
  }

  @override
  String repNumber(int number) {
    return 'Wiederholung $number';
  }

  @override
  String get repResultGood => 'Gute Technik';

  @override
  String get repResultNeedsAttention => 'Achtung nötig';

  @override
  String get repResultImproved => 'Besser als zuvor';

  @override
  String get repResultNotAssessed => 'Schwer zu bewerten';

  @override
  String get repIssueShallowDepth => 'Versuche etwas tiefer zu gehen';

  @override
  String get repIssueForwardLean => 'Oberkörper war nach vorn geneigt';

  @override
  String get repIssueKneesInward => 'Knie bewegten sich nach innen';

  @override
  String get repVideoNotSaved => 'Video nicht gespeichert';

  @override
  String get repReplay => 'Erneut abspielen';

  @override
  String get repWhatHappened => 'Was passiert ist';

  @override
  String get repHowToImprove => 'So verbesserst du dich';

  @override
  String get repWhatWentWell => 'Was gut war';

  @override
  String get repPrevious => 'Vorherige Wiederholung';

  @override
  String get repNext => 'Nächste Wiederholung';

  @override
  String get repFeedbackGood =>
      'Diese Wiederholung lag in den von MotionFit messbaren Technikbereichen.';

  @override
  String get repFeedbackDepth =>
      'Du hast deine übliche Kniebeugentiefe nicht erreicht. Gehe etwas tiefer und halte den Oberkörper stabil.';

  @override
  String get repFeedbackTorso =>
      'Dein Oberkörper war bei dieser Wiederholung zu weit nach vorn geneigt. Halte die Brust aufrechter.';

  @override
  String get repFeedbackKnees =>
      'Deine Knie bewegten sich bei dieser Wiederholung nach innen. Richte sie an den Zehen aus.';

  @override
  String repFeedbackGeneric(String area) {
    return 'Bei dieser Wiederholung braucht $area Aufmerksamkeit.';
  }

  @override
  String get deleteWorkoutVideo => 'Trainingsvideo löschen';

  @override
  String get deleteWorkoutVideoTitle => 'Dieses Trainingsvideo löschen?';

  @override
  String get deleteWorkoutVideoBody =>
      'Nur das lokale Video wird gelöscht. Analyse und Trainingsdaten bleiben erhalten.';

  @override
  String get workoutVideoDeleted => 'Trainingsvideo gelöscht';
}
