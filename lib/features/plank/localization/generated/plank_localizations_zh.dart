// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'plank_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class PlankLocalizationsZh extends PlankLocalizations {
  PlankLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'motionfit - workout coach';

  @override
  String get navSquat => '平板支撑练习';

  @override
  String get navChallenge => '挑战';

  @override
  String get navRecords => '进步';

  @override
  String get navSettings => '设置';

  @override
  String get challengeTitle => '我的平板支撑练习挑战';

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
  String get challengeDailyGoal => '每日第二个目标';

  @override
  String get challengeSevenDayStart => '开始7天挑战';

  @override
  String get challengeSevenDaySettings => '设定您的 7 天目标';

  @override
  String get challengeSevenDaySettingsDescription => '选择第 1 天。目标每天增加 5 秒。';

  @override
  String get challengeFirstDayGoal => '第 1 天目标秒数';

  @override
  String challengeSevenDayPreview(int first, int last) {
    return '第 1 天：$first 秒 → 第 7 天：$last 秒';
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
  String get challengeCumulativeTitle => '总秒数挑战';

  @override
  String get challengeCumulativeDescription => '按照适合您的时间表达到平板支撑总锻炼目标';

  @override
  String get challengeCumulativeSummary => '选择持续时间和总目标；休息日让你进步。';

  @override
  String get challengePreset200 => '7天内200秒平板支撑运动';

  @override
  String get challengePreset500 => '14天内500秒平板支撑运动';

  @override
  String get challengeCustomGoal => '选择您自己的持续时间和目标';

  @override
  String get challengeRestWithoutReset => '休息日不会重置进度';

  @override
  String get challengeCumulativeStart => '开始总秒数挑战';

  @override
  String get challengeHistoryTitle => '过去的挑战';

  @override
  String get challengeHistoryEmpty => '您已完成和结束的挑战将显示在此处。';

  @override
  String get challengeRecommended => '为您推荐';

  @override
  String challengeRecommendationFromWorkout(int reps) {
    return '从您第一次锻炼 $reps 秒开始推荐。';
  }

  @override
  String get challengeRecommendationDefault => '建议您以 7 天的温和时间开始第一次挑战。';

  @override
  String get challengeActive => '主动挑战';

  @override
  String get challengeNext => '下一个';

  @override
  String challengeDayNumber(int day) {
    return '日 $day';
  }

  @override
  String get challengeRecoveryDay => '康复日';

  @override
  String challengeTodayProgress(int current, int target) {
    return '今日 $current / $target 秒';
  }

  @override
  String get challengeRestToday => '今天需要时间恢复。';

  @override
  String get challengeTodayCompleted => '今天的目标完成·明天继续';

  @override
  String challengeRepsRemaining(int reps) {
    return '$reps 还剩几秒';
  }

  @override
  String challengeWeekNumber(int week) {
    return '周 $week';
  }

  @override
  String challengeThisWeekProgress(int current, int target) {
    return '本周 $current / $target 锻炼';
  }

  @override
  String challengeOverallDays(int current, int target) {
    return '总计 $current / $target 天';
  }

  @override
  String challengeRepsProgress(int current, int target) {
    return '$current / $target 秒';
  }

  @override
  String challengeDaysRemaining(int days) {
    return '$days 剩余天数';
  }

  @override
  String challengeTodaySuggested(int reps) {
    return '今天建议：$reps 秒';
  }

  @override
  String challengePercent(int percent) {
    return '$percent 完成%';
  }

  @override
  String get challengeSquatStart => '开始平板支撑练习';

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
  String get challengeGoalLabel => '目标秒数';

  @override
  String get challengeNotFound => '此挑战不再可用。';

  @override
  String get challengePeriod => '时期';

  @override
  String get challengeStatus => '地位';

  @override
  String get challengeTotalReps => '平板支撑运动总秒数';

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
  String get challengeReminderNotificationTitle => '你的平板支撑练习挑战正在等待着';

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
  String get commonDone => '完成';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '关闭';

  @override
  String get commonRetry => '再试一次';

  @override
  String get commonSave => '保存';

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
  String get commonOn => '开启';

  @override
  String get commonOff => '关闭';

  @override
  String get commonEnabled => '启用';

  @override
  String get commonDisabled => '已关闭';

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
    return '$count 秒';
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
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes 分 $seconds 秒';
  }

  @override
  String get homeGreeting => '准备好开始了吗？';

  @override
  String get homeTodayTitle => '今天的记录';

  @override
  String get homeTodayNoWorkout => '今天还没有进行平板支撑练习。简短的一组是一个很好的开始。';

  @override
  String homeTodaySummary(int reps, int sets) {
    return '$reps 平板支撑练习 秒跨 $sets';
  }

  @override
  String get homeViewResult => '查看结果';

  @override
  String get homeTodaySets => '今天设定';

  @override
  String get homeTodayReps => '今天秒数';

  @override
  String get streakLabel => '连续记录';

  @override
  String streakDays(int days) {
    return '$days天';
  }

  @override
  String get homeWorkoutSetup => '下一次锻炼';

  @override
  String get homeSetsLabel => '套';

  @override
  String get homeRepsPerSetLabel => '每组秒数';

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
    return '选择 $min 到 $max 之间的值。';
  }

  @override
  String get guideTitle => '设置您的相机';

  @override
  String get guideLandscapeTitle => '将手机横过来';

  @override
  String get guideLandscapeBody => '平板支撑运动跟踪使用横向模式。在就位之前将手机水平放置。';

  @override
  String get countdownLandscapePrompt => '将手机保持横向模式';

  @override
  String get guideSubtitle => '让您的肩膀、臀部、膝盖和脚踝保持可见，以便 MotionFit 可以测量您的平板支撑运动。';

  @override
  String get guideWholeBody => '将相机放在侧面，让您的全身可见。';

  @override
  String get guideStableCamera => '将手机放在稳定的地方。';

  @override
  String get guideOnePerson => '确保框架内只有一个人。';

  @override
  String get guideCameraAngle => '使用侧视图或略微倾斜的侧视图。';

  @override
  String get guideLighting => '避免黑暗的房间和强烈的背光。';

  @override
  String get guidePrivacy => '视频保留在此设备上，并且仅当“保留视频审阅”打开时才会保存。';

  @override
  String get guideContinue => '我已就位';

  @override
  String get permissionCameraTitle => '需要相机访问权限';

  @override
  String get permissionCameraBody =>
      'MotionFit 使用摄像头来计算平板支撑运动的秒数。当您打开“保留视频查看”时，视频仅保存在此设备上。';

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
    return '从 $seconds 开始';
  }

  @override
  String get calibrationTitle => '找到你的平板支撑锻炼位置';

  @override
  String get calibrationBody => '进行直板支撑练习，并看到整个身体。';

  @override
  String get calibrationStayStill => '保持身体挺直片刻';

  @override
  String get calibrationComplete => '一切就绪';

  @override
  String get calibrationFailed => '我们无法检测到明确的平板支撑练习位置。';

  @override
  String get calibrationRetry => '重新校准';

  @override
  String workoutSetProgress(int current, int total) {
    return '设置 $total 的 $current';
  }

  @override
  String workoutRepProgress(int current, int target) {
    return '$current 之 $target';
  }

  @override
  String workoutTotalReps(int count) {
    return '总计$count';
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
  String get workoutStateReady => '就位';

  @override
  String get workoutStateDescending => '检查对齐情况';

  @override
  String get workoutStateBottom => '保持稳定';

  @override
  String get workoutStateAscending => '重新调整你的身体';

  @override
  String get workoutStateCompleted => '保持一秒';

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
    return '下一篇：设置$set 之 $total';
  }

  @override
  String get restCompletedSets => '已完成的套装';

  @override
  String get restTotalReps => '到目前为止平板支撑锻炼时间';

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
  String get completeTotalReps => '平板支撑运动总秒数';

  @override
  String get completeCompletedSets => '套数已完成';

  @override
  String get completeActiveTime => '活跃时间';

  @override
  String get completeRestTime => '休息时间';

  @override
  String get completeTotalTime => '总时间';

  @override
  String get completeAverageRepTime => '平均保持检查点';

  @override
  String get completeFormSummary => '表格摘要';

  @override
  String get todayCoaching => '今天的辅导';

  @override
  String coachingIssueFrequency(int total, int count, String issue) {
    return '在 $total 秒的 $count 中，\n$issue';
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
    return '您想从明天开始在 $time 上收到每日提醒吗？';
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
    return '$count 锻炼';
  }

  @override
  String recordsAverageForm(int score) {
    return '平均形式 $score';
  }

  @override
  String recordsWorkoutTime(String time) {
    return '时间 $time';
  }

  @override
  String get recordsFirstWeek => '这是您本周的第一张唱片';

  @override
  String recordsMoreThanLastWeek(int count) {
    return '$count 比上周多秒';
  }

  @override
  String recordsLessThanLastWeek(int count) {
    return '$count 比上周少了几秒';
  }

  @override
  String get recordsSameAsLastWeek => '成交量与上周持平';

  @override
  String get recordsTrendEmpty => '完成更多锻炼以了解您的体形趋势。';

  @override
  String get recordsFirstFormScore => '第一形式成绩';

  @override
  String recordsRecentAverage(int count, int score) {
    return '最后$count 平均$score';
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
  String get recordsFormTrend => '形式趋势';

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
    return '会话 $number';
  }

  @override
  String get recordsListNewest => '最新的优先';

  @override
  String get recordsOpenDetail => '查看详情';

  @override
  String get recordsEmptyTitle => '还没有锻炼';

  @override
  String get recordsEmptyBody => '完成您的第一次平板支撑锻炼，它将出现在此处。';

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
  String get statsTotalReps => '平板支撑运动总秒数';

  @override
  String get statsWorkoutDays => '锻炼日';

  @override
  String get statsTotalActiveTime => '活跃时间';

  @override
  String get statsAverageSets => '平均组数';

  @override
  String get statsAverageReps => '平板支撑平均运动秒数';

  @override
  String get statsDailyReps => '平板支撑每天的锻炼时间';

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
  String get detailSetBreakdown => '按秒计算';

  @override
  String get detailTotalReps => '平板支撑运动总秒数';

  @override
  String get detailAverageRep => '平均保持检查点';

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
    return '设置$set：$reps秒';
  }

  @override
  String detailSessionOn(String date, String time) {
    return '$date 在 $time';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsRateApp => '评价这个应用程序';

  @override
  String get settingsRateAppSubtitle => '评价 MotionFit';

  @override
  String get settingsRateAppError => '无法打开应用商店，请重试。';

  @override
  String get settingsSectionGeneral => '通用';

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
  String get themeLight => '浅色';

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
  String get languageChanged => '语言已更新';

  @override
  String get voiceCoachingEnabled => '语音辅导';

  @override
  String get voiceRepCountEnabled => '说第二次数';

  @override
  String get voiceFormEnabled => '表格提示';

  @override
  String get voiceEncouragementEnabled => '鼓励';

  @override
  String get voiceRate => '语速';

  @override
  String get voiceRateSlow => '慢';

  @override
  String get voiceRateNormal => '正常';

  @override
  String get voiceRateFast => '快';

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
    return '从 $day 复制时间';
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
  String get weekdaySundayShort => '周日';

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
  String get privacyNoVideoStorage => '当启用“保持视频查看”时，锻炼视频仅存储在此设备上。';

  @override
  String get privacyNoUpload => '相机帧不会上传到服务器。';

  @override
  String get privacyStoredData => '该设备上存储的数据';

  @override
  String get privacyStoredDataDescription =>
      'MotionFit 存储锻炼时间、组数、保持秒数和表格结果，以便您可以查看您的进度。';

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
  String get appInfoDescription => 'MotionFit 计时平板支撑并提供私人的、设备上的身体调整指导。';

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
  String get errorWholeBody => '检查肩链、髋链和膝链。';

  @override
  String get errorMultiplePeople => '视野中不止一个人。画面中仅保留一个人。';

  @override
  String get errorTrackingLost => '训练仍在继续，而检测仍在继续尝试。';

  @override
  String get errorDatabaseSave => '无法保存您的锻炼。';

  @override
  String get errorTtsVoiceMissing => '该设备上未安装语音。';

  @override
  String get errorTtsLocaleUnsupported => '此设备上所选语言不支持语音指导。';

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
  String get formScore => '姿势评分';

  @override
  String get formShort => '姿势';

  @override
  String formScoreValue(int score) {
    return '$score 分';
  }

  @override
  String get formIssueDepth => '髋关节对齐';

  @override
  String get formIssueTorsoLean => '身体线条';

  @override
  String get formIssueHeelLift => '足部稳定性';

  @override
  String get formIssueKneeAlignment => '腿部伸展';

  @override
  String get formIssueBalance => '身体稳定性';

  @override
  String get formIssueDescentSpeed => '位置控制';

  @override
  String get formIssueAscentSpeed => '位置控制';

  @override
  String get formIssueControl => '保持稳定性';

  @override
  String get formIssueStandingCompletion => '笔直的身体线条';

  @override
  String get formIssueNotObservable => '从这个相机角度无法评估';

  @override
  String get formStrengthDepth => '臀部对齐';

  @override
  String get formStrengthControl => '稳住';

  @override
  String get formStrengthBalance => '稳定的车身线条';

  @override
  String get coachTrackingLost1 => '当我不断检测时，你的锻炼仍在进行。';

  @override
  String get coachTrackingLost2 => '短暂的遮挡不会暂停您的锻炼。';

  @override
  String get coachWholeBody1 => '保持肩膀、臀部、膝盖和脚踝可见。';

  @override
  String get coachWholeBody2 => '向侧面移动，这样我就能看到你完整的平板支撑练习。';

  @override
  String get coachMultiplePeople1 => '画面中只保留一个人，这样我就能追踪到你。';

  @override
  String get coachReady1 => '你已经就位了。让我们开始吧。';

  @override
  String get coachReady2 => '位置很好。坚持平板支撑练习。';

  @override
  String coachStartSet(int set) {
    return '设置$set。我们走吧。';
  }

  @override
  String coachSevenDayChallengeStart(int day) {
    return '七日挑战的起始日 $day。';
  }

  @override
  String coachCumulativeChallengeStart(int completed, int remaining) {
    return '开始累积秒数挑战。您已完成 $completed 秒，还剩 $remaining 秒。';
  }

  @override
  String coachRepCount(int count) {
    return '$count秒';
  }

  @override
  String get coachDepth1 => '将臀部与肩膀对齐。';

  @override
  String get coachDepth2 => '保持臀部在一条直线上。';

  @override
  String get coachTorso1 => '支撑你的核心并保持背部挺直。';

  @override
  String get coachTorso2 => '保持肩膀和臀部水平。';

  @override
  String get coachHeel1 => '通过脚后跟向后压。';

  @override
  String get coachHeel2 => '保持双脚稳定。';

  @override
  String get coachKnees1 => '轻轻伸直双腿。';

  @override
  String get coachKnees2 => '保持膝盖伸展，而不是锁定。';

  @override
  String get coachBalance1 => '保持体重居中。';

  @override
  String get coachBalance2 => '保持稳定，不要左右移动。';

  @override
  String get coachDescendSlow1 => '控制好平板支撑的锻炼位置。';

  @override
  String get coachDescendSlow2 => '平稳地移动至对齐位置。';

  @override
  String get coachDescendFaster1 => '返回直板支撑练习。';

  @override
  String get coachDescendFaster2 => '重置您的对齐方式并继续按住。';

  @override
  String get coachAscendControlled1 => '稍微降低臀部并保持控制。';

  @override
  String get coachAscendControlled2 => '保持臀部与肩膀齐平。';

  @override
  String get coachAscendFaster1 => '将臀部稍微抬起成一条线。';

  @override
  String get coachAscendFaster2 => '让你的臀部恢复对齐。';

  @override
  String get coachControl1 => '保持稳定并保持呼吸。';

  @override
  String get coachControl2 => '支撑你的核心并尽量减少运动。';

  @override
  String get coachStandTall1 => '拉长你的身体，从肩膀到脚后跟。';

  @override
  String get coachStandTall2 => '保持双腿和背部在一条线上。';

  @override
  String get coachGood1 => '握得好。继续呼吸。';

  @override
  String get coachGood2 => '强对齐。继续持有。';

  @override
  String get coachGood3 => '稳定的平板支撑练习。继续努力吧。';

  @override
  String get coachLastTwo => '还剩两秒。坚强点！';

  @override
  String get coachLastOne => '还剩一秒。坚强地完成！';

  @override
  String coachSetComplete(int set) {
    return '伟大的。设置$set完成。';
  }

  @override
  String coachRestStart(int seconds) {
    return '休息 $seconds 秒。呼吸并重置。';
  }

  @override
  String get coachRestTenSeconds => '还剩十秒休息时间。';

  @override
  String get coachRestComplete => '休息结束了。为下一组做好准备。';

  @override
  String coachWorkoutComplete(int reps) {
    return '锻炼完成。您进行了平板支撑练习 $reps 秒。';
  }

  @override
  String get notificationReminderTitle => '今天的平板支撑练习时间到了';

  @override
  String get notificationReminderBody => '即使是短暂的会议也很重要。准备好后打开 MotionFit。';

  @override
  String get notificationReminderBodyVariant2 => '简短的集中平板支撑练习可以让今天的运动发挥作用。';

  @override
  String notificationStreakReminderBody(int days) {
    return '今天通过简短的训练来保持您的 $days 天连续活力。';
  }

  @override
  String get semanticsIncrease => '增加';

  @override
  String get semanticsDecrease => '减少';

  @override
  String semanticsSelectedTab(String tab) {
    return '选定的选项卡：$tab';
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
    return '$target 的电流重复 $current';
  }

  @override
  String get repVideoReviewTitle => '平板支撑练习视频回顾';

  @override
  String get repVideoReviewDescription => '将此锻炼视频保存在您的设备上以查看每个保持部分。';

  @override
  String get repVideoLocalOnly => '仅本地·从未上传';

  @override
  String get formReviewTitle => '表格审核';

  @override
  String get formReviewMainIssue => '主要问题';

  @override
  String get viewRepTimeline => '查看保留时间线';

  @override
  String get repTimelineTitle => '平板支撑练习回顾';

  @override
  String get repTimelineAll => '全部';

  @override
  String get repTimelineImprove => '提升';

  @override
  String get repTimelineNoImprovement => '没有保持部分需要改进。';

  @override
  String repSetNumber(int number) {
    return '设置$number';
  }

  @override
  String repNumber(int number) {
    return '第二个$number';
  }

  @override
  String get repResultGood => '状态好';

  @override
  String get repResultNeedsAttention => '需要注意';

  @override
  String get repResultImproved => '比上一段更好';

  @override
  String get repResultNotAssessed => '难以评估';

  @override
  String get repIssueShallowDepth => '将臀部与肩膀对齐';

  @override
  String get repIssueForwardLean => '身体线条错位';

  @override
  String get repIssueKneesInward => '腿没有完全伸展';

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
  String get repPrevious => '上一段';

  @override
  String get repNext => '下一段';

  @override
  String get repFeedbackGood => '您的身体保持在 MotionFit 可以评估的平板支撑运动对准范围内。';

  @override
  String get repFeedbackDepth => '你的臀部偏离了一条直线。保持肩膀、臀部和脚跟对齐。';

  @override
  String get repFeedbackTorso => '你的身体线条发生了变化。支撑你的核心并保持背部挺直。';

  @override
  String get repFeedbackKnees => '在保持过程中你的膝盖弯曲。轻轻拉长双腿。';

  @override
  String repFeedbackGeneric(String area) {
    return '这第二点在$area中需要注意。';
  }

  @override
  String get deleteWorkoutVideo => '删除锻炼视频';

  @override
  String get deleteWorkoutVideoTitle => '删除这个锻炼视频吗？';

  @override
  String get deleteWorkoutVideoBody => '仅删除本地视频。保留分析和锻炼记录。';

  @override
  String get workoutVideoDeleted => '锻炼视频已删除';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class PlankLocalizationsZhHant extends PlankLocalizationsZh {
  PlankLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appName => 'motionfit - workout coach';

  @override
  String get navSquat => '平板支撐練習';

  @override
  String get navChallenge => '挑戰';

  @override
  String get navRecords => '進步';

  @override
  String get navSettings => '設定';

  @override
  String get challengeTitle => '我的平板支撐練習挑戰';

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
  String get challengeDailyGoal => '每日第二個目標';

  @override
  String get challengeSevenDayStart => '開始7天挑戰';

  @override
  String get challengeSevenDaySettings => '設定您的 7 天目標';

  @override
  String get challengeSevenDaySettingsDescription => '選擇第 1 天。目標每天增加 5 秒。';

  @override
  String get challengeFirstDayGoal => '第 1 天目標秒數';

  @override
  String challengeSevenDayPreview(int first, int last) {
    return '第 1 天：$first 秒 → 第 7 天：$last 秒';
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
  String get challengeCumulativeTitle => '總秒數挑戰';

  @override
  String get challengeCumulativeDescription => '按照適合您的時間表達到平板支撐總運動目標';

  @override
  String get challengeCumulativeSummary => '選擇持續時間和總目標；休息日讓你進步。';

  @override
  String get challengePreset200 => '7天內200秒平板支撐運動';

  @override
  String get challengePreset500 => '14天內500秒平板支撐運動';

  @override
  String get challengeCustomGoal => '選擇您自己的持續時間和目標';

  @override
  String get challengeRestWithoutReset => '休息日不會重置進度';

  @override
  String get challengeCumulativeStart => '開始總秒數挑戰';

  @override
  String get challengeHistoryTitle => '過去的挑戰';

  @override
  String get challengeHistoryEmpty => '您已完成和結束的挑戰將顯示在此。';

  @override
  String get challengeRecommended => '為您推薦';

  @override
  String challengeRecommendationFromWorkout(int reps) {
    return '從您第一次鍛鍊 $reps 秒開始推薦。';
  }

  @override
  String get challengeRecommendationDefault => '建議您以 7 天的溫和時間開始第一次挑戰。';

  @override
  String get challengeActive => '主動挑戰';

  @override
  String get challengeNext => '下一個';

  @override
  String challengeDayNumber(int day) {
    return '日 $day';
  }

  @override
  String get challengeRecoveryDay => '康復日';

  @override
  String challengeTodayProgress(int current, int target) {
    return '今日 $current / $target 秒';
  }

  @override
  String get challengeRestToday => '今天需要時間恢復。';

  @override
  String get challengeTodayCompleted => '今天的目標完成·明天繼續';

  @override
  String challengeRepsRemaining(int reps) {
    return '$reps 還剩幾秒鐘';
  }

  @override
  String challengeWeekNumber(int week) {
    return '週 $week';
  }

  @override
  String challengeThisWeekProgress(int current, int target) {
    return '本週 $current / $target 鍛煉';
  }

  @override
  String challengeOverallDays(int current, int target) {
    return '總計 $current / $target 天';
  }

  @override
  String challengeRepsProgress(int current, int target) {
    return '$current / $target 秒';
  }

  @override
  String challengeDaysRemaining(int days) {
    return '$days 剩餘天數';
  }

  @override
  String challengeTodaySuggested(int reps) {
    return '今天建議：$reps 秒';
  }

  @override
  String challengePercent(int percent) {
    return '$percent 完成%';
  }

  @override
  String get challengeSquatStart => '開始平板支撐練習';

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
  String get challengeGoalLabel => '目標秒數';

  @override
  String get challengeNotFound => '此挑戰不再可用。';

  @override
  String get challengePeriod => '時期';

  @override
  String get challengeStatus => '地位';

  @override
  String get challengeTotalReps => '平板支撐運動總秒數';

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
  String get challengeReminderNotificationTitle => '你的平板支撐練習挑戰正在等待著';

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
  String get commonDone => '完成';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '關閉';

  @override
  String get commonRetry => '再試一次';

  @override
  String get commonSave => '儲存';

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
  String get commonOn => '開啟';

  @override
  String get commonOff => '關閉';

  @override
  String get commonEnabled => '啟用';

  @override
  String get commonDisabled => '已關閉';

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
    return '$count 秒';
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
    return '$hours 小時 $minutes 分鐘';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes 分 $seconds 秒';
  }

  @override
  String get homeGreeting => '準備好開始了嗎？';

  @override
  String get homeTodayTitle => '今天的記錄';

  @override
  String get homeTodayNoWorkout => '今天還沒有進行平板支撐練習。簡短的一組是一個很好的開始。';

  @override
  String homeTodaySummary(int reps, int sets) {
    return '$reps 平板支撐練習 秒跨 $sets';
  }

  @override
  String get homeViewResult => '查看結果';

  @override
  String get homeTodaySets => '今天設定';

  @override
  String get homeTodayReps => '今天秒數';

  @override
  String get streakLabel => '連續記錄';

  @override
  String streakDays(int days) {
    return '$days天';
  }

  @override
  String get homeWorkoutSetup => '下次鍛鍊';

  @override
  String get homeSetsLabel => '套';

  @override
  String get homeRepsPerSetLabel => '每組秒數';

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
    return '選擇 $min 到 $max 之間的值。';
  }

  @override
  String get guideTitle => '設定您的相機';

  @override
  String get guideLandscapeTitle => '將手機橫過來';

  @override
  String get guideLandscapeBody => '平板支撐運動追蹤使用橫向模式。在就位之前將手機水平放置。';

  @override
  String get countdownLandscapePrompt => '將手機保持橫向模式';

  @override
  String get guideSubtitle => '讓您的肩膀、臀部、膝蓋和腳踝保持可見，以便 MotionFit 可以測量您的平板支撐運動。';

  @override
  String get guideWholeBody => '將相機放在側面，讓您的全身可見。';

  @override
  String get guideStableCamera => '將手機放在穩定的地方。';

  @override
  String get guideOnePerson => '確保框架內只有一個人。';

  @override
  String get guideCameraAngle => '使用側視圖或略微傾斜的側視圖。';

  @override
  String get guideLighting => '避免黑暗的房間和強烈的背光。';

  @override
  String get guidePrivacy => '影片保留在此裝置上，僅在「保留影片審閱」開啟時才會儲存。';

  @override
  String get guideContinue => '我已就位';

  @override
  String get permissionCameraTitle => '需要相機存取權限';

  @override
  String get permissionCameraBody =>
      'MotionFit 使用攝影機計算平板支撐運動的秒數。當您開啟「保留影片檢視」時，影片僅儲存在此裝置上。';

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
    return '從 $seconds 開始';
  }

  @override
  String get calibrationTitle => '找到你的平板支撐運動位置';

  @override
  String get calibrationBody => '進行直板支撐練習，並看到整個身體。';

  @override
  String get calibrationStayStill => '保持身體挺直片刻';

  @override
  String get calibrationComplete => '一切就緒';

  @override
  String get calibrationFailed => '我們無法偵測到明確的平板支撐練習位置。';

  @override
  String get calibrationRetry => '重新校準';

  @override
  String workoutSetProgress(int current, int total) {
    return '設定 $total 的 $current';
  }

  @override
  String workoutRepProgress(int current, int target) {
    return '$current 之 $target';
  }

  @override
  String workoutTotalReps(int count) {
    return '總計$count';
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
  String get workoutStateReady => '就位';

  @override
  String get workoutStateDescending => '檢查對齊情況';

  @override
  String get workoutStateBottom => '保持穩定';

  @override
  String get workoutStateAscending => '重新調整你的身體';

  @override
  String get workoutStateCompleted => '保持一秒';

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
    return '下一篇：設定$set 之 $total';
  }

  @override
  String get restCompletedSets => '已完成的套裝';

  @override
  String get restTotalReps => '到目前為止平板支撐運動時間';

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
  String get completeTotalReps => '平板支撐運動總秒數';

  @override
  String get completeCompletedSets => '套數已完成';

  @override
  String get completeActiveTime => '活躍時間';

  @override
  String get completeRestTime => '休息時間';

  @override
  String get completeTotalTime => '總時間';

  @override
  String get completeAverageRepTime => '平均保持檢查點';

  @override
  String get completeFormSummary => '表格摘要';

  @override
  String get todayCoaching => '今天的輔導';

  @override
  String coachingIssueFrequency(int total, int count, String issue) {
    return '在 $total 秒的 $count 中，\n$issue';
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
    return '您想從明天開始在 $time 上收到每日提醒嗎？';
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
    return '$count 鍛煉';
  }

  @override
  String recordsAverageForm(int score) {
    return '平均形式 $score';
  }

  @override
  String recordsWorkoutTime(String time) {
    return '時間 $time';
  }

  @override
  String get recordsFirstWeek => '這是您本週的第一張唱片';

  @override
  String recordsMoreThanLastWeek(int count) {
    return '$count 比上週多秒';
  }

  @override
  String recordsLessThanLastWeek(int count) {
    return '$count 比上週少了幾秒鐘';
  }

  @override
  String get recordsSameAsLastWeek => '成交量與上週持平';

  @override
  String get recordsTrendEmpty => '完成更多運動以了解您的體形趨勢。';

  @override
  String get recordsFirstFormScore => '第一形式成績';

  @override
  String recordsRecentAverage(int count, int score) {
    return '最後$count 平均$score';
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
  String get recordsFormTrend => '形式趨勢';

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
    return '會話 $number';
  }

  @override
  String get recordsListNewest => '最新的優先';

  @override
  String get recordsOpenDetail => '看詳情';

  @override
  String get recordsEmptyTitle => '還沒有鍛煉';

  @override
  String get recordsEmptyBody => '完成您的第一次平板支撐鍛煉，它將出現在此處。';

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
  String get statsTotalReps => '平板支撐運動總秒數';

  @override
  String get statsWorkoutDays => '運動日';

  @override
  String get statsTotalActiveTime => '活躍時間';

  @override
  String get statsAverageSets => '平均組數';

  @override
  String get statsAverageReps => '平板支撐平均運動秒數';

  @override
  String get statsDailyReps => '平板支撐每天的運動時間';

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
  String get detailSetBreakdown => '以秒計算';

  @override
  String get detailTotalReps => '平板支撐運動總秒數';

  @override
  String get detailAverageRep => '平均保持檢查點';

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
    return '設定$set：$reps秒';
  }

  @override
  String detailSessionOn(String date, String time) {
    return '$date 在 $time';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsRateApp => '評價這個應用程式';

  @override
  String get settingsRateAppSubtitle => '評價 MotionFit';

  @override
  String get settingsRateAppError => '無法開啟 App Store，請再試一次。';

  @override
  String get settingsSectionGeneral => '一般';

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
  String get themeLight => '淺色';

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
  String get languageChanged => '語言已更新';

  @override
  String get voiceCoachingEnabled => '語音輔導';

  @override
  String get voiceRepCountEnabled => '說第二次數';

  @override
  String get voiceFormEnabled => '表格提示';

  @override
  String get voiceEncouragementEnabled => '鼓勵';

  @override
  String get voiceRate => '語速';

  @override
  String get voiceRateSlow => '慢';

  @override
  String get voiceRateNormal => '正常';

  @override
  String get voiceRateFast => '快';

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
    return '從 $day 複製時間';
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
  String get weekdaySundayShort => '週日';

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
  String get privacyNoVideoStorage => '當啟用「保持影片檢視」時，鍛鍊影片僅儲存在此裝置上。';

  @override
  String get privacyNoUpload => '相機幀不會上傳到伺服器。';

  @override
  String get privacyStoredData => '該設備上儲存的數據';

  @override
  String get privacyStoredDataDescription =>
      'MotionFit 儲存鍛鍊時間、組數、保持秒數和表格結果，以便您可以查看您的進度。';

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
  String get appInfoDescription => 'MotionFit 計時平板支撐並提供私人的、設備上的身體調整指導。';

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
  String get errorWholeBody => '檢查肩鏈、髖鍊和膝鏈。';

  @override
  String get errorMultiplePeople => '視野中不只一個人。畫面中僅保留一個人。';

  @override
  String get errorTrackingLost => '訓練仍在繼續，而檢測仍在繼續嘗試。';

  @override
  String get errorDatabaseSave => '無法保存您的鍛鍊。';

  @override
  String get errorTtsVoiceMissing => '該設備上未安裝語音。';

  @override
  String get errorTtsLocaleUnsupported => '此裝置上所選語言不支援語音指導。';

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
  String get formScore => '姿勢評分';

  @override
  String get formShort => '姿勢';

  @override
  String formScoreValue(int score) {
    return '$score 分';
  }

  @override
  String get formIssueDepth => '髖關節對齊';

  @override
  String get formIssueTorsoLean => '身體線條';

  @override
  String get formIssueHeelLift => '足部穩定性';

  @override
  String get formIssueKneeAlignment => '腿部伸展';

  @override
  String get formIssueBalance => '身體穩定性';

  @override
  String get formIssueDescentSpeed => '位置控制';

  @override
  String get formIssueAscentSpeed => '位置控制';

  @override
  String get formIssueControl => '保持穩定性';

  @override
  String get formIssueStandingCompletion => '筆直的身體線條';

  @override
  String get formIssueNotObservable => '從這個相機角度無法評估';

  @override
  String get formStrengthDepth => '臀部對齊';

  @override
  String get formStrengthControl => '穩住';

  @override
  String get formStrengthBalance => '穩定的車身線條';

  @override
  String get coachTrackingLost1 => '當我不斷檢測時，你的鍛鍊仍在進行中。';

  @override
  String get coachTrackingLost2 => '短暫的遮蔽不會暫停您的運動。';

  @override
  String get coachWholeBody1 => '保持肩膀、臀部、膝蓋和腳踝可見。';

  @override
  String get coachWholeBody2 => '向側面移動，這樣我就能看到你完整的平板支撐練習。';

  @override
  String get coachMultiplePeople1 => '畫面中只保留一個人，這樣我就能追蹤到你。';

  @override
  String get coachReady1 => '你已經就位了。讓我們開始吧。';

  @override
  String get coachReady2 => '位置很好。堅持平板支撐練習。';

  @override
  String coachStartSet(int set) {
    return '設定$set。我們走吧。';
  }

  @override
  String coachSevenDayChallengeStart(int day) {
    return '七日挑戰的起始日 $day。';
  }

  @override
  String coachCumulativeChallengeStart(int completed, int remaining) {
    return '開始累積秒數挑戰。您已完成 $completed 秒，還剩 $remaining 秒。';
  }

  @override
  String coachRepCount(int count) {
    return '$count秒';
  }

  @override
  String get coachDepth1 => '將臀部與肩膀對齊。';

  @override
  String get coachDepth2 => '保持臀部成一直線。';

  @override
  String get coachTorso1 => '支撐你的核心並保持背部挺直。';

  @override
  String get coachTorso2 => '保持肩膀和臀部水平。';

  @override
  String get coachHeel1 => '透過腳跟向後壓。';

  @override
  String get coachHeel2 => '保持雙腳穩定。';

  @override
  String get coachKnees1 => '輕輕伸直雙腿。';

  @override
  String get coachKnees2 => '保持膝蓋伸展，而不是鎖住。';

  @override
  String get coachBalance1 => '保持體重居中。';

  @override
  String get coachBalance2 => '保持穩定，不要左右移動。';

  @override
  String get coachDescendSlow1 => '控制好平板支撐的運動位置。';

  @override
  String get coachDescendSlow2 => '平穩地移動至對齊位置。';

  @override
  String get coachDescendFaster1 => '返回直板支撐練習。';

  @override
  String get coachDescendFaster2 => '重置您的對齊方式並繼續按住。';

  @override
  String get coachAscendControlled1 => '稍微降低臀部並保持控制。';

  @override
  String get coachAscendControlled2 => '保持臀部與肩膀齊平。';

  @override
  String get coachAscendFaster1 => '將臀部稍微抬起成一條線。';

  @override
  String get coachAscendFaster2 => '讓你的臀部恢復對齊。';

  @override
  String get coachControl1 => '保持穩定並保持呼吸。';

  @override
  String get coachControl2 => '支撐你的核心並盡量減少運動。';

  @override
  String get coachStandTall1 => '拉長你的身體，從肩膀到腳跟。';

  @override
  String get coachStandTall2 => '保持雙腿和背部在一條線上。';

  @override
  String get coachGood1 => '握得好。繼續呼吸。';

  @override
  String get coachGood2 => '強對齊。繼續持有。';

  @override
  String get coachGood3 => '穩定的平板支撐練習。繼續努力吧。';

  @override
  String get coachLastTwo => '還剩兩秒。堅強點！';

  @override
  String get coachLastOne => '還剩一秒鐘。堅強地完成！';

  @override
  String coachSetComplete(int set) {
    return '偉大的。設定$set完成。';
  }

  @override
  String coachRestStart(int seconds) {
    return '休息 $seconds 秒。呼吸並重置。';
  }

  @override
  String get coachRestTenSeconds => '還剩十秒休息時間。';

  @override
  String get coachRestComplete => '休息結束了。為下一組做好準備。';

  @override
  String coachWorkoutComplete(int reps) {
    return '鍛煉完成。您進行了平板支撐練習 $reps 秒。';
  }

  @override
  String get notificationReminderTitle => '今天的平板支撐練習時間到了';

  @override
  String get notificationReminderBody => '即使是短暫的會議也很重要。準備好後打開 MotionFit。';

  @override
  String get notificationReminderBodyVariant2 => '簡短的集中平板支撐練習可以讓今天的運動發揮作用。';

  @override
  String notificationStreakReminderBody(int days) {
    return '今天就透過簡短的訓練來保持您的 $days 天連續活力。';
  }

  @override
  String get semanticsIncrease => '增加';

  @override
  String get semanticsDecrease => '減少';

  @override
  String semanticsSelectedTab(String tab) {
    return '選定的選項卡：$tab';
  }

  @override
  String semanticsCalendarWorkoutDate(String date) {
    return '$date，運動紀錄';
  }

  @override
  String semanticsCalendarEmptyDate(String date) {
    return '$date，沒有鍛煉';
  }

  @override
  String semanticsCurrentRep(int current, int target) {
    return '$target 的電流重複 $current';
  }

  @override
  String get repVideoReviewTitle => '平板支撐練習影片回顧';

  @override
  String get repVideoReviewDescription => '將此鍛鍊影片儲存在您的裝置上以查看每個保持部分。';

  @override
  String get repVideoLocalOnly => '僅本地·從未上傳';

  @override
  String get formReviewTitle => '表格審核';

  @override
  String get formReviewMainIssue => '主要問題';

  @override
  String get viewRepTimeline => '查看保留時間軸';

  @override
  String get repTimelineTitle => '平板支撐練習回顧';

  @override
  String get repTimelineAll => '全部';

  @override
  String get repTimelineImprove => '提升';

  @override
  String get repTimelineNoImprovement => '沒有保持部分需要改進。';

  @override
  String repSetNumber(int number) {
    return '設定$number';
  }

  @override
  String repNumber(int number) {
    return '第二個$number';
  }

  @override
  String get repResultGood => '狀態好';

  @override
  String get repResultNeedsAttention => '需要注意';

  @override
  String get repResultImproved => '比上一段更好';

  @override
  String get repResultNotAssessed => '難以評估';

  @override
  String get repIssueShallowDepth => '將臀部與肩膀對齊';

  @override
  String get repIssueForwardLean => '身體線條錯位';

  @override
  String get repIssueKneesInward => '腿沒有完全伸展';

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
  String get repPrevious => '上一段';

  @override
  String get repNext => '下一段';

  @override
  String get repFeedbackGood => '您的身體保持在 MotionFit 可以評估的平板支撐運動對準範圍內。';

  @override
  String get repFeedbackDepth => '你的臀部偏離了一條直線。保持肩膀、臀部和腳跟對齊。';

  @override
  String get repFeedbackTorso => '你的身體線條發生了變化。支撐你的核心並保持背部挺直。';

  @override
  String get repFeedbackKnees => '在保持過程中你的膝蓋彎曲。輕輕拉長雙腿。';

  @override
  String repFeedbackGeneric(String area) {
    return '這第二點在$area中需要注意。';
  }

  @override
  String get deleteWorkoutVideo => '刪除鍛煉視頻';

  @override
  String get deleteWorkoutVideoTitle => '刪除這個運動影片嗎？';

  @override
  String get deleteWorkoutVideoBody => '僅刪除本地影片。保留分析和鍛鍊記錄。';

  @override
  String get workoutVideoDeleted => '鍛鍊影片已刪除';
}
