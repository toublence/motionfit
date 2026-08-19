// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'motionfit - workout coach';

  @override
  String get navSquat => '스쿼트';

  @override
  String get navWorkout => '운동';

  @override
  String get navChallenge => '챌린지';

  @override
  String get navRecords => '성장';

  @override
  String get navSettings => '설정';

  @override
  String get challengeTitle => '나만의 스쿼트 챌린지';

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
  String get challengeDailyGoal => '일일 목표 방식';

  @override
  String get challengeSevenDayStart => '7일 챌린지 시작';

  @override
  String get challengeSevenDaySettings => '7일 목표 설정';

  @override
  String get challengeSevenDaySettingsDescription =>
      '1일차 목표를 정하면 이후 목표가 매일 5회씩 늘어납니다.';

  @override
  String get challengeFirstDayGoal => '1일차 목표 횟수';

  @override
  String challengeSevenDayPreview(int first, int last) {
    return '1일차 $first회 → 7일차 $last회';
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
  String get challengeCumulativeTitle => '누적 횟수 챌린지';

  @override
  String get challengeCumulativeDescription => '원하는 일정에 맞춰 총 스쿼트 횟수를 달성하는 챌린지';

  @override
  String get challengeCumulativeSummary => '기간과 총횟수를 정하고 쉬는 날에도 진행률을 유지해요.';

  @override
  String get challengePreset200 => '7일 동안 200회';

  @override
  String get challengePreset500 => '14일 동안 500회';

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
    return '첫 운동 $reps회를 기준으로 추천했어요.';
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
    return '오늘 $current / $target회';
  }

  @override
  String get challengeRestToday => '오늘은 충분히 회복하세요.';

  @override
  String get challengeTodayCompleted => '오늘 목표 완료 · 내일 다시 진행해요';

  @override
  String challengeRepsRemaining(int reps) {
    return '목표까지 $reps회';
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
    return '$current / $target회';
  }

  @override
  String challengeDaysRemaining(int days) {
    return '$days일 남음';
  }

  @override
  String challengeTodaySuggested(int reps) {
    return '오늘 권장 목표 $reps회';
  }

  @override
  String challengePercent(int percent) {
    return '$percent% 완료';
  }

  @override
  String get challengeSquatStart => '스쿼트 시작';

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
  String get challengeGoalLabel => '목표 횟수';

  @override
  String get challengeNotFound => '이 챌린지를 찾을 수 없습니다.';

  @override
  String get challengePeriod => '진행 기간';

  @override
  String get challengeStatus => '상태';

  @override
  String get challengeTotalReps => '누적 스쿼트';

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
  String get challengeReminderNotificationTitle => '스쿼트 챌린지를 이어갈 시간이에요';

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
      other: '$count회',
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
    return '스쿼트 $reps회 · $sets세트';
  }

  @override
  String get homeViewResult => '결과 보기';

  @override
  String get homeTodaySets => '오늘 한 세트';

  @override
  String get homeTodayReps => '오늘 한 횟수';

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
  String get homeRepsPerSetLabel => '세트당 횟수';

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
  String get guideSubtitle => '어깨부터 무릎까지 보이면 발목이 없어도 스쿼트를 측정해요.';

  @override
  String get guideWholeBody => '가능하면 어깨, 골반, 무릎이 화면에 보이게 해주세요.';

  @override
  String get guideStableCamera => '휴대폰을 흔들리지 않는 곳에 놓아주세요.';

  @override
  String get guideOnePerson => '화면에는 한 명만 나오게 해주세요.';

  @override
  String get guideCameraAngle => '가능하면 측면이나 약간 비스듬한 측면에서 촬영하세요.';

  @override
  String get guideLighting => '어두운 곳과 강한 역광은 피해주세요.';

  @override
  String get guidePrivacy => '영상은 기기에만 머물며 Rep 영상 리뷰를 켠 경우에만 저장돼요.';

  @override
  String get guideContinue => '준비됐어요';

  @override
  String get permissionCameraTitle => '카메라 권한이 필요해요';

  @override
  String get permissionCameraBody =>
      'MotionFit은 스쿼트 횟수를 세기 위해 카메라를 사용해요. Rep 영상 리뷰를 켠 경우에만 영상을 이 기기에 저장해요.';

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
  String get calibrationTitle => '서 있는 자세를 확인하고 있어요';

  @override
  String get calibrationBody => '바르게 서서 어깨부터 무릎까지 보여주세요.';

  @override
  String get calibrationStayStill => '잠시만 그대로 있어주세요';

  @override
  String get calibrationComplete => '준비 완료';

  @override
  String get calibrationFailed => '서 있는 자세를 선명하게 확인하지 못했어요.';

  @override
  String get calibrationRetry => '다시 보정';

  @override
  String workoutSetProgress(int current, int total) {
    return '$current / $total세트';
  }

  @override
  String workoutRepProgress(int current, int target) {
    return '$current / $target회';
  }

  @override
  String workoutTotalReps(int count) {
    return '누적 $count회';
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
  String get workoutStateReady => '준비';

  @override
  String get workoutStateDescending => '내려가는 중';

  @override
  String get workoutStateBottom => '최저점';

  @override
  String get workoutStateAscending => '올라오는 중';

  @override
  String get workoutStateCompleted => '좋아요';

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
  String get restTotalReps => '현재까지 스쿼트';

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
  String get completeTotalReps => '총 스쿼트 횟수';

  @override
  String get completeCompletedSets => '완료 세트';

  @override
  String get completeActiveTime => '실제 운동 시간';

  @override
  String get completeRestTime => '총 휴식 시간';

  @override
  String get completeTotalTime => '전체 소요 시간';

  @override
  String get completeAverageRepTime => '평균 반복 시간';

  @override
  String get completeFormSummary => '자세 요약';

  @override
  String get todayCoaching => '오늘의 코칭';

  @override
  String coachingIssueFrequency(int total, int count, String issue) {
    return '$total회 중 $count회에서\n$issue';
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
  String get postWorkoutReminderTitle => '다음 운동도 잊지 않도록 알려드릴까요?';

  @override
  String postWorkoutReminderBody(String time) {
    return '주 3회 목표를 이어갈 수 있도록 $time에 운동을 알려드려요.';
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
    return '지난주보다 $count회 더 했어요';
  }

  @override
  String recordsLessThanLastWeek(int count) {
    return '지난주보다 $count회 적게 했어요';
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
  String get recordsCalendarTitle => '최근 운동 기록';

  @override
  String get recordsWorkoutRecords => '운동 기록';

  @override
  String get recordsNoWorkoutOnDay => '이 날은 운동 기록이 없어요';

  @override
  String get exercisePushup => '푸쉬업';

  @override
  String get exercisePlank => '플랭크';

  @override
  String get recordsConsistency => '꾸준함';

  @override
  String recordsWeeklyStreak(int count) {
    return '🔥 $count주 연속 목표 달성 중';
  }

  @override
  String get recordsStreakFirstWeek => '첫 주 기록을 만들어보세요';

  @override
  String get recordsWeeklyGoalComplete => '🔥 이번 주 목표 완료';

  @override
  String recordsStreakRemaining(int count) {
    return '$count회 더 운동하면 기록이 이어져요';
  }

  @override
  String recordsStreakStartRemaining(int count) {
    return '이번 주 $count회를 더 완료하면 연속 기록이 시작돼요';
  }

  @override
  String recordsStreakContinued(int count) {
    return '$count주 연속 기록을 이어갔어요';
  }

  @override
  String recordsRecentWeeksSummary(int count) {
    return '최근 16주 · $count일 운동';
  }

  @override
  String recordsRangeSummary(String from, String to, int count) {
    return '$from ~ $to · $count일 운동';
  }

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
  String get recordsEmptyTitle => '첫 운동을 시작해볼까요?';

  @override
  String get recordsEmptyBody => '첫 운동을 시작하면 오늘의 기록이 채워져요.';

  @override
  String get recordsStartWorkout => '첫 운동 시작';

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
  String get statsTotalReps => '총 스쿼트 횟수';

  @override
  String get statsWorkoutDays => '운동한 날';

  @override
  String get statsTotalActiveTime => '총 운동 시간';

  @override
  String get statsAverageSets => '평균 세트 수';

  @override
  String get statsAverageReps => '평균 스쿼트 횟수';

  @override
  String get statsDailyReps => '날짜별 스쿼트';

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
  String get detailSetBreakdown => '세트별 횟수';

  @override
  String get detailTotalReps => '총 스쿼트 횟수';

  @override
  String get detailAverageRep => '평균 반복 시간';

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
    return '$set세트: $reps회';
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
  String get voiceRepCountEnabled => '횟수 음성 안내';

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
  String get privacyNoVideoStorage => 'Rep 영상 리뷰를 켠 경우에만 운동 영상을 이 기기에 저장해요.';

  @override
  String get privacyNoUpload => '카메라 프레임을 서버로 전송하지 않아요.';

  @override
  String get privacyStoredData => '이 기기에 저장되는 데이터';

  @override
  String get privacyStoredDataDescription =>
      '진행 상황을 확인할 수 있도록 운동 시간, 세트, 횟수, 자세 결과를 저장해요.';

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
  String get appInfoDescription => 'MotionFit은 기기 안에서 스쿼트 횟수를 세고 자세 개선을 도와줘요.';

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
  String get formIssueDepth => '스쿼트 깊이';

  @override
  String get formIssueTorsoLean => '상체 안정성';

  @override
  String get formIssueHeelLift => '발뒤꿈치 유지';

  @override
  String get formIssueKneeAlignment => '무릎 정렬';

  @override
  String get formIssueBalance => '좌우 균형';

  @override
  String get formIssueDescentSpeed => '하강 속도';

  @override
  String get formIssueAscentSpeed => '상승 속도';

  @override
  String get formIssueControl => '동작 제어';

  @override
  String get formIssueStandingCompletion => '완전히 일어서기';

  @override
  String get formIssueNotObservable => '현재 카메라 각도에서는 평가할 수 없음';

  @override
  String get formStrengthDepth => '일정한 깊이';

  @override
  String get formStrengthControl => '안정적인 동작';

  @override
  String get formStrengthBalance => '균형 잡힌 자세';

  @override
  String get coachTrackingLost1 => '카메라 앞에 서주세요.';

  @override
  String get coachTrackingLost2 => '관절을 다시 찾고 있어요.';

  @override
  String get coachWholeBody1 => '어깨, 골반, 무릎이 보이게 서주세요.';

  @override
  String get coachWholeBody2 => '발목 없이도 괜찮아요. 무릎까지 보여주세요.';

  @override
  String get coachMultiplePeople1 => '정확히 인식할 수 있도록 화면에는 한 명만 있어 주세요.';

  @override
  String get coachReady1 => '좋아요. 준비됐습니다. 시작할게요.';

  @override
  String get coachReady2 => '자세가 잘 보여요. 첫 스쿼트를 준비하세요.';

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
    return '누적 횟수 챌린지를 시작합니다. 현재 $completed회, $remaining회 남았습니다.';
  }

  @override
  String coachRepCount(int count) {
    return '$count';
  }

  @override
  String get coachDepth1 => '조금 더 깊게 앉아요!';

  @override
  String get coachDepth2 => '다음엔 깊이를 조금 더!';

  @override
  String get coachTorso1 => '가슴 들고, 허리 단단히!';

  @override
  String get coachTorso2 => '상체 세우고 올라와요!';

  @override
  String get coachHeel1 => '뒤꿈치 붙이고 밀어요!';

  @override
  String get coachHeel2 => '발바닥 전체로 밀어요!';

  @override
  String get coachKnees1 => '무릎은 발끝 방향으로!';

  @override
  String get coachKnees2 => '무릎이 안으로 모이지 않게!';

  @override
  String get coachBalance1 => '체중은 양발에 고르게!';

  @override
  String get coachBalance2 => '한쪽으로 쏠리지 않게!';

  @override
  String get coachDescendSlow1 => '내려갈 때 조금만 천천히.';

  @override
  String get coachDescendSlow2 => '좋아요, 내려가는 속도를 조절해요.';

  @override
  String get coachDescendFaster1 => '멈추지 말고 자연스럽게 내려가요.';

  @override
  String get coachDescendFaster2 => '다음엔 부드럽게 이어서 내려가요.';

  @override
  String get coachAscendControlled1 => '올라올 때 속도를 조금만 조절해요.';

  @override
  String get coachAscendControlled2 => '서두르지 말고 부드럽게 올라와요.';

  @override
  String get coachAscendFaster1 => '좋아요, 이제 힘 있게 올라와요!';

  @override
  String get coachAscendFaster2 => '발바닥을 밀면서 힘 있게 올라와요!';

  @override
  String get coachControl1 => '흔들리지 않게, 부드럽게!';

  @override
  String get coachControl2 => '급하게 바꾸지 말고 이어가요!';

  @override
  String get coachStandTall1 => '마지막에 조금 더 곧게 일어서 보세요.';

  @override
  String get coachStandTall2 => '서 있던 자세까지 끝까지 올라오세요.';

  @override
  String get coachGood1 => '좋아요, 이 리듬 그대로!';

  @override
  String get coachGood2 => '안정적이에요. 계속 갑니다!';

  @override
  String get coachGood3 => '좋은 자세예요. 한 번 더!';

  @override
  String get coachLastTwo => '마지막 두 개! 힘내요!';

  @override
  String get coachLastOne => '마지막 하나! 끝까지!';

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
    return '운동 완료. 스쿼트 $reps회를 마쳤어요.';
  }

  @override
  String get notificationReminderTitle => '오늘의 스쿼트 시간이에요';

  @override
  String get notificationReminderBody => '짧게라도 시작해 보세요. 준비되면 MotionFit을 열어주세요.';

  @override
  String get notificationReminderBodyVariant2 => '집중해서 몇 번만 움직여도 오늘의 운동이 달라져요.';

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
    return '현재 $target회 중 $current회';
  }

  @override
  String get repVideoReviewTitle => 'Rep 영상 리뷰';

  @override
  String get repVideoReviewDescription =>
      '각 Rep을 다시 볼 수 있도록 운동 영상을 이 기기에 저장합니다.';

  @override
  String get repVideoLocalOnly => '기기에만 저장 · 업로드하지 않음';

  @override
  String get formReviewTitle => '자세 리뷰';

  @override
  String get formReviewMainIssue => '주요 개선점';

  @override
  String get viewRepTimeline => 'Rep 타임라인 보기';

  @override
  String get repTimelineTitle => 'Rep 리뷰';

  @override
  String get repTimelineAll => '전체';

  @override
  String get repTimelineImprove => '개선 필요';

  @override
  String get repTimelineNoImprovement => '개선할 Rep이 없습니다.';

  @override
  String repSetNumber(int number) {
    return '세트 $number';
  }

  @override
  String repNumber(int number) {
    return 'Rep $number';
  }

  @override
  String get repResultGood => '좋은 자세예요';

  @override
  String get repResultNeedsAttention => '확인 필요';

  @override
  String get repResultImproved => '직전 Rep보다 좋아졌어요';

  @override
  String get repResultNotAssessed => '자세 확인이 어려워요';

  @override
  String get repIssueShallowDepth => '조금 더 깊게 내려가 보세요';

  @override
  String get repIssueForwardLean => '상체가 앞으로 기울었어요';

  @override
  String get repIssueKneesInward => '무릎이 안쪽으로 움직였어요';

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
  String get repPrevious => '이전 Rep';

  @override
  String get repNext => '다음 Rep';

  @override
  String get repFeedbackGood => 'MotionFit이 확인할 수 있는 자세 범위가 안정적이었습니다.';

  @override
  String get repFeedbackDepth =>
      '평소 스쿼트 깊이에 도달하지 못했습니다. 가슴을 안정적으로 유지하며 조금 더 내려가 보세요.';

  @override
  String get repFeedbackTorso => '이 Rep에서 상체가 너무 앞으로 기울었습니다. 가슴을 조금 더 세워 주세요.';

  @override
  String get repFeedbackKnees => '이 Rep에서 무릎이 안쪽으로 움직였습니다. 무릎과 발끝 방향을 맞춰 주세요.';

  @override
  String repFeedbackGeneric(String area) {
    return '이 Rep은 $area 부분을 확인해 주세요.';
  }

  @override
  String get deleteWorkoutVideo => '운동 영상 삭제';

  @override
  String get deleteWorkoutVideoTitle => '이 운동 영상을 삭제할까요?';

  @override
  String get deleteWorkoutVideoBody =>
      '기기에 저장된 영상만 삭제됩니다. Rep 분석과 운동 기록은 유지됩니다.';

  @override
  String get workoutVideoDeleted => '운동 영상을 삭제했습니다';
}
