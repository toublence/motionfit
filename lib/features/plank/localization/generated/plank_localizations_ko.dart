// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'plank_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class PlankLocalizationsKo extends PlankLocalizations {
  PlankLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'MotionFit - Plank';

  @override
  String get navSquat => '플랭크';

  @override
  String get navChallenge => '챌린지';

  @override
  String get navRecords => '성장';

  @override
  String get navSettings => '설정';

  @override
  String get challengeTitle => '나만의 플랭크 챌린지';

  @override
  String get challengeSubtitle => '목표에 맞는 챌린지를 선택하고 꾸준히 운동해보세요.';

  @override
  String get challengeChooseTitle => '챌린지 선택';

  @override
  String get challengeSevenDayTitle => '7일 시작 챌린지';

  @override
  String get challengeSevenDayDescription => '처음 시작하는 사용자를 위한 단계별 프로그램';

  @override
  String get challengeSevenDaySummary => '7일 동안 매일 늘어나는 수준별 목표에 도전해요.';

  @override
  String get challengeSevenDayEveryDay => '회복일 없이 7일간 매일 진행';

  @override
  String challengeDurationDays(int days) {
    return '$days일';
  }

  @override
  String get challengeLevelGoals => '사용자 수준별 목표';

  @override
  String get challengeRecoveryIncluded => '회복일 포함';

  @override
  String get challengeDailyGoal => '일일 시간 목표';

  @override
  String get challengeSevenDayStart => '7일 챌린지 시작';

  @override
  String get challengeSevenDaySettings => '7일 목표 설정';

  @override
  String get challengeSevenDaySettingsDescription =>
      '1일차 목표를 정하면 이후 목표가 매일 5초씩 늘어납니다.';

  @override
  String get challengeFirstDayGoal => '1일차 목표 시간';

  @override
  String challengeSevenDayPreview(int first, int last) {
    return '1일차 $first초 → 7일차 $last초';
  }

  @override
  String get challengeWeeklyTitle => '주 3회 챌린지';

  @override
  String get challengeWeeklyDescription => '매일 운동하기 부담스러운 사용자를 위한 습관 챌린지';

  @override
  String get challengeWeeklySummary => '4주 동안 선택한 요일에 일주일 3회 운동해요.';

  @override
  String challengeDurationWeeks(int weeks) {
    return '$weeks주';
  }

  @override
  String get challengeThreePerWeek => '일주일에 3회';

  @override
  String get challengeChooseWeekdays => '운동 요일 3개 선택';

  @override
  String get challengeWorkoutDaysCount => '운동한 날짜를 기준으로 진행';

  @override
  String get challengeWeeklyStart => '주 3회 챌린지 시작';

  @override
  String get challengeCumulativeTitle => '누적 시간 챌린지';

  @override
  String get challengeCumulativeDescription => '원하는 일정에 맞춰 총 플랭크 시간을 달성하는 챌린지';

  @override
  String get challengeCumulativeSummary => '기간과 총시간를 정하고 쉬는 날에도 진행률을 유지해요.';

  @override
  String get challengePreset200 => '7일 동안 200초';

  @override
  String get challengePreset500 => '14일 동안 500초';

  @override
  String get challengeCustomGoal => '기간과 목표 직접 설정';

  @override
  String get challengeRestWithoutReset => '하루를 쉬어도 계속 진행 가능';

  @override
  String get challengeCumulativeStart => '누적 챌린지 시작';

  @override
  String get challengeHistoryTitle => '지난 챌린지';

  @override
  String get challengeHistoryEmpty => '완료하거나 종료한 챌린지가 여기에 표시됩니다.';

  @override
  String get challengeRecommended => '추천 챌린지';

  @override
  String challengeRecommendationFromWorkout(int reps) {
    return '첫 운동 $reps초를 기준으로 추천했어요.';
  }

  @override
  String get challengeRecommendationDefault => '첫 챌린지로 가볍게 시작하는 7일 코스를 추천해요.';

  @override
  String get challengeActive => '진행 중인 챌린지';

  @override
  String get challengeNext => '다음 목표';

  @override
  String challengeDayNumber(int day) {
    return '$day일 차';
  }

  @override
  String get challengeRecoveryDay => '회복일';

  @override
  String challengeTodayProgress(int current, int target) {
    return '오늘 $current / $target초';
  }

  @override
  String get challengeRestToday => '오늘은 충분히 회복하세요.';

  @override
  String get challengeTodayCompleted => '오늘 목표 완료 · 내일 다시 진행해요';

  @override
  String challengeRepsRemaining(int reps) {
    return '목표까지 $reps초';
  }

  @override
  String challengeWeekNumber(int week) {
    return '$week주 차';
  }

  @override
  String challengeThisWeekProgress(int current, int target) {
    return '이번 주 $current / $target회';
  }

  @override
  String challengeOverallDays(int current, int target) {
    return '전체 $current / $target일';
  }

  @override
  String challengeRepsProgress(int current, int target) {
    return '$current / $target초';
  }

  @override
  String challengeDaysRemaining(int days) {
    return '$days일 남음';
  }

  @override
  String challengeTodaySuggested(int reps) {
    return '오늘 권장 목표 $reps초';
  }

  @override
  String challengePercent(int percent) {
    return '$percent% 완료';
  }

  @override
  String get challengeSquatStart => '플랭크 시작';

  @override
  String get challengeTodayWorkoutStart => '오늘 운동 시작';

  @override
  String get challengeViewDetails => '상세 보기';

  @override
  String get challengeRestart => '다시 시작';

  @override
  String get challengeDeleteHistory => '히스토리에서 삭제';

  @override
  String get challengeCumulativeSettings => '누적 목표 설정';

  @override
  String get challengeDurationLabel => '기간';

  @override
  String get challengeGoalLabel => '목표 시간';

  @override
  String get challengeNotFound => '이 챌린지를 찾을 수 없습니다.';

  @override
  String get challengePeriod => '진행 기간';

  @override
  String get challengeStatus => '상태';

  @override
  String get challengeTotalReps => '누적 플랭크 시간';

  @override
  String get challengeWorkoutDays => '운동한 날짜';

  @override
  String challengeDaysCount(int days) {
    return '$days일';
  }

  @override
  String get challengeTotalTime => '총 운동 시간';

  @override
  String get challengeSchedule => '일정 및 진행 상황';

  @override
  String get challengeNotifications => '챌린지 알림';

  @override
  String get challengeNotificationsDescription => '이 챌린지의 알림 설정을 저장합니다.';

  @override
  String get challengeReminderNotificationTitle => '플랭크 챌린지를 이어갈 시간이에요';

  @override
  String get challengeReminderNotificationBody =>
      'MotionFit을 열고 오늘의 챌린지 목표를 향해 운동해보세요.';

  @override
  String get challengeSelectedWeekdays => '선택한 운동 요일';

  @override
  String get challengeNoProgressYet => '아직 챌린지 운동 기록이 없습니다.';

  @override
  String get challengeCancel => '챌린지 종료';

  @override
  String get challengeCancelTitle => '챌린지를 종료할까요?';

  @override
  String get challengeCancelDescription => '운동 기록은 유지되며 챌린지는 지난 챌린지로 이동합니다.';

  @override
  String get challengeStatusActive => '진행 중';

  @override
  String get challengeStatusCompleted => '완료';

  @override
  String get challengeStatusEnded => '종료';

  @override
  String get challengeStatusCancelled => '사용자 취소';

  @override
  String get challengeProgressUpdated => '챌린지 진행률이 업데이트되었어요.';

  @override
  String get challengeCheck => '챌린지 확인';

  @override
  String get commonDone => '완료';

  @override
  String get commonCancel => '취소';

  @override
  String get commonClose => '닫기';

  @override
  String get commonRetry => '다시 시도';

  @override
  String get commonSave => '저장';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonConfirm => '확인';

  @override
  String get commonBack => '뒤로';

  @override
  String get commonContinue => '계속';

  @override
  String get commonStart => '시작';

  @override
  String get commonSkip => '건너뛰기';

  @override
  String get commonEdit => '편집';

  @override
  String get commonOn => '켜짐';

  @override
  String get commonOff => '꺼짐';

  @override
  String get commonEnabled => '사용';

  @override
  String get commonDisabled => '사용 안 함';

  @override
  String get commonNotAvailable => '사용할 수 없음';

  @override
  String get commonToday => '오늘';

  @override
  String get commonYesterday => '어제';

  @override
  String get commonLoading => '불러오는 중…';

  @override
  String unitSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count세트',
    );
    return '$_temp0';
  }

  @override
  String unitReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count초',
    );
    return '$_temp0';
  }

  @override
  String unitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count초',
    );
    return '$_temp0';
  }

  @override
  String unitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count분',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes분 $seconds초';
  }

  @override
  String get homeGreeting => '움직일 준비가 되셨나요?';

  @override
  String get homeTodayTitle => '오늘 기록';

  @override
  String get homeTodayNoWorkout => '오늘은 아직 운동하지 않았어요. 짧은 한 세트부터 시작해 보세요.';

  @override
  String homeTodaySummary(int reps, int sets) {
    return '플랭크 $reps초 · $sets세트';
  }

  @override
  String get homeViewResult => '결과 보기';

  @override
  String get homeTodaySets => '오늘 한 세트';

  @override
  String get homeTodayReps => '오늘 유지 시간';

  @override
  String get streakLabel => '연속 운동';

  @override
  String streakDays(int days) {
    return '$days일';
  }

  @override
  String get homeWorkoutSetup => '다음 운동';

  @override
  String get homeSetsLabel => '세트 수';

  @override
  String get homeRepsPerSetLabel => '세트당 시간';

  @override
  String get homeRestTimeLabel => '휴식 시간';

  @override
  String get homeDirectInputHint => '숫자를 입력하세요';

  @override
  String get homeStartWorkout => '운동 시작';

  @override
  String get homeLastSettingsRestored => '지난 운동 설정을 불러왔어요.';

  @override
  String get validationNumberRequired => '숫자를 입력해 주세요.';

  @override
  String validationRange(num min, num max) {
    return '$min에서 $max 사이의 값을 선택해 주세요.';
  }

  @override
  String get guideTitle => '카메라를 준비해 주세요';

  @override
  String get guideLandscapeTitle => '휴대폰을 가로로 돌려주세요';

  @override
  String get guideLandscapeBody =>
      '플랭크는 가로 화면으로 측정해요. 자세를 잡기 전에 휴대폰을 가로로 놓아주세요.';

  @override
  String get countdownLandscapePrompt => '휴대폰을 가로 방향으로 유지해 주세요';

  @override
  String get guideSubtitle => '어깨부터 발목까지 보이도록 옆으로 서면 플랭크 자세와 시간을 측정해요.';

  @override
  String get guideWholeBody => '몸 전체가 보이도록 카메라를 옆에 두세요.';

  @override
  String get guideStableCamera => '휴대폰을 흔들리지 않는 곳에 놓아주세요.';

  @override
  String get guideOnePerson => '화면에는 한 명만 나오게 해주세요.';

  @override
  String get guideCameraAngle => '옆면 또는 약간 비스듬한 옆면을 보여주세요.';

  @override
  String get guideLighting => '어두운 곳과 강한 역광은 피해주세요.';

  @override
  String get guidePrivacy => '영상은 기기에만 머물며 홀드 구간 영상 리뷰를 켠 경우에만 저장돼요.';

  @override
  String get guideContinue => '준비됐어요';

  @override
  String get permissionCameraTitle => '카메라 권한이 필요해요';

  @override
  String get permissionCameraBody =>
      'MotionFit은 플랭크 유지 시간과 자세를 측정하기 위해 카메라를 사용해요. 플랭크 영상 리뷰를 켠 경우에만 영상을 이 기기에 저장해요.';

  @override
  String get permissionCameraRequest => '계속';

  @override
  String get permissionCameraDenied => '카메라 권한이 거부되었어요. 기록과 설정은 계속 이용할 수 있어요.';

  @override
  String get permissionCameraPermanentlyDenied =>
      '운동을 시작하려면 시스템 설정에서 카메라 권한을 허용해 주세요.';

  @override
  String get permissionOpenSettings => '설정 열기';

  @override
  String get permissionNotificationTitle => '운동 알림을 허용할까요?';

  @override
  String get permissionNotificationBody => '알림은 사용자가 설정한 운동 리마인더에만 사용돼요.';

  @override
  String get permissionNotificationRequest => '알림 허용';

  @override
  String get permissionNotificationDenied =>
      '알림이 꺼져 있어요. 리마인더를 받으려면 시스템 설정에서 알림을 켜주세요.';

  @override
  String get countdownGetReady => '준비하세요';

  @override
  String countdownBeginsIn(int seconds) {
    return '$seconds초 후 시작';
  }

  @override
  String get calibrationTitle => '플랭크 자세를 찾는 중';

  @override
  String get calibrationBody => '몸 전체가 보이도록 곧은 플랭크 자세를 유지하세요.';

  @override
  String get calibrationStayStill => '잠시 몸을 일직선으로 유지하세요';

  @override
  String get calibrationComplete => '준비 완료';

  @override
  String get calibrationFailed => '선명한 플랭크 자세를 찾지 못했어요.';

  @override
  String get calibrationRetry => '다시 보정';

  @override
  String workoutSetProgress(int current, int total) {
    return '$current / $total세트';
  }

  @override
  String workoutRepProgress(int current, int target) {
    return '$current / $target초';
  }

  @override
  String workoutTotalReps(int count) {
    return '누적 $count초';
  }

  @override
  String get workoutElapsed => '운동 경과 시간';

  @override
  String get workoutPause => '일시정지';

  @override
  String get workoutResume => '운동 계속하기';

  @override
  String get workoutEnd => '운동 멈추기';

  @override
  String get workoutBackToSetup => '운동 설정으로 돌아가기';

  @override
  String get workoutEndDialogTitle => '운동을 멈출까요?';

  @override
  String get workoutEndDialogBody => '진행 중인 운동을 저장하고 홈에서 이어서 할 수 있어요.';

  @override
  String get workoutEndDialogConfirm => '저장하고 나가기';

  @override
  String get workoutPauseReasonBackground => '앱이 백그라운드로 이동해 운동을 일시정지했어요.';

  @override
  String get workoutPauseReasonInterruption => '시스템 중단으로 운동을 일시정지했어요.';

  @override
  String get workoutStateReady => '자세를 잡아주세요';

  @override
  String get workoutStateDescending => '정렬 확인 중';

  @override
  String get workoutStateBottom => '그대로 유지하세요';

  @override
  String get workoutStateAscending => '몸을 다시 정렬하세요';

  @override
  String get workoutStateCompleted => '1초 유지';

  @override
  String get workoutStateTrackingLost => '인식 계속 시도 중';

  @override
  String get workoutStatePaused => '일시정지됨';

  @override
  String get workoutTrackingGood => '관절 인식 중';

  @override
  String get workoutCameraSwitch => '카메라 전환';

  @override
  String get workoutSkeletonToggle => '자세 가이드 표시';

  @override
  String get restTitle => '휴식';

  @override
  String restNextSet(int set, int total) {
    return '다음: $set / $total세트';
  }

  @override
  String get restCompletedSets => '완료한 세트';

  @override
  String get restTotalReps => '현재까지 유지 시간';

  @override
  String get restSkip => '휴식 건너뛰기';

  @override
  String get restAddFifteenSeconds => '15초 추가';

  @override
  String get restEndWorkout => '운동 멈추기';

  @override
  String get restAlmostDone => '곧 시작해요';

  @override
  String get restReady => '다음 세트를 시작할 시간이에요';

  @override
  String get completeTitle => '운동 완료';

  @override
  String get completeSubtitle => '수고했어요. 이번 운동을 한눈에 확인해 보세요.';

  @override
  String get workoutInterruptedSubtitle => '일찍 마치기 전까지 기록된 내용을 확인해 보세요.';

  @override
  String get completeTotalReps => '총 플랭크 시간';

  @override
  String get completeCompletedSets => '완료 세트';

  @override
  String get completeActiveTime => '실제 운동 시간';

  @override
  String get completeRestTime => '총 휴식 시간';

  @override
  String get completeTotalTime => '전체 소요 시간';

  @override
  String get completeAverageRepTime => '평균 홀드 구간';

  @override
  String get completeFormSummary => '자세 요약';

  @override
  String get todayCoaching => '오늘의 코칭';

  @override
  String coachingIssueFrequency(int total, int count, String issue) {
    return '$total초 중 $count초에서\n$issue';
  }

  @override
  String get completeTopImprovement => '다음 운동의 집중 포인트';

  @override
  String get completeStrengths => '잘한 점';

  @override
  String get completeSaved => '운동 기록을 이 기기에 저장했어요';

  @override
  String get completeSaveFailed => '운동 기록을 저장하지 못했어요. 나가기 전에 다시 시도해 주세요.';

  @override
  String get completeNoFormData => '자세를 요약하기에 보이는 동작이 충분하지 않았어요.';

  @override
  String get completeFinish => '마치기';

  @override
  String get postWorkoutReminderTitle => '이 흐름을 내일도 이어가세요';

  @override
  String postWorkoutReminderBody(String time) {
    return '내일부터 매일 $time에 알려드릴까요?';
  }

  @override
  String get postWorkoutReminderEnable => '알림 받기';

  @override
  String get postWorkoutReminderLater => '나중에';

  @override
  String get postWorkoutReminderEnabled => '리마인더를 설정했어요.';

  @override
  String get recordsTitle => '성장';

  @override
  String get recordsWeeklySummary => '이번 주';

  @override
  String recordsWorkoutCount(int count) {
    return '$count회 운동';
  }

  @override
  String recordsAverageForm(int score) {
    return '평균 자세 $score';
  }

  @override
  String recordsWorkoutTime(String time) {
    return '시간 $time';
  }

  @override
  String get recordsFirstWeek => '이번 주 첫 기록이에요';

  @override
  String recordsMoreThanLastWeek(int count) {
    return '지난주보다 $count초 더 했어요';
  }

  @override
  String recordsLessThanLastWeek(int count) {
    return '지난주보다 $count초 적게 했어요';
  }

  @override
  String get recordsSameAsLastWeek => '지난주와 같은 운동량이에요';

  @override
  String get recordsTrendEmpty => '운동을 더 하면 자세 변화를 확인할 수 있어요.';

  @override
  String get recordsFirstFormScore => '첫 자세 기록';

  @override
  String recordsRecentAverage(int count, int score) {
    return '최근 $count회 평균 $score';
  }

  @override
  String get recordsStrength => '강점';

  @override
  String get recordsFocus => '집중';

  @override
  String get recordsTodayPoint => '오늘의 포인트';

  @override
  String get recordsToday => '오늘';

  @override
  String get recordsRecentWorkouts => '최근 운동';

  @override
  String get recordsCalendarTitle => '운동 캘린더';

  @override
  String get recordsFormTrend => '자세 변화';

  @override
  String get recordsViewCalendar => '캘린더';

  @override
  String get recordsViewList => '목록';

  @override
  String get recordsViewStats => '통계';

  @override
  String get recordsCalendarPreviousMonth => '이전 달';

  @override
  String get recordsCalendarNextMonth => '다음 달';

  @override
  String get recordsCalendarWorkoutDay => '운동한 날';

  @override
  String get recordsCalendarNoWorkoutSelected => '운동한 날짜를 선택하면 세션을 볼 수 있어요.';

  @override
  String get recordsDayTotal => '하루 합계';

  @override
  String recordsSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 세션',
    );
    return '$_temp0';
  }

  @override
  String recordsSessionTitle(int number) {
    return '세션 $number';
  }

  @override
  String get recordsListNewest => '최신순';

  @override
  String get recordsOpenDetail => '상세 보기';

  @override
  String get recordsEmptyTitle => '아직 운동 기록이 없어요';

  @override
  String get recordsEmptyBody => '첫 플랭크 운동을 마치면 여기에 기록이 표시돼요.';

  @override
  String get recordsStartWorkout => '운동 시작';

  @override
  String get recordsLoading => '운동 기록을 불러오는 중…';

  @override
  String get recordsLoadError => '운동 기록을 불러오지 못했어요.';

  @override
  String get statsPeriod => '기간';

  @override
  String get statsPeriod7Days => '7일';

  @override
  String get statsPeriod30Days => '30일';

  @override
  String get statsPeriodThisMonth => '이번 달';

  @override
  String get statsPeriodAll => '전체';

  @override
  String get statsPeriodCustom => '사용자 지정';

  @override
  String get statsCustomRange => '날짜 범위 선택';

  @override
  String get statsTotalReps => '총 플랭크 시간';

  @override
  String get statsWorkoutDays => '운동한 날';

  @override
  String get statsTotalActiveTime => '총 운동 시간';

  @override
  String get statsAverageSets => '평균 세트 수';

  @override
  String get statsAverageReps => '평균 플랭크 시간';

  @override
  String get statsDailyReps => '날짜별 플랭크 시간';

  @override
  String get statsTrend => '기간별 변화';

  @override
  String get statsFrequentImprovements => '자주 나타난 집중 포인트';

  @override
  String get statsNoData => '이 기간에는 운동 기록이 없어요.';

  @override
  String statsTrendUp(num percent) {
    return '$percent% 증가';
  }

  @override
  String statsTrendDown(num percent) {
    return '$percent% 감소';
  }

  @override
  String get statsTrendFlat => '변화 없음';

  @override
  String get detailTitle => '운동 상세';

  @override
  String get detailStartTime => '시작 시간';

  @override
  String get detailEndTime => '종료 시간';

  @override
  String get detailActiveTime => '실제 운동 시간';

  @override
  String get detailRestTime => '휴식 시간';

  @override
  String get detailTotalTime => '전체 소요 시간';

  @override
  String get detailSets => '세트';

  @override
  String get detailSetBreakdown => '세트별 유지 시간';

  @override
  String get detailTotalReps => '총 플랭크 시간';

  @override
  String get detailAverageRep => '평균 홀드 구간';

  @override
  String get detailFormSummary => '자세 요약';

  @override
  String get detailImprovements => '개선 포인트';

  @override
  String get detailStrengths => '잘한 점';

  @override
  String get detailInterrupted => '중간에 종료됨';

  @override
  String get detailCompleted => '완료';

  @override
  String detailSetRow(int set, int reps) {
    return '$set세트: $reps초';
  }

  @override
  String detailSessionOn(String date, String time) {
    return '$date $time';
  }

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsRateApp => '앱 평가하기';

  @override
  String get settingsRateAppSubtitle => 'MotionFit을 평가해 주세요';

  @override
  String get settingsRateAppError => '스토어를 열 수 없어요. 다시 시도해 주세요.';

  @override
  String get settingsSectionGeneral => '일반';

  @override
  String get settingsSectionCoaching => '음성 코칭';

  @override
  String get settingsSectionReminder => '운동 리마인더';

  @override
  String get settingsSectionCamera => '카메라';

  @override
  String get settingsSectionPrivacy => '개인정보 및 데이터';

  @override
  String get settingsSectionAbout => '앱 정보';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsDisplayTheme => '화면 테마';

  @override
  String get settingsColorTheme => '컬러 테마';

  @override
  String get themeLight => '라이트';

  @override
  String get themePureBlack => '퓨어 블랙';

  @override
  String get themeSystem => '시스템';

  @override
  String get colorThemeByeokcheong => '벽청색';

  @override
  String get colorThemeChuhyang => '추향색';

  @override
  String get colorThemeJangdan => '장단색';

  @override
  String get colorThemeCheonghyeon => '청현색';

  @override
  String get colorThemeHaenghwang => '행황색';

  @override
  String get colorThemeChunyu => '춘유록색';

  @override
  String get colorThemeSeolbaek => '설백색';

  @override
  String get colorThemeByeokja => '벽자색';

  @override
  String get colorThemeChwiram => '취람색';

  @override
  String get languageSystem => '기기 언어 사용';

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
  String get languageChanged => '언어를 변경했어요';

  @override
  String get voiceCoachingEnabled => '음성 코칭';

  @override
  String get voiceRepCountEnabled => '유지 시간 음성 안내';

  @override
  String get voiceFormEnabled => '자세 코칭';

  @override
  String get voiceEncouragementEnabled => '격려 음성';

  @override
  String get voiceRate => '음성 속도';

  @override
  String get voiceRateSlow => '느리게';

  @override
  String get voiceRateNormal => '보통';

  @override
  String get voiceRateFast => '빠르게';

  @override
  String get voiceTest => '음성 테스트';

  @override
  String get voiceTestPhrase => '좋아요. 음성 코치가 준비됐어요.';

  @override
  String get voiceUnavailable => '이 언어와 호환되는 오프라인 음성이 설치되어 있지 않아요.';

  @override
  String get reminderTitle => '운동 리마인더';

  @override
  String get reminderSubtitle => '운동할 요일마다 알림 시간을 정해보세요.';

  @override
  String get reminderEnabled => '리마인더 사용';

  @override
  String get reminderTime => '알림 시간';

  @override
  String get reminderCopyTime => '이 시간 복사';

  @override
  String reminderCopyFromDay(String day) {
    return '$day 시간 복사';
  }

  @override
  String get reminderApplyAll => '모든 요일에 적용';

  @override
  String reminderNext(String dateTime) {
    return '다음 알림: $dateTime';
  }

  @override
  String get reminderNoneScheduled => '예정된 리마인더가 없어요';

  @override
  String get reminderPermissionNeeded => '리마인더를 켜려면 알림을 허용해 주세요.';

  @override
  String get reminderSaved => '리마인더 일정을 저장했어요';

  @override
  String get weekdayMonday => '월요일';

  @override
  String get weekdayTuesday => '화요일';

  @override
  String get weekdayWednesday => '수요일';

  @override
  String get weekdayThursday => '목요일';

  @override
  String get weekdayFriday => '금요일';

  @override
  String get weekdaySaturday => '토요일';

  @override
  String get weekdaySunday => '일요일';

  @override
  String get weekdayMondayShort => '월';

  @override
  String get weekdayTuesdayShort => '화';

  @override
  String get weekdayWednesdayShort => '수';

  @override
  String get weekdayThursdayShort => '목';

  @override
  String get weekdayFridayShort => '금';

  @override
  String get weekdaySaturdayShort => '토';

  @override
  String get weekdaySundayShort => '일';

  @override
  String get cameraFront => '전면 카메라';

  @override
  String get cameraRear => '후면 카메라';

  @override
  String get cameraMirrorPreview => '전면 화면 좌우 반전';

  @override
  String get cameraPoseOverlay => '자세 가이드 오버레이';

  @override
  String get cameraKeepScreenAwake => '운동 중 화면 켜두기';

  @override
  String get settingsHaptics => '햅틱 피드백';

  @override
  String get privacyTitle => '데이터 처리 안내';

  @override
  String get privacyLocalProcessing => '자세 분석은 이 기기에서 실행돼요.';

  @override
  String get privacyNoVideoStorage => '홀드 구간 영상 리뷰를 켠 경우에만 운동 영상을 이 기기에 저장해요.';

  @override
  String get privacyNoUpload => '카메라 프레임을 서버로 전송하지 않아요.';

  @override
  String get privacyStoredData => '이 기기에 저장되는 데이터';

  @override
  String get privacyStoredDataDescription =>
      '진행 상황을 확인할 수 있도록 운동 시간, 세트, 유지 시간, 자세 결과를 저장해요.';

  @override
  String get privacyDeleteData => '모든 운동 데이터 삭제';

  @override
  String get privacyDeleteConfirmTitle => '모든 운동 데이터를 삭제할까요?';

  @override
  String get privacyDeleteConfirmBody => '이 기기의 운동 기록이 영구적으로 삭제되며 되돌릴 수 없어요.';

  @override
  String get privacyDeleteConfirmAction => '모든 데이터 삭제';

  @override
  String get privacyDeleteSuccess => '운동 데이터를 삭제했어요';

  @override
  String get privacyDeleteFailure => '운동 데이터를 삭제하지 못했어요.';

  @override
  String get appInfoTitle => '앱 정보';

  @override
  String appInfoVersion(String version) {
    return '버전 $version';
  }

  @override
  String get appInfoLicenses => '오픈 소스 라이선스';

  @override
  String get appInfoPrivacyPolicy => '개인정보 처리방침';

  @override
  String get appInfoDescription => 'MotionFit은 기기 안에서 플랭크 유지 시간과 자세를 분석해요.';

  @override
  String get errorGenericTitle => '문제가 발생했어요';

  @override
  String get errorGenericBody => '다시 시도해 주세요. 기존 운동 기록은 안전하게 보관되어 있어요.';

  @override
  String get errorCameraInit => '카메라를 시작하지 못했어요.';

  @override
  String get errorCameraInUse => '다른 앱에서 카메라를 사용 중일 수 있어요.';

  @override
  String get errorPoseModelLoad => '자세 인식 모델을 불러오지 못했어요.';

  @override
  String get errorNoPerson => '사람이 보이지 않아요. 화면 안으로 들어와 주세요.';

  @override
  String get errorWholeBody => '어깨, 골반, 무릎 중 한쪽 관절선을 확인하고 있어요.';

  @override
  String get errorMultiplePeople => '두 명 이상이 보여요. 화면에는 한 명만 나오게 해주세요.';

  @override
  String get errorTrackingLost => '운동은 멈추지 않고 인식을 계속 시도하고 있어요.';

  @override
  String get errorDatabaseSave => '운동 기록을 저장하지 못했어요.';

  @override
  String get errorTtsVoiceMissing => '이 기기에 음성 엔진이 설치되어 있지 않아요.';

  @override
  String get errorTtsLocaleUnsupported => '이 기기에서는 선택한 언어의 음성 코칭을 지원하지 않아요.';

  @override
  String get emptyNoFormIssues => '반복해서 나타난 자세 문제가 없어요.';

  @override
  String get emptyNotEnoughData => '아직 데이터가 충분하지 않아요';

  @override
  String get loadingCamera => '카메라를 시작하는 중…';

  @override
  String get loadingPoseModel => '동작 인식을 준비하는 중…';

  @override
  String get loadingSavingWorkout => '운동 기록을 저장하는 중…';

  @override
  String get formScore => '자세 점수';

  @override
  String get formShort => '자세';

  @override
  String formScoreValue(int score) {
    return '$score점';
  }

  @override
  String get formIssueDepth => '골반 정렬';

  @override
  String get formIssueTorsoLean => '몸의 일직선';

  @override
  String get formIssueHeelLift => '발 안정성';

  @override
  String get formIssueKneeAlignment => '다리 펴기';

  @override
  String get formIssueBalance => '몸의 안정성';

  @override
  String get formIssueDescentSpeed => '자세 제어';

  @override
  String get formIssueAscentSpeed => '자세 제어';

  @override
  String get formIssueControl => '홀드 안정성';

  @override
  String get formIssueStandingCompletion => '곧은 몸 정렬';

  @override
  String get formIssueNotObservable => '현재 카메라 각도에서는 평가할 수 없음';

  @override
  String get formStrengthDepth => '안정적인 골반';

  @override
  String get formStrengthControl => '흔들림 없는 홀드';

  @override
  String get formStrengthBalance => '곧은 몸 정렬';

  @override
  String get coachTrackingLost1 => '카메라 앞에 서주세요.';

  @override
  String get coachTrackingLost2 => '관절을 다시 찾고 있어요.';

  @override
  String get coachWholeBody1 => '어깨, 골반, 무릎, 발목이 모두 보이게 해주세요.';

  @override
  String get coachWholeBody2 => '몸 전체가 보이도록 카메라 옆에 자리 잡아주세요.';

  @override
  String get coachMultiplePeople1 => '정확히 인식할 수 있도록 화면에는 한 명만 있어 주세요.';

  @override
  String get coachReady1 => '좋아요. 준비됐습니다. 시작할게요.';

  @override
  String get coachReady2 => '좋은 자세예요. 플랭크를 유지하세요.';

  @override
  String coachStartSet(int set) {
    return '$set세트, 시작합니다.';
  }

  @override
  String coachSevenDayChallengeStart(int day) {
    return '7일 챌린지 $day일차를 시작합니다.';
  }

  @override
  String coachCumulativeChallengeStart(int completed, int remaining) {
    return '누적 시간 챌린지를 시작합니다. 현재 $completed초, $remaining초 남았습니다.';
  }

  @override
  String coachRepCount(int count) {
    return '$count초';
  }

  @override
  String get coachDepth1 => '골반을 어깨 높이에 맞춰주세요.';

  @override
  String get coachDepth2 => '어깨부터 발뒤꿈치까지 일직선을 유지하세요.';

  @override
  String get coachTorso1 => '코어에 힘을 주고 허리를 곧게 유지하세요.';

  @override
  String get coachTorso2 => '어깨와 골반 높이를 안정적으로 맞춰주세요.';

  @override
  String get coachHeel1 => '발뒤꿈치를 뒤로 밀어주세요.';

  @override
  String get coachHeel2 => '발을 안정적으로 고정하세요.';

  @override
  String get coachKnees1 => '다리를 부드럽게 펴주세요.';

  @override
  String get coachKnees2 => '무릎을 굽히지 말고 길게 뻗어주세요.';

  @override
  String get coachBalance1 => '체중을 가운데에 유지하세요.';

  @override
  String get coachBalance2 => '좌우로 흔들리지 않게 유지하세요.';

  @override
  String get coachDescendSlow1 => '천천히 플랭크 자세를 잡아주세요.';

  @override
  String get coachDescendSlow2 => '부드럽게 몸을 일직선으로 맞춰주세요.';

  @override
  String get coachDescendFaster1 => '곧은 플랭크 자세로 돌아오세요.';

  @override
  String get coachDescendFaster2 => '정렬을 다시 맞추고 유지하세요.';

  @override
  String get coachAscendControlled1 => '골반을 조금 낮추고 안정적으로 유지하세요.';

  @override
  String get coachAscendControlled2 => '골반과 어깨 높이를 맞춰주세요.';

  @override
  String get coachAscendFaster1 => '골반을 조금 들어 일직선으로 맞추세요.';

  @override
  String get coachAscendFaster2 => '골반을 몸의 일직선으로 되돌리세요.';

  @override
  String get coachControl1 => '흔들리지 않게 호흡을 이어가세요.';

  @override
  String get coachControl2 => '코어에 힘을 주고 움직임을 줄이세요.';

  @override
  String get coachStandTall1 => '어깨부터 발뒤꿈치까지 길게 뻗으세요.';

  @override
  String get coachStandTall2 => '등과 다리를 한 줄로 유지하세요.';

  @override
  String get coachGood1 => '좋아요. 호흡하며 유지하세요.';

  @override
  String get coachGood2 => '정렬이 안정적이에요. 계속 유지하세요.';

  @override
  String get coachGood3 => '좋은 플랭크예요. 그대로 이어가세요.';

  @override
  String get coachLastTwo => '2초 남았어요. 힘내요!';

  @override
  String get coachLastOne => '1초 남았어요. 끝까지!';

  @override
  String coachSetComplete(int set) {
    return '좋습니다. $set세트가 끝났어요.';
  }

  @override
  String coachRestStart(int seconds) {
    return '$seconds초 쉬고, 다음 세트 준비하세요.';
  }

  @override
  String get coachRestTenSeconds => '휴식이 10초 남았습니다.';

  @override
  String get coachRestComplete => '휴식이 끝났어요. 다음 세트를 준비하세요.';

  @override
  String coachWorkoutComplete(int reps) {
    return '운동 완료. 플랭크를 $reps초 유지했어요.';
  }

  @override
  String get notificationReminderTitle => '오늘의 플랭크 시간이에요';

  @override
  String get notificationReminderBody => '짧게라도 시작해 보세요. 준비되면 MotionFit을 열어주세요.';

  @override
  String get notificationReminderBodyVariant2 => '짧게 집중한 플랭크도 오늘의 좋은 운동이 돼요.';

  @override
  String notificationStreakReminderBody(int days) {
    return '오늘 짧게 운동하고 $days일 연속 기록을 이어가세요.';
  }

  @override
  String get semanticsIncrease => '늘리기';

  @override
  String get semanticsDecrease => '줄이기';

  @override
  String semanticsSelectedTab(String tab) {
    return '선택된 탭: $tab';
  }

  @override
  String semanticsCalendarWorkoutDate(String date) {
    return '$date, 운동 기록 있음';
  }

  @override
  String semanticsCalendarEmptyDate(String date) {
    return '$date, 운동 기록 없음';
  }

  @override
  String semanticsCurrentRep(int current, int target) {
    return '현재 $target초 중 $current초';
  }

  @override
  String get repVideoReviewTitle => '플랭크 영상 리뷰';

  @override
  String get repVideoReviewDescription =>
      '홀드 구간을 다시 볼 수 있도록 운동 영상을 이 기기에 저장합니다.';

  @override
  String get repVideoLocalOnly => '기기에만 저장 · 업로드하지 않음';

  @override
  String get formReviewTitle => '자세 리뷰';

  @override
  String get formReviewMainIssue => '주요 개선점';

  @override
  String get viewRepTimeline => '홀드 타임라인 보기';

  @override
  String get repTimelineTitle => '플랭크 리뷰';

  @override
  String get repTimelineAll => '전체';

  @override
  String get repTimelineImprove => '개선 필요';

  @override
  String get repTimelineNoImprovement => '개선할 홀드 구간이 없습니다.';

  @override
  String repSetNumber(int number) {
    return '세트 $number';
  }

  @override
  String repNumber(int number) {
    return '$number초 구간';
  }

  @override
  String get repResultGood => '좋은 자세예요';

  @override
  String get repResultNeedsAttention => '확인 필요';

  @override
  String get repResultImproved => '직전 구간보다 좋아졌어요';

  @override
  String get repResultNotAssessed => '자세 확인이 어려워요';

  @override
  String get repIssueShallowDepth => '골반을 어깨 높이에 맞춰주세요';

  @override
  String get repIssueForwardLean => '몸의 일직선이 흐트러졌어요';

  @override
  String get repIssueKneesInward => '다리가 충분히 펴지지 않았어요';

  @override
  String get repVideoNotSaved => '저장된 영상 없음';

  @override
  String get repReplay => '다시 재생';

  @override
  String get repWhatHappened => '어떻게 움직였나요';

  @override
  String get repHowToImprove => '이렇게 개선해보세요';

  @override
  String get repWhatWentWell => '잘한 점';

  @override
  String get repPrevious => '이전 구간';

  @override
  String get repNext => '다음 구간';

  @override
  String get repFeedbackGood => 'MotionFit이 확인한 플랭크 정렬 범위가 안정적이었습니다.';

  @override
  String get repFeedbackDepth => '골반이 일직선에서 벗어났습니다. 어깨, 골반, 발뒤꿈치를 맞춰주세요.';

  @override
  String get repFeedbackTorso => '몸의 정렬이 흔들렸습니다. 코어에 힘을 주고 등을 곧게 유지하세요.';

  @override
  String get repFeedbackKnees => '홀드 중 무릎이 굽혀졌습니다. 다리를 부드럽게 길게 뻗으세요.';

  @override
  String repFeedbackGeneric(String area) {
    return '이 홀드 구간은 $area 부분을 확인해 주세요.';
  }

  @override
  String get deleteWorkoutVideo => '운동 영상 삭제';

  @override
  String get deleteWorkoutVideoTitle => '이 운동 영상을 삭제할까요?';

  @override
  String get deleteWorkoutVideoBody =>
      '기기에 저장된 영상만 삭제됩니다. 홀드 구간 분석과 운동 기록은 유지됩니다.';

  @override
  String get workoutVideoDeleted => '운동 영상을 삭제했습니다';
}
