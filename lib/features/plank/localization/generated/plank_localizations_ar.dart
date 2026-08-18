// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'plank_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class PlankLocalizationsAr extends PlankLocalizations {
  PlankLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'MotionFit - Plank';

  @override
  String get navSquat => 'البلانك';

  @override
  String get navChallenge => 'التحدي';

  @override
  String get navRecords => 'التقدم';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get challengeTitle => 'تحدي البلانك الخاص بي';

  @override
  String get challengeSubtitle =>
      'اختر تحديًا يناسب هدفك واستمر في التمرين بانتظام.';

  @override
  String get challengeChooseTitle => 'اختر تحديًا';

  @override
  String get challengeSevenDayTitle => 'تحدي البداية لمدة 7 أيام';

  @override
  String get challengeSevenDayDescription => 'برنامج تدريجي للمبتدئين';

  @override
  String get challengeSevenDaySummary =>
      'اتبع هدفًا يناسب مستواك ويزداد يوميًا لمدة 7 أيام.';

  @override
  String get challengeSevenDayEveryDay =>
      'استمر يوميًا لمدة 7 أيام دون أيام تعافٍ';

  @override
  String challengeDurationDays(int days) {
    return '$days أيام';
  }

  @override
  String get challengeLevelGoals => 'أهداف تناسب مستواك';

  @override
  String get challengeRecoveryIncluded => 'يتضمن أيام تعافٍ';

  @override
  String get challengeDailyGoal => 'أهداف يومية للثوانٍ';

  @override
  String get challengeSevenDayStart => 'بدء تحدي 7 أيام';

  @override
  String get challengeSevenDaySettings => 'حدد هدف 7 أيام';

  @override
  String get challengeSevenDaySettingsDescription =>
      'اختر هدف اليوم الأول، وسيزداد الهدف 5 ثوانٍ يوميًا.';

  @override
  String get challengeFirstDayGoal => 'هدف ثوانٍ اليوم الأول';

  @override
  String challengeSevenDayPreview(int first, int last) {
    return 'اليوم 1: $first ← اليوم 7: $last ثوانٍ';
  }

  @override
  String get challengeWeeklyTitle => 'تحدي 3 مرات أسبوعيًا';

  @override
  String get challengeWeeklyDescription =>
      'تحدي لبناء عادة دون الحاجة إلى تمرين يومي';

  @override
  String get challengeWeeklySummary =>
      'تمرّن في 3 أيام تختارها أسبوعيًا لمدة 4 أسابيع.';

  @override
  String challengeDurationWeeks(int weeks) {
    return '$weeks أسابيع';
  }

  @override
  String get challengeThreePerWeek => '3 تمارين كل أسبوع';

  @override
  String get challengeChooseWeekdays => 'اختر 3 أيام للتمرين';

  @override
  String get challengeWorkoutDaysCount => 'يُحسب التقدم حسب أيام التمرين';

  @override
  String get challengeWeeklyStart => 'بدء التحدي الأسبوعي';

  @override
  String get challengeCumulativeTitle => 'تحدي مجموع الثوانٍ';

  @override
  String get challengeCumulativeDescription =>
      'حقق هدفًا إجماليًا للالبلانك وفق جدولك';

  @override
  String get challengeCumulativeSummary =>
      'اختر المدة والهدف الإجمالي مع الحفاظ على التقدم في أيام الراحة.';

  @override
  String get challengePreset200 => '200 البلانك خلال 7 أيام';

  @override
  String get challengePreset500 => '500 البلانك خلال 14 يومًا';

  @override
  String get challengeCustomGoal => 'اختر المدة والهدف';

  @override
  String get challengeRestWithoutReset => 'أيام الراحة لا تعيد ضبط التقدم';

  @override
  String get challengeCumulativeStart => 'بدء تحدي المجموع';

  @override
  String get challengeHistoryTitle => 'التحديات السابقة';

  @override
  String get challengeHistoryEmpty => 'ستظهر التحديات المكتملة والمنتهية هنا.';

  @override
  String get challengeRecommended => 'موصى به لك';

  @override
  String challengeRecommendationFromWorkout(int reps) {
    return 'موصى به بناءً على تمرينك الأول الذي بلغ $reps ثوانٍ.';
  }

  @override
  String get challengeRecommendationDefault =>
      'نوصي ببداية مريحة لمدة 7 أيام لتحديك الأول.';

  @override
  String get challengeActive => 'التحدي النشط';

  @override
  String get challengeNext => 'التالي';

  @override
  String challengeDayNumber(int day) {
    return 'اليوم $day';
  }

  @override
  String get challengeRecoveryDay => 'يوم تعافٍ';

  @override
  String challengeTodayProgress(int current, int target) {
    return 'اليوم $current / $target ثوانٍ';
  }

  @override
  String get challengeRestToday => 'امنح نفسك وقتًا كافيًا للتعافي اليوم.';

  @override
  String get challengeTodayCompleted => 'اكتمل هدف اليوم · تابع غدًا';

  @override
  String challengeRepsRemaining(int reps) {
    return 'متبقٍ $reps ثوانٍ';
  }

  @override
  String challengeWeekNumber(int week) {
    return 'الأسبوع $week';
  }

  @override
  String challengeThisWeekProgress(int current, int target) {
    return 'هذا الأسبوع $current / $target تمارين';
  }

  @override
  String challengeOverallDays(int current, int target) {
    return 'الإجمالي $current / $target أيام';
  }

  @override
  String challengeRepsProgress(int current, int target) {
    return '$current / $target ثوانٍ';
  }

  @override
  String challengeDaysRemaining(int days) {
    return 'متبقٍ $days أيام';
  }

  @override
  String challengeTodaySuggested(int reps) {
    return 'الهدف المقترح لليوم: $reps ثوانٍ';
  }

  @override
  String challengePercent(int percent) {
    return 'اكتمل $percent٪';
  }

  @override
  String get challengeSquatStart => 'بدء البلانك';

  @override
  String get challengeTodayWorkoutStart => 'بدء تمرين اليوم';

  @override
  String get challengeViewDetails => 'عرض التفاصيل';

  @override
  String get challengeRestart => 'البدء مجددًا';

  @override
  String get challengeDeleteHistory => 'الحذف من السجل';

  @override
  String get challengeCumulativeSettings => 'تحديد الهدف الإجمالي';

  @override
  String get challengeDurationLabel => 'المدة';

  @override
  String get challengeGoalLabel => 'الثوانٍ المستهدفة';

  @override
  String get challengeNotFound => 'لم يعد هذا التحدي متاحًا.';

  @override
  String get challengePeriod => 'الفترة';

  @override
  String get challengeStatus => 'الحالة';

  @override
  String get challengeTotalReps => 'إجمالي البلانك';

  @override
  String get challengeWorkoutDays => 'أيام التمرين';

  @override
  String challengeDaysCount(int days) {
    return '$days أيام';
  }

  @override
  String get challengeTotalTime => 'إجمالي وقت التمرين';

  @override
  String get challengeSchedule => 'الجدول والتقدم';

  @override
  String get challengeNotifications => 'تذكيرات التحدي';

  @override
  String get challengeNotificationsDescription =>
      'احفظ إعداد التذكير لهذا التحدي.';

  @override
  String get challengeReminderNotificationTitle => 'تحدي البلانك بانتظارك';

  @override
  String get challengeReminderNotificationBody =>
      'افتح MotionFit وتقدم نحو هدف تحدي اليوم.';

  @override
  String get challengeSelectedWeekdays => 'أيام التمرين المختارة';

  @override
  String get challengeNoProgressYet => 'لا توجد تمارين للتحدي بعد.';

  @override
  String get challengeCancel => 'إنهاء التحدي';

  @override
  String get challengeCancelTitle => 'هل تريد إنهاء هذا التحدي؟';

  @override
  String get challengeCancelDescription =>
      'ستبقى سجلات تمرينك محفوظة وسينتقل التحدي إلى السجل.';

  @override
  String get challengeStatusActive => 'قيد التقدم';

  @override
  String get challengeStatusCompleted => 'مكتمل';

  @override
  String get challengeStatusEnded => 'منتهٍ';

  @override
  String get challengeStatusCancelled => 'ملغى';

  @override
  String get challengeProgressUpdated => 'تم تحديث تقدم التحدي.';

  @override
  String get challengeCheck => 'عرض التحدي';

  @override
  String get commonDone => 'تم';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonStart => 'بدء';

  @override
  String get commonSkip => 'تخطٍّ';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonOn => 'تشغيل';

  @override
  String get commonOff => 'إيقاف';

  @override
  String get commonEnabled => 'مفعّل';

  @override
  String get commonDisabled => 'غير مفعّل';

  @override
  String get commonNotAvailable => 'غير متاح';

  @override
  String get commonToday => 'اليوم';

  @override
  String get commonYesterday => 'أمس';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String unitSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مجموعة',
      many: '$count مجموعة',
      few: '$count مجموعات',
      two: 'مجموعتان',
      one: 'مجموعة واحدة',
      zero: '0 مجموعات',
    );
    return '$_temp0';
  }

  @override
  String unitReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ثوانٍ',
      many: '$count ثوانٍ',
      few: '$count ثوانٍ',
      two: 'ثوانٍ',
      one: 'ثوانٍ واحد',
      zero: '0 ثوانٍ',
    );
    return '$_temp0';
  }

  @override
  String unitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ثانية',
      many: '$count ثانية',
      few: '$count ثوانٍ',
      two: 'ثانيتان',
      one: 'ثانية واحدة',
      zero: '0 ثانية',
    );
    return '$_temp0';
  }

  @override
  String unitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      many: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
      zero: '0 دقيقة',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes د $seconds ث';
  }

  @override
  String get homeGreeting => 'هل أنت مستعد للحركة؟';

  @override
  String get homeTodayTitle => 'سجل اليوم';

  @override
  String get homeTodayNoWorkout =>
      'لم تؤدِّ تمارين البلانك اليوم بعد. ابدأ بمجموعة قصيرة.';

  @override
  String homeTodaySummary(int reps, int sets) {
    return '$reps البلانك ضمن $sets مجموعة';
  }

  @override
  String get homeViewResult => 'عرض النتيجة';

  @override
  String get homeTodaySets => 'مجموعات اليوم';

  @override
  String get homeTodayReps => 'ما أنجزته اليوم';

  @override
  String get streakLabel => 'السلسلة';

  @override
  String streakDays(int days) {
    return '$days أيام';
  }

  @override
  String get homeWorkoutSetup => 'التمرين التالي';

  @override
  String get homeSetsLabel => 'عدد المجموعات';

  @override
  String get homeRepsPerSetLabel => 'ثوانٍ لكل مجموعة';

  @override
  String get homeRestTimeLabel => 'وقت الراحة';

  @override
  String get homeDirectInputHint => 'أدخل رقمًا';

  @override
  String get homeStartWorkout => 'بدء التمرين';

  @override
  String get homeLastSettingsRestored => 'إعدادات تمرينك الأخير جاهزة.';

  @override
  String get validationNumberRequired => 'أدخل رقمًا.';

  @override
  String validationRange(num min, num max) {
    return 'اختر قيمة من $min إلى $max.';
  }

  @override
  String get guideTitle => 'جهّز الكاميرا';

  @override
  String get guideLandscapeTitle => 'أدر هاتفك إلى الوضع الأفقي';

  @override
  String get guideLandscapeBody =>
      'يعمل تتبع البلانك بالوضع الأفقي. ضع الهاتف أفقيًا قبل اتخاذ الوضعية.';

  @override
  String get countdownLandscapePrompt => 'أبقِ هاتفك في الوضع الأفقي';

  @override
  String get guideSubtitle => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get guideWholeBody => 'اجعل جسمك كاملًا ظاهرًا من الرأس إلى القدمين.';

  @override
  String get guideStableCamera => 'ضع هاتفك في مكان ثابت.';

  @override
  String get guideOnePerson => 'تأكد من وجود شخص واحد فقط في الإطار.';

  @override
  String get guideCameraAngle =>
      'استخدم زاوية جانبية أو جانبية مائلة قليلًا إن أمكن.';

  @override
  String get guideLighting => 'تجنب الأماكن المعتمة والإضاءة الخلفية القوية.';

  @override
  String get guidePrivacy =>
      'يبقى الفيديو على هذا الجهاز ولا يُحفظ إلا عند تفعيل مراجعة الثوانٍ.';

  @override
  String get guideContinue => 'أنا في الموضع المناسب';

  @override
  String get permissionCameraTitle => 'يلزم السماح باستخدام الكاميرا';

  @override
  String get permissionCameraBody =>
      'يستخدم MotionFit الكاميرا لعدّ البلانك. لا يُحفظ الفيديو على هذا الجهاز إلا عند تفعيل المراجعة.';

  @override
  String get permissionCameraRequest => 'متابعة';

  @override
  String get permissionCameraDenied =>
      'رُفض إذن الكاميرا. لا يزال بإمكانك عرض السجل والإعدادات.';

  @override
  String get permissionCameraPermanentlyDenied =>
      'اسمح باستخدام الكاميرا من إعدادات النظام لبدء التمرين.';

  @override
  String get permissionOpenSettings => 'فتح الإعدادات';

  @override
  String get permissionNotificationTitle => 'هل تسمح بتذكيرات التمرين؟';

  @override
  String get permissionNotificationBody =>
      'تُستخدم الإشعارات فقط للتذكيرات التي تضبطها.';

  @override
  String get permissionNotificationRequest => 'السماح بالإشعارات';

  @override
  String get permissionNotificationDenied =>
      'الإشعارات متوقفة. فعّلها من إعدادات النظام لتلقي التذكيرات.';

  @override
  String get countdownGetReady => 'استعد';

  @override
  String countdownBeginsIn(int seconds) {
    return 'البدء خلال $seconds';
  }

  @override
  String get calibrationTitle => 'البلانك';

  @override
  String get calibrationBody => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get calibrationStayStill => 'اثبت للحظة';

  @override
  String get calibrationComplete => 'أصبحت جاهزًا';

  @override
  String get calibrationFailed => 'تعذر تحديد وضع وقوف واضح.';

  @override
  String get calibrationRetry => 'إعادة المعايرة';

  @override
  String workoutSetProgress(int current, int total) {
    return 'المجموعة $current من $total';
  }

  @override
  String workoutRepProgress(int current, int target) {
    return '$current من $target';
  }

  @override
  String workoutTotalReps(int count) {
    return 'الإجمالي $count';
  }

  @override
  String get workoutElapsed => 'الوقت المنقضي';

  @override
  String get workoutPause => 'إيقاف مؤقت';

  @override
  String get workoutResume => 'متابعة التمرين';

  @override
  String get workoutEnd => 'إيقاف مؤقت';

  @override
  String get workoutBackToSetup => 'العودة إلى الإعداد';

  @override
  String get workoutEndDialogTitle => 'هل تريد التوقف مؤقتًا؟';

  @override
  String get workoutEndDialogBody =>
      'سيتم حفظ تقدمك لتتمكن من المتابعة من الشاشة الرئيسية.';

  @override
  String get workoutEndDialogConfirm => 'حفظ ومغادرة';

  @override
  String get workoutPauseReasonBackground =>
      'توقف التمرين مؤقتًا عندما انتقل التطبيق إلى الخلفية.';

  @override
  String get workoutPauseReasonInterruption =>
      'توقف التمرين مؤقتًا بعد مقاطعة من النظام.';

  @override
  String get workoutStateReady => 'البلانك';

  @override
  String get workoutStateDescending =>
      'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get workoutStateBottom =>
      'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get workoutStateAscending => 'صعود';

  @override
  String get workoutStateCompleted => 'تمت ثانية واحدة';

  @override
  String get workoutStateTrackingLost => 'عُد إلى نطاق الكاميرا';

  @override
  String get workoutStatePaused => 'متوقف مؤقتًا';

  @override
  String get workoutTrackingGood => 'الجسم ظاهر';

  @override
  String get workoutCameraSwitch => 'تبديل الكاميرا';

  @override
  String get workoutSkeletonToggle => 'إظهار دليل الوضعية';

  @override
  String get restTitle => 'راحة';

  @override
  String restNextSet(int set, int total) {
    return 'التالي: المجموعة $set من $total';
  }

  @override
  String get restCompletedSets => 'المجموعات المكتملة';

  @override
  String get restTotalReps => 'البلانك حتى الآن';

  @override
  String get restSkip => 'تخطي الراحة';

  @override
  String get restAddFifteenSeconds => 'إضافة 15 ثانية';

  @override
  String get restEndWorkout => 'إيقاف مؤقت';

  @override
  String get restAlmostDone => 'أوشكت الراحة على الانتهاء';

  @override
  String get restReady => 'حان وقت المجموعة التالية';

  @override
  String get completeTitle => 'اكتمل التمرين';

  @override
  String get completeSubtitle => 'أداء قوي. إليك ملخص جلستك.';

  @override
  String get workoutInterruptedSubtitle =>
      'راجع ما تم تسجيله قبل الإنهاء المبكر.';

  @override
  String get completeTotalReps => 'إجمالي البلانك';

  @override
  String get completeCompletedSets => 'المجموعات المكتملة';

  @override
  String get completeActiveTime => 'وقت التمرين الفعلي';

  @override
  String get completeRestTime => 'وقت الراحة';

  @override
  String get completeTotalTime => 'الوقت الإجمالي';

  @override
  String get completeAverageRepTime => 'متوسط زمن الثوانٍ';

  @override
  String get completeFormSummary => 'ملخص الأداء';

  @override
  String get todayCoaching => 'تدريب اليوم';

  @override
  String coachingIssueFrequency(int total, int count, String issue) {
    return 'في $count من أصل $total ثوانٍ:\n$issue';
  }

  @override
  String get completeTopImprovement => 'نقطة التركيز القادمة';

  @override
  String get completeStrengths => 'ما أتقنته';

  @override
  String get completeSaved => 'حُفظ التمرين على هذا الجهاز';

  @override
  String get completeSaveFailed =>
      'تعذر حفظ التمرين. أعد المحاولة قبل المغادرة.';

  @override
  String get completeNoFormData =>
      'لم تكن الحركة الظاهرة كافية لإنشاء ملخص للأداء.';

  @override
  String get completeFinish => 'إنهاء';

  @override
  String get postWorkoutReminderTitle => 'حافظ على زخمك';

  @override
  String postWorkoutReminderBody(String time) {
    return 'هل تريد تذكيرًا يوميًا الساعة $time بدءًا من الغد؟';
  }

  @override
  String get postWorkoutReminderEnable => 'ذكّرني';

  @override
  String get postWorkoutReminderLater => 'ربما لاحقًا';

  @override
  String get postWorkoutReminderEnabled => 'تم ضبط التذكير.';

  @override
  String get recordsTitle => 'التقدم';

  @override
  String get recordsWeeklySummary => 'هذا الأسبوع';

  @override
  String recordsWorkoutCount(int count) {
    return '$count تمارين';
  }

  @override
  String recordsAverageForm(int score) {
    return 'متوسط الأداء $score';
  }

  @override
  String recordsWorkoutTime(String time) {
    return 'الوقت $time';
  }

  @override
  String get recordsFirstWeek => 'هذا أول سجل لك هذا الأسبوع';

  @override
  String recordsMoreThanLastWeek(int count) {
    return 'أديت $count ثوانٍ أكثر من الأسبوع الماضي';
  }

  @override
  String recordsLessThanLastWeek(int count) {
    return 'أديت $count ثوانٍ أقل من الأسبوع الماضي';
  }

  @override
  String get recordsSameAsLastWeek => 'نفس حجم الأسبوع الماضي';

  @override
  String get recordsTrendEmpty => 'أكمل المزيد من التمارين لرؤية تطور أدائك.';

  @override
  String get recordsFirstFormScore => 'أول نتيجة للأداء';

  @override
  String recordsRecentAverage(int count, int score) {
    return 'متوسط آخر $count تمارين: $score';
  }

  @override
  String get recordsStrength => 'نقطة قوة';

  @override
  String get recordsFocus => 'التركيز';

  @override
  String get recordsTodayPoint => 'تركيز اليوم';

  @override
  String get recordsToday => 'اليوم';

  @override
  String get recordsRecentWorkouts => 'التمارين الأخيرة';

  @override
  String get recordsCalendarTitle => 'تقويم التمارين';

  @override
  String get recordsFormTrend => 'تطور الأداء';

  @override
  String get recordsViewCalendar => 'التقويم';

  @override
  String get recordsViewList => 'القائمة';

  @override
  String get recordsViewStats => 'الإحصاءات';

  @override
  String get recordsCalendarPreviousMonth => 'الشهر السابق';

  @override
  String get recordsCalendarNextMonth => 'الشهر التالي';

  @override
  String get recordsCalendarWorkoutDay => 'يوم تمرين';

  @override
  String get recordsCalendarNoWorkoutSelected => 'اختر يوم تمرين لعرض جلساته.';

  @override
  String get recordsDayTotal => 'إجمالي اليوم';

  @override
  String recordsSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جلسة',
      many: '$count جلسة',
      few: '$count جلسات',
      two: 'جلستان',
      one: 'جلسة واحدة',
      zero: 'لا جلسات',
    );
    return '$_temp0';
  }

  @override
  String recordsSessionTitle(int number) {
    return 'الجلسة $number';
  }

  @override
  String get recordsListNewest => 'الأحدث أولًا';

  @override
  String get recordsOpenDetail => 'عرض التفاصيل';

  @override
  String get recordsEmptyTitle => 'لا توجد تمارين بعد';

  @override
  String get recordsEmptyBody => 'أكمل أول تمرين البلانك وسيظهر هنا.';

  @override
  String get recordsStartWorkout => 'بدء تمرين';

  @override
  String get recordsLoading => 'جارٍ تحميل تمارينك…';

  @override
  String get recordsLoadError => 'تعذر تحميل سجل تمارينك.';

  @override
  String get statsPeriod => 'الفترة';

  @override
  String get statsPeriod7Days => '7 أيام';

  @override
  String get statsPeriod30Days => '30 يومًا';

  @override
  String get statsPeriodThisMonth => 'هذا الشهر';

  @override
  String get statsPeriodAll => 'كل الوقت';

  @override
  String get statsPeriodCustom => 'مخصصة';

  @override
  String get statsCustomRange => 'اختيار نطاق التاريخ';

  @override
  String get statsTotalReps => 'إجمالي البلانك';

  @override
  String get statsWorkoutDays => 'أيام التمرين';

  @override
  String get statsTotalActiveTime => 'إجمالي وقت التمرين';

  @override
  String get statsAverageSets => 'متوسط المجموعات';

  @override
  String get statsAverageReps => 'متوسط البلانك';

  @override
  String get statsDailyReps => 'البلانك حسب اليوم';

  @override
  String get statsTrend => 'التغير مع الوقت';

  @override
  String get statsFrequentImprovements => 'نقاط التركيز المتكررة';

  @override
  String get statsNoData => 'لا توجد تمارين في هذه الفترة.';

  @override
  String statsTrendUp(num percent) {
    return 'ارتفاع $percent%';
  }

  @override
  String statsTrendDown(num percent) {
    return 'انخفاض $percent%';
  }

  @override
  String get statsTrendFlat => 'لا تغيير';

  @override
  String get detailTitle => 'تفاصيل التمرين';

  @override
  String get detailStartTime => 'وقت البدء';

  @override
  String get detailEndTime => 'وقت الانتهاء';

  @override
  String get detailActiveTime => 'وقت التمرين الفعلي';

  @override
  String get detailRestTime => 'وقت الراحة';

  @override
  String get detailTotalTime => 'الوقت الإجمالي';

  @override
  String get detailSets => 'المجموعات';

  @override
  String get detailSetBreakdown => 'الثوانٍ حسب المجموعة';

  @override
  String get detailTotalReps => 'إجمالي البلانك';

  @override
  String get detailAverageRep => 'متوسط زمن الثوانٍ';

  @override
  String get detailFormSummary => 'ملخص الأداء';

  @override
  String get detailImprovements => 'نقاط التحسين';

  @override
  String get detailStrengths => 'نقاط القوة';

  @override
  String get detailInterrupted => 'انتهى مبكرًا';

  @override
  String get detailCompleted => 'مكتمل';

  @override
  String detailSetRow(int set, int reps) {
    return 'المجموعة $set: $reps ثوانٍ';
  }

  @override
  String detailSessionOn(String date, String time) {
    return '$date، $time';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsRateApp => 'قيّم هذا التطبيق';

  @override
  String get settingsRateAppSubtitle => 'قيّم MotionFit';

  @override
  String get settingsRateAppError => 'تعذر فتح المتجر. حاول مرة أخرى.';

  @override
  String get settingsSectionGeneral => 'عام';

  @override
  String get settingsSectionCoaching => 'التدريب الصوتي';

  @override
  String get settingsSectionReminder => 'تذكيرات التمرين';

  @override
  String get settingsSectionCamera => 'الكاميرا';

  @override
  String get settingsSectionPrivacy => 'الخصوصية والبيانات';

  @override
  String get settingsSectionAbout => 'حول التطبيق';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsDisplayTheme => 'مظهر الشاشة';

  @override
  String get settingsColorTheme => 'سمة الألوان';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themePureBlack => 'أسود خالص';

  @override
  String get themeSystem => 'النظام';

  @override
  String get colorThemeByeokcheong => 'أزرق بيوكتشيونغ';

  @override
  String get colorThemeChuhyang => 'بيج تشوهيانغ';

  @override
  String get colorThemeJangdan => 'أحمر جانغدان';

  @override
  String get colorThemeCheonghyeon => 'أزرق تشيونغهيون';

  @override
  String get colorThemeHaenghwang => 'مشمشي هينغهوانغ';

  @override
  String get colorThemeChunyu => 'أخضر تشونيو';

  @override
  String get colorThemeSeolbaek => 'أبيض سولبيك';

  @override
  String get colorThemeByeokja => 'بنفسجي بيوكجا';

  @override
  String get colorThemeChwiram => 'نعناعي تشويرام';

  @override
  String get languageSystem => 'استخدام لغة الجهاز';

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
  String get languageChanged => 'تم تحديث اللغة';

  @override
  String get voiceCoachingEnabled => 'التدريب الصوتي';

  @override
  String get voiceRepCountEnabled => 'نطق عدد الثوانٍ';

  @override
  String get voiceFormEnabled => 'إرشادات الأداء';

  @override
  String get voiceEncouragementEnabled => 'عبارات التشجيع';

  @override
  String get voiceRate => 'سرعة النطق';

  @override
  String get voiceRateSlow => 'بطيئة';

  @override
  String get voiceRateNormal => 'عادية';

  @override
  String get voiceRateFast => 'سريعة';

  @override
  String get voiceTest => 'اختبار الصوت';

  @override
  String get voiceTestPhrase => 'رائع. مدربك الصوتي جاهز.';

  @override
  String get voiceUnavailable =>
      'لا يوجد صوت متوافق يعمل دون اتصال مثبت لهذه اللغة.';

  @override
  String get reminderTitle => 'تذكيرات التمرين';

  @override
  String get reminderSubtitle => 'اختر وقتًا لكل يوم تريد التمرن فيه.';

  @override
  String get reminderEnabled => 'تفعيل التذكير';

  @override
  String get reminderTime => 'وقت التذكير';

  @override
  String get reminderCopyTime => 'نسخ هذا الوقت';

  @override
  String reminderCopyFromDay(String day) {
    return 'نسخ الوقت من $day';
  }

  @override
  String get reminderApplyAll => 'تطبيق على كل الأيام';

  @override
  String reminderNext(String dateTime) {
    return 'التذكير التالي: $dateTime';
  }

  @override
  String get reminderNoneScheduled => 'لا توجد تذكيرات مجدولة';

  @override
  String get reminderPermissionNeeded => 'اسمح بالإشعارات لتشغيل التذكيرات.';

  @override
  String get reminderSaved => 'حُفظ جدول التذكيرات';

  @override
  String get weekdayMonday => 'الاثنين';

  @override
  String get weekdayTuesday => 'الثلاثاء';

  @override
  String get weekdayWednesday => 'الأربعاء';

  @override
  String get weekdayThursday => 'الخميس';

  @override
  String get weekdayFriday => 'الجمعة';

  @override
  String get weekdaySaturday => 'السبت';

  @override
  String get weekdaySunday => 'الأحد';

  @override
  String get weekdayMondayShort => 'اثن';

  @override
  String get weekdayTuesdayShort => 'ثلا';

  @override
  String get weekdayWednesdayShort => 'أرب';

  @override
  String get weekdayThursdayShort => 'خمي';

  @override
  String get weekdayFridayShort => 'جمع';

  @override
  String get weekdaySaturdayShort => 'سبت';

  @override
  String get weekdaySundayShort => 'أحد';

  @override
  String get cameraFront => 'الكاميرا الأمامية';

  @override
  String get cameraRear => 'الكاميرا الخلفية';

  @override
  String get cameraMirrorPreview => 'عكس معاينة الكاميرا الأمامية';

  @override
  String get cameraPoseOverlay => 'طبقة دليل الوضعية';

  @override
  String get cameraKeepScreenAwake => 'إبقاء الشاشة مضاءة أثناء التمرين';

  @override
  String get settingsHaptics => 'الاستجابة اللمسية';

  @override
  String get privacyTitle => 'كيفية التعامل مع بياناتك';

  @override
  String get privacyLocalProcessing => 'يعمل تحليل الوضعية على هذا الجهاز.';

  @override
  String get privacyNoVideoStorage =>
      'لا يُحفظ فيديو التمرين على هذا الجهاز إلا عند تفعيل مراجعة الثوانٍ.';

  @override
  String get privacyNoUpload => 'لا تُرفع إطارات الكاميرا إلى أي خادم.';

  @override
  String get privacyStoredData => 'البيانات المحفوظة على هذا الجهاز';

  @override
  String get privacyStoredDataDescription =>
      'يحفظ MotionFit أوقات التمرين والمجموعات والثوانٍ ونتائج الأداء كي تراجع تقدمك.';

  @override
  String get privacyDeleteData => 'حذف جميع بيانات التمرين';

  @override
  String get privacyDeleteConfirmTitle => 'هل تريد حذف جميع بيانات التمرين؟';

  @override
  String get privacyDeleteConfirmBody =>
      'سيؤدي ذلك إلى حذف سجل تمارينك نهائيًا من هذا الجهاز. ولا يمكن التراجع عنه.';

  @override
  String get privacyDeleteConfirmAction => 'حذف كل البيانات';

  @override
  String get privacyDeleteSuccess => 'حُذفت بيانات التمرين';

  @override
  String get privacyDeleteFailure => 'تعذر حذف بيانات التمرين.';

  @override
  String get appInfoTitle => 'معلومات التطبيق';

  @override
  String appInfoVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get appInfoLicenses => 'تراخيص المصادر المفتوحة';

  @override
  String get appInfoPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get appInfoDescription =>
      'يعدّ MotionFit تمارين البلانك ويقدم إرشادات خاصة على الجهاز لتحسين الأداء.';

  @override
  String get errorGenericTitle => 'حدث خطأ ما';

  @override
  String get errorGenericBody => 'حاول مرة أخرى. سجلات تمارينك الحالية آمنة.';

  @override
  String get errorCameraInit => 'تعذر تشغيل الكاميرا.';

  @override
  String get errorCameraInUse => 'قد تكون الكاميرا قيد الاستخدام في تطبيق آخر.';

  @override
  String get errorPoseModelLoad => 'تعذر تحميل نموذج اكتشاف الوضعية.';

  @override
  String get errorNoPerson => 'لم يُكتشف شخص. ادخل في نطاق الكاميرا.';

  @override
  String get errorWholeBody =>
      'جسمك غير ظاهر بالكامل. ابتعد قليلًا عن الكاميرا.';

  @override
  String get errorMultiplePeople =>
      'يوجد أكثر من شخص في الصورة. أبقِ شخصًا واحدًا فقط في الإطار.';

  @override
  String get errorTrackingLost => 'توقف التتبع حتى يظهر جسمك من جديد.';

  @override
  String get errorDatabaseSave => 'تعذر حفظ تمرينك.';

  @override
  String get errorTtsVoiceMissing => 'لا يوجد صوت نطق مثبت على هذا الجهاز.';

  @override
  String get errorTtsLocaleUnsupported =>
      'لا يدعم هذا الجهاز التدريب الصوتي باللغة المحددة.';

  @override
  String get emptyNoFormIssues => 'لم تُكتشف مشكلات أداء متكررة.';

  @override
  String get emptyNotEnoughData => 'لا توجد بيانات كافية بعد';

  @override
  String get loadingCamera => 'جارٍ تشغيل الكاميرا…';

  @override
  String get loadingPoseModel => 'جارٍ تجهيز اكتشاف الحركة…';

  @override
  String get loadingSavingWorkout => 'جارٍ حفظ التمرين…';

  @override
  String get formScore => 'درجة الأداء';

  @override
  String get formShort => 'الأداء';

  @override
  String formScoreValue(int score) {
    return '$score نقطة';
  }

  @override
  String get formIssueDepth => 'حاذِ الوركين مع الكتفين.';

  @override
  String get formIssueTorsoLean => 'شد عضلات الجذع وحافظ على استقامة الظهر.';

  @override
  String get formIssueHeelLift => 'ثبات الكعبين';

  @override
  String get formIssueKneeAlignment =>
      'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get formIssueBalance => 'التوازن بين الجانبين';

  @override
  String get formIssueDescentSpeed => 'سرعة النزول';

  @override
  String get formIssueAscentSpeed => 'سرعة الصعود';

  @override
  String get formIssueControl => 'شد عضلات الجذع وحافظ على استقامة الظهر.';

  @override
  String get formIssueStandingCompletion => 'اكتمال الوقوف';

  @override
  String get formIssueNotObservable => 'لا يمكن تقييمه من زاوية الكاميرا هذه';

  @override
  String get formStrengthDepth => 'عمق متناسق';

  @override
  String get formStrengthControl => 'حركة مضبوطة';

  @override
  String get formStrengthBalance => 'توازن ثابت';

  @override
  String get coachTrackingLost1 => 'عُد إلى نطاق الكاميرا وسنواصل.';

  @override
  String get coachTrackingLost2 =>
      'لم أعد أراك. انتقل إلى موضع يظهر فيه جسمك كاملًا.';

  @override
  String get coachWholeBody1 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachWholeBody2 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachMultiplePeople1 =>
      'أبقِ شخصًا واحدًا فقط في الإطار كي أتمكن من تتبعك.';

  @override
  String get coachReady1 => 'أنت في الموضع المناسب. لنبدأ.';

  @override
  String get coachReady2 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String coachStartSet(int set) {
    return 'المجموعة $set. هيا نبدأ.';
  }

  @override
  String coachSevenDayChallengeStart(int day) {
    return 'يبدأ اليوم $day من تحدي الأيام السبعة.';
  }

  @override
  String coachCumulativeChallengeStart(int completed, int remaining) {
    return 'يبدأ تحدي الثوانٍ التراكمية. أكملت $completed ثوانٍ، وتبقى $remaining ثوانٍ.';
  }

  @override
  String coachRepCount(int count) {
    return '$count ثانية';
  }

  @override
  String get coachDepth1 => 'حاذِ الوركين مع الكتفين.';

  @override
  String get coachDepth2 => 'حاذِ الوركين مع الكتفين.';

  @override
  String get coachTorso1 => 'شد عضلات الجذع وحافظ على استقامة الظهر.';

  @override
  String get coachTorso2 => 'شد عضلات الجذع وحافظ على استقامة الظهر.';

  @override
  String get coachHeel1 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachHeel2 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachKnees1 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachKnees2 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachBalance1 => 'شد عضلات الجذع وحافظ على استقامة الظهر.';

  @override
  String get coachBalance2 => 'شد عضلات الجذع وحافظ على استقامة الظهر.';

  @override
  String get coachDescendSlow1 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachDescendSlow2 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachDescendFaster1 =>
      'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachDescendFaster2 =>
      'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachAscendControlled1 => 'حاذِ الوركين مع الكتفين.';

  @override
  String get coachAscendControlled2 => 'حاذِ الوركين مع الكتفين.';

  @override
  String get coachAscendFaster1 => 'حاذِ الوركين مع الكتفين.';

  @override
  String get coachAscendFaster2 => 'حاذِ الوركين مع الكتفين.';

  @override
  String get coachControl1 => 'شد عضلات الجذع وحافظ على استقامة الظهر.';

  @override
  String get coachControl2 => 'شد عضلات الجذع وحافظ على استقامة الظهر.';

  @override
  String get coachStandTall1 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachStandTall2 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachGood1 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachGood2 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachGood3 => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get coachLastTwo => 'تبقى اثنان. واصل بقوة!';

  @override
  String get coachLastOne => 'الأخيرة. أنهِ بقوة!';

  @override
  String coachSetComplete(int set) {
    return 'أحسنت. اكتملت المجموعة $set.';
  }

  @override
  String coachRestStart(int seconds) {
    return 'استرح لمدة $seconds ثانية. تنفّس واستعد.';
  }

  @override
  String get coachRestTenSeconds => 'بقيت عشر ثوانٍ من الراحة.';

  @override
  String get coachRestComplete => 'انتهت الراحة. استعد للمجموعة التالية.';

  @override
  String coachWorkoutComplete(int reps) {
    return 'اكتمل التمرين. حافظت على البلانك لمدة $reps ثانية.';
  }

  @override
  String get notificationReminderTitle => 'حان وقت البلانك اليوم';

  @override
  String get notificationReminderBody =>
      'حتى الجلسة القصيرة لها أثر. افتح MotionFit عندما تكون مستعدًا.';

  @override
  String get notificationReminderBodyVariant2 =>
      'بضع البلانك مركزة تكفي لتضيف نشاطًا إلى يومك.';

  @override
  String notificationStreakReminderBody(int days) {
    return 'حافظ اليوم على سلسلتك لمدة $days أيام بتمرين قصير.';
  }

  @override
  String get semanticsIncrease => 'زيادة';

  @override
  String get semanticsDecrease => 'تقليل';

  @override
  String semanticsSelectedTab(String tab) {
    return 'علامة التبويب المحددة: $tab';
  }

  @override
  String semanticsCalendarWorkoutDate(String date) {
    return '$date، يوجد تمرين مسجل';
  }

  @override
  String semanticsCalendarEmptyDate(String date) {
    return '$date، لا يوجد تمرين';
  }

  @override
  String semanticsCurrentRep(int current, int target) {
    return 'الثوانٍ الحالي $current من $target';
  }

  @override
  String get repVideoReviewTitle => 'مراجعة فيديو الثوانٍ';

  @override
  String get repVideoReviewDescription =>
      'احفظ فيديو هذا التمرين على الجهاز لمراجعة كل ثوانٍ لاحقًا.';

  @override
  String get repVideoLocalOnly => 'محلي فقط · لا يتم رفعه';

  @override
  String get formReviewTitle => 'مراجعة الوضعية';

  @override
  String get formReviewMainIssue => 'المشكلة الرئيسية';

  @override
  String get viewRepTimeline => 'عرض مخطط الثوانٍ';

  @override
  String get repTimelineTitle => 'مراجعة الثوانٍ';

  @override
  String get repTimelineAll => 'الكل';

  @override
  String get repTimelineImprove => 'تحسين';

  @override
  String get repTimelineNoImprovement => 'لا توجد ثوانٍ تحتاج إلى تحسين.';

  @override
  String repSetNumber(int number) {
    return 'المجموعة $number';
  }

  @override
  String repNumber(int number) {
    return 'الثوانٍ $number';
  }

  @override
  String get repResultGood => 'وضعية جيدة';

  @override
  String get repResultNeedsAttention => 'يحتاج إلى انتباه';

  @override
  String get repResultImproved => 'أفضل من الثوانٍ السابق';

  @override
  String get repResultNotAssessed => 'يصعب التقييم';

  @override
  String get repIssueShallowDepth => 'حاذِ الوركين مع الكتفين.';

  @override
  String get repIssueForwardLean => 'شد عضلات الجذع وحافظ على استقامة الظهر.';

  @override
  String get repIssueKneesInward => 'تحركت الركبتان إلى الداخل';

  @override
  String get repVideoNotSaved => 'لم يتم حفظ الفيديو';

  @override
  String get repReplay => 'إعادة التشغيل';

  @override
  String get repWhatHappened => 'ماذا حدث';

  @override
  String get repHowToImprove => 'كيفية التحسين';

  @override
  String get repWhatWentWell => 'ما تم بشكل جيد';

  @override
  String get repPrevious => 'الثوانٍ السابق';

  @override
  String get repNext => 'الثوانٍ التالي';

  @override
  String get repFeedbackGood => 'حافظ على استقامة الكتفين والوركين والكعبين.';

  @override
  String get repFeedbackDepth => 'حاذِ الوركين مع الكتفين.';

  @override
  String get repFeedbackTorso => 'شد عضلات الجذع وحافظ على استقامة الظهر.';

  @override
  String get repFeedbackKnees =>
      'تحركت ركبتاك إلى الداخل. حافظ على محاذاتهما مع أصابع القدمين.';

  @override
  String repFeedbackGeneric(String area) {
    return 'يحتاج هذا الثوانٍ إلى الانتباه في $area.';
  }

  @override
  String get deleteWorkoutVideo => 'حذف فيديو التمرين';

  @override
  String get deleteWorkoutVideoTitle => 'حذف فيديو التمرين هذا؟';

  @override
  String get deleteWorkoutVideoBody =>
      'سيُحذف الفيديو المحلي فقط، وستبقى تحليلات الثوانٍ وسجل التمرين.';

  @override
  String get workoutVideoDeleted => 'تم حذف فيديو التمرين';
}
