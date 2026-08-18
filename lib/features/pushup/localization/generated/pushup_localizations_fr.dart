// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'pushup_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class PushupLocalizationsFr extends PushupLocalizations {
  PushupLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'MotionFit - Pompes';

  @override
  String get navPushup => 'Pompes';

  @override
  String get navChallenge => 'Défi';

  @override
  String get navRecords => 'Progrès';

  @override
  String get navSettings => 'Réglages';

  @override
  String get challengeTitle => 'Mon défi de pompes';

  @override
  String get challengeSubtitle =>
      'Choisissez un défi adapté à votre objectif et entraînez-vous régulièrement.';

  @override
  String get challengeChooseTitle => 'Choisir un défi';

  @override
  String get challengeSevenDayTitle => 'Défi débutant de 7 jours';

  @override
  String get challengeSevenDayDescription =>
      'Un programme progressif pour débuter';

  @override
  String get challengeSevenDaySummary =>
      'Suivez pendant 7 jours un objectif adapté qui augmente chaque jour.';

  @override
  String get challengeSevenDayEveryDay =>
      'Continuez chaque jour pendant 7 jours sans récupération';

  @override
  String challengeDurationDays(int days) {
    return '$days jours';
  }

  @override
  String get challengeLevelGoals => 'Objectifs adaptés à votre niveau';

  @override
  String get challengeRecoveryIncluded => 'Jours de récupération inclus';

  @override
  String get challengeDailyGoal => 'Objectifs quotidiens';

  @override
  String get challengeSevenDayStart => 'Commencer le défi de 7 jours';

  @override
  String get challengeSevenDaySettings => 'Définir l’objectif sur 7 jours';

  @override
  String get challengeSevenDaySettingsDescription =>
      'Choisissez le jour 1. L’objectif augmente de 5 répétitions par jour.';

  @override
  String get challengeFirstDayGoal => 'Répétitions cibles du jour 1';

  @override
  String challengeSevenDayPreview(int first, int last) {
    return 'Jour 1 : $first → Jour 7 : $last répétitions';
  }

  @override
  String get challengeWeeklyTitle => 'Défi 3 fois par semaine';

  @override
  String get challengeWeeklyDescription =>
      'Un défi d’habitude sans entraînement quotidien';

  @override
  String get challengeWeeklySummary =>
      'Entraînez-vous 3 jours choisis par semaine pendant 4 semaines.';

  @override
  String challengeDurationWeeks(int weeks) {
    return '$weeks semaines';
  }

  @override
  String get challengeThreePerWeek => '3 entraînements par semaine';

  @override
  String get challengeChooseWeekdays => 'Choisir 3 jours d’entraînement';

  @override
  String get challengeWorkoutDaysCount =>
      'Progression selon les jours d’entraînement';

  @override
  String get challengeWeeklyStart => 'Commencer le défi hebdomadaire';

  @override
  String get challengeCumulativeTitle => 'Défi de répétitions cumulées';

  @override
  String get challengeCumulativeDescription =>
      'Atteignez un total de pompes selon votre emploi du temps';

  @override
  String get challengeCumulativeSummary =>
      'Choisissez durée et objectif total ; le repos conserve la progression.';

  @override
  String get challengePreset200 => '200 pompes en 7 jours';

  @override
  String get challengePreset500 => '500 pompes en 14 jours';

  @override
  String get challengeCustomGoal => 'Choisir la durée et l’objectif';

  @override
  String get challengeRestWithoutReset =>
      'Les jours de repos ne réinitialisent rien';

  @override
  String get challengeCumulativeStart => 'Commencer le défi cumulé';

  @override
  String get challengeHistoryTitle => 'Défis précédents';

  @override
  String get challengeHistoryEmpty => 'Les défis terminés apparaîtront ici.';

  @override
  String get challengeRecommended => 'Recommandé pour vous';

  @override
  String challengeRecommendationFromWorkout(int reps) {
    return 'Recommandé d’après votre premier entraînement de $reps répétitions.';
  }

  @override
  String get challengeRecommendationDefault =>
      'Pour votre premier défi, nous recommandons un départ en douceur sur 7 jours.';

  @override
  String get challengeActive => 'Défi actif';

  @override
  String get challengeNext => 'À suivre';

  @override
  String challengeDayNumber(int day) {
    return 'Jour $day';
  }

  @override
  String get challengeRecoveryDay => 'Jour de récupération';

  @override
  String challengeTodayProgress(int current, int target) {
    return 'Aujourd’hui $current / $target répétitions';
  }

  @override
  String get challengeRestToday => 'Prenez le temps de récupérer aujourd’hui.';

  @override
  String get challengeTodayCompleted =>
      'Objectif du jour atteint · Continuez demain';

  @override
  String challengeRepsRemaining(int reps) {
    return 'Encore $reps répétitions';
  }

  @override
  String challengeWeekNumber(int week) {
    return 'Semaine $week';
  }

  @override
  String challengeThisWeekProgress(int current, int target) {
    return 'Cette semaine $current / $target entraînements';
  }

  @override
  String challengeOverallDays(int current, int target) {
    return 'Total $current / $target jours';
  }

  @override
  String challengeRepsProgress(int current, int target) {
    return '$current / $target répétitions';
  }

  @override
  String challengeDaysRemaining(int days) {
    return 'Encore $days jours';
  }

  @override
  String challengeTodaySuggested(int reps) {
    return 'Objectif conseillé aujourd’hui : $reps répétitions';
  }

  @override
  String challengePercent(int percent) {
    return '$percent % terminé';
  }

  @override
  String get challengePushupStart => 'Commencer les pompes';

  @override
  String get challengeTodayWorkoutStart => 'Commencer l’entraînement du jour';

  @override
  String get challengeViewDetails => 'Voir les détails';

  @override
  String get challengeRestart => 'Recommencer';

  @override
  String get challengeDeleteHistory => 'Supprimer de l’historique';

  @override
  String get challengeCumulativeSettings => 'Définir l’objectif total';

  @override
  String get challengeDurationLabel => 'Durée';

  @override
  String get challengeGoalLabel => 'Répétitions cibles';

  @override
  String get challengeNotFound => 'Ce défi n’est plus disponible.';

  @override
  String get challengePeriod => 'Période';

  @override
  String get challengeStatus => 'État';

  @override
  String get challengeTotalReps => 'Total de pompes';

  @override
  String get challengeWorkoutDays => 'Jours d’entraînement';

  @override
  String challengeDaysCount(int days) {
    return '$days jours';
  }

  @override
  String get challengeTotalTime => 'Temps total d’entraînement';

  @override
  String get challengeSchedule => 'Programme et progression';

  @override
  String get challengeNotifications => 'Rappels du défi';

  @override
  String get challengeNotificationsDescription =>
      'Enregistrer le réglage de rappel de ce défi.';

  @override
  String get challengeReminderNotificationTitle =>
      'Votre défi de pompes vous attend';

  @override
  String get challengeReminderNotificationBody =>
      'Ouvrez MotionFit et progressez vers l’objectif du jour.';

  @override
  String get challengeSelectedWeekdays => 'Jours d’entraînement choisis';

  @override
  String get challengeNoProgressYet =>
      'Aucun entraînement du défi pour le moment.';

  @override
  String get challengeCancel => 'Terminer le défi';

  @override
  String get challengeCancelTitle => 'Terminer ce défi ?';

  @override
  String get challengeCancelDescription =>
      'Vos entraînements restent enregistrés. Le défi passera dans l’historique.';

  @override
  String get challengeStatusActive => 'En cours';

  @override
  String get challengeStatusCompleted => 'Terminé';

  @override
  String get challengeStatusEnded => 'Arrêté';

  @override
  String get challengeStatusCancelled => 'Annulé';

  @override
  String get challengeProgressUpdated =>
      'La progression de votre défi a été mise à jour.';

  @override
  String get challengeCheck => 'Voir le défi';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonStart => 'Commencer';

  @override
  String get commonSkip => 'Passer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonOn => 'Activé';

  @override
  String get commonOff => 'Désactivé';

  @override
  String get commonEnabled => 'Activé';

  @override
  String get commonDisabled => 'Désactivé';

  @override
  String get commonNotAvailable => 'Indisponible';

  @override
  String get commonToday => 'Aujourd’hui';

  @override
  String get commonYesterday => 'Hier';

  @override
  String get commonLoading => 'Chargement…';

  @override
  String unitSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séries',
      one: '1 série',
      zero: '0 séries',
    );
    return '$_temp0';
  }

  @override
  String unitReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count répétitions',
      one: '1 répétition',
      zero: '0 répétitions',
    );
    return '$_temp0';
  }

  @override
  String unitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secondes',
      one: '1 seconde',
      zero: '0 secondes',
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
    return '$hours h $minutes min';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String get homeGreeting => 'Prêt à bouger ?';

  @override
  String get homeTodayTitle => 'Bilan du jour';

  @override
  String get homeTodayNoWorkout =>
      'Pas encore de pompes aujourd’hui. Une petite série est un excellent début.';

  @override
  String homeTodaySummary(int reps, int sets) {
    return 'Pompes : $reps · Séries : $sets';
  }

  @override
  String get homeViewResult => 'Voir le résultat';

  @override
  String get homeTodaySets => 'Séries du jour';

  @override
  String get homeTodayReps => 'Faits aujourd’hui';

  @override
  String get streakLabel => 'Série';

  @override
  String streakDays(int days) {
    return '$days jours';
  }

  @override
  String get homeWorkoutSetup => 'Prochain entraînement';

  @override
  String get homeSetsLabel => 'Séries';

  @override
  String get homeRepsPerSetLabel => 'Répétitions par série';

  @override
  String get homeRestTimeLabel => 'Temps de repos';

  @override
  String get homeDirectInputHint => 'Saisis un nombre';

  @override
  String get homeStartWorkout => 'Commencer l’entraînement';

  @override
  String get homeLastSettingsRestored =>
      'Tes derniers réglages d’entraînement sont prêts.';

  @override
  String get validationNumberRequired => 'Saisis un nombre.';

  @override
  String validationRange(num min, num max) {
    return 'Choisis une valeur entre $min et $max.';
  }

  @override
  String get guideTitle => 'Installe ta caméra';

  @override
  String get guideSubtitle =>
      'Place le téléphone de côté pour garder mains, épaules, hanches et pieds visibles.';

  @override
  String get guideLandscape =>
      'Tourne le téléphone en mode paysage et place-le à côté de toi.';

  @override
  String get guideWholeBody =>
      'Garde un bras complet et la ligne du corps visibles.';

  @override
  String get guideStableCamera => 'Place ton téléphone sur un support stable.';

  @override
  String get guideOnePerson =>
      'Assure-toi qu’une seule personne se trouve dans le cadre.';

  @override
  String get guideCameraAngle =>
      'Si possible, filme-toi de côté ou légèrement de biais.';

  @override
  String get guideLighting =>
      'Évite les pièces sombres et les forts contre-jours.';

  @override
  String get guidePrivacy =>
      'La vidéo reste sur cet appareil et n’est enregistrée que si la revue par répétition est activée.';

  @override
  String get guideContinue => 'Je suis en position';

  @override
  String get permissionCameraTitle => 'Accès à la caméra requis';

  @override
  String get permissionCameraBody =>
      'MotionFit utilise la caméra pour compter les pompes. La vidéo n’est enregistrée sur cet appareil que si la revue est activée.';

  @override
  String get permissionCameraRequest => 'Continuer';

  @override
  String get permissionCameraDenied =>
      'L’accès à la caméra a été refusé. Tu peux toujours consulter l’historique et les réglages.';

  @override
  String get permissionCameraPermanentlyDenied =>
      'Autorise l’accès à la caméra dans les réglages système pour commencer un entraînement.';

  @override
  String get permissionOpenSettings => 'Ouvrir les réglages';

  @override
  String get permissionNotificationTitle =>
      'Autoriser les rappels d’entraînement ?';

  @override
  String get permissionNotificationBody =>
      'Les notifications servent uniquement aux rappels que tu programmes.';

  @override
  String get permissionNotificationRequest => 'Autoriser les notifications';

  @override
  String get permissionNotificationDenied =>
      'Les notifications sont désactivées. Active-les dans les réglages système pour recevoir des rappels.';

  @override
  String get countdownGetReady => 'Prépare-toi';

  @override
  String countdownBeginsIn(int seconds) {
    return 'Départ dans $seconds';
  }

  @override
  String get calibrationTitle => 'Repérage de ta position haute de pompe';

  @override
  String get calibrationBody =>
      'Tiens la position haute de pompe, bras tendus.';

  @override
  String get calibrationStayStill => 'Reste immobile un instant';

  @override
  String get calibrationComplete => 'Tout est prêt';

  @override
  String get calibrationFailed =>
      'Ta position haute de pompe n’a pas pu être détectée clairement.';

  @override
  String get calibrationRetry => 'Recalibrer';

  @override
  String workoutSetProgress(int current, int total) {
    return 'Série $current sur $total';
  }

  @override
  String workoutRepProgress(int current, int target) {
    return '$current sur $target';
  }

  @override
  String workoutTotalReps(int count) {
    return 'Total : $count';
  }

  @override
  String get workoutElapsed => 'Temps écoulé';

  @override
  String get workoutPause => 'Pause';

  @override
  String get workoutResume => 'Reprendre l’entraînement';

  @override
  String get workoutEnd => 'Mettre en pause';

  @override
  String get workoutBackToSetup => 'Retour à la configuration';

  @override
  String get workoutEndDialogTitle => 'Mettre l’entraînement en pause ?';

  @override
  String get workoutEndDialogBody =>
      'Ta progression sera enregistrée pour que tu puisses continuer depuis l’accueil.';

  @override
  String get workoutEndDialogConfirm => 'Enregistrer et quitter';

  @override
  String get workoutPauseReasonBackground =>
      'L’entraînement a été mis en pause pendant que l’application était en arrière-plan.';

  @override
  String get workoutPauseReasonInterruption =>
      'L’entraînement a été mis en pause après une interruption du système.';

  @override
  String get workoutStateReady => 'Prêt';

  @override
  String get workoutStateDescending => 'Descente';

  @override
  String get workoutStateBottom => 'Position basse';

  @override
  String get workoutStateAscending => 'Montée';

  @override
  String get workoutStateCompleted => 'Belle répétition';

  @override
  String get workoutStateTrackingLost => 'Détection en cours';

  @override
  String get workoutStatePaused => 'En pause';

  @override
  String get workoutTrackingGood => 'Articulations détectées';

  @override
  String get workoutCameraSwitch => 'Changer de caméra';

  @override
  String get workoutSkeletonToggle => 'Afficher le guide de posture';

  @override
  String get restTitle => 'Repos';

  @override
  String restNextSet(int set, int total) {
    return 'À suivre : série $set sur $total';
  }

  @override
  String get restCompletedSets => 'Séries terminées';

  @override
  String get restTotalReps => 'Pompes jusqu’ici';

  @override
  String get restSkip => 'Passer le repos';

  @override
  String get restAddFifteenSeconds => 'Ajouter 15 secondes';

  @override
  String get restEndWorkout => 'Mettre en pause';

  @override
  String get restAlmostDone => 'Encore un instant';

  @override
  String get restReady => 'Place à la prochaine série';

  @override
  String get completeTitle => 'Entraînement terminé';

  @override
  String get completeSubtitle => 'Beau travail. Voici un aperçu de ta séance.';

  @override
  String get workoutInterruptedSubtitle =>
      'Consulte les données enregistrées avant l’arrêt anticipé.';

  @override
  String get completeTotalReps => 'Total de pompes';

  @override
  String get completeCompletedSets => 'Séries terminées';

  @override
  String get completeActiveTime => 'Temps actif';

  @override
  String get completeRestTime => 'Temps de repos';

  @override
  String get completeTotalTime => 'Temps total';

  @override
  String get completeAverageRepTime => 'Temps moyen par répétition';

  @override
  String get completeFormSummary => 'Bilan technique';

  @override
  String get todayCoaching => 'Coaching du jour';

  @override
  String coachingIssueFrequency(int total, int count, String issue) {
    return 'Sur $total répétitions, $count montrent :\n$issue';
  }

  @override
  String get completeTopImprovement => 'Objectif pour la prochaine fois';

  @override
  String get completeStrengths => 'Points réussis';

  @override
  String get completeSaved => 'Entraînement enregistré sur cet appareil';

  @override
  String get completeSaveFailed =>
      'L’entraînement n’a pas pu être enregistré. Réessaie avant de quitter.';

  @override
  String get completeNoFormData =>
      'Les mouvements visibles n’étaient pas suffisants pour établir un bilan technique.';

  @override
  String get completeFinish => 'Terminer';

  @override
  String get postWorkoutReminderTitle => 'Gardez votre élan';

  @override
  String postWorkoutReminderBody(String time) {
    return 'Souhaitez-vous un rappel quotidien à $time dès demain ?';
  }

  @override
  String get postWorkoutReminderEnable => 'Me le rappeler';

  @override
  String get postWorkoutReminderLater => 'Peut-être plus tard';

  @override
  String get postWorkoutReminderEnabled => 'Votre rappel est programmé.';

  @override
  String get recordsTitle => 'Progression';

  @override
  String get recordsWeeklySummary => 'Cette semaine';

  @override
  String recordsWorkoutCount(int count) {
    return '$count entraînements';
  }

  @override
  String recordsAverageForm(int score) {
    return 'Posture moyenne $score';
  }

  @override
  String recordsWorkoutTime(String time) {
    return 'Temps $time';
  }

  @override
  String get recordsFirstWeek => 'C’est votre premier résultat cette semaine';

  @override
  String recordsMoreThanLastWeek(int count) {
    return '$count répétitions de plus que la semaine dernière';
  }

  @override
  String recordsLessThanLastWeek(int count) {
    return '$count répétitions de moins que la semaine dernière';
  }

  @override
  String get recordsSameAsLastWeek => 'Même volume que la semaine dernière';

  @override
  String get recordsTrendEmpty =>
      'Faites plus d’entraînements pour voir votre tendance de posture.';

  @override
  String get recordsFirstFormScore => 'Premier score de posture';

  @override
  String recordsRecentAverage(int count, int score) {
    return 'Moyenne des $count derniers : $score';
  }

  @override
  String get recordsStrength => 'Point fort';

  @override
  String get recordsFocus => 'À travailler';

  @override
  String get recordsTodayPoint => 'Point du jour';

  @override
  String get recordsToday => 'Aujourd’hui';

  @override
  String get recordsRecentWorkouts => 'Séances récentes';

  @override
  String get recordsCalendarTitle => 'Calendrier des séances';

  @override
  String get recordsFormTrend => 'Évolution de la posture';

  @override
  String get recordsViewCalendar => 'Calendrier';

  @override
  String get recordsViewList => 'Liste';

  @override
  String get recordsViewStats => 'Statistiques';

  @override
  String get recordsCalendarPreviousMonth => 'Mois précédent';

  @override
  String get recordsCalendarNextMonth => 'Mois suivant';

  @override
  String get recordsCalendarWorkoutDay => 'Jour d’entraînement';

  @override
  String get recordsCalendarNoWorkoutSelected =>
      'Sélectionne un jour d’entraînement pour voir ses séances.';

  @override
  String get recordsDayTotal => 'Total du jour';

  @override
  String recordsSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séances',
      one: '1 séance',
      zero: 'Aucune séance',
    );
    return '$_temp0';
  }

  @override
  String recordsSessionTitle(int number) {
    return 'Séance $number';
  }

  @override
  String get recordsListNewest => 'Plus récentes en premier';

  @override
  String get recordsOpenDetail => 'Voir les détails';

  @override
  String get recordsEmptyTitle => 'Aucun entraînement pour le moment';

  @override
  String get recordsEmptyBody =>
      'Termine ton premier entraînement de pompes pour le retrouver ici.';

  @override
  String get recordsStartWorkout => 'Commencer un entraînement';

  @override
  String get recordsLoading => 'Chargement de tes entraînements…';

  @override
  String get recordsLoadError =>
      'Ton historique d’entraînement n’a pas pu être chargé.';

  @override
  String get statsPeriod => 'Période';

  @override
  String get statsPeriod7Days => '7 jours';

  @override
  String get statsPeriod30Days => '30 jours';

  @override
  String get statsPeriodThisMonth => 'Ce mois-ci';

  @override
  String get statsPeriodAll => 'Depuis le début';

  @override
  String get statsPeriodCustom => 'Personnalisée';

  @override
  String get statsCustomRange => 'Choisir une plage de dates';

  @override
  String get statsTotalReps => 'Total de pompes';

  @override
  String get statsWorkoutDays => 'Jours d’entraînement';

  @override
  String get statsTotalActiveTime => 'Temps actif';

  @override
  String get statsAverageSets => 'Moyenne de séries';

  @override
  String get statsAverageReps => 'Moyenne de pompes';

  @override
  String get statsDailyReps => 'Pompes par jour';

  @override
  String get statsTrend => 'Évolution';

  @override
  String get statsFrequentImprovements => 'Objectifs fréquents';

  @override
  String get statsNoData => 'Aucun entraînement sur cette période.';

  @override
  String statsTrendUp(num percent) {
    return 'Hausse de $percent %';
  }

  @override
  String statsTrendDown(num percent) {
    return 'Baisse de $percent %';
  }

  @override
  String get statsTrendFlat => 'Aucun changement';

  @override
  String get detailTitle => 'Détails de l’entraînement';

  @override
  String get detailStartTime => 'Début';

  @override
  String get detailEndTime => 'Fin';

  @override
  String get detailActiveTime => 'Temps actif';

  @override
  String get detailRestTime => 'Temps de repos';

  @override
  String get detailTotalTime => 'Temps total';

  @override
  String get detailSets => 'Séries';

  @override
  String get detailSetBreakdown => 'Répétitions par série';

  @override
  String get detailTotalReps => 'Total de pompes';

  @override
  String get detailAverageRep => 'Temps moyen par répétition';

  @override
  String get detailFormSummary => 'Bilan technique';

  @override
  String get detailImprovements => 'Axes d’amélioration';

  @override
  String get detailStrengths => 'Points forts';

  @override
  String get detailInterrupted => 'Terminé plus tôt';

  @override
  String get detailCompleted => 'Terminé';

  @override
  String detailSetRow(int set, int reps) {
    return 'Série $set : $reps rép.';
  }

  @override
  String detailSessionOn(String date, String time) {
    return '$date à $time';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsRateApp => 'Noter cette app';

  @override
  String get settingsRateAppSubtitle => 'Notez MotionFit';

  @override
  String get settingsRateAppError =>
      'Impossible d’ouvrir la boutique. Réessayez.';

  @override
  String get settingsSectionGeneral => 'Général';

  @override
  String get settingsSectionCoaching => 'Coaching vocal';

  @override
  String get settingsSectionReminder => 'Rappels d’entraînement';

  @override
  String get settingsSectionCamera => 'Caméra';

  @override
  String get settingsSectionPrivacy => 'Confidentialité et données';

  @override
  String get settingsSectionAbout => 'À propos';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsDisplayTheme => 'Thème d’affichage';

  @override
  String get settingsColorTheme => 'Thème de couleur';

  @override
  String get themeLight => 'Clair';

  @override
  String get themePureBlack => 'Noir pur';

  @override
  String get themeSystem => 'Système';

  @override
  String get colorThemeByeokcheong => 'Bleu Byeokcheong';

  @override
  String get colorThemeChuhyang => 'Beige Chuhyang';

  @override
  String get colorThemeJangdan => 'Rouge Jangdan';

  @override
  String get colorThemeCheonghyeon => 'Bleu Cheonghyeon';

  @override
  String get colorThemeHaenghwang => 'Abricot Haenghwang';

  @override
  String get colorThemeChunyu => 'Vert Chunyu';

  @override
  String get colorThemeSeolbaek => 'Blanc Seolbaek';

  @override
  String get colorThemeByeokja => 'Violet Byeokja';

  @override
  String get colorThemeChwiram => 'Menthe Chwiram';

  @override
  String get languageSystem => 'Utiliser la langue de l’appareil';

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
  String get languageChanged => 'Langue mise à jour';

  @override
  String get voiceCoachingEnabled => 'Coaching vocal';

  @override
  String get voiceRepCountEnabled => 'Annoncer les répétitions';

  @override
  String get voiceFormEnabled => 'Conseils techniques';

  @override
  String get voiceEncouragementEnabled => 'Encouragements';

  @override
  String get voiceRate => 'Débit de la voix';

  @override
  String get voiceRateSlow => 'Lent';

  @override
  String get voiceRateNormal => 'Normal';

  @override
  String get voiceRateFast => 'Rapide';

  @override
  String get voiceTest => 'Tester la voix';

  @override
  String get voiceTestPhrase => 'Parfait. Ton coach vocal est prêt.';

  @override
  String get voiceUnavailable =>
      'Aucune voix hors ligne compatible n’est installée pour cette langue.';

  @override
  String get reminderTitle => 'Rappels d’entraînement';

  @override
  String get reminderSubtitle =>
      'Choisis une heure pour chaque jour où tu souhaites t’entraîner.';

  @override
  String get reminderEnabled => 'Rappel activé';

  @override
  String get reminderTime => 'Heure du rappel';

  @override
  String get reminderCopyTime => 'Copier cette heure';

  @override
  String reminderCopyFromDay(String day) {
    return 'Copier l’heure de $day';
  }

  @override
  String get reminderApplyAll => 'Appliquer à tous les jours';

  @override
  String reminderNext(String dateTime) {
    return 'Prochain rappel : $dateTime';
  }

  @override
  String get reminderNoneScheduled => 'Aucun rappel programmé';

  @override
  String get reminderPermissionNeeded =>
      'Autorise les notifications pour activer les rappels.';

  @override
  String get reminderSaved => 'Planning des rappels enregistré';

  @override
  String get weekdayMonday => 'Lundi';

  @override
  String get weekdayTuesday => 'Mardi';

  @override
  String get weekdayWednesday => 'Mercredi';

  @override
  String get weekdayThursday => 'Jeudi';

  @override
  String get weekdayFriday => 'Vendredi';

  @override
  String get weekdaySaturday => 'Samedi';

  @override
  String get weekdaySunday => 'Dimanche';

  @override
  String get weekdayMondayShort => 'Lun.';

  @override
  String get weekdayTuesdayShort => 'Mar.';

  @override
  String get weekdayWednesdayShort => 'Mer.';

  @override
  String get weekdayThursdayShort => 'Jeu.';

  @override
  String get weekdayFridayShort => 'Ven.';

  @override
  String get weekdaySaturdayShort => 'Sam.';

  @override
  String get weekdaySundayShort => 'Dim.';

  @override
  String get cameraFront => 'Caméra avant';

  @override
  String get cameraRear => 'Caméra arrière';

  @override
  String get cameraMirrorPreview => 'Inverser l’aperçu avant';

  @override
  String get cameraPoseOverlay => 'Superposer le guide de posture';

  @override
  String get cameraKeepScreenAwake =>
      'Garder l’écran allumé pendant l’entraînement';

  @override
  String get settingsHaptics => 'Retour haptique';

  @override
  String get privacyTitle => 'Traitement de tes données';

  @override
  String get privacyLocalProcessing =>
      'L’analyse de la posture s’effectue sur cet appareil.';

  @override
  String get privacyNoVideoStorage =>
      'La vidéo de la séance n’est enregistrée sur cet appareil que si la revue est activée.';

  @override
  String get privacyNoUpload =>
      'Les images de la caméra ne sont envoyées à aucun serveur.';

  @override
  String get privacyStoredData => 'Données enregistrées sur cet appareil';

  @override
  String get privacyStoredDataDescription =>
      'MotionFit enregistre les heures d’entraînement, les séries, les répétitions et les résultats techniques pour te permettre de suivre tes progrès.';

  @override
  String get privacyDeleteData => 'Supprimer toutes les données d’entraînement';

  @override
  String get privacyDeleteConfirmTitle =>
      'Supprimer toutes les données d’entraînement ?';

  @override
  String get privacyDeleteConfirmBody =>
      'Cette action supprime définitivement ton historique d’entraînement de cet appareil. Elle est irréversible.';

  @override
  String get privacyDeleteConfirmAction => 'Supprimer toutes les données';

  @override
  String get privacyDeleteSuccess => 'Données d’entraînement supprimées';

  @override
  String get privacyDeleteFailure =>
      'Les données d’entraînement n’ont pas pu être supprimées.';

  @override
  String get appInfoTitle => 'Informations sur l’application';

  @override
  String appInfoVersion(String version) {
    return 'Version $version';
  }

  @override
  String get appInfoLicenses => 'Licences open source';

  @override
  String get appInfoPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get appInfoDescription =>
      'MotionFit compte les pompes et fournit des conseils techniques privés, directement sur ton appareil.';

  @override
  String get errorGenericTitle => 'Un problème est survenu';

  @override
  String get errorGenericBody =>
      'Réessaie. Tes données d’entraînement existantes sont en sécurité.';

  @override
  String get errorCameraInit => 'La caméra n’a pas pu démarrer.';

  @override
  String get errorCameraInUse =>
      'La caméra est peut-être utilisée par une autre application.';

  @override
  String get errorPoseModelLoad =>
      'Le modèle de détection de posture n’a pas pu être chargé.';

  @override
  String get errorNoPerson =>
      'Aucune personne détectée. Place-toi dans le cadre.';

  @override
  String get errorWholeBody =>
      'Recherche d’un alignement épaule, hanche et genou.';

  @override
  String get errorMultiplePeople =>
      'Plusieurs personnes sont dans le cadre. Une seule personne doit rester visible.';

  @override
  String get errorTrackingLost =>
      'L’exercice continue pendant que la détection réessaie.';

  @override
  String get errorDatabaseSave =>
      'Ton entraînement n’a pas pu être enregistré.';

  @override
  String get errorTtsVoiceMissing =>
      'Aucune voix de synthèse vocale n’est installée sur cet appareil.';

  @override
  String get errorTtsLocaleUnsupported =>
      'Le coaching vocal n’est pas pris en charge pour la langue sélectionnée sur cet appareil.';

  @override
  String get emptyNoFormIssues =>
      'Aucun problème technique récurrent n’a été détecté.';

  @override
  String get emptyNotEnoughData => 'Pas encore assez de données';

  @override
  String get loadingCamera => 'Démarrage de la caméra…';

  @override
  String get loadingPoseModel => 'Préparation de la détection des mouvements…';

  @override
  String get loadingSavingWorkout => 'Enregistrement de l’entraînement…';

  @override
  String get formScore => 'Score technique';

  @override
  String get formShort => 'Posture';

  @override
  String formScoreValue(int score) {
    return '$score pts';
  }

  @override
  String get formIssueDepth => 'Profondeur du pompe';

  @override
  String get formIssueTorsoLean => 'Alignement du corps';

  @override
  String get formIssueHeelLift => 'Position des hanches';

  @override
  String get formIssueKneeAlignment => 'Alignement des coudes';

  @override
  String get formIssueBalance => 'Équilibre gauche-droite';

  @override
  String get formIssueDescentSpeed => 'Vitesse de descente';

  @override
  String get formIssueAscentSpeed => 'Vitesse de montée';

  @override
  String get formIssueControl => 'Maîtrise du mouvement';

  @override
  String get formIssueStandingCompletion => 'Extension des bras';

  @override
  String get formIssueNotObservable =>
      'Impossible à évaluer sous cet angle de caméra';

  @override
  String get formStrengthDepth => 'Profondeur régulière';

  @override
  String get formStrengthControl => 'Mouvement maîtrisé';

  @override
  String get formStrengthBalance => 'Équilibre stable';

  @override
  String get coachTrackingLost1 =>
      'L’exercice continue pendant que je poursuis la détection.';

  @override
  String get coachTrackingLost2 =>
      'Une brève occultation ne met pas l’exercice en pause.';

  @override
  String get coachWholeBody1 =>
      'Garde poignet, coude, épaule, hanche et cheville dans le cadre.';

  @override
  String get coachWholeBody2 =>
      'Éloigne-toi pour montrer toute la position de pompe.';

  @override
  String get coachMultiplePeople1 =>
      'Garde une seule personne dans le cadre pour que je puisse te suivre.';

  @override
  String get coachReady1 => 'Tu es en position. C’est parti.';

  @override
  String get coachReady2 =>
      'Bonne position. Prépare-toi pour ton premier pompe.';

  @override
  String coachStartSet(int set) {
    return 'Série $set. C’est parti.';
  }

  @override
  String coachSevenDayChallengeStart(int day) {
    return 'Le jour $day du défi de sept jours commence.';
  }

  @override
  String coachCumulativeChallengeStart(int completed, int remaining) {
    return 'Le défi de répétitions cumulées commence. Tu as réalisé $completed répétitions, il en reste $remaining.';
  }

  @override
  String coachRepCount(int count) {
    return '$count';
  }

  @override
  String get coachDepth1 =>
      'À la prochaine répétition, essaie de descendre un peu plus bas.';

  @override
  String get coachDepth2 =>
      'Donne un peu plus de profondeur au prochain pompe.';

  @override
  String get coachTorso1 => 'Garde épaules, hanches et chevilles alignées.';

  @override
  String get coachTorso2 => 'Gaine le tronc et garde le corps droit.';

  @override
  String get coachHeel1 => 'Garde les hanches à hauteur des épaules.';

  @override
  String get coachHeel2 => 'Évite de laisser les hanches tomber ou monter.';

  @override
  String get coachKnees1 =>
      'Oriente les coudes vers l’arrière, pas sur les côtés.';

  @override
  String get coachKnees2 => 'Rapproche un peu les coudes du corps.';

  @override
  String get coachBalance1 => 'Répartis ton poids également des deux côtés.';

  @override
  String get coachBalance2 =>
      'Trouve une position stable et équilibrée pour la prochaine répétition.';

  @override
  String get coachDescendSlow1 =>
      'La prochaine fois, essaie de descendre un peu plus lentement.';

  @override
  String get coachDescendSlow2 =>
      'Maîtrise la descente à la prochaine répétition.';

  @override
  String get coachDescendFaster1 =>
      'À la prochaine répétition, descends un peu plus rapidement.';

  @override
  String get coachDescendFaster2 =>
      'Lors de la prochaine descente, continue le mouvement sans marquer de pause.';

  @override
  String get coachAscendControlled1 =>
      'Remonte en douceur et garde le contrôle.';

  @override
  String get coachAscendControlled2 =>
      'Repousse à un rythme régulier et contrôlé.';

  @override
  String get coachAscendFaster1 => 'Remonte avec un peu plus d’élan.';

  @override
  String get coachAscendFaster2 =>
      'À la prochaine répétition, repousse un peu plus franchement.';

  @override
  String get coachControl1 =>
      'Réalise la prochaine répétition avec fluidité du début à la fin.';

  @override
  String get coachControl2 => 'Garde le contrôle pendant tout le mouvement.';

  @override
  String get coachStandTall1 => 'Termine avec les bras complètement tendus.';

  @override
  String get coachStandTall2 => 'Repousse jusqu’à la position haute.';

  @override
  String get coachGood1 => 'Bien. Garde ce rythme.';

  @override
  String get coachGood2 => 'Bon contrôle. Continue comme ça.';

  @override
  String get coachGood3 => 'Belle répétition. Encore une comme ça.';

  @override
  String get coachLastTwo => 'Plus que deux. Tiens bon !';

  @override
  String get coachLastOne => 'La dernière. Finis fort !';

  @override
  String coachSetComplete(int set) {
    return 'Super. La série $set est terminée.';
  }

  @override
  String coachRestStart(int seconds) {
    return 'Repose-toi pendant $seconds secondes. Respire et récupère.';
  }

  @override
  String get coachRestTenSeconds => 'Plus que dix secondes de repos.';

  @override
  String get coachRestComplete =>
      'Le repos est terminé. Prépare-toi pour la prochaine série.';

  @override
  String coachWorkoutComplete(int reps) {
    return 'Entraînement terminé. Tu as réalisé $reps pompes.';
  }

  @override
  String get notificationReminderTitle => 'C’est l’heure des pompes du jour';

  @override
  String get notificationReminderBody =>
      'Même une courte séance compte. Ouvre MotionFit quand tu es prêt.';

  @override
  String get notificationReminderBodyVariant2 =>
      'Quelques pompes bien exécutés suffisent pour faire bouger ta journée.';

  @override
  String notificationStreakReminderBody(int days) {
    return 'Préservez aujourd’hui votre série de $days jours avec une courte séance.';
  }

  @override
  String get semanticsIncrease => 'Augmenter';

  @override
  String get semanticsDecrease => 'Diminuer';

  @override
  String semanticsSelectedTab(String tab) {
    return 'Onglet sélectionné : $tab';
  }

  @override
  String semanticsCalendarWorkoutDate(String date) {
    return '$date, entraînement enregistré';
  }

  @override
  String semanticsCalendarEmptyDate(String date) {
    return '$date, aucun entraînement';
  }

  @override
  String semanticsCurrentRep(int current, int target) {
    return 'Répétition actuelle : $current sur $target';
  }

  @override
  String get repVideoReviewTitle => 'Revue vidéo par répétition';

  @override
  String get repVideoReviewDescription =>
      'Enregistrez la vidéo de cette séance sur l’appareil pour revoir chaque répétition ensuite.';

  @override
  String get repVideoLocalOnly => 'Local uniquement · Jamais téléversé';

  @override
  String get formReviewTitle => 'Analyse de la posture';

  @override
  String get formReviewMainIssue => 'Problème principal';

  @override
  String get viewRepTimeline => 'Voir les répétitions';

  @override
  String get repTimelineTitle => 'Analyse des répétitions';

  @override
  String get repTimelineAll => 'Toutes';

  @override
  String get repTimelineImprove => 'À améliorer';

  @override
  String get repTimelineNoImprovement => 'Aucune répétition n’est à améliorer.';

  @override
  String repSetNumber(int number) {
    return 'Série $number';
  }

  @override
  String repNumber(int number) {
    return 'Répétition $number';
  }

  @override
  String get repResultGood => 'Bonne posture';

  @override
  String get repResultNeedsAttention => 'À surveiller';

  @override
  String get repResultImproved => 'Mieux que la précédente';

  @override
  String get repResultNotAssessed => 'Difficile à évaluer';

  @override
  String get repIssueShallowDepth => 'Essayez de descendre un peu plus';

  @override
  String get repIssueForwardLean => 'Le buste s’est penché vers l’avant';

  @override
  String get repIssueKneesInward => 'Les coudes se sont écartés';

  @override
  String get repVideoNotSaved => 'Vidéo non enregistrée';

  @override
  String get repReplay => 'Rejouer';

  @override
  String get repWhatHappened => 'Ce qui s’est passé';

  @override
  String get repHowToImprove => 'Comment progresser';

  @override
  String get repWhatWentWell => 'Points réussis';

  @override
  String get repPrevious => 'Répétition précédente';

  @override
  String get repNext => 'Répétition suivante';

  @override
  String get repFeedbackGood =>
      'Cette répétition est restée dans les plages que MotionFit a pu évaluer.';

  @override
  String get repFeedbackDepth =>
      'Vous n’avez pas atteint votre profondeur habituelle. Descendez un peu plus en gardant le buste stable.';

  @override
  String get repFeedbackTorso =>
      'La ligne du corps a changé. Gaine le tronc et stabilise les hanches.';

  @override
  String get repFeedbackKnees =>
      'Tes coudes se sont écartés. Oriente-les vers l’arrière près du corps.';

  @override
  String repFeedbackGeneric(String area) {
    return 'Cette répétition demande de l’attention pour $area.';
  }

  @override
  String get deleteWorkoutVideo => 'Supprimer la vidéo de la séance';

  @override
  String get deleteWorkoutVideoTitle => 'Supprimer cette vidéo ?';

  @override
  String get deleteWorkoutVideoBody =>
      'Seule la vidéo locale sera supprimée. L’analyse et la séance resteront enregistrées.';

  @override
  String get workoutVideoDeleted => 'Vidéo de la séance supprimée';
}
