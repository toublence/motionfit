// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'motionfit - workout coach';

  @override
  String get navSquat => '深蹲';

  @override
  String get navWorkout => '运动';

  @override
  String get navChallenge => '挑战';

  @override
  String get navRecords => '进步';

  @override
  String get navSettings => '设置';

  @override
  String get challengeTitle => '我的深蹲挑战';

  @override
  String get challengeSubtitle => '选择适合您目标的挑战并坚持不懈地前进。';

  @override
  String get challengeChooseTitle => '选择一个挑战';

  @override
  String get challengeSevenDayTitle => '7 天新手挑战';

  @override
  String get challengeSevenDayDescription => '适合初学者的分步计划';

  @override
  String get challengeSevenDaySummary => '遵循每天增加的基于级别的目标，持续 7 天。';

  @override
  String get challengeSevenDayEveryDay => '每天持续 7 天，没有恢复日';

  @override
  String challengeDurationDays(int days) {
    return '$days天';
  }

  @override
  String get challengeLevelGoals => '根据您的水平量身定制的目标';

  @override
  String get challengeRecoveryIncluded => '包括恢复天数';

  @override
  String get challengeDailyGoal => '每日次数目标';

  @override
  String get challengeSevenDayStart => '开始7天挑战';

  @override
  String get challengeSevenDaySettings => '设定您的 7 天目标';

  @override
  String get challengeSevenDaySettingsDescription => '选择第 1 天。目标每天增加 5 次。';

  @override
  String get challengeFirstDayGoal => '第一天目标次数';

  @override
  String challengeSevenDayPreview(int first, int last) {
    return '第 1 天：$first 次 → 第 7 天：$last 次';
  }

  @override
  String get challengeWeeklyTitle => '每周3次挑战';

  @override
  String get challengeWeeklyDescription => '针对不想每天锻炼的人的习惯挑战';

  @override
  String get challengeWeeklySummary => '每周选择 3 天进行锻炼，持续 4 周。';

  @override
  String challengeDurationWeeks(int weeks) {
    return '$weeks周';
  }

  @override
  String get challengeThreePerWeek => '每周 3 次锻炼';

  @override
  String get challengeChooseWeekdays => '选择 3 天锻炼';

  @override
  String get challengeWorkoutDaysCount => '进度取决于锻炼天数';

  @override
  String get challengeWeeklyStart => '开始每周挑战';

  @override
  String get challengeCumulativeTitle => '总次数挑战';

  @override
  String get challengeCumulativeDescription => '按照适合您的时间表完成深蹲总目标';

  @override
  String get challengeCumulativeSummary => '选择持续时间和总目标；休息日让你进步。';

  @override
  String get challengePreset200 => '7天内200个深蹲';

  @override
  String get challengePreset500 => '14天内500个深蹲';

  @override
  String get challengeCustomGoal => '选择您自己的持续时间和目标';

  @override
  String get challengeRestWithoutReset => '休息日不会重置进度';

  @override
  String get challengeCumulativeStart => '开始总次数挑战';

  @override
  String get challengeHistoryTitle => '过去的挑战';

  @override
  String get challengeHistoryEmpty => '您已完成和结束的挑战将显示在此处。';

  @override
  String get challengeRecommended => '为您推荐';

  @override
  String challengeRecommendationFromWorkout(int reps) {
    return '从您第一次$reps次数锻炼中推荐。';
  }

  @override
  String get challengeRecommendationDefault => '建议您以 7 天的温和时间开始第一次挑战。';

  @override
  String get challengeActive => '主动挑战';

  @override
  String get challengeNext => '下一个';

  @override
  String challengeDayNumber(int day) {
    return '日$day';
  }

  @override
  String get challengeRecoveryDay => '康复日';

  @override
  String challengeTodayProgress(int current, int target) {
    return '今天 $current/$target 次';
  }

  @override
  String get challengeRestToday => '今天需要时间恢复。';

  @override
  String get challengeTodayCompleted => '今天的目标完成·明天继续';

  @override
  String challengeRepsRemaining(int reps) {
    return '还剩 $reps 次';
  }

  @override
  String challengeWeekNumber(int week) {
    return '周$week';
  }

  @override
  String challengeThisWeekProgress(int current, int target) {
    return '本周$current/$target锻炼';
  }

  @override
  String challengeOverallDays(int current, int target) {
    return '总计$current/$target天';
  }

  @override
  String challengeRepsProgress(int current, int target) {
    return '$current/$target 次';
  }

  @override
  String challengeDaysRemaining(int days) {
    return '还剩 $days 天';
  }

  @override
  String challengeTodaySuggested(int reps) {
    return '今天建议：$reps 次';
  }

  @override
  String challengePercent(int percent) {
    return '$percent完成%';
  }

  @override
  String get challengeSquatStart => '开始深蹲';

  @override
  String get challengeTodayWorkoutStart => '开始今天的锻炼';

  @override
  String get challengeViewDetails => '查看详情';

  @override
  String get challengeRestart => '重新开始';

  @override
  String get challengeDeleteHistory => '从历史记录中删除';

  @override
  String get challengeCumulativeSettings => '设定您的总目标';

  @override
  String get challengeDurationLabel => '期间';

  @override
  String get challengeGoalLabel => '目标次数';

  @override
  String get challengeNotFound => '此挑战不再可用。';

  @override
  String get challengePeriod => '时期';

  @override
  String get challengeStatus => '地位';

  @override
  String get challengeTotalReps => '深蹲总数';

  @override
  String get challengeWorkoutDays => '锻炼日';

  @override
  String challengeDaysCount(int days) {
    return '$days天';
  }

  @override
  String get challengeTotalTime => '总锻炼时间';

  @override
  String get challengeSchedule => '日程及进度';

  @override
  String get challengeNotifications => '挑战提醒';

  @override
  String get challengeNotificationsDescription => '在此挑战中保留提醒偏好。';

  @override
  String get challengeReminderNotificationTitle => '你的深蹲挑战正在等待';

  @override
  String get challengeReminderNotificationBody =>
      '打开 MotionFit 并朝着今天的挑战目标取得进展。';

  @override
  String get challengeSelectedWeekdays => '选定的锻炼日';

  @override
  String get challengeNoProgressYet => '还没有挑战训练。';

  @override
  String get challengeCancel => '结束挑战';

  @override
  String get challengeCancelTitle => '结束这个挑战吗？';

  @override
  String get challengeCancelDescription => '您的锻炼记录将被保存。这一挑战将成为历史。';

  @override
  String get challengeStatusActive => '进行中';

  @override
  String get challengeStatusCompleted => '完全的';

  @override
  String get challengeStatusEnded => '结束';

  @override
  String get challengeStatusCancelled => '取消';

  @override
  String get challengeProgressUpdated => '您的挑战进度已更新。';

  @override
  String get challengeCheck => '查看挑战';

  @override
  String get commonDone => '完毕';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '关闭';

  @override
  String get commonRetry => '再试一次';

  @override
  String get commonSave => '节省';

  @override
  String get commonDelete => '删除';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonBack => '后退';

  @override
  String get commonContinue => '继续';

  @override
  String get commonStart => '开始';

  @override
  String get commonSkip => '跳过';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonOn => '在';

  @override
  String get commonOff => '离开';

  @override
  String get commonEnabled => '启用';

  @override
  String get commonDisabled => '残疾人';

  @override
  String get commonNotAvailable => '无法使用';

  @override
  String get commonToday => '今天';

  @override
  String get commonYesterday => '昨天';

  @override
  String get commonLoading => '加载中…';

  @override
  String unitSets(int count) {
    return '$count 组';
  }

  @override
  String unitReps(int count) {
    return '$count 次';
  }

  @override
  String unitSeconds(int count) {
    return '$count 秒';
  }

  @override
  String unitMinutes(int count) {
    return '$count 分钟';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours小时$minutes分钟';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes分$seconds秒';
  }

  @override
  String get homeGreeting => '准备好搬家了吗？';

  @override
  String get homeTodayTitle => '今天的记录';

  @override
  String get homeTodayNoWorkout => '今天还没有深蹲。简短的一组是一个很好的开始。';

  @override
  String homeTodaySummary(int reps, int sets) {
    return '$reps 次深蹲，共 $sets 组';
  }

  @override
  String get homeViewResult => '查看结果';

  @override
  String get homeTodaySets => '今天设定';

  @override
  String get homeTodayReps => '今天完成';

  @override
  String get streakLabel => '条纹';

  @override
  String streakDays(int days) {
    return '$days天';
  }

  @override
  String get homeWorkoutSetup => '下一次锻炼';

  @override
  String get homeSetsLabel => '套';

  @override
  String get homeRepsPerSetLabel => '每组次数';

  @override
  String get homeRestTimeLabel => '休息时间';

  @override
  String get homeDirectInputHint => '输入一个数字';

  @override
  String get homeStartWorkout => '开始锻炼';

  @override
  String get homeLastSettingsRestored => '您上次的锻炼设置已准备就绪。';

  @override
  String get validationNumberRequired => '输入一个数字。';

  @override
  String validationRange(num min, num max) {
    return '选择从$min到$max的值。';
  }

  @override
  String get guideTitle => '设置您的相机';

  @override
  String get guideSubtitle => 'MotionFit 无需拍到脚踝，只要肩部到膝盖入镜即可测量深蹲。';

  @override
  String get guideWholeBody => '尽量让肩部、髋部和膝盖保持在画面中。';

  @override
  String get guideStableCamera => '将手机放在稳定的地方。';

  @override
  String get guideOnePerson => '确保框架内只有一个人。';

  @override
  String get guideCameraAngle => '尽可能使用侧面或略微倾斜的侧视图。';

  @override
  String get guideLighting => '避免黑暗的房间和强烈的背光。';

  @override
  String get guidePrivacy => '视频保留在此设备上，并且仅当“代表视频审阅”打开时才会保存。';

  @override
  String get guideContinue => '我已就位';

  @override
  String get permissionCameraTitle => '需要相机访问权限';

  @override
  String get permissionCameraBody =>
      'MotionFit 使用摄像头来计算深蹲次数。当您打开“Rep Video Review”时，视频仅保存在此设备上。';

  @override
  String get permissionCameraRequest => '继续';

  @override
  String get permissionCameraDenied => '相机访问被拒绝。您仍然可以查看记录和设置。';

  @override
  String get permissionCameraPermanentlyDenied => '在系统设置中允许相机访问以开始锻炼。';

  @override
  String get permissionOpenSettings => '打开设置';

  @override
  String get permissionNotificationTitle => '允许锻炼提醒吗？';

  @override
  String get permissionNotificationBody => '通知仅用于您安排的提醒。';

  @override
  String get permissionNotificationRequest => '允许通知';

  @override
  String get permissionNotificationDenied => '通知已关闭。在系统设置中打开它们以接收提醒。';

  @override
  String get countdownGetReady => '准备';

  @override
  String countdownBeginsIn(int seconds) {
    return '从$seconds开始';
  }

  @override
  String get calibrationTitle => '正在确认站立姿势';

  @override
  String get calibrationBody => '站直，并让肩部到膝盖保持在画面中。';

  @override
  String get calibrationStayStill => '保持静止一会儿';

  @override
  String get calibrationComplete => '一切就绪';

  @override
  String get calibrationFailed => '无法清晰识别站立姿势。';

  @override
  String get calibrationRetry => '重新校准';

  @override
  String workoutSetProgress(int current, int total) {
    return '第 $current/$total 组';
  }

  @override
  String workoutRepProgress(int current, int target) {
    return '$current/$target 次';
  }

  @override
  String workoutTotalReps(int count) {
    return '总计 $count 次';
  }

  @override
  String get workoutElapsed => '经过时间';

  @override
  String get workoutPause => '暂停';

  @override
  String get workoutResume => '恢复锻炼';

  @override
  String get workoutEnd => '暂时停止';

  @override
  String get workoutBackToSetup => '返回设置';

  @override
  String get workoutEndDialogTitle => '暂时停下来吗？';

  @override
  String get workoutEndDialogBody => '您的进度将被保存，以便您可以从主屏幕继续。';

  @override
  String get workoutEndDialogConfirm => '保存并离开';

  @override
  String get workoutPauseReasonBackground => '当应用程序处于后台时，锻炼暂停。';

  @override
  String get workoutPauseReasonInterruption => '系统中断后锻炼暂停。';

  @override
  String get workoutStateReady => '准备好';

  @override
  String get workoutStateDescending => '往下走';

  @override
  String get workoutStateBottom => '在底部';

  @override
  String get workoutStateAscending => '即将推出';

  @override
  String get workoutStateCompleted => '很好的代表';

  @override
  String get workoutStateTrackingLost => '仍在检测中';

  @override
  String get workoutStatePaused => '已暂停';

  @override
  String get workoutTrackingGood => '检测到关节';

  @override
  String get workoutCameraSwitch => '切换相机';

  @override
  String get workoutSkeletonToggle => '显示姿势指南';

  @override
  String get restTitle => '休息';

  @override
  String restNextSet(int set, int total) {
    return '下一篇：设置$total的$set';
  }

  @override
  String get restCompletedSets => '已完成的套装';

  @override
  String get restTotalReps => '到目前为止深蹲';

  @override
  String get restSkip => '跳过休息';

  @override
  String get restAddFifteenSeconds => '添加 15 秒';

  @override
  String get restEndWorkout => '暂时停止';

  @override
  String get restAlmostDone => '快准备好了';

  @override
  String get restReady => '下一组的时间';

  @override
  String get completeTitle => '锻炼完成';

  @override
  String get completeSubtitle => '工作扎实。这是您的会话概览。';

  @override
  String get workoutInterruptedSubtitle => '在提前结束之前回顾一下您录制的内容。';

  @override
  String get completeTotalReps => '深蹲总数';

  @override
  String get completeCompletedSets => '套数已完成';

  @override
  String get completeActiveTime => '活跃时间';

  @override
  String get completeRestTime => '休息时间';

  @override
  String get completeTotalTime => '总时间';

  @override
  String get completeAverageRepTime => '平均重复时间';

  @override
  String get completeFormSummary => '表格摘要';

  @override
  String get todayCoaching => '今天的辅导';

  @override
  String coachingIssueFrequency(int total, int count, String issue) {
    return '在$total次数的$count中，$issue';
  }

  @override
  String get completeTopImprovement => '下次重点';

  @override
  String get completeStrengths => '什么进展顺利';

  @override
  String get completeSaved => '此设备上保存的锻炼数据';

  @override
  String get completeSaveFailed => '无法保存锻炼。离开前再试一次。';

  @override
  String get completeNoFormData => '没有足够的可见运动来进行表格摘要。';

  @override
  String get completeFinish => '结束';

  @override
  String get postWorkoutReminderTitle => '保持势头';

  @override
  String postWorkoutReminderBody(String time) {
    return '您想要从明天开始在$time上收到每日提醒吗？';
  }

  @override
  String get postWorkoutReminderEnable => '提醒我';

  @override
  String get postWorkoutReminderLater => '也许稍后';

  @override
  String get postWorkoutReminderEnabled => '您的提醒已设置。';

  @override
  String get recordsTitle => '进步';

  @override
  String get recordsWeeklySummary => '本星期';

  @override
  String recordsWorkoutCount(int count) {
    return '$count锻炼';
  }

  @override
  String recordsAverageForm(int score) {
    return '平均动作评分 $score';
  }

  @override
  String recordsWorkoutTime(String time) {
    return '时间$time';
  }

  @override
  String get recordsFirstWeek => '这是您本周的第一张唱片';

  @override
  String recordsMoreThanLastWeek(int count) {
    return '$count比上周更多的次数';
  }

  @override
  String recordsLessThanLastWeek(int count) {
    return '$count次数比上周少';
  }

  @override
  String get recordsSameAsLastWeek => '成交量与上周持平';

  @override
  String get recordsTrendEmpty => '完成更多锻炼以了解您的体形趋势。';

  @override
  String get recordsFirstFormScore => '首次动作评分';

  @override
  String recordsRecentAverage(int count, int score) {
    return '最后$count平均$score';
  }

  @override
  String get recordsStrength => '力量';

  @override
  String get recordsFocus => '重点';

  @override
  String get recordsTodayPoint => '今日焦点';

  @override
  String get recordsToday => '今天';

  @override
  String get recordsRecentWorkouts => '最近的锻炼';

  @override
  String get recordsCalendarTitle => '锻炼日历';

  @override
  String get recordsFormTrend => '动作趋势';

  @override
  String get recordsViewCalendar => '日历';

  @override
  String get recordsViewList => '列表';

  @override
  String get recordsViewStats => '统计数据';

  @override
  String get recordsCalendarPreviousMonth => '上个月';

  @override
  String get recordsCalendarNextMonth => '下个月';

  @override
  String get recordsCalendarWorkoutDay => '锻炼日';

  @override
  String get recordsCalendarNoWorkoutSelected => '选择锻炼日以查看其课程。';

  @override
  String get recordsDayTotal => '每日总计';

  @override
  String recordsSessionsCount(int count) {
    return '$count 次训练';
  }

  @override
  String recordsSessionTitle(int number) {
    return '会话$number';
  }

  @override
  String get recordsListNewest => '最新的优先';

  @override
  String get recordsOpenDetail => '查看详情';

  @override
  String get recordsEmptyTitle => '还没有锻炼';

  @override
  String get recordsEmptyBody => '完成您的第一次深蹲锻炼，它将出现在此处。';

  @override
  String get recordsStartWorkout => '开始锻炼';

  @override
  String get recordsLoading => '正在加载您的锻炼...';

  @override
  String get recordsLoadError => '我们无法加载您的锻炼记录。';

  @override
  String get statsPeriod => '时期';

  @override
  String get statsPeriod7Days => '7天';

  @override
  String get statsPeriod30Days => '30天';

  @override
  String get statsPeriodThisMonth => '本月';

  @override
  String get statsPeriodAll => '所有时间';

  @override
  String get statsPeriodCustom => '风俗';

  @override
  String get statsCustomRange => '选择日期范围';

  @override
  String get statsTotalReps => '深蹲总数';

  @override
  String get statsWorkoutDays => '锻炼日';

  @override
  String get statsTotalActiveTime => '活跃时间';

  @override
  String get statsAverageSets => '平均组数';

  @override
  String get statsAverageReps => '平均深蹲';

  @override
  String get statsDailyReps => '白天深蹲';

  @override
  String get statsTrend => '随着时间的推移而变化';

  @override
  String get statsFrequentImprovements => '经常关注的领域';

  @override
  String get statsNoData => '这段时间没有锻炼。';

  @override
  String statsTrendUp(num percent) {
    return '上涨$percent%';
  }

  @override
  String statsTrendDown(num percent) {
    return '下降$percent%';
  }

  @override
  String get statsTrendFlat => '没有变化';

  @override
  String get detailTitle => '锻炼详情';

  @override
  String get detailStartTime => '开始';

  @override
  String get detailEndTime => '结束';

  @override
  String get detailActiveTime => '活跃时间';

  @override
  String get detailRestTime => '休息时间';

  @override
  String get detailTotalTime => '总时间';

  @override
  String get detailSets => '套';

  @override
  String get detailSetBreakdown => '按组次数';

  @override
  String get detailTotalReps => '深蹲总数';

  @override
  String get detailAverageRep => '平均重复时间';

  @override
  String get detailFormSummary => '表格摘要';

  @override
  String get detailImprovements => '改进点';

  @override
  String get detailStrengths => '优势';

  @override
  String get detailInterrupted => '提早结束';

  @override
  String get detailCompleted => '完全的';

  @override
  String detailSetRow(int set, int reps) {
    return '设置$set：$reps次数';
  }

  @override
  String detailSessionOn(String date, String time) {
    return '$date于$time';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsRateApp => '评价这个应用程序';

  @override
  String get settingsRateAppSubtitle => '评价 MotionFit';

  @override
  String get settingsRateAppError => '无法开店。请再试一次。';

  @override
  String get settingsSectionGeneral => '一般的';

  @override
  String get settingsSectionCoaching => '语音辅导';

  @override
  String get settingsSectionReminder => '锻炼提醒';

  @override
  String get settingsSectionCamera => '相机';

  @override
  String get settingsSectionPrivacy => '隐私和数据';

  @override
  String get settingsSectionAbout => '关于';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsDisplayTheme => '画面主题';

  @override
  String get settingsColorTheme => '色彩主题';

  @override
  String get themeLight => '光';

  @override
  String get themePureBlack => '纯黑';

  @override
  String get themeSystem => '系统';

  @override
  String get colorThemeByeokcheong => '碧清蓝';

  @override
  String get colorThemeChuhyang => '秋香米色';

  @override
  String get colorThemeJangdan => '长丹红';

  @override
  String get colorThemeCheonghyeon => '清贤蓝';

  @override
  String get colorThemeHaenghwang => '杏黄杏';

  @override
  String get colorThemeChunyu => '春雨绿';

  @override
  String get colorThemeSeolbaek => '雪白白';

  @override
  String get colorThemeByeokja => '碧紫紫';

  @override
  String get colorThemeChwiram => '奇兰薄荷';

  @override
  String get languageSystem => '使用设备语言';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageGerman => '德语';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languageFrench => '法国人';

  @override
  String get languageJapanese => '日本语';

  @override
  String get languageArabic => '巴黎';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageChineseTraditional => '繁體中文';

  @override
  String get languageChanged => '语言已更新';

  @override
  String get voiceCoachingEnabled => '语音辅导';

  @override
  String get voiceRepCountEnabled => '说出次数';

  @override
  String get voiceFormEnabled => '表格提示';

  @override
  String get voiceEncouragementEnabled => '鼓励';

  @override
  String get voiceRate => '语速';

  @override
  String get voiceRateSlow => '慢的';

  @override
  String get voiceRateNormal => '普通的';

  @override
  String get voiceRateFast => '快速地';

  @override
  String get voiceTest => '测试语音';

  @override
  String get voiceTestPhrase => '伟大的。您的语音教练已准备就绪。';

  @override
  String get voiceUnavailable => '没有安装与该语言兼容的离线语音。';

  @override
  String get reminderTitle => '锻炼提醒';

  @override
  String get reminderSubtitle => '为您每天想要训练的时间选择一个时间。';

  @override
  String get reminderEnabled => '已启用提醒';

  @override
  String get reminderTime => '提醒时间';

  @override
  String get reminderCopyTime => '这次复制';

  @override
  String reminderCopyFromDay(String day) {
    return '从$day复制时间';
  }

  @override
  String get reminderApplyAll => '适用于每一天';

  @override
  String reminderNext(String dateTime) {
    return '下次提醒：$dateTime';
  }

  @override
  String get reminderNoneScheduled => '没有安排提醒';

  @override
  String get reminderPermissionNeeded => '允许通知打开提醒。';

  @override
  String get reminderSaved => '提醒时间表已保存';

  @override
  String get weekdayMonday => '周一';

  @override
  String get weekdayTuesday => '周二';

  @override
  String get weekdayWednesday => '周三';

  @override
  String get weekdayThursday => '周四';

  @override
  String get weekdayFriday => '星期五';

  @override
  String get weekdaySaturday => '周六';

  @override
  String get weekdaySunday => '星期日';

  @override
  String get weekdayMondayShort => '周一';

  @override
  String get weekdayTuesdayShort => '星期二';

  @override
  String get weekdayWednesdayShort => '周三';

  @override
  String get weekdayThursdayShort => '星期四';

  @override
  String get weekdayFridayShort => '周五';

  @override
  String get weekdaySaturdayShort => '星期六';

  @override
  String get weekdaySundayShort => '太阳';

  @override
  String get cameraFront => '前置摄像头';

  @override
  String get cameraRear => '后置摄像头';

  @override
  String get cameraMirrorPreview => '后视镜正面预览';

  @override
  String get cameraPoseOverlay => '姿势指南覆盖';

  @override
  String get cameraKeepScreenAwake => '锻炼期间保持屏幕唤醒';

  @override
  String get settingsHaptics => '触觉反馈';

  @override
  String get privacyTitle => '如何处理您的数据';

  @override
  String get privacyLocalProcessing => '姿势分析在此设备上运行。';

  @override
  String get privacyNoVideoStorage => '仅当启用“代表视频查看”时，锻炼视频才会存储在此设备上。';

  @override
  String get privacyNoUpload => '相机帧不会上传到服务器。';

  @override
  String get privacyStoredData => '该设备上存储的数据';

  @override
  String get privacyStoredDataDescription =>
      'MotionFit 会保存锻炼时间、组数、次数和表格结果，以便您可以查看您的进度。';

  @override
  String get privacyDeleteData => '删除所有锻炼数据';

  @override
  String get privacyDeleteConfirmTitle => '删除所有锻炼数据？';

  @override
  String get privacyDeleteConfirmBody => '这将从该设备中永久删除您的锻炼历史记录。此操作无法撤消。';

  @override
  String get privacyDeleteConfirmAction => '删除所有数据';

  @override
  String get privacyDeleteSuccess => '锻炼数据已删除';

  @override
  String get privacyDeleteFailure => '无法删除锻炼数据。';

  @override
  String get appInfoTitle => '应用信息';

  @override
  String appInfoVersion(String version) {
    return '版本$version';
  }

  @override
  String get appInfoLicenses => '开源许可证';

  @override
  String get appInfoPrivacyPolicy => '隐私政策';

  @override
  String get appInfoDescription => 'MotionFit 计算深蹲次数并提供私人的设备上形式指导。';

  @override
  String get errorGenericTitle => '出了点问题';

  @override
  String get errorGenericBody => '请再试一次。您现有的锻炼记录是安全的。';

  @override
  String get errorCameraInit => '相机无法启动。';

  @override
  String get errorCameraInUse => '相机可能正在被其他应用程序使用。';

  @override
  String get errorPoseModelLoad => '无法加载姿势模型。';

  @override
  String get errorNoPerson => '没有发现任何人。步入视野。';

  @override
  String get errorWholeBody => '正在检查肩部、髋部和膝盖的连线。';

  @override
  String get errorMultiplePeople => '视野中不止一个人。画面中仅保留一个人。';

  @override
  String get errorTrackingLost => '训练仍在继续，而检测仍在继续尝试。';

  @override
  String get errorDatabaseSave => '无法保存您的锻炼。';

  @override
  String get errorTtsVoiceMissing => '该设备上未安装语音。';

  @override
  String get errorTtsLocaleUnsupported => '此设备上所选语言不支持语音辅导。';

  @override
  String get emptyNoFormIssues => '未检测到重复的表单问题。';

  @override
  String get emptyNotEnoughData => '还没有足够的数据';

  @override
  String get loadingCamera => '启动相机...';

  @override
  String get loadingPoseModel => '正在准备移动检测...';

  @override
  String get loadingSavingWorkout => '保存锻炼...';

  @override
  String get formScore => '动作评分';

  @override
  String get formShort => '动作';

  @override
  String formScoreValue(int score) {
    return '$score分';
  }

  @override
  String get formIssueDepth => '深蹲深度';

  @override
  String get formIssueTorsoLean => '上身稳定性';

  @override
  String get formIssueHeelLift => '脚跟接触';

  @override
  String get formIssueKneeAlignment => '膝盖对齐';

  @override
  String get formIssueBalance => '左右平衡';

  @override
  String get formIssueDescentSpeed => '下降速度';

  @override
  String get formIssueAscentSpeed => '上升速度';

  @override
  String get formIssueControl => '运动控制';

  @override
  String get formIssueStandingCompletion => '站立完成度';

  @override
  String get formIssueNotObservable => '从这个相机角度无法评估';

  @override
  String get formStrengthDepth => '一致的深度';

  @override
  String get formStrengthControl => '受控运动';

  @override
  String get formStrengthBalance => '稳定平衡';

  @override
  String get coachTrackingLost1 => '当我不断检测时，你的锻炼仍在进行。';

  @override
  String get coachTrackingLost2 => '短暂的遮挡不会暂停您的锻炼。';

  @override
  String get coachWholeBody1 => '肩部、髋部和膝盖入镜后即可测量。';

  @override
  String get coachWholeBody2 => '即使脚踝不在画面中，也可以继续锻炼。';

  @override
  String get coachMultiplePeople1 => '画面中只保留一个人，这样我就能追踪到你。';

  @override
  String get coachReady1 => '你已经就位了。让我们开始吧。';

  @override
  String get coachReady2 => '姿势很好。准备开始第一次深蹲。';

  @override
  String coachStartSet(int set) {
    return '设置$set。我们走吧。';
  }

  @override
  String coachSevenDayChallengeStart(int day) {
    return '七日挑战的起始日$day。';
  }

  @override
  String coachCumulativeChallengeStart(int completed, int remaining) {
    return '开始累积次数挑战。您已完成$completed次，还剩$remaining。';
  }

  @override
  String coachRepCount(int count) {
    return '$count';
  }

  @override
  String get coachDepth1 => '下一次，尝试降低一点。';

  @override
  String get coachDepth2 => '下一次深蹲再蹲低一点。';

  @override
  String get coachTorso1 => '上身再稳定一点。';

  @override
  String get coachTorso2 => '下一次动作时，让胸部自然挺起。';

  @override
  String get coachHeel1 => '尽量让脚跟贴住地面。';

  @override
  String get coachHeel2 => '下一次动作时，用整个脚掌发力。';

  @override
  String get coachKnees1 => '让膝盖朝向脚尖的方向。';

  @override
  String get coachKnees2 => '下一次动作时，让膝盖保持对齐。';

  @override
  String get coachBalance1 => '保持两侧体重均匀。';

  @override
  String get coachBalance2 => '为下一次代表找到一个均匀、稳定的姿势。';

  @override
  String get coachDescendSlow1 => '下次尝试放慢一点。';

  @override
  String get coachDescendSlow2 => '控制下一次代表的下降方式。';

  @override
  String get coachDescendFaster1 => '下次下坡时速度要快一点。';

  @override
  String get coachDescendFaster2 => '继续下一个下降过程，不要停下来。';

  @override
  String get coachAscendControlled1 => '顺利起身并保持控制。';

  @override
  String get coachAscendControlled2 => '站起时保持稳定的节奏。';

  @override
  String get coachAscendFaster1 => '更加自信地开车。';

  @override
  String get coachAscendFaster2 => '下一次站起时再果断一点。';

  @override
  String get coachControl1 => '让下一次动作从头到尾都顺利进行。';

  @override
  String get coachControl2 => '在整个动作中保持控制。';

  @override
  String get coachStandTall1 => '结束时再站直一点。';

  @override
  String get coachStandTall2 => '完全回到站立姿势。';

  @override
  String get coachGood1 => '好的。保持这个节奏。';

  @override
  String get coachGood2 => '控制得好。继续下去。';

  @override
  String get coachGood3 => '强代表。再做一次。';

  @override
  String get coachLastTwo => '最后两个。坚强点！';

  @override
  String get coachLastOne => '最后一张。坚强地完成！';

  @override
  String coachSetComplete(int set) {
    return '伟大的。设置$set完成。';
  }

  @override
  String coachRestStart(int seconds) {
    return '休息$seconds秒。呼吸并重置。';
  }

  @override
  String get coachRestTenSeconds => '还剩十秒休息时间。';

  @override
  String get coachRestComplete => '休息结束了。为下一组做好准备。';

  @override
  String coachWorkoutComplete(int reps) {
    return '锻炼完成。您完成了$reps深蹲。';
  }

  @override
  String get notificationReminderTitle => '今天的深蹲时间';

  @override
  String get notificationReminderBody => '即使是短暂的会议也很重要。准备好后打开 MotionFit。';

  @override
  String get notificationReminderBodyVariant2 => '一些有针对性的深蹲可以使今天的运动发挥作用。';

  @override
  String notificationStreakReminderBody(int days) {
    return '今天通过简短的训练来保持您的$days连续几天的活力。';
  }

  @override
  String get semanticsIncrease => '增加';

  @override
  String get semanticsDecrease => '减少';

  @override
  String semanticsSelectedTab(String tab) {
    return '所选选项卡：$tab';
  }

  @override
  String semanticsCalendarWorkoutDate(String date) {
    return '$date，锻炼记录';
  }

  @override
  String semanticsCalendarEmptyDate(String date) {
    return '$date，没有锻炼';
  }

  @override
  String semanticsCurrentRep(int current, int target) {
    return '$target的电流重复$current';
  }

  @override
  String get repVideoReviewTitle => '代表视频回顾';

  @override
  String get repVideoReviewDescription => '在此设备上保存锻炼视频以查看各个代表。';

  @override
  String get repVideoLocalOnly => '仅本地·从未上传';

  @override
  String get formReviewTitle => '表格审核';

  @override
  String get formReviewMainIssue => '主要问题';

  @override
  String get viewRepTimeline => '查看代表时间表';

  @override
  String get repTimelineTitle => '代表审查';

  @override
  String get repTimelineAll => '全部';

  @override
  String get repTimelineImprove => '提升';

  @override
  String get repTimelineNoImprovement => '没有代表需要改进。';

  @override
  String repSetNumber(int number) {
    return '设置$number';
  }

  @override
  String repNumber(int number) {
    return '代表$number';
  }

  @override
  String get repResultGood => '状态好';

  @override
  String get repResultNeedsAttention => '需要注意';

  @override
  String get repResultImproved => '比之前的代表更好';

  @override
  String get repResultNotAssessed => '难以评估';

  @override
  String get repIssueShallowDepth => '尝试更深入一点';

  @override
  String get repIssueForwardLean => '上半身向前倾';

  @override
  String get repIssueKneesInward => '膝盖向内移动';

  @override
  String get repVideoNotSaved => '视频未保存';

  @override
  String get repReplay => '重播';

  @override
  String get repWhatHappened => '发生了什么';

  @override
  String get repHowToImprove => '如何改进';

  @override
  String get repWhatWentWell => '什么进展顺利';

  @override
  String get repPrevious => '以前的代表';

  @override
  String get repNext => '下一位代表';

  @override
  String get repFeedbackGood => '该代表保持在 MotionFit 可以评估的范围内。';

  @override
  String get repFeedbackDepth => '没有达到平时的深蹲深度。保持胸部稳定，并尝试再蹲低一点。';

  @override
  String get repFeedbackTorso => '这次动作中上身前倾过多。请让胸部更直立。';

  @override
  String get repFeedbackKnees => '这次动作中膝盖向内移动。请让膝盖与脚尖保持同一方向。';

  @override
  String repFeedbackGeneric(String area) {
    return '该代表需要在$area中引起注意。';
  }

  @override
  String get deleteWorkoutVideo => '删除锻炼视频';

  @override
  String get deleteWorkoutVideoTitle => '删除这个锻炼视频吗？';

  @override
  String get deleteWorkoutVideoBody => '仅删除本地视频。代表分析和锻炼记录将保留。';

  @override
  String get workoutVideoDeleted => '锻炼视频已删除';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appName => 'motionfit - workout coach';

  @override
  String get navSquat => '深蹲';

  @override
  String get navWorkout => '運動';

  @override
  String get navChallenge => '挑戰';

  @override
  String get navRecords => '進步';

  @override
  String get navSettings => '設定';

  @override
  String get challengeTitle => '我的深蹲挑戰';

  @override
  String get challengeSubtitle => '選擇適合您目標的挑戰並堅持不懈地前進。';

  @override
  String get challengeChooseTitle => '選擇一個挑戰';

  @override
  String get challengeSevenDayTitle => '7 天新手挑戰';

  @override
  String get challengeSevenDayDescription => '適合初學者的逐步計劃';

  @override
  String get challengeSevenDaySummary => '遵循每天增加的基於等級的目標，持續 7 天。';

  @override
  String get challengeSevenDayEveryDay => '每天持續 7 天，沒有恢復日';

  @override
  String challengeDurationDays(int days) {
    return '$days天';
  }

  @override
  String get challengeLevelGoals => '根據您的等級量身定制的目標';

  @override
  String get challengeRecoveryIncluded => '包括恢復天數';

  @override
  String get challengeDailyGoal => '每日次數目標';

  @override
  String get challengeSevenDayStart => '開始7天挑戰';

  @override
  String get challengeSevenDaySettings => '設定您的 7 天目標';

  @override
  String get challengeSevenDaySettingsDescription => '選擇第 1 天。目標每天增加 5 次。';

  @override
  String get challengeFirstDayGoal => '第一天目標次數';

  @override
  String challengeSevenDayPreview(int first, int last) {
    return '第 1 天：$first 次 → 第 7 天：$last 次';
  }

  @override
  String get challengeWeeklyTitle => '每週3次挑戰';

  @override
  String get challengeWeeklyDescription => '針對不想每天運動的人的習慣挑戰';

  @override
  String get challengeWeeklySummary => '每週選擇 3 天進行鍛煉，持續 4 週。';

  @override
  String challengeDurationWeeks(int weeks) {
    return '$weeks週';
  }

  @override
  String get challengeThreePerWeek => '每週 3 次鍛煉';

  @override
  String get challengeChooseWeekdays => '選擇 3 天鍛煉';

  @override
  String get challengeWorkoutDaysCount => '進度取決於鍛鍊天數';

  @override
  String get challengeWeeklyStart => '開始每週挑戰';

  @override
  String get challengeCumulativeTitle => '總次數挑戰';

  @override
  String get challengeCumulativeDescription => '按照適合您的時間表完成深蹲總目標';

  @override
  String get challengeCumulativeSummary => '選擇持續時間和總目標；休息日讓你進步。';

  @override
  String get challengePreset200 => '7天內200個深蹲';

  @override
  String get challengePreset500 => '14天內500個深蹲';

  @override
  String get challengeCustomGoal => '選擇您自己的持續時間和目標';

  @override
  String get challengeRestWithoutReset => '休息日不會重置進度';

  @override
  String get challengeCumulativeStart => '開始總次數挑戰';

  @override
  String get challengeHistoryTitle => '過去的挑戰';

  @override
  String get challengeHistoryEmpty => '您已完成和結束的挑戰將顯示在此。';

  @override
  String get challengeRecommended => '為您推薦';

  @override
  String challengeRecommendationFromWorkout(int reps) {
    return '從您第一次$reps次數鍛鍊中推薦。';
  }

  @override
  String get challengeRecommendationDefault => '建議您以 7 天的溫和時間開始第一次挑戰。';

  @override
  String get challengeActive => '主動挑戰';

  @override
  String get challengeNext => '下一個';

  @override
  String challengeDayNumber(int day) {
    return '日$day';
  }

  @override
  String get challengeRecoveryDay => '康復日';

  @override
  String challengeTodayProgress(int current, int target) {
    return '今天 $current/$target 次';
  }

  @override
  String get challengeRestToday => '今天需要時間恢復。';

  @override
  String get challengeTodayCompleted => '今天的目標完成·明天繼續';

  @override
  String challengeRepsRemaining(int reps) {
    return '還剩 $reps 次';
  }

  @override
  String challengeWeekNumber(int week) {
    return '週$week';
  }

  @override
  String challengeThisWeekProgress(int current, int target) {
    return '本週$current/$target鍛煉';
  }

  @override
  String challengeOverallDays(int current, int target) {
    return '總計$current/$target天';
  }

  @override
  String challengeRepsProgress(int current, int target) {
    return '$current/$target 次';
  }

  @override
  String challengeDaysRemaining(int days) {
    return '還剩 $days 天';
  }

  @override
  String challengeTodaySuggested(int reps) {
    return '今天建議：$reps 次';
  }

  @override
  String challengePercent(int percent) {
    return '$percent完成%';
  }

  @override
  String get challengeSquatStart => '開始深蹲';

  @override
  String get challengeTodayWorkoutStart => '開始今天的鍛煉';

  @override
  String get challengeViewDetails => '看詳情';

  @override
  String get challengeRestart => '重新開始';

  @override
  String get challengeDeleteHistory => '從歷史記錄中刪除';

  @override
  String get challengeCumulativeSettings => '設定您的總目標';

  @override
  String get challengeDurationLabel => '期間';

  @override
  String get challengeGoalLabel => '目標次數';

  @override
  String get challengeNotFound => '此挑戰不再可用。';

  @override
  String get challengePeriod => '時期';

  @override
  String get challengeStatus => '地位';

  @override
  String get challengeTotalReps => '深蹲總數';

  @override
  String get challengeWorkoutDays => '運動日';

  @override
  String challengeDaysCount(int days) {
    return '$days天';
  }

  @override
  String get challengeTotalTime => '總運動時間';

  @override
  String get challengeSchedule => '行程及進度';

  @override
  String get challengeNotifications => '挑戰提醒';

  @override
  String get challengeNotificationsDescription => '在此挑戰中保留提醒偏好。';

  @override
  String get challengeReminderNotificationTitle => '你的深蹲挑戰正在等待';

  @override
  String get challengeReminderNotificationBody =>
      '打開 MotionFit 並朝著今天的挑戰目標取得進展。';

  @override
  String get challengeSelectedWeekdays => '選定的鍛鍊日';

  @override
  String get challengeNoProgressYet => '還沒有挑戰訓練。';

  @override
  String get challengeCancel => '結束挑戰';

  @override
  String get challengeCancelTitle => '結束這個挑戰嗎？';

  @override
  String get challengeCancelDescription => '您的鍛鍊記錄將被儲存。這項挑戰將成為歷史。';

  @override
  String get challengeStatusActive => '進行中';

  @override
  String get challengeStatusCompleted => '完全的';

  @override
  String get challengeStatusEnded => '結束';

  @override
  String get challengeStatusCancelled => '取消';

  @override
  String get challengeProgressUpdated => '您的挑戰進度已更新。';

  @override
  String get challengeCheck => '查看挑戰';

  @override
  String get commonDone => '完畢';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '關閉';

  @override
  String get commonRetry => '再試一次';

  @override
  String get commonSave => '節省';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonBack => '後退';

  @override
  String get commonContinue => '繼續';

  @override
  String get commonStart => '開始';

  @override
  String get commonSkip => '跳過';

  @override
  String get commonEdit => '編輯';

  @override
  String get commonOn => '在';

  @override
  String get commonOff => '離開';

  @override
  String get commonEnabled => '啟用';

  @override
  String get commonDisabled => '殘障人士';

  @override
  String get commonNotAvailable => '無法使用';

  @override
  String get commonToday => '今天';

  @override
  String get commonYesterday => '昨天';

  @override
  String get commonLoading => '載入中…';

  @override
  String unitSets(int count) {
    return '$count 組';
  }

  @override
  String unitReps(int count) {
    return '$count 次';
  }

  @override
  String unitSeconds(int count) {
    return '$count 秒';
  }

  @override
  String unitMinutes(int count) {
    return '$count 分鐘';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours小時$minutes分鐘';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes分$seconds秒';
  }

  @override
  String get homeGreeting => '準備好搬家了嗎？';

  @override
  String get homeTodayTitle => '今天的記錄';

  @override
  String get homeTodayNoWorkout => '今天還沒有深蹲。簡短的一組是一個很好的開始。';

  @override
  String homeTodaySummary(int reps, int sets) {
    return '$reps 次深蹲，共 $sets 組';
  }

  @override
  String get homeViewResult => '查看結果';

  @override
  String get homeTodaySets => '今天設定';

  @override
  String get homeTodayReps => '今天完成';

  @override
  String get streakLabel => '條紋';

  @override
  String streakDays(int days) {
    return '$days天';
  }

  @override
  String get homeWorkoutSetup => '下次鍛鍊';

  @override
  String get homeSetsLabel => '套';

  @override
  String get homeRepsPerSetLabel => '每組次數';

  @override
  String get homeRestTimeLabel => '休息時間';

  @override
  String get homeDirectInputHint => '輸入一個數字';

  @override
  String get homeStartWorkout => '開始鍛鍊';

  @override
  String get homeLastSettingsRestored => '您上次的鍛鍊設定已準備就緒。';

  @override
  String get validationNumberRequired => '輸入一個數字。';

  @override
  String validationRange(num min, num max) {
    return '選擇從$min到$max的值。';
  }

  @override
  String get guideTitle => '設定您的相機';

  @override
  String get guideSubtitle => 'MotionFit 無需拍到腳踝，只要肩部到膝蓋入鏡即可測量深蹲。';

  @override
  String get guideWholeBody => '盡量讓肩部、髖部和膝蓋保持在畫面中。';

  @override
  String get guideStableCamera => '將手機放在穩定的地方。';

  @override
  String get guideOnePerson => '確保框架內只有一個人。';

  @override
  String get guideCameraAngle => '盡可能使用側面或略微傾斜的側視圖。';

  @override
  String get guideLighting => '避免黑暗的房間和強烈的背光。';

  @override
  String get guidePrivacy => '影片保留在此裝置上，僅當「代表影片審閱」開啟時才會儲存。';

  @override
  String get guideContinue => '我已就位';

  @override
  String get permissionCameraTitle => '需要相機存取權限';

  @override
  String get permissionCameraBody =>
      'MotionFit 使用攝影機計算深蹲次數。當您開啟「Rep Video Review」時，影片只會儲存在此裝置上。';

  @override
  String get permissionCameraRequest => '繼續';

  @override
  String get permissionCameraDenied => '相機訪問被拒絕。您仍然可以查看記錄和設定。';

  @override
  String get permissionCameraPermanentlyDenied => '在系統設定中允許相機存取以開始鍛鍊。';

  @override
  String get permissionOpenSettings => '開啟設定';

  @override
  String get permissionNotificationTitle => '允許鍛鍊提醒嗎？';

  @override
  String get permissionNotificationBody => '通知僅用於您安排的提醒。';

  @override
  String get permissionNotificationRequest => '允許通知';

  @override
  String get permissionNotificationDenied => '通知已關閉。在系統設定中開啟它們以接收提醒。';

  @override
  String get countdownGetReady => '準備';

  @override
  String countdownBeginsIn(int seconds) {
    return '從$seconds開始';
  }

  @override
  String get calibrationTitle => '正在確認站立姿勢';

  @override
  String get calibrationBody => '站直，並讓肩部到膝蓋保持在畫面中。';

  @override
  String get calibrationStayStill => '保持靜止一會兒';

  @override
  String get calibrationComplete => '一切就緒';

  @override
  String get calibrationFailed => '無法清楚辨識站立姿勢。';

  @override
  String get calibrationRetry => '重新校準';

  @override
  String workoutSetProgress(int current, int total) {
    return '第 $current/$total 組';
  }

  @override
  String workoutRepProgress(int current, int target) {
    return '$current/$target 次';
  }

  @override
  String workoutTotalReps(int count) {
    return '總計 $count 次';
  }

  @override
  String get workoutElapsed => '經過時間';

  @override
  String get workoutPause => '暫停';

  @override
  String get workoutResume => '恢復鍛鍊';

  @override
  String get workoutEnd => '暫時停止';

  @override
  String get workoutBackToSetup => '返回設定';

  @override
  String get workoutEndDialogTitle => '暫時停下來嗎？';

  @override
  String get workoutEndDialogBody => '您的進度將被保存，以便您可以從主畫面繼續。';

  @override
  String get workoutEndDialogConfirm => '保存並離開';

  @override
  String get workoutPauseReasonBackground => '當應用程式處於背景時，鍛鍊暫停。';

  @override
  String get workoutPauseReasonInterruption => '系統中斷後運動暫停。';

  @override
  String get workoutStateReady => '準備好';

  @override
  String get workoutStateDescending => '往下走';

  @override
  String get workoutStateBottom => '在底部';

  @override
  String get workoutStateAscending => '即將推出';

  @override
  String get workoutStateCompleted => '很好的代表';

  @override
  String get workoutStateTrackingLost => '仍在檢測中';

  @override
  String get workoutStatePaused => '已暫停';

  @override
  String get workoutTrackingGood => '偵測到關節';

  @override
  String get workoutCameraSwitch => '切換相機';

  @override
  String get workoutSkeletonToggle => '顯示姿勢指南';

  @override
  String get restTitle => '休息';

  @override
  String restNextSet(int set, int total) {
    return '下一篇：設定$total的$set';
  }

  @override
  String get restCompletedSets => '已完成的套裝';

  @override
  String get restTotalReps => '到目前為止深蹲';

  @override
  String get restSkip => '跳過休息';

  @override
  String get restAddFifteenSeconds => '添加 15 秒';

  @override
  String get restEndWorkout => '暫時停止';

  @override
  String get restAlmostDone => '快準備好了';

  @override
  String get restReady => '下一組的時間';

  @override
  String get completeTitle => '鍛鍊完成';

  @override
  String get completeSubtitle => '工作紮實。這是您的會話概覽。';

  @override
  String get workoutInterruptedSubtitle => '在提前結束之前回顧一下您錄製的內容。';

  @override
  String get completeTotalReps => '深蹲總數';

  @override
  String get completeCompletedSets => '套數已完成';

  @override
  String get completeActiveTime => '活躍時間';

  @override
  String get completeRestTime => '休息時間';

  @override
  String get completeTotalTime => '總時間';

  @override
  String get completeAverageRepTime => '平均重複時間';

  @override
  String get completeFormSummary => '表格摘要';

  @override
  String get todayCoaching => '今天的輔導';

  @override
  String coachingIssueFrequency(int total, int count, String issue) {
    return '在$total次數的$count中，$issue';
  }

  @override
  String get completeTopImprovement => '下次重點';

  @override
  String get completeStrengths => '什麼進展順利';

  @override
  String get completeSaved => '此設備上已儲存的鍛鍊數據';

  @override
  String get completeSaveFailed => '無法保存鍛鍊。離開前再試一次。';

  @override
  String get completeNoFormData => '沒有足夠的可見運動來進行表格摘要。';

  @override
  String get completeFinish => '結束';

  @override
  String get postWorkoutReminderTitle => '保持勢頭';

  @override
  String postWorkoutReminderBody(String time) {
    return '您想要從明天開始在$time上收到每日提醒嗎？';
  }

  @override
  String get postWorkoutReminderEnable => '提醒我';

  @override
  String get postWorkoutReminderLater => '也許稍後';

  @override
  String get postWorkoutReminderEnabled => '您的提醒已設定。';

  @override
  String get recordsTitle => '進步';

  @override
  String get recordsWeeklySummary => '本星期';

  @override
  String recordsWorkoutCount(int count) {
    return '$count鍛煉';
  }

  @override
  String recordsAverageForm(int score) {
    return '平均動作評分 $score';
  }

  @override
  String recordsWorkoutTime(String time) {
    return '時間$time';
  }

  @override
  String get recordsFirstWeek => '這是您本週的第一張唱片';

  @override
  String recordsMoreThanLastWeek(int count) {
    return '$count比上週更多的次數';
  }

  @override
  String recordsLessThanLastWeek(int count) {
    return '$count次數比上週少';
  }

  @override
  String get recordsSameAsLastWeek => '成交量與上週持平';

  @override
  String get recordsTrendEmpty => '完成更多運動以了解您的體形趨勢。';

  @override
  String get recordsFirstFormScore => '首次動作評分';

  @override
  String recordsRecentAverage(int count, int score) {
    return '最後$count平均$score';
  }

  @override
  String get recordsStrength => '力量';

  @override
  String get recordsFocus => '重點';

  @override
  String get recordsTodayPoint => '今日焦點';

  @override
  String get recordsToday => '今天';

  @override
  String get recordsRecentWorkouts => '最近的鍛鍊';

  @override
  String get recordsCalendarTitle => '鍛鍊日曆';

  @override
  String get recordsFormTrend => '動作趨勢';

  @override
  String get recordsViewCalendar => '日曆';

  @override
  String get recordsViewList => '清單';

  @override
  String get recordsViewStats => '統計數據';

  @override
  String get recordsCalendarPreviousMonth => '上個月';

  @override
  String get recordsCalendarNextMonth => '下個月';

  @override
  String get recordsCalendarWorkoutDay => '運動日';

  @override
  String get recordsCalendarNoWorkoutSelected => '選擇鍛煉日以查看其課程。';

  @override
  String get recordsDayTotal => '每日總計';

  @override
  String recordsSessionsCount(int count) {
    return '$count 次訓練';
  }

  @override
  String recordsSessionTitle(int number) {
    return '會話$number';
  }

  @override
  String get recordsListNewest => '最新的優先';

  @override
  String get recordsOpenDetail => '看詳情';

  @override
  String get recordsEmptyTitle => '還沒有鍛煉';

  @override
  String get recordsEmptyBody => '完成您的第一次深蹲鍛煉，它將出現在此處。';

  @override
  String get recordsStartWorkout => '開始鍛鍊';

  @override
  String get recordsLoading => '正在加載您的鍛鍊...';

  @override
  String get recordsLoadError => '我們無法加載您的鍛鍊記錄。';

  @override
  String get statsPeriod => '時期';

  @override
  String get statsPeriod7Days => '7天';

  @override
  String get statsPeriod30Days => '30天';

  @override
  String get statsPeriodThisMonth => '本月';

  @override
  String get statsPeriodAll => '所有時間';

  @override
  String get statsPeriodCustom => '風俗';

  @override
  String get statsCustomRange => '選擇日期範圍';

  @override
  String get statsTotalReps => '深蹲總數';

  @override
  String get statsWorkoutDays => '運動日';

  @override
  String get statsTotalActiveTime => '活躍時間';

  @override
  String get statsAverageSets => '平均組數';

  @override
  String get statsAverageReps => '平均深蹲';

  @override
  String get statsDailyReps => '白天深蹲';

  @override
  String get statsTrend => '隨著時間的推移而改變';

  @override
  String get statsFrequentImprovements => '經常關注的領域';

  @override
  String get statsNoData => '這段時間沒有運動。';

  @override
  String statsTrendUp(num percent) {
    return '上漲$percent%';
  }

  @override
  String statsTrendDown(num percent) {
    return '下降$percent%';
  }

  @override
  String get statsTrendFlat => '沒有變化';

  @override
  String get detailTitle => '運動詳情';

  @override
  String get detailStartTime => '開始';

  @override
  String get detailEndTime => '結束';

  @override
  String get detailActiveTime => '活躍時間';

  @override
  String get detailRestTime => '休息時間';

  @override
  String get detailTotalTime => '總時間';

  @override
  String get detailSets => '套';

  @override
  String get detailSetBreakdown => '按組次數';

  @override
  String get detailTotalReps => '深蹲總數';

  @override
  String get detailAverageRep => '平均重複時間';

  @override
  String get detailFormSummary => '表格摘要';

  @override
  String get detailImprovements => '改進點';

  @override
  String get detailStrengths => '優勢';

  @override
  String get detailInterrupted => '提早結束';

  @override
  String get detailCompleted => '完全的';

  @override
  String detailSetRow(int set, int reps) {
    return '設定$set：$reps次數';
  }

  @override
  String detailSessionOn(String date, String time) {
    return '$date於$time';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsRateApp => '評價這個應用程式';

  @override
  String get settingsRateAppSubtitle => '評價 MotionFit';

  @override
  String get settingsRateAppError => '無法開店。請再試一次。';

  @override
  String get settingsSectionGeneral => '一般的';

  @override
  String get settingsSectionCoaching => '語音輔導';

  @override
  String get settingsSectionReminder => '鍛鍊提醒';

  @override
  String get settingsSectionCamera => '相機';

  @override
  String get settingsSectionPrivacy => '隱私和數據';

  @override
  String get settingsSectionAbout => '關於';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsDisplayTheme => '畫面主題';

  @override
  String get settingsColorTheme => '色彩主題';

  @override
  String get themeLight => '光';

  @override
  String get themePureBlack => '純黑';

  @override
  String get themeSystem => '系統';

  @override
  String get colorThemeByeokcheong => '碧清藍';

  @override
  String get colorThemeChuhyang => '秋香米色';

  @override
  String get colorThemeJangdan => '長丹紅';

  @override
  String get colorThemeCheonghyeon => '清賢藍';

  @override
  String get colorThemeHaenghwang => '杏黃杏';

  @override
  String get colorThemeChunyu => '春雨綠';

  @override
  String get colorThemeSeolbaek => '雪白白';

  @override
  String get colorThemeByeokja => '碧紫紫';

  @override
  String get colorThemeChwiram => '奇蘭薄荷';

  @override
  String get languageSystem => '使用裝置語言';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageGerman => '德文';

  @override
  String get languageSpanish => '西班牙語';

  @override
  String get languageFrench => '法國人';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageArabic => '巴黎';

  @override
  String get languageChineseSimplified => '簡體中文';

  @override
  String get languageChineseTraditional => '繁體中文';

  @override
  String get languageChanged => '語言已更新';

  @override
  String get voiceCoachingEnabled => '語音輔導';

  @override
  String get voiceRepCountEnabled => '說出次數';

  @override
  String get voiceFormEnabled => '表格提示';

  @override
  String get voiceEncouragementEnabled => '鼓勵';

  @override
  String get voiceRate => '語速';

  @override
  String get voiceRateSlow => '慢的';

  @override
  String get voiceRateNormal => '普通的';

  @override
  String get voiceRateFast => '快速地';

  @override
  String get voiceTest => '測試語音';

  @override
  String get voiceTestPhrase => '偉大的。您的語音教練已準備就緒。';

  @override
  String get voiceUnavailable => '沒有安裝與該語言相容的離線語音。';

  @override
  String get reminderTitle => '鍛鍊提醒';

  @override
  String get reminderSubtitle => '為您每天想要訓練的時間選擇一個時間。';

  @override
  String get reminderEnabled => '已啟用提醒';

  @override
  String get reminderTime => '提醒時間';

  @override
  String get reminderCopyTime => '這次複製';

  @override
  String reminderCopyFromDay(String day) {
    return '從$day複製時間';
  }

  @override
  String get reminderApplyAll => '適用於每一天';

  @override
  String reminderNext(String dateTime) {
    return '下次提醒：$dateTime';
  }

  @override
  String get reminderNoneScheduled => '沒有安排提醒';

  @override
  String get reminderPermissionNeeded => '允許通知開啟提醒。';

  @override
  String get reminderSaved => '提醒時間表已儲存';

  @override
  String get weekdayMonday => '週一';

  @override
  String get weekdayTuesday => '週二';

  @override
  String get weekdayWednesday => '週三';

  @override
  String get weekdayThursday => '週四';

  @override
  String get weekdayFriday => '星期五';

  @override
  String get weekdaySaturday => '週六';

  @override
  String get weekdaySunday => '星期日';

  @override
  String get weekdayMondayShort => '週一';

  @override
  String get weekdayTuesdayShort => '星期二';

  @override
  String get weekdayWednesdayShort => '週三';

  @override
  String get weekdayThursdayShort => '星期四';

  @override
  String get weekdayFridayShort => '週五';

  @override
  String get weekdaySaturdayShort => '星期六';

  @override
  String get weekdaySundayShort => '太陽';

  @override
  String get cameraFront => '前置鏡頭';

  @override
  String get cameraRear => '後置攝像頭';

  @override
  String get cameraMirrorPreview => '後視鏡正面預覽';

  @override
  String get cameraPoseOverlay => '姿勢指南覆蓋';

  @override
  String get cameraKeepScreenAwake => '鍛鍊期間保持螢幕喚醒';

  @override
  String get settingsHaptics => '觸覺回饋';

  @override
  String get privacyTitle => '如何處理您的數據';

  @override
  String get privacyLocalProcessing => '姿勢分析在此設備上運行。';

  @override
  String get privacyNoVideoStorage => '僅當啟用「代表影片檢視」時，鍛鍊影片才會儲存在此裝置上。';

  @override
  String get privacyNoUpload => '相機幀不會上傳到伺服器。';

  @override
  String get privacyStoredData => '該設備上儲存的數據';

  @override
  String get privacyStoredDataDescription =>
      'MotionFit 會儲存鍛鍊時間、組數、次數和表格結果，以便您可以查看您的進度。';

  @override
  String get privacyDeleteData => '刪除所有鍛鍊數據';

  @override
  String get privacyDeleteConfirmTitle => '刪除所有鍛鍊數據？';

  @override
  String get privacyDeleteConfirmBody => '這將從該裝置中永久刪除您的鍛鍊歷史記錄。此操作無法撤銷。';

  @override
  String get privacyDeleteConfirmAction => '刪除所有數據';

  @override
  String get privacyDeleteSuccess => '鍛鍊數據已刪除';

  @override
  String get privacyDeleteFailure => '無法刪除鍛鍊數據。';

  @override
  String get appInfoTitle => '應用程式資訊';

  @override
  String appInfoVersion(String version) {
    return '版本$version';
  }

  @override
  String get appInfoLicenses => '開源許可證';

  @override
  String get appInfoPrivacyPolicy => '隱私權政策';

  @override
  String get appInfoDescription => 'MotionFit 計算深蹲次數並提供私人的設備上形式指引。';

  @override
  String get errorGenericTitle => '出了點問題';

  @override
  String get errorGenericBody => '請再試一次。您現有的運動記錄是安全的。';

  @override
  String get errorCameraInit => '相機無法啟動。';

  @override
  String get errorCameraInUse => '相機可能正在被其他應用程式使用。';

  @override
  String get errorPoseModelLoad => '無法載入姿勢模型。';

  @override
  String get errorNoPerson => '沒有發現任何人。步入視野。';

  @override
  String get errorWholeBody => '正在檢查肩部、髖部和膝蓋的連線。';

  @override
  String get errorMultiplePeople => '視野中不只一個人。畫面中僅保留一個人。';

  @override
  String get errorTrackingLost => '訓練仍在繼續，而檢測仍在繼續嘗試。';

  @override
  String get errorDatabaseSave => '無法保存您的鍛鍊。';

  @override
  String get errorTtsVoiceMissing => '該設備上未安裝語音。';

  @override
  String get errorTtsLocaleUnsupported => '此裝置上所選語言不支援語音輔導。';

  @override
  String get emptyNoFormIssues => '未偵測到重複的表單問題。';

  @override
  String get emptyNotEnoughData => '還沒有足夠的數據';

  @override
  String get loadingCamera => '啟動相機...';

  @override
  String get loadingPoseModel => '正在準備移動檢測...';

  @override
  String get loadingSavingWorkout => '儲存鍛鍊...';

  @override
  String get formScore => '動作評分';

  @override
  String get formShort => '動作';

  @override
  String formScoreValue(int score) {
    return '$score分';
  }

  @override
  String get formIssueDepth => '深蹲深度';

  @override
  String get formIssueTorsoLean => '上身穩定性';

  @override
  String get formIssueHeelLift => '腳跟接觸';

  @override
  String get formIssueKneeAlignment => '膝蓋對齊';

  @override
  String get formIssueBalance => '左右平衡';

  @override
  String get formIssueDescentSpeed => '下降速度';

  @override
  String get formIssueAscentSpeed => '上升速度';

  @override
  String get formIssueControl => '運動控制';

  @override
  String get formIssueStandingCompletion => '站立完成度';

  @override
  String get formIssueNotObservable => '從這個相機角度無法評估';

  @override
  String get formStrengthDepth => '一致的深度';

  @override
  String get formStrengthControl => '受控運動';

  @override
  String get formStrengthBalance => '穩定平衡';

  @override
  String get coachTrackingLost1 => '當我不斷檢測時，你的鍛鍊仍在進行中。';

  @override
  String get coachTrackingLost2 => '短暫的遮蔽不會暫停您的運動。';

  @override
  String get coachWholeBody1 => '肩部、髖部和膝蓋入鏡後即可測量。';

  @override
  String get coachWholeBody2 => '即使腳踝不在畫面中，也可以繼續鍛鍊。';

  @override
  String get coachMultiplePeople1 => '畫面中只保留一個人，這樣我就能追蹤到你。';

  @override
  String get coachReady1 => '你已經就位了。讓我們開始吧。';

  @override
  String get coachReady2 => '姿勢很好。準備開始第一次深蹲。';

  @override
  String coachStartSet(int set) {
    return '設定$set。我們走吧。';
  }

  @override
  String coachSevenDayChallengeStart(int day) {
    return '七日挑戰的起始日$day。';
  }

  @override
  String coachCumulativeChallengeStart(int completed, int remaining) {
    return '開始累積次數挑戰。您已完成$completed次，還剩$remaining。';
  }

  @override
  String coachRepCount(int count) {
    return '$count';
  }

  @override
  String get coachDepth1 => '下次，試著降低一點。';

  @override
  String get coachDepth2 => '下一次深蹲再蹲低一點。';

  @override
  String get coachTorso1 => '上身再穩定一點。';

  @override
  String get coachTorso2 => '下一次動作時，讓胸部自然挺起。';

  @override
  String get coachHeel1 => '盡量讓腳跟貼住地面。';

  @override
  String get coachHeel2 => '下一次動作時，用整個腳掌發力。';

  @override
  String get coachKnees1 => '讓膝蓋朝向腳尖的方向。';

  @override
  String get coachKnees2 => '下一次動作時，讓膝蓋保持對齊。';

  @override
  String get coachBalance1 => '保持兩側體重均勻。';

  @override
  String get coachBalance2 => '為下一次代表找到一個均勻、穩定的姿勢。';

  @override
  String get coachDescendSlow1 => '下次嘗試放慢一點。';

  @override
  String get coachDescendSlow2 => '控制下一次代表的下降方式。';

  @override
  String get coachDescendFaster1 => '下次下坡時速度要快一點。';

  @override
  String get coachDescendFaster2 => '繼續下一個下降過程，不要停下來。';

  @override
  String get coachAscendControlled1 => '順利起身並保持控制。';

  @override
  String get coachAscendControlled2 => '站起時保持穩定的節奏。';

  @override
  String get coachAscendFaster1 => '更有自信地開車。';

  @override
  String get coachAscendFaster2 => '下一次站起時再果斷一點。';

  @override
  String get coachControl1 => '讓下一次動作從頭到尾都順利進行。';

  @override
  String get coachControl2 => '在整個動作中保持控制。';

  @override
  String get coachStandTall1 => '結束時再站直一點。';

  @override
  String get coachStandTall2 => '完全回到站立姿勢。';

  @override
  String get coachGood1 => '好的。保持這個節奏。';

  @override
  String get coachGood2 => '控制得好。繼續下去。';

  @override
  String get coachGood3 => '強代表。再做一次。';

  @override
  String get coachLastTwo => '最後兩個。堅強點！';

  @override
  String get coachLastOne => '最後一張。堅強地完成！';

  @override
  String coachSetComplete(int set) {
    return '偉大的。設定$set完成。';
  }

  @override
  String coachRestStart(int seconds) {
    return '休息$seconds秒。呼吸並重置。';
  }

  @override
  String get coachRestTenSeconds => '還剩十秒休息時間。';

  @override
  String get coachRestComplete => '休息結束了。為下一組做好準備。';

  @override
  String coachWorkoutComplete(int reps) {
    return '鍛煉完成。您完成了$reps深蹲。';
  }

  @override
  String get notificationReminderTitle => '今天的深蹲時間';

  @override
  String get notificationReminderBody => '即使是短暫的會議也很重要。準備好後打開 MotionFit。';

  @override
  String get notificationReminderBodyVariant2 => '一些有針對性的深蹲可以使今天的運動發揮作用。';

  @override
  String notificationStreakReminderBody(int days) {
    return '今天就透過簡短的訓練來保持您的$days連續幾天的活力。';
  }

  @override
  String get semanticsIncrease => '增加';

  @override
  String get semanticsDecrease => '減少';

  @override
  String semanticsSelectedTab(String tab) {
    return '所選選項卡：$tab';
  }

  @override
  String semanticsCalendarWorkoutDate(String date) {
    return '$date，鍛鍊記錄';
  }

  @override
  String semanticsCalendarEmptyDate(String date) {
    return '$date，沒有鍛煉';
  }

  @override
  String semanticsCurrentRep(int current, int target) {
    return '$target的電流重複$current';
  }

  @override
  String get repVideoReviewTitle => '代表影片回顧';

  @override
  String get repVideoReviewDescription => '在此裝置上儲存鍛鍊影片以查看各個代表。';

  @override
  String get repVideoLocalOnly => '僅本地·從未上傳';

  @override
  String get formReviewTitle => '表格審核';

  @override
  String get formReviewMainIssue => '主要問題';

  @override
  String get viewRepTimeline => '查看代表時間表';

  @override
  String get repTimelineTitle => '代表審查';

  @override
  String get repTimelineAll => '全部';

  @override
  String get repTimelineImprove => '提升';

  @override
  String get repTimelineNoImprovement => '沒有代表需要改進。';

  @override
  String repSetNumber(int number) {
    return '設定$number';
  }

  @override
  String repNumber(int number) {
    return '代表$number';
  }

  @override
  String get repResultGood => '狀態好';

  @override
  String get repResultNeedsAttention => '需要注意';

  @override
  String get repResultImproved => '比之前的代表更好';

  @override
  String get repResultNotAssessed => '難以評估';

  @override
  String get repIssueShallowDepth => '試著更深入一點';

  @override
  String get repIssueForwardLean => '上半身向前傾';

  @override
  String get repIssueKneesInward => '膝蓋向內移動';

  @override
  String get repVideoNotSaved => '影片未儲存';

  @override
  String get repReplay => '重播';

  @override
  String get repWhatHappened => '發生了什麼事';

  @override
  String get repHowToImprove => '如何改進';

  @override
  String get repWhatWentWell => '什麼進展順利';

  @override
  String get repPrevious => '以前的代表';

  @override
  String get repNext => '下一位代表';

  @override
  String get repFeedbackGood => '該代表保持在 MotionFit 可以評估的範圍內。';

  @override
  String get repFeedbackDepth => '沒有達到平時的深蹲深度。保持胸部穩定，並嘗試再蹲低一點。';

  @override
  String get repFeedbackTorso => '這次動作中上身前傾過多。請讓胸部更直立。';

  @override
  String get repFeedbackKnees => '這次動作中膝蓋向內移動。請讓膝蓋與腳尖保持同一方向。';

  @override
  String repFeedbackGeneric(String area) {
    return '此代表需要在$area中引起注意。';
  }

  @override
  String get deleteWorkoutVideo => '刪除鍛煉視頻';

  @override
  String get deleteWorkoutVideoTitle => '刪除這個運動影片嗎？';

  @override
  String get deleteWorkoutVideoBody => '僅刪除本地影片。代表分析和鍛煉記錄將保留。';

  @override
  String get workoutVideoDeleted => '鍛鍊影片已刪除';
}
