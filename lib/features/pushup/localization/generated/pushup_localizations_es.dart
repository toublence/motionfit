// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'pushup_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class PushupLocalizationsEs extends PushupLocalizations {
  PushupLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'motionfit - workout coach';

  @override
  String get navPushup => 'Flexiones';

  @override
  String get navChallenge => 'Desafío';

  @override
  String get navRecords => 'Progreso';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get challengeTitle => 'Mi desafío de flexiones';

  @override
  String get challengeSubtitle =>
      'Elige un desafío que se adapte a tu objetivo y entrena con constancia.';

  @override
  String get challengeChooseTitle => 'Elige un desafío';

  @override
  String get challengeSevenDayTitle => 'Desafío inicial de 7 días';

  @override
  String get challengeSevenDayDescription =>
      'Un programa paso a paso para principiantes';

  @override
  String get challengeSevenDaySummary =>
      'Sigue durante 7 días un objetivo adaptado que aumenta cada día.';

  @override
  String get challengeSevenDayEveryDay =>
      'Continúa los 7 días sin días de recuperación';

  @override
  String challengeDurationDays(int days) {
    return '$days días';
  }

  @override
  String get challengeLevelGoals => 'Objetivos adaptados a tu nivel';

  @override
  String get challengeRecoveryIncluded => 'Incluye días de recuperación';

  @override
  String get challengeDailyGoal => 'Objetivos diarios de repeticiones';

  @override
  String get challengeSevenDayStart => 'Iniciar desafío de 7 días';

  @override
  String get challengeSevenDaySettings => 'Configura el objetivo de 7 días';

  @override
  String get challengeSevenDaySettingsDescription =>
      'Elige el día 1. El objetivo aumenta 5 repeticiones cada día.';

  @override
  String get challengeFirstDayGoal => 'Repeticiones del día 1';

  @override
  String challengeSevenDayPreview(int first, int last) {
    return 'Día 1: $first → Día 7: $last repeticiones';
  }

  @override
  String get challengeWeeklyTitle => 'Desafío 3 veces por semana';

  @override
  String get challengeWeeklyDescription =>
      'Un desafío de hábito si no quieres entrenar a diario';

  @override
  String get challengeWeeklySummary =>
      'Entrena 3 días elegidos por semana durante 4 semanas.';

  @override
  String challengeDurationWeeks(int weeks) {
    return '$weeks semanas';
  }

  @override
  String get challengeThreePerWeek => '3 entrenamientos por semana';

  @override
  String get challengeChooseWeekdays => 'Elige 3 días de entrenamiento';

  @override
  String get challengeWorkoutDaysCount =>
      'El progreso se basa en días entrenados';

  @override
  String get challengeWeeklyStart => 'Iniciar desafío semanal';

  @override
  String get challengeCumulativeTitle => 'Desafío de repeticiones totales';

  @override
  String get challengeCumulativeDescription =>
      'Alcanza un total de flexiones con el horario que prefieras';

  @override
  String get challengeCumulativeSummary =>
      'Elige duración y objetivo total; descansar conserva el progreso.';

  @override
  String get challengePreset200 => '200 flexiones en 7 días';

  @override
  String get challengePreset500 => '500 flexiones en 14 días';

  @override
  String get challengeCustomGoal => 'Elige duración y objetivo';

  @override
  String get challengeRestWithoutReset => 'Descansar no reinicia el progreso';

  @override
  String get challengeCumulativeStart => 'Iniciar desafío total';

  @override
  String get challengeHistoryTitle => 'Desafíos anteriores';

  @override
  String get challengeHistoryEmpty =>
      'Los desafíos completados y finalizados aparecerán aquí.';

  @override
  String get challengeRecommended => 'Recomendado para ti';

  @override
  String challengeRecommendationFromWorkout(int reps) {
    return 'Recomendado según tu primer entrenamiento de $reps repeticiones.';
  }

  @override
  String get challengeRecommendationDefault =>
      'Para tu primer desafío recomendamos un inicio suave de 7 días.';

  @override
  String get challengeActive => 'Desafío activo';

  @override
  String get challengeNext => 'Siguiente';

  @override
  String challengeDayNumber(int day) {
    return 'Día $day';
  }

  @override
  String get challengeRecoveryDay => 'Día de recuperación';

  @override
  String challengeTodayProgress(int current, int target) {
    return 'Hoy $current / $target repeticiones';
  }

  @override
  String get challengeRestToday => 'Recupérate bien hoy.';

  @override
  String get challengeTodayCompleted =>
      'Objetivo de hoy completado · Continúa mañana';

  @override
  String challengeRepsRemaining(int reps) {
    return 'Faltan $reps repeticiones';
  }

  @override
  String challengeWeekNumber(int week) {
    return 'Semana $week';
  }

  @override
  String challengeThisWeekProgress(int current, int target) {
    return 'Esta semana $current / $target entrenamientos';
  }

  @override
  String challengeOverallDays(int current, int target) {
    return 'Total $current / $target días';
  }

  @override
  String challengeRepsProgress(int current, int target) {
    return '$current / $target repeticiones';
  }

  @override
  String challengeDaysRemaining(int days) {
    return 'Quedan $days días';
  }

  @override
  String challengeTodaySuggested(int reps) {
    return 'Objetivo sugerido para hoy: $reps repeticiones';
  }

  @override
  String challengePercent(int percent) {
    return '$percent% completado';
  }

  @override
  String get challengePushupStart => 'Iniciar flexiones';

  @override
  String get challengeTodayWorkoutStart => 'Iniciar entrenamiento de hoy';

  @override
  String get challengeViewDetails => 'Ver detalles';

  @override
  String get challengeRestart => 'Empezar de nuevo';

  @override
  String get challengeDeleteHistory => 'Eliminar del historial';

  @override
  String get challengeCumulativeSettings => 'Configura tu objetivo total';

  @override
  String get challengeDurationLabel => 'Duración';

  @override
  String get challengeGoalLabel => 'Repeticiones objetivo';

  @override
  String get challengeNotFound => 'Este desafío ya no está disponible.';

  @override
  String get challengePeriod => 'Periodo';

  @override
  String get challengeStatus => 'Estado';

  @override
  String get challengeTotalReps => 'Flexiones totales';

  @override
  String get challengeWorkoutDays => 'Días de entrenamiento';

  @override
  String challengeDaysCount(int days) {
    return '$days días';
  }

  @override
  String get challengeTotalTime => 'Tiempo total de entrenamiento';

  @override
  String get challengeSchedule => 'Plan y progreso';

  @override
  String get challengeNotifications => 'Recordatorios del desafío';

  @override
  String get challengeNotificationsDescription =>
      'Guarda la preferencia de recordatorio de este desafío.';

  @override
  String get challengeReminderNotificationTitle =>
      'Tu desafío de flexiones te espera';

  @override
  String get challengeReminderNotificationBody =>
      'Abre MotionFit y avanza hacia el objetivo de hoy.';

  @override
  String get challengeSelectedWeekdays => 'Días de entrenamiento elegidos';

  @override
  String get challengeNoProgressYet => 'Aún no hay entrenamientos del desafío.';

  @override
  String get challengeCancel => 'Finalizar desafío';

  @override
  String get challengeCancelTitle => '¿Finalizar este desafío?';

  @override
  String get challengeCancelDescription =>
      'Tus entrenamientos seguirán guardados. El desafío pasará al historial.';

  @override
  String get challengeStatusActive => 'En curso';

  @override
  String get challengeStatusCompleted => 'Completado';

  @override
  String get challengeStatusEnded => 'Finalizado';

  @override
  String get challengeStatusCancelled => 'Cancelado';

  @override
  String get challengeProgressUpdated =>
      'El progreso del desafío se ha actualizado.';

  @override
  String get challengeCheck => 'Ver desafío';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonRetry => 'Volver a intentar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonStart => 'Empezar';

  @override
  String get commonSkip => 'Omitir';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonOn => 'Activado';

  @override
  String get commonOff => 'Desactivado';

  @override
  String get commonEnabled => 'Activado';

  @override
  String get commonDisabled => 'Desactivado';

  @override
  String get commonNotAvailable => 'No disponible';

  @override
  String get commonToday => 'Hoy';

  @override
  String get commonYesterday => 'Ayer';

  @override
  String get commonLoading => 'Cargando…';

  @override
  String unitSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count series',
      one: '1 serie',
      zero: '0 series',
    );
    return '$_temp0';
  }

  @override
  String unitReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repeticiones',
      one: '1 repetición',
      zero: '0 repeticiones',
    );
    return '$_temp0';
  }

  @override
  String unitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segundos',
      one: '1 segundo',
      zero: '0 segundos',
    );
    return '$_temp0';
  }

  @override
  String unitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
      zero: '0 minutos',
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
  String get homeGreeting => '¿Listo para moverte?';

  @override
  String get homeTodayTitle => 'Registro de hoy';

  @override
  String get homeTodayNoWorkout =>
      'Aún no has hecho flexiones hoy. Una serie corta es un gran comienzo.';

  @override
  String homeTodaySummary(int reps, int sets) {
    return 'Flexiones: $reps · Series: $sets';
  }

  @override
  String get homeViewResult => 'Ver resultado';

  @override
  String get homeTodaySets => 'Series de hoy';

  @override
  String get homeTodayReps => 'Hechas hoy';

  @override
  String get streakLabel => 'Racha';

  @override
  String streakDays(int days) {
    return '$days días';
  }

  @override
  String get homeWorkoutSetup => 'Próximo entrenamiento';

  @override
  String get homeSetsLabel => 'Series';

  @override
  String get homeRepsPerSetLabel => 'Repeticiones por serie';

  @override
  String get homeRestTimeLabel => 'Tiempo de descanso';

  @override
  String get homeDirectInputHint => 'Introduce un número';

  @override
  String get homeStartWorkout => 'Empezar entrenamiento';

  @override
  String get homeLastSettingsRestored =>
      'Tu última configuración de entrenamiento está lista.';

  @override
  String get validationNumberRequired => 'Introduce un número.';

  @override
  String validationRange(num min, num max) {
    return 'Elige un valor entre $min y $max.';
  }

  @override
  String get guideTitle => 'Configura la cámara';

  @override
  String get guideSubtitle =>
      'Una imagen clara de cuerpo entero ayuda a MotionFit a contar con precisión.';

  @override
  String get guideLandscape =>
      'Gira el teléfono a posición horizontal y colócalo a tu lado.';

  @override
  String get guideWholeBody =>
      'Mantén visible un brazo completo y la línea del cuerpo.';

  @override
  String get guideStableCamera => 'Coloca el teléfono en un lugar estable.';

  @override
  String get guideOnePerson =>
      'Asegúrate de que solo haya una persona en pantalla.';

  @override
  String get guideCameraAngle =>
      'Siempre que puedas, usa una vista lateral o ligeramente oblicua.';

  @override
  String get guideLighting =>
      'Evita las habitaciones oscuras y la luz intensa a contraluz.';

  @override
  String get guidePrivacy =>
      'El vídeo permanece en este dispositivo y solo se guarda si activas la revisión por repetición.';

  @override
  String get guideContinue => 'Estoy en posición';

  @override
  String get permissionCameraTitle => 'Se necesita acceso a la cámara';

  @override
  String get permissionCameraBody =>
      'MotionFit usa la cámara para contar flexiones. El vídeo solo se guarda en este dispositivo si activas la revisión.';

  @override
  String get permissionCameraRequest => 'Continuar';

  @override
  String get permissionCameraDenied =>
      'Se ha denegado el acceso a la cámara. Aún puedes consultar tus registros y ajustes.';

  @override
  String get permissionCameraPermanentlyDenied =>
      'Permite el acceso a la cámara en los ajustes del sistema para empezar un entrenamiento.';

  @override
  String get permissionOpenSettings => 'Abrir ajustes';

  @override
  String get permissionNotificationTitle =>
      '¿Permitir recordatorios de entrenamiento?';

  @override
  String get permissionNotificationBody =>
      'Las notificaciones solo se usan para los recordatorios que programes.';

  @override
  String get permissionNotificationRequest => 'Permitir notificaciones';

  @override
  String get permissionNotificationDenied =>
      'Las notificaciones están desactivadas. Actívalas en los ajustes del sistema para recibir recordatorios.';

  @override
  String get countdownGetReady => 'Prepárate';

  @override
  String countdownBeginsIn(int seconds) {
    return 'Empieza en $seconds';
  }

  @override
  String get calibrationTitle => 'Buscando la posición alta de flexión';

  @override
  String get calibrationBody =>
      'Mantén la posición alta de flexión con los brazos extendidos.';

  @override
  String get calibrationStayStill => 'Quédate quieto un momento';

  @override
  String get calibrationComplete => 'Todo listo';

  @override
  String get calibrationFailed =>
      'No hemos podido detectar una posición alta de flexión clara.';

  @override
  String get calibrationRetry => 'Volver a calibrar';

  @override
  String workoutSetProgress(int current, int total) {
    return 'Serie $current de $total';
  }

  @override
  String workoutRepProgress(int current, int target) {
    return '$current de $target';
  }

  @override
  String workoutTotalReps(int count) {
    return 'Total: $count';
  }

  @override
  String get workoutElapsed => 'Tiempo transcurrido';

  @override
  String get workoutPause => 'Pausar';

  @override
  String get workoutResume => 'Reanudar entrenamiento';

  @override
  String get workoutEnd => 'Pausar por ahora';

  @override
  String get workoutBackToSetup => 'Volver a la configuración';

  @override
  String get workoutEndDialogTitle => '¿Pausar por ahora?';

  @override
  String get workoutEndDialogBody =>
      'Tu progreso se guardará para que puedas continuar desde la pantalla de inicio.';

  @override
  String get workoutEndDialogConfirm => 'Guardar y salir';

  @override
  String get workoutPauseReasonBackground =>
      'El entrenamiento se ha pausado mientras la aplicación estaba en segundo plano.';

  @override
  String get workoutPauseReasonInterruption =>
      'El entrenamiento se ha pausado después de una interrupción del sistema.';

  @override
  String get workoutStateReady => 'Listo';

  @override
  String get workoutStateDescending => 'Bajando';

  @override
  String get workoutStateBottom => 'Abajo';

  @override
  String get workoutStateAscending => 'Subiendo';

  @override
  String get workoutStateCompleted => 'Buena repetición';

  @override
  String get workoutStateTrackingLost => 'Vuelve a entrar en pantalla';

  @override
  String get workoutStatePaused => 'En pausa';

  @override
  String get workoutTrackingGood => 'Cuerpo visible';

  @override
  String get workoutCameraSwitch => 'Cambiar de cámara';

  @override
  String get workoutSkeletonToggle => 'Mostrar guía de postura';

  @override
  String get restTitle => 'Descanso';

  @override
  String restNextSet(int set, int total) {
    return 'Siguiente: serie $set de $total';
  }

  @override
  String get restCompletedSets => 'Series completadas';

  @override
  String get restTotalReps => 'Flexiones hasta ahora';

  @override
  String get restSkip => 'Omitir descanso';

  @override
  String get restAddFifteenSeconds => 'Añadir 15 segundos';

  @override
  String get restEndWorkout => 'Pausar por ahora';

  @override
  String get restAlmostDone => 'Ya casi';

  @override
  String get restReady => 'Hora de la siguiente serie';

  @override
  String get completeTitle => 'Entrenamiento completado';

  @override
  String get completeSubtitle =>
      'Buen trabajo. Este es el resumen de tu sesión.';

  @override
  String get workoutInterruptedSubtitle =>
      'Revisa lo registrado antes de terminar antes de tiempo.';

  @override
  String get completeTotalReps => 'Flexiones totales';

  @override
  String get completeCompletedSets => 'Series completadas';

  @override
  String get completeActiveTime => 'Tiempo activo';

  @override
  String get completeRestTime => 'Tiempo de descanso';

  @override
  String get completeTotalTime => 'Tiempo total';

  @override
  String get completeAverageRepTime => 'Tiempo medio por repetición';

  @override
  String get completeFormSummary => 'Resumen de la técnica';

  @override
  String get todayCoaching => 'Consejo de hoy';

  @override
  String coachingIssueFrequency(int total, int count, String issue) {
    return 'En $count de $total repeticiones:\n$issue';
  }

  @override
  String get completeTopImprovement => 'Objetivo para la próxima vez';

  @override
  String get completeStrengths => 'Lo que has hecho bien';

  @override
  String get completeSaved => 'Entrenamiento guardado en este dispositivo';

  @override
  String get completeSaveFailed =>
      'No se ha podido guardar el entrenamiento. Vuelve a intentarlo antes de salir.';

  @override
  String get completeNoFormData =>
      'No hubo suficiente movimiento visible para generar un resumen de la técnica.';

  @override
  String get completeFinish => 'Finalizar';

  @override
  String get postWorkoutReminderTitle => 'Mantén el ritmo';

  @override
  String postWorkoutReminderBody(String time) {
    return '¿Quieres un recordatorio diario a las $time a partir de mañana?';
  }

  @override
  String get postWorkoutReminderEnable => 'Recordármelo';

  @override
  String get postWorkoutReminderLater => 'Quizá más tarde';

  @override
  String get postWorkoutReminderEnabled => 'Tu recordatorio está listo.';

  @override
  String get recordsTitle => 'Progreso';

  @override
  String get recordsWeeklySummary => 'Esta semana';

  @override
  String recordsWorkoutCount(int count) {
    return '$count entrenamientos';
  }

  @override
  String recordsAverageForm(int score) {
    return 'Técnica media $score';
  }

  @override
  String recordsWorkoutTime(String time) {
    return 'Tiempo $time';
  }

  @override
  String get recordsFirstWeek => 'Es tu primer registro de esta semana';

  @override
  String recordsMoreThanLastWeek(int count) {
    return '$count repeticiones más que la semana pasada';
  }

  @override
  String recordsLessThanLastWeek(int count) {
    return '$count repeticiones menos que la semana pasada';
  }

  @override
  String get recordsSameAsLastWeek => 'El mismo volumen que la semana pasada';

  @override
  String get recordsTrendEmpty =>
      'Completa más entrenamientos para ver tu evolución técnica.';

  @override
  String get recordsFirstFormScore => 'Primera puntuación técnica';

  @override
  String recordsRecentAverage(int count, int score) {
    return 'Media de los últimos $count: $score';
  }

  @override
  String get recordsStrength => 'Fortaleza';

  @override
  String get recordsFocus => 'Enfoque';

  @override
  String get recordsTodayPoint => 'Enfoque de hoy';

  @override
  String get recordsToday => 'Hoy';

  @override
  String get recordsRecentWorkouts => 'Entrenamientos recientes';

  @override
  String get recordsCalendarTitle => 'Calendario de entrenamientos';

  @override
  String get recordsFormTrend => 'Evolución de la técnica';

  @override
  String get recordsViewCalendar => 'Calendario';

  @override
  String get recordsViewList => 'Lista';

  @override
  String get recordsViewStats => 'Estadísticas';

  @override
  String get recordsCalendarPreviousMonth => 'Mes anterior';

  @override
  String get recordsCalendarNextMonth => 'Mes siguiente';

  @override
  String get recordsCalendarWorkoutDay => 'Día de entrenamiento';

  @override
  String get recordsCalendarNoWorkoutSelected =>
      'Selecciona un día de entrenamiento para ver sus sesiones.';

  @override
  String get recordsDayTotal => 'Total diario';

  @override
  String recordsSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones',
      one: '1 sesión',
      zero: 'Ninguna sesión',
    );
    return '$_temp0';
  }

  @override
  String recordsSessionTitle(int number) {
    return 'Sesión $number';
  }

  @override
  String get recordsListNewest => 'Más recientes primero';

  @override
  String get recordsOpenDetail => 'Ver detalles';

  @override
  String get recordsEmptyTitle => 'Aún no hay entrenamientos';

  @override
  String get recordsEmptyBody =>
      'Completa tu primer entrenamiento de flexiones y aparecerá aquí.';

  @override
  String get recordsStartWorkout => 'Empezar un entrenamiento';

  @override
  String get recordsLoading => 'Cargando tus entrenamientos…';

  @override
  String get recordsLoadError =>
      'No hemos podido cargar tu registro de entrenamientos.';

  @override
  String get statsPeriod => 'Periodo';

  @override
  String get statsPeriod7Days => '7 días';

  @override
  String get statsPeriod30Days => '30 días';

  @override
  String get statsPeriodThisMonth => 'Este mes';

  @override
  String get statsPeriodAll => 'Todo el periodo';

  @override
  String get statsPeriodCustom => 'Personalizado';

  @override
  String get statsCustomRange => 'Elegir intervalo de fechas';

  @override
  String get statsTotalReps => 'Flexiones totales';

  @override
  String get statsWorkoutDays => 'Días de entrenamiento';

  @override
  String get statsTotalActiveTime => 'Tiempo activo';

  @override
  String get statsAverageSets => 'Media de series';

  @override
  String get statsAverageReps => 'Media de flexiones';

  @override
  String get statsDailyReps => 'Flexiones por día';

  @override
  String get statsTrend => 'Evolución';

  @override
  String get statsFrequentImprovements => 'Objetivos frecuentes';

  @override
  String get statsNoData => 'No hay entrenamientos en este periodo.';

  @override
  String statsTrendUp(num percent) {
    return 'Sube un $percent %';
  }

  @override
  String statsTrendDown(num percent) {
    return 'Baja un $percent %';
  }

  @override
  String get statsTrendFlat => 'Sin cambios';

  @override
  String get detailTitle => 'Detalles del entrenamiento';

  @override
  String get detailStartTime => 'Inicio';

  @override
  String get detailEndTime => 'Fin';

  @override
  String get detailActiveTime => 'Tiempo activo';

  @override
  String get detailRestTime => 'Tiempo de descanso';

  @override
  String get detailTotalTime => 'Tiempo total';

  @override
  String get detailSets => 'Series';

  @override
  String get detailSetBreakdown => 'Repeticiones por serie';

  @override
  String get detailTotalReps => 'Flexiones totales';

  @override
  String get detailAverageRep => 'Tiempo medio por repetición';

  @override
  String get detailFormSummary => 'Resumen de la técnica';

  @override
  String get detailImprovements => 'Puntos de mejora';

  @override
  String get detailStrengths => 'Puntos fuertes';

  @override
  String get detailInterrupted => 'Finalizado antes de tiempo';

  @override
  String get detailCompleted => 'Completado';

  @override
  String detailSetRow(int set, int reps) {
    return 'Serie $set: $reps rep.';
  }

  @override
  String detailSessionOn(String date, String time) {
    return '$date a las $time';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsRateApp => 'Calificar esta app';

  @override
  String get settingsRateAppSubtitle => 'Califica MotionFit';

  @override
  String get settingsRateAppError =>
      'No se pudo abrir la tienda. Inténtalo de nuevo.';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionCoaching => 'Entrenamiento por voz';

  @override
  String get settingsSectionReminder => 'Recordatorios de entrenamiento';

  @override
  String get settingsSectionCamera => 'Cámara';

  @override
  String get settingsSectionPrivacy => 'Privacidad y datos';

  @override
  String get settingsSectionAbout => 'Acerca de';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsDisplayTheme => 'Tema de pantalla';

  @override
  String get settingsColorTheme => 'Tema de color';

  @override
  String get themeLight => 'Claro';

  @override
  String get themePureBlack => 'Negro puro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get colorThemeByeokcheong => 'Azul Byeokcheong';

  @override
  String get colorThemeChuhyang => 'Beige Chuhyang';

  @override
  String get colorThemeJangdan => 'Rojo Jangdan';

  @override
  String get colorThemeCheonghyeon => 'Azul Cheonghyeon';

  @override
  String get colorThemeHaenghwang => 'Albaricoque Haenghwang';

  @override
  String get colorThemeChunyu => 'Verde Chunyu';

  @override
  String get colorThemeSeolbaek => 'Blanco Seolbaek';

  @override
  String get colorThemeByeokja => 'Violeta Byeokja';

  @override
  String get colorThemeChwiram => 'Menta Chwiram';

  @override
  String get languageSystem => 'Usar idioma del dispositivo';

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
  String get languageChanged => 'Idioma actualizado';

  @override
  String get voiceCoachingEnabled => 'Entrenamiento por voz';

  @override
  String get voiceRepCountEnabled => 'Decir el número de repeticiones';

  @override
  String get voiceFormEnabled => 'Consejos de técnica';

  @override
  String get voiceEncouragementEnabled => 'Ánimos';

  @override
  String get voiceRate => 'Velocidad de la voz';

  @override
  String get voiceRateSlow => 'Lenta';

  @override
  String get voiceRateNormal => 'Normal';

  @override
  String get voiceRateFast => 'Rápida';

  @override
  String get voiceTest => 'Probar voz';

  @override
  String get voiceTestPhrase => 'Genial. Tu entrenador por voz está listo.';

  @override
  String get voiceUnavailable =>
      'No hay ninguna voz sin conexión compatible instalada para este idioma.';

  @override
  String get reminderTitle => 'Recordatorios de entrenamiento';

  @override
  String get reminderSubtitle =>
      'Elige una hora para cada día que quieras entrenar.';

  @override
  String get reminderEnabled => 'Recordatorio activado';

  @override
  String get reminderTime => 'Hora del recordatorio';

  @override
  String get reminderCopyTime => 'Copiar esta hora';

  @override
  String reminderCopyFromDay(String day) {
    return 'Copiar hora de $day';
  }

  @override
  String get reminderApplyAll => 'Aplicar a todos los días';

  @override
  String reminderNext(String dateTime) {
    return 'Próximo recordatorio: $dateTime';
  }

  @override
  String get reminderNoneScheduled => 'No hay recordatorios programados';

  @override
  String get reminderPermissionNeeded =>
      'Permite las notificaciones para activar los recordatorios.';

  @override
  String get reminderSaved => 'Horario de recordatorios guardado';

  @override
  String get weekdayMonday => 'Lunes';

  @override
  String get weekdayTuesday => 'Martes';

  @override
  String get weekdayWednesday => 'Miércoles';

  @override
  String get weekdayThursday => 'Jueves';

  @override
  String get weekdayFriday => 'Viernes';

  @override
  String get weekdaySaturday => 'Sábado';

  @override
  String get weekdaySunday => 'Domingo';

  @override
  String get weekdayMondayShort => 'Lun';

  @override
  String get weekdayTuesdayShort => 'Mar';

  @override
  String get weekdayWednesdayShort => 'Mié';

  @override
  String get weekdayThursdayShort => 'Jue';

  @override
  String get weekdayFridayShort => 'Vie';

  @override
  String get weekdaySaturdayShort => 'Sáb';

  @override
  String get weekdaySundayShort => 'Dom';

  @override
  String get cameraFront => 'Cámara frontal';

  @override
  String get cameraRear => 'Cámara trasera';

  @override
  String get cameraMirrorPreview => 'Reflejar vista frontal';

  @override
  String get cameraPoseOverlay => 'Guía de postura superpuesta';

  @override
  String get cameraKeepScreenAwake =>
      'Mantener la pantalla activa durante el entrenamiento';

  @override
  String get settingsHaptics => 'Respuesta háptica';

  @override
  String get privacyTitle => 'Cómo se tratan tus datos';

  @override
  String get privacyLocalProcessing =>
      'El análisis de postura se ejecuta en este dispositivo.';

  @override
  String get privacyNoVideoStorage =>
      'El vídeo del entrenamiento solo se guarda en este dispositivo cuando activas la revisión.';

  @override
  String get privacyNoUpload =>
      'Las imágenes de la cámara no se envían a ningún servidor.';

  @override
  String get privacyStoredData => 'Datos guardados en este dispositivo';

  @override
  String get privacyStoredDataDescription =>
      'MotionFit guarda las horas de entrenamiento, las series, las repeticiones y los resultados de técnica para que puedas consultar tu progreso.';

  @override
  String get privacyDeleteData => 'Eliminar todos los datos de entrenamiento';

  @override
  String get privacyDeleteConfirmTitle =>
      '¿Eliminar todos los datos de entrenamiento?';

  @override
  String get privacyDeleteConfirmBody =>
      'Esto eliminará de forma permanente tu historial de entrenamiento de este dispositivo. No se puede deshacer.';

  @override
  String get privacyDeleteConfirmAction => 'Eliminar todos los datos';

  @override
  String get privacyDeleteSuccess => 'Datos de entrenamiento eliminados';

  @override
  String get privacyDeleteFailure =>
      'No se han podido eliminar los datos de entrenamiento.';

  @override
  String get appInfoTitle => 'Información de la aplicación';

  @override
  String appInfoVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get appInfoLicenses => 'Licencias de código abierto';

  @override
  String get appInfoPrivacyPolicy => 'Política de privacidad';

  @override
  String get appInfoDescription =>
      'MotionFit cuenta flexiones y ofrece indicaciones privadas de técnica directamente en tu dispositivo.';

  @override
  String get errorGenericTitle => 'Algo ha salido mal';

  @override
  String get errorGenericBody =>
      'Vuelve a intentarlo. Tus registros de entrenamiento actuales están a salvo.';

  @override
  String get errorCameraInit => 'No se ha podido iniciar la cámara.';

  @override
  String get errorCameraInUse =>
      'Es posible que otra aplicación esté usando la cámara.';

  @override
  String get errorPoseModelLoad =>
      'No se ha podido cargar el modelo de postura.';

  @override
  String get errorNoPerson =>
      'No se ha detectado ninguna persona. Entra en pantalla.';

  @override
  String get errorWholeBody =>
      'Tu cuerpo no se ve por completo. Aléjate un poco.';

  @override
  String get errorMultiplePeople =>
      'Hay más de una persona en pantalla. Deja solo a una persona en la imagen.';

  @override
  String get errorTrackingLost =>
      'El seguimiento está en pausa hasta que tu cuerpo vuelva a ser visible.';

  @override
  String get errorDatabaseSave => 'No se ha podido guardar tu entrenamiento.';

  @override
  String get errorTtsVoiceMissing =>
      'No hay ninguna voz de síntesis instalada en este dispositivo.';

  @override
  String get errorTtsLocaleUnsupported =>
      'Este dispositivo no admite el entrenamiento por voz para el idioma seleccionado.';

  @override
  String get emptyNoFormIssues =>
      'No se han detectado problemas de técnica repetidos.';

  @override
  String get emptyNotEnoughData => 'Aún no hay suficientes datos';

  @override
  String get loadingCamera => 'Iniciando cámara…';

  @override
  String get loadingPoseModel => 'Preparando la detección de movimiento…';

  @override
  String get loadingSavingWorkout => 'Guardando entrenamiento…';

  @override
  String get formScore => 'Puntuación de la técnica';

  @override
  String get formShort => 'Técnica';

  @override
  String formScoreValue(int score) {
    return '$score ptos.';
  }

  @override
  String get formIssueDepth => 'Profundidad de la flexión';

  @override
  String get formIssueTorsoLean => 'Alineación corporal';

  @override
  String get formIssueHeelLift => 'Posición de la cadera';

  @override
  String get formIssueKneeAlignment => 'Alineación de los codos';

  @override
  String get formIssueBalance => 'Equilibrio izquierda-derecha';

  @override
  String get formIssueDescentSpeed => 'Velocidad de bajada';

  @override
  String get formIssueAscentSpeed => 'Velocidad de subida';

  @override
  String get formIssueControl => 'Control del movimiento';

  @override
  String get formIssueStandingCompletion => 'Extensión de brazos';

  @override
  String get formIssueNotObservable =>
      'No se puede evaluar desde este ángulo de cámara';

  @override
  String get formStrengthDepth => 'Profundidad constante';

  @override
  String get formStrengthControl => 'Movimiento controlado';

  @override
  String get formStrengthBalance => 'Equilibrio estable';

  @override
  String get coachTrackingLost1 =>
      'Vuelve a entrar en pantalla y continuaremos.';

  @override
  String get coachTrackingLost2 =>
      'He dejado de verte. Colócate donde se vea todo tu cuerpo.';

  @override
  String get coachWholeBody1 =>
      'Mantén muñeca, codo, hombro, cadera y tobillo en pantalla.';

  @override
  String get coachWholeBody2 =>
      'Aléjate para que se vea toda la posición de flexión.';

  @override
  String get coachMultiplePeople1 =>
      'Deja solo a una persona en pantalla para que pueda seguirte.';

  @override
  String get coachReady1 => 'Estás en posición. Empecemos.';

  @override
  String get coachReady2 =>
      'Buena posición. Prepárate para tu primera flexión.';

  @override
  String coachStartSet(int set) {
    return 'Serie $set. Vamos.';
  }

  @override
  String coachSevenDayChallengeStart(int day) {
    return 'Comienza el día $day del desafío de siete días.';
  }

  @override
  String coachCumulativeChallengeStart(int completed, int remaining) {
    return 'Comienza el desafío de repeticiones acumuladas. Llevas $completed repeticiones y te quedan $remaining.';
  }

  @override
  String coachRepCount(int count) {
    return '$count';
  }

  @override
  String get coachDepth1 =>
      'En la próxima repetición, intenta bajar un poco más.';

  @override
  String get coachDepth2 =>
      'Dale un poco más de profundidad a la siguiente flexión.';

  @override
  String get coachTorso1 => 'Mantén hombros, cadera y tobillos en línea.';

  @override
  String get coachTorso2 => 'Activa el abdomen y mantén el cuerpo recto.';

  @override
  String get coachHeel1 => 'Mantén la cadera a la altura de los hombros.';

  @override
  String get coachHeel2 => 'Evita bajar o elevar demasiado la cadera.';

  @override
  String get coachKnees1 => 'Lleva los codos hacia atrás, no hacia los lados.';

  @override
  String get coachKnees2 => 'Acerca un poco más los codos al cuerpo.';

  @override
  String get coachBalance1 => 'Reparte el peso por igual entre ambos lados.';

  @override
  String get coachBalance2 =>
      'Busca una postura estable y equilibrada para la próxima repetición.';

  @override
  String get coachDescendSlow1 =>
      'La próxima vez, intenta bajar un poco más despacio.';

  @override
  String get coachDescendSlow2 =>
      'Controla la bajada en la próxima repetición.';

  @override
  String get coachDescendFaster1 =>
      'En la próxima repetición, baja un poco más rápido.';

  @override
  String get coachDescendFaster2 =>
      'En la próxima bajada, mantén el movimiento sin detenerte.';

  @override
  String get coachAscendControlled1 => 'Sube con suavidad y mantén el control.';

  @override
  String get coachAscendControlled2 =>
      'Empuja hacia arriba con un ritmo constante y controlado.';

  @override
  String get coachAscendFaster1 => 'Sube con un poco más de impulso.';

  @override
  String get coachAscendFaster2 =>
      'En la próxima repetición, empuja hacia arriba con más decisión.';

  @override
  String get coachControl1 =>
      'Haz la próxima repetición con fluidez de principio a fin.';

  @override
  String get coachControl2 => 'Mantén el control durante todo el movimiento.';

  @override
  String get coachStandTall1 =>
      'Termina con los brazos completamente extendidos.';

  @override
  String get coachStandTall2 => 'Vuelve por completo a la posición alta.';

  @override
  String get coachGood1 => 'Bien. Mantén ese ritmo.';

  @override
  String get coachGood2 => 'Buen control. Sigue así.';

  @override
  String get coachGood3 => 'Gran repetición. Hazlo otra vez.';

  @override
  String get coachLastTwo => 'Últimas dos. ¡Sigue fuerte!';

  @override
  String get coachLastOne => 'Última. ¡Termina fuerte!';

  @override
  String coachSetComplete(int set) {
    return 'Genial. Has completado la serie $set.';
  }

  @override
  String coachRestStart(int seconds) {
    return 'Descansa $seconds segundos. Respira y recupérate.';
  }

  @override
  String get coachRestTenSeconds => 'Quedan diez segundos de descanso.';

  @override
  String get coachRestComplete =>
      'Se acabó el descanso. Prepárate para la siguiente serie.';

  @override
  String coachWorkoutComplete(int reps) {
    return 'Entrenamiento completado. Has hecho $reps flexiones.';
  }

  @override
  String get notificationReminderTitle => 'Hora de las flexiones de hoy';

  @override
  String get notificationReminderBody =>
      'Incluso una sesión corta cuenta. Abre MotionFit cuando estés listo.';

  @override
  String get notificationReminderBodyVariant2 =>
      'Unas cuantas flexiones bien hechas suman movimiento a tu día.';

  @override
  String notificationStreakReminderBody(int days) {
    return 'Mantén hoy tu racha de $days días con una sesión corta.';
  }

  @override
  String get semanticsIncrease => 'Aumentar';

  @override
  String get semanticsDecrease => 'Disminuir';

  @override
  String semanticsSelectedTab(String tab) {
    return 'Pestaña seleccionada: $tab';
  }

  @override
  String semanticsCalendarWorkoutDate(String date) {
    return '$date, entrenamiento registrado';
  }

  @override
  String semanticsCalendarEmptyDate(String date) {
    return '$date, sin entrenamiento';
  }

  @override
  String semanticsCurrentRep(int current, int target) {
    return 'Repetición actual: $current de $target';
  }

  @override
  String get repVideoReviewTitle => 'Revisión en vídeo por repetición';

  @override
  String get repVideoReviewDescription =>
      'Guarda el vídeo de este entrenamiento en el dispositivo para revisar cada repetición después.';

  @override
  String get repVideoLocalOnly => 'Solo local · Nunca se sube';

  @override
  String get formReviewTitle => 'Revisión de técnica';

  @override
  String get formReviewMainIssue => 'Problema principal';

  @override
  String get viewRepTimeline => 'Ver repeticiones';

  @override
  String get repTimelineTitle => 'Revisión de repeticiones';

  @override
  String get repTimelineAll => 'Todas';

  @override
  String get repTimelineImprove => 'Mejorar';

  @override
  String get repTimelineNoImprovement => 'Ninguna repetición necesita mejorar.';

  @override
  String repSetNumber(int number) {
    return 'Serie $number';
  }

  @override
  String repNumber(int number) {
    return 'Repetición $number';
  }

  @override
  String get repResultGood => 'Buena técnica';

  @override
  String get repResultNeedsAttention => 'Requiere atención';

  @override
  String get repResultImproved => 'Mejor que la anterior';

  @override
  String get repResultNotAssessed => 'Difícil de evaluar';

  @override
  String get repIssueShallowDepth => 'Intenta bajar un poco más';

  @override
  String get repIssueForwardLean => 'El torso se inclinó hacia delante';

  @override
  String get repIssueKneesInward => 'Los codos se abrieron hacia fuera';

  @override
  String get repVideoNotSaved => 'Vídeo no guardado';

  @override
  String get repReplay => 'Repetir';

  @override
  String get repWhatHappened => 'Qué ocurrió';

  @override
  String get repHowToImprove => 'Cómo mejorar';

  @override
  String get repWhatWentWell => 'Lo que salió bien';

  @override
  String get repPrevious => 'Repetición anterior';

  @override
  String get repNext => 'Siguiente repetición';

  @override
  String get repFeedbackGood =>
      'Esta repetición se mantuvo dentro de los rangos que MotionFit pudo evaluar.';

  @override
  String get repFeedbackDepth =>
      'No alcanzaste tu profundidad habitual. Baja un poco más manteniendo el pecho estable.';

  @override
  String get repFeedbackTorso =>
      'La línea corporal cambió durante la repetición. Activa el abdomen y estabiliza la cadera.';

  @override
  String get repFeedbackKnees =>
      'Los codos se abrieron hacia fuera. Llévalos hacia atrás y cerca del cuerpo.';

  @override
  String repFeedbackGeneric(String area) {
    return 'Esta repetición requiere atención en $area.';
  }

  @override
  String get deleteWorkoutVideo => 'Eliminar vídeo del entrenamiento';

  @override
  String get deleteWorkoutVideoTitle => '¿Eliminar este vídeo?';

  @override
  String get deleteWorkoutVideoBody =>
      'Solo se eliminará el vídeo local. El análisis y el registro se conservarán.';

  @override
  String get workoutVideoDeleted => 'Vídeo del entrenamiento eliminado';
}
