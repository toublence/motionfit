// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'plank_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class PlankLocalizationsJa extends PlankLocalizations {
  PlankLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'MotionFit - Plank';

  @override
  String get navSquat => 'プランク';

  @override
  String get navChallenge => 'チャレンジ';

  @override
  String get navRecords => '進歩';

  @override
  String get navSettings => '設定';

  @override
  String get challengeTitle => '自分だけのプランクチャレンジ';

  @override
  String get challengeSubtitle => '目標に合うチャレンジを選んで、無理なく続けましょう。';

  @override
  String get challengeChooseTitle => 'チャレンジを選択';

  @override
  String get challengeSevenDayTitle => '7日間スタートチャレンジ';

  @override
  String get challengeSevenDayDescription => '初心者向けの段階的なプログラム';

  @override
  String get challengeSevenDaySummary => '7日間、毎日増えるレベル別目標に挑戦します。';

  @override
  String get challengeSevenDayEveryDay => '回復日なしで7日間毎日実施';

  @override
  String challengeDurationDays(int days) {
    return '$days日間';
  }

  @override
  String get challengeLevelGoals => 'レベルに合った目標';

  @override
  String get challengeRecoveryIncluded => '回復日を含む';

  @override
  String get challengeDailyGoal => '1日ごとの秒数目標';

  @override
  String get challengeSevenDayStart => '7日間チャレンジを開始';

  @override
  String get challengeSevenDaySettings => '7日間の目標を設定';

  @override
  String get challengeSevenDaySettingsDescription => '1日目の目標を決めると、毎日5秒ずつ増えます。';

  @override
  String get challengeFirstDayGoal => '1日目の目標秒数';

  @override
  String challengeSevenDayPreview(int first, int last) {
    return '1日目 $first秒 → 7日目 $last秒';
  }

  @override
  String get challengeWeeklyTitle => '週3回チャレンジ';

  @override
  String get challengeWeeklyDescription => '毎日の運動が負担な方のための習慣チャレンジ';

  @override
  String get challengeWeeklySummary => '4週間、選んだ曜日に週3回運動します。';

  @override
  String challengeDurationWeeks(int weeks) {
    return '$weeks週間';
  }

  @override
  String get challengeThreePerWeek => '週に3回';

  @override
  String get challengeChooseWeekdays => '運動する曜日を3つ選択';

  @override
  String get challengeWorkoutDaysCount => '運動した日数で進行';

  @override
  String get challengeWeeklyStart => '週3回チャレンジを開始';

  @override
  String get challengeCumulativeTitle => '累計秒数チャレンジ';

  @override
  String get challengeCumulativeDescription => '自分のペースでプランクの合計目標を達成';

  @override
  String get challengeCumulativeSummary => '期間と合計秒数を選び、休んでも進捗を維持します。';

  @override
  String get challengePreset200 => '7日間で200秒';

  @override
  String get challengePreset500 => '14日間で500秒';

  @override
  String get challengeCustomGoal => '期間と目標を設定';

  @override
  String get challengeRestWithoutReset => '休んでも進捗はリセットされません';

  @override
  String get challengeCumulativeStart => '累計チャレンジを開始';

  @override
  String get challengeHistoryTitle => '過去のチャレンジ';

  @override
  String get challengeHistoryEmpty => '完了・終了したチャレンジがここに表示されます。';

  @override
  String get challengeRecommended => 'おすすめ';

  @override
  String challengeRecommendationFromWorkout(int reps) {
    return '初回の運動 $reps秒を基準におすすめしています。';
  }

  @override
  String get challengeRecommendationDefault => '最初は無理なく始められる7日間コースがおすすめです。';

  @override
  String get challengeActive => '進行中のチャレンジ';

  @override
  String get challengeNext => '次の目標';

  @override
  String challengeDayNumber(int day) {
    return '$day日目';
  }

  @override
  String get challengeRecoveryDay => '回復日';

  @override
  String challengeTodayProgress(int current, int target) {
    return '今日 $current / $target秒';
  }

  @override
  String get challengeRestToday => '今日はしっかり回復しましょう。';

  @override
  String get challengeTodayCompleted => '今日の目標達成 · 続きは明日';

  @override
  String challengeRepsRemaining(int reps) {
    return '目標まであと$reps秒';
  }

  @override
  String challengeWeekNumber(int week) {
    return '$week週目';
  }

  @override
  String challengeThisWeekProgress(int current, int target) {
    return '今週 $current / $target回';
  }

  @override
  String challengeOverallDays(int current, int target) {
    return '全体 $current / $target日';
  }

  @override
  String challengeRepsProgress(int current, int target) {
    return '$current / $target秒';
  }

  @override
  String challengeDaysRemaining(int days) {
    return '残り$days日';
  }

  @override
  String challengeTodaySuggested(int reps) {
    return '今日の推奨目標 $reps秒';
  }

  @override
  String challengePercent(int percent) {
    return '$percent%完了';
  }

  @override
  String get challengeSquatStart => 'プランクを開始';

  @override
  String get challengeTodayWorkoutStart => '今日の運動を開始';

  @override
  String get challengeViewDetails => '詳細を見る';

  @override
  String get challengeRestart => 'もう一度開始';

  @override
  String get challengeDeleteHistory => '履歴から削除';

  @override
  String get challengeCumulativeSettings => '累計目標を設定';

  @override
  String get challengeDurationLabel => '期間';

  @override
  String get challengeGoalLabel => '目標秒数';

  @override
  String get challengeNotFound => 'このチャレンジは利用できません。';

  @override
  String get challengePeriod => '期間';

  @override
  String get challengeStatus => '状態';

  @override
  String get challengeTotalReps => '累計プランク';

  @override
  String get challengeWorkoutDays => '運動日数';

  @override
  String challengeDaysCount(int days) {
    return '$days日';
  }

  @override
  String get challengeTotalTime => '合計運動時間';

  @override
  String get challengeSchedule => 'スケジュールと進捗';

  @override
  String get challengeNotifications => 'チャレンジ通知';

  @override
  String get challengeNotificationsDescription => 'このチャレンジの通知設定を保存します。';

  @override
  String get challengeReminderNotificationTitle => 'プランクチャレンジの時間です';

  @override
  String get challengeReminderNotificationBody => 'MotionFitを開いて今日の目標を進めましょう。';

  @override
  String get challengeSelectedWeekdays => '選択した運動曜日';

  @override
  String get challengeNoProgressYet => 'チャレンジの運動記録はまだありません。';

  @override
  String get challengeCancel => 'チャレンジを終了';

  @override
  String get challengeCancelTitle => 'このチャレンジを終了しますか？';

  @override
  String get challengeCancelDescription => '運動記録は残り、チャレンジは履歴に移動します。';

  @override
  String get challengeStatusActive => '進行中';

  @override
  String get challengeStatusCompleted => '完了';

  @override
  String get challengeStatusEnded => '終了';

  @override
  String get challengeStatusCancelled => 'キャンセル';

  @override
  String get challengeProgressUpdated => 'チャレンジの進捗を更新しました。';

  @override
  String get challengeCheck => 'チャレンジを確認';

  @override
  String get commonDone => '完了';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonRetry => 'もう一度試す';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '削除';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonBack => '戻る';

  @override
  String get commonContinue => '続ける';

  @override
  String get commonStart => '開始';

  @override
  String get commonSkip => 'スキップ';

  @override
  String get commonEdit => '編集';

  @override
  String get commonOn => 'オン';

  @override
  String get commonOff => 'オフ';

  @override
  String get commonEnabled => '有効';

  @override
  String get commonDisabled => '無効';

  @override
  String get commonNotAvailable => '利用できません';

  @override
  String get commonToday => '今日';

  @override
  String get commonYesterday => '昨日';

  @override
  String get commonLoading => '読み込み中…';

  @override
  String unitSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countセット',
    );
    return '$_temp0';
  }

  @override
  String unitReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count秒',
    );
    return '$_temp0';
  }

  @override
  String unitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count秒',
    );
    return '$_temp0';
  }

  @override
  String unitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes分$seconds秒';
  }

  @override
  String get homeGreeting => '体を動かす準備はできましたか？';

  @override
  String get homeTodayTitle => '今日の記録';

  @override
  String get homeTodayNoWorkout => '今日はまだプランクをしていません。短い1セットから始めましょう。';

  @override
  String homeTodaySummary(int reps, int sets) {
    return 'プランク$reps秒・$setsセット';
  }

  @override
  String get homeViewResult => '結果を見る';

  @override
  String get homeTodaySets => '今日のセット';

  @override
  String get homeTodayReps => '今日の秒数';

  @override
  String get streakLabel => '連続記録';

  @override
  String streakDays(int days) {
    return '$days日';
  }

  @override
  String get homeWorkoutSetup => '次のワークアウト';

  @override
  String get homeSetsLabel => 'セット数';

  @override
  String get homeRepsPerSetLabel => '1セットの秒数';

  @override
  String get homeRestTimeLabel => '休憩時間';

  @override
  String get homeDirectInputHint => '数値を入力';

  @override
  String get homeStartWorkout => 'ワークアウトを開始';

  @override
  String get homeLastSettingsRestored => '前回のワークアウト設定を復元しました。';

  @override
  String get validationNumberRequired => '数値を入力してください。';

  @override
  String validationRange(num min, num max) {
    return '$minから$maxまでの値を選んでください。';
  }

  @override
  String get guideTitle => 'カメラをセットしましょう';

  @override
  String get guideLandscapeTitle => 'スマートフォンを横向きにしてください';

  @override
  String get guideLandscapeBody => 'プランクは横画面で計測します。姿勢を取る前にスマートフォンを横向きに置いてください。';

  @override
  String get countdownLandscapePrompt => 'スマートフォンを横向きのままにしてください';

  @override
  String get guideSubtitle => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get guideWholeBody => '頭からつま先まで全身が画面に入るようにしてください。';

  @override
  String get guideStableCamera => 'スマートフォンを安定した場所に置いてください。';

  @override
  String get guideOnePerson => '画面には1人だけ映るようにしてください。';

  @override
  String get guideCameraAngle => 'できるだけ真横か、少し斜め横から撮影してください。';

  @override
  String get guideLighting => '暗い場所や強い逆光を避けてください。';

  @override
  String get guidePrivacy => '映像は端末内に留まり、ホールド区間動画レビューをオンにした場合のみ保存されます。';

  @override
  String get guideContinue => '位置につきました';

  @override
  String get permissionCameraTitle => 'カメラへのアクセスが必要です';

  @override
  String get permissionCameraBody =>
      'MotionFitはプランクの時間と姿勢を測るためにカメラを使用します。レビューをオンにした場合のみ映像を端末に保存します。';

  @override
  String get permissionCameraRequest => '続ける';

  @override
  String get permissionCameraDenied => 'カメラへのアクセスが拒否されました。記録と設定は引き続き利用できます。';

  @override
  String get permissionCameraPermanentlyDenied =>
      'ワークアウトを始めるには、システム設定でカメラを許可してください。';

  @override
  String get permissionOpenSettings => '設定を開く';

  @override
  String get permissionNotificationTitle => 'ワークアウトの通知を許可しますか？';

  @override
  String get permissionNotificationBody => '通知は、設定したリマインダーにのみ使用されます。';

  @override
  String get permissionNotificationRequest => '通知を許可';

  @override
  String get permissionNotificationDenied =>
      '通知がオフです。リマインダーを受け取るにはシステム設定でオンにしてください。';

  @override
  String get countdownGetReady => '準備してください';

  @override
  String countdownBeginsIn(int seconds) {
    return '$seconds秒後に開始';
  }

  @override
  String get calibrationTitle => 'プランク';

  @override
  String get calibrationBody => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get calibrationStayStill => '少しの間そのままでいてください';

  @override
  String get calibrationComplete => '準備完了';

  @override
  String get calibrationFailed => '立ち姿勢をはっきり確認できませんでした。';

  @override
  String get calibrationRetry => 'もう一度調整';

  @override
  String workoutSetProgress(int current, int total) {
    return '$current / $totalセット';
  }

  @override
  String workoutRepProgress(int current, int target) {
    return '$current / $target秒';
  }

  @override
  String workoutTotalReps(int count) {
    return '合計$count秒';
  }

  @override
  String get workoutElapsed => '経過時間';

  @override
  String get workoutPause => '一時停止';

  @override
  String get workoutResume => 'ワークアウトを再開';

  @override
  String get workoutEnd => 'いったん停止';

  @override
  String get workoutBackToSetup => '設定に戻る';

  @override
  String get workoutEndDialogTitle => 'いったん停止しますか？';

  @override
  String get workoutEndDialogBody => '進行状況を保存し、ホーム画面から続けられます。';

  @override
  String get workoutEndDialogConfirm => '保存して終了';

  @override
  String get workoutPauseReasonBackground => 'アプリがバックグラウンドに移動したため、一時停止しました。';

  @override
  String get workoutPauseReasonInterruption => 'システムによる中断後、ワークアウトを一時停止しました。';

  @override
  String get workoutStateReady => 'プランク';

  @override
  String get workoutStateDescending => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get workoutStateBottom => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get workoutStateAscending => '上がっています';

  @override
  String get workoutStateCompleted => '1秒キープ';

  @override
  String get workoutStateTrackingLost => '画面内に戻ってください';

  @override
  String get workoutStatePaused => '一時停止中';

  @override
  String get workoutTrackingGood => '全身を認識中';

  @override
  String get workoutCameraSwitch => 'カメラを切り替える';

  @override
  String get workoutSkeletonToggle => '姿勢ガイドを表示';

  @override
  String get restTitle => '休憩';

  @override
  String restNextSet(int set, int total) {
    return '次：$set / $totalセット';
  }

  @override
  String get restCompletedSets => '完了したセット';

  @override
  String get restTotalReps => 'ここまでの保持時間';

  @override
  String get restSkip => '休憩をスキップ';

  @override
  String get restAddFifteenSeconds => '15秒追加';

  @override
  String get restEndWorkout => 'いったん停止';

  @override
  String get restAlmostDone => 'もうすぐです';

  @override
  String get restReady => '次のセットを始めましょう';

  @override
  String get completeTitle => 'ワークアウト完了';

  @override
  String get completeSubtitle => 'お疲れさまでした。今回の内容を振り返りましょう。';

  @override
  String get workoutInterruptedSubtitle => '早めに終了するまでの記録を確認できます。';

  @override
  String get completeTotalReps => 'プランク合計時間';

  @override
  String get completeCompletedSets => '完了セット';

  @override
  String get completeActiveTime => '運動時間';

  @override
  String get completeRestTime => '休憩時間';

  @override
  String get completeTotalTime => '合計時間';

  @override
  String get completeAverageRepTime => '平均ホールド区間';

  @override
  String get completeFormSummary => 'フォームのまとめ';

  @override
  String get todayCoaching => '今日のコーチング';

  @override
  String coachingIssueFrequency(int total, int count, String issue) {
    return '$total秒中$count秒で\n$issue';
  }

  @override
  String get completeTopImprovement => '次回のポイント';

  @override
  String get completeStrengths => '良かった点';

  @override
  String get completeSaved => 'ワークアウトをこの端末に保存しました';

  @override
  String get completeSaveFailed => 'ワークアウトを保存できませんでした。画面を閉じる前にもう一度試してください。';

  @override
  String get completeNoFormData => 'フォームをまとめるための動きが十分に映っていませんでした。';

  @override
  String get completeFinish => '終了';

  @override
  String get postWorkoutReminderTitle => '明日も続けましょう';

  @override
  String postWorkoutReminderBody(String time) {
    return '明日から毎日$timeにお知らせしますか？';
  }

  @override
  String get postWorkoutReminderEnable => '通知する';

  @override
  String get postWorkoutReminderLater => 'あとで';

  @override
  String get postWorkoutReminderEnabled => 'リマインダーを設定しました。';

  @override
  String get recordsTitle => '進歩';

  @override
  String get recordsWeeklySummary => '今週';

  @override
  String recordsWorkoutCount(int count) {
    return '$count回の運動';
  }

  @override
  String recordsAverageForm(int score) {
    return '平均フォーム $score';
  }

  @override
  String recordsWorkoutTime(String time) {
    return '時間 $time';
  }

  @override
  String get recordsFirstWeek => '今週最初の記録です';

  @override
  String recordsMoreThanLastWeek(int count) {
    return '先週より$count秒長くできました';
  }

  @override
  String recordsLessThanLastWeek(int count) {
    return '先週より$count秒短いです';
  }

  @override
  String get recordsSameAsLastWeek => '先週と同じ運動量です';

  @override
  String get recordsTrendEmpty => '運動を続けるとフォームの変化を確認できます。';

  @override
  String get recordsFirstFormScore => '最初のフォーム記録';

  @override
  String recordsRecentAverage(int count, int score) {
    return '直近$count回の平均 $score';
  }

  @override
  String get recordsStrength => '強み';

  @override
  String get recordsFocus => '意識する点';

  @override
  String get recordsTodayPoint => '今日のポイント';

  @override
  String get recordsToday => '今日';

  @override
  String get recordsRecentWorkouts => '最近のワークアウト';

  @override
  String get recordsCalendarTitle => 'ワークアウトカレンダー';

  @override
  String get recordsFormTrend => 'フォームの推移';

  @override
  String get recordsViewCalendar => 'カレンダー';

  @override
  String get recordsViewList => '一覧';

  @override
  String get recordsViewStats => '統計';

  @override
  String get recordsCalendarPreviousMonth => '前の月';

  @override
  String get recordsCalendarNextMonth => '次の月';

  @override
  String get recordsCalendarWorkoutDay => '運動した日';

  @override
  String get recordsCalendarNoWorkoutSelected => '運動した日を選ぶとセッションを確認できます。';

  @override
  String get recordsDayTotal => '1日の合計';

  @override
  String recordsSessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countセッション',
    );
    return '$_temp0';
  }

  @override
  String recordsSessionTitle(int number) {
    return 'セッション$number';
  }

  @override
  String get recordsListNewest => '新しい順';

  @override
  String get recordsOpenDetail => '詳細を見る';

  @override
  String get recordsEmptyTitle => 'ワークアウト記録はまだありません';

  @override
  String get recordsEmptyBody => '最初のプランクワークアウトを終えると、ここに表示されます。';

  @override
  String get recordsStartWorkout => 'ワークアウトを開始';

  @override
  String get recordsLoading => 'ワークアウトを読み込み中…';

  @override
  String get recordsLoadError => 'ワークアウト記録を読み込めませんでした。';

  @override
  String get statsPeriod => '期間';

  @override
  String get statsPeriod7Days => '7日間';

  @override
  String get statsPeriod30Days => '30日間';

  @override
  String get statsPeriodThisMonth => '今月';

  @override
  String get statsPeriodAll => '全期間';

  @override
  String get statsPeriodCustom => '期間を指定';

  @override
  String get statsCustomRange => '日付範囲を選択';

  @override
  String get statsTotalReps => 'プランク合計時間';

  @override
  String get statsWorkoutDays => '運動した日数';

  @override
  String get statsTotalActiveTime => '合計運動時間';

  @override
  String get statsAverageSets => '平均セット数';

  @override
  String get statsAverageReps => '平均プランク秒数';

  @override
  String get statsDailyReps => '日別プランク時間';

  @override
  String get statsTrend => '推移';

  @override
  String get statsFrequentImprovements => 'よく見られた改善ポイント';

  @override
  String get statsNoData => 'この期間のワークアウトはありません。';

  @override
  String statsTrendUp(num percent) {
    return '$percent%増加';
  }

  @override
  String statsTrendDown(num percent) {
    return '$percent%減少';
  }

  @override
  String get statsTrendFlat => '変化なし';

  @override
  String get detailTitle => 'ワークアウト詳細';

  @override
  String get detailStartTime => '開始時刻';

  @override
  String get detailEndTime => '終了時刻';

  @override
  String get detailActiveTime => '運動時間';

  @override
  String get detailRestTime => '休憩時間';

  @override
  String get detailTotalTime => '合計時間';

  @override
  String get detailSets => 'セット';

  @override
  String get detailSetBreakdown => 'セット別保持時間';

  @override
  String get detailTotalReps => 'プランク合計時間';

  @override
  String get detailAverageRep => '平均ホールド区間';

  @override
  String get detailFormSummary => 'フォームのまとめ';

  @override
  String get detailImprovements => '改善ポイント';

  @override
  String get detailStrengths => '良かった点';

  @override
  String get detailInterrupted => '途中で終了';

  @override
  String get detailCompleted => '完了';

  @override
  String detailSetRow(int set, int reps) {
    return '$setセット：$reps秒';
  }

  @override
  String detailSessionOn(String date, String time) {
    return '$date $time';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsRateApp => 'このアプリを評価';

  @override
  String get settingsRateAppSubtitle => 'MotionFitを評価してください';

  @override
  String get settingsRateAppError => 'ストアを開けませんでした。もう一度お試しください。';

  @override
  String get settingsSectionGeneral => '一般';

  @override
  String get settingsSectionCoaching => '音声コーチング';

  @override
  String get settingsSectionReminder => 'ワークアウトリマインダー';

  @override
  String get settingsSectionCamera => 'カメラ';

  @override
  String get settingsSectionPrivacy => 'プライバシーとデータ';

  @override
  String get settingsSectionAbout => 'アプリ情報';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsDisplayTheme => '画面テーマ';

  @override
  String get settingsColorTheme => 'カラーテーマ';

  @override
  String get themeLight => 'ライト';

  @override
  String get themePureBlack => 'ピュアブラック';

  @override
  String get themeSystem => 'システム';

  @override
  String get colorThemeByeokcheong => '碧青色';

  @override
  String get colorThemeChuhyang => '秋香色';

  @override
  String get colorThemeJangdan => '長丹色';

  @override
  String get colorThemeCheonghyeon => '青玄色';

  @override
  String get colorThemeHaenghwang => '杏黄色';

  @override
  String get colorThemeChunyu => '春柳緑色';

  @override
  String get colorThemeSeolbaek => '雪白色';

  @override
  String get colorThemeByeokja => '碧紫色';

  @override
  String get colorThemeChwiram => '翠嵐色';

  @override
  String get languageSystem => '端末の言語を使用';

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
  String get languageChanged => '言語を変更しました';

  @override
  String get voiceCoachingEnabled => '音声コーチング';

  @override
  String get voiceRepCountEnabled => '秒数を読み上げる';

  @override
  String get voiceFormEnabled => 'フォームのアドバイス';

  @override
  String get voiceEncouragementEnabled => '励ましの音声';

  @override
  String get voiceRate => '読み上げ速度';

  @override
  String get voiceRateSlow => '遅い';

  @override
  String get voiceRateNormal => '標準';

  @override
  String get voiceRateFast => '速い';

  @override
  String get voiceTest => '音声をテスト';

  @override
  String get voiceTestPhrase => 'いいですね。音声コーチの準備ができました。';

  @override
  String get voiceUnavailable => 'この言語に対応するオフライン音声がインストールされていません。';

  @override
  String get reminderTitle => 'ワークアウトリマインダー';

  @override
  String get reminderSubtitle => '運動したい曜日ごとに時刻を選んでください。';

  @override
  String get reminderEnabled => 'リマインダーを有効にする';

  @override
  String get reminderTime => '通知時刻';

  @override
  String get reminderCopyTime => 'この時刻をコピー';

  @override
  String reminderCopyFromDay(String day) {
    return '$dayの時刻をコピー';
  }

  @override
  String get reminderApplyAll => 'すべての曜日に適用';

  @override
  String reminderNext(String dateTime) {
    return '次の通知：$dateTime';
  }

  @override
  String get reminderNoneScheduled => '予定されているリマインダーはありません';

  @override
  String get reminderPermissionNeeded => 'リマインダーをオンにするには通知を許可してください。';

  @override
  String get reminderSaved => 'リマインダーを保存しました';

  @override
  String get weekdayMonday => '月曜日';

  @override
  String get weekdayTuesday => '火曜日';

  @override
  String get weekdayWednesday => '水曜日';

  @override
  String get weekdayThursday => '木曜日';

  @override
  String get weekdayFriday => '金曜日';

  @override
  String get weekdaySaturday => '土曜日';

  @override
  String get weekdaySunday => '日曜日';

  @override
  String get weekdayMondayShort => '月';

  @override
  String get weekdayTuesdayShort => '火';

  @override
  String get weekdayWednesdayShort => '水';

  @override
  String get weekdayThursdayShort => '木';

  @override
  String get weekdayFridayShort => '金';

  @override
  String get weekdaySaturdayShort => '土';

  @override
  String get weekdaySundayShort => '日';

  @override
  String get cameraFront => 'フロントカメラ';

  @override
  String get cameraRear => 'リアカメラ';

  @override
  String get cameraMirrorPreview => 'フロント映像を左右反転';

  @override
  String get cameraPoseOverlay => '姿勢ガイドのオーバーレイ';

  @override
  String get cameraKeepScreenAwake => 'ワークアウト中は画面をオンにする';

  @override
  String get settingsHaptics => '触覚フィードバック';

  @override
  String get privacyTitle => 'データの取り扱い';

  @override
  String get privacyLocalProcessing => '姿勢分析はこの端末上で行われます。';

  @override
  String get privacyNoVideoStorage =>
      'ホールド区間動画レビューをオンにした場合のみ、ワークアウト動画を端末に保存します。';

  @override
  String get privacyNoUpload => 'カメラのフレームはサーバーへ送信されません。';

  @override
  String get privacyStoredData => 'この端末に保存されるデータ';

  @override
  String get privacyStoredDataDescription =>
      '進捗を確認できるよう、運動時間、セット、保持時間、フォーム結果を保存します。';

  @override
  String get privacyDeleteData => 'すべてのワークアウトデータを削除';

  @override
  String get privacyDeleteConfirmTitle => 'すべてのワークアウトデータを削除しますか？';

  @override
  String get privacyDeleteConfirmBody =>
      'この端末のワークアウト履歴が完全に削除されます。この操作は取り消せません。';

  @override
  String get privacyDeleteConfirmAction => 'すべてのデータを削除';

  @override
  String get privacyDeleteSuccess => 'ワークアウトデータを削除しました';

  @override
  String get privacyDeleteFailure => 'ワークアウトデータを削除できませんでした。';

  @override
  String get appInfoTitle => 'アプリ情報';

  @override
  String appInfoVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get appInfoLicenses => 'オープンソースライセンス';

  @override
  String get appInfoPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get appInfoDescription => 'MotionFitは端末上でプランクの時間と姿勢を分析します。';

  @override
  String get errorGenericTitle => '問題が発生しました';

  @override
  String get errorGenericBody => 'もう一度お試しください。これまでのワークアウト記録は安全です。';

  @override
  String get errorCameraInit => 'カメラを起動できませんでした。';

  @override
  String get errorCameraInUse => '別のアプリがカメラを使用している可能性があります。';

  @override
  String get errorPoseModelLoad => '姿勢検出モデルを読み込めませんでした。';

  @override
  String get errorNoPerson => '人を検出できません。画面内に入ってください。';

  @override
  String get errorWholeBody => '全身が映っていません。少し後ろへ移動してください。';

  @override
  String get errorMultiplePeople => '複数の人が映っています。画面には1人だけ入ってください。';

  @override
  String get errorTrackingLost => '全身が再び見えるまで検出を一時停止します。';

  @override
  String get errorDatabaseSave => 'ワークアウトを保存できませんでした。';

  @override
  String get errorTtsVoiceMissing => 'この端末に読み上げ音声がインストールされていません。';

  @override
  String get errorTtsLocaleUnsupported => 'この端末では、選択した言語の音声コーチングに対応していません。';

  @override
  String get emptyNoFormIssues => '繰り返し見られるフォームの問題はありませんでした。';

  @override
  String get emptyNotEnoughData => 'まだデータが足りません';

  @override
  String get loadingCamera => 'カメラを起動中…';

  @override
  String get loadingPoseModel => '動きの検出を準備中…';

  @override
  String get loadingSavingWorkout => 'ワークアウトを保存中…';

  @override
  String get formScore => 'フォームスコア';

  @override
  String get formShort => 'フォーム';

  @override
  String formScoreValue(int score) {
    return '$score点';
  }

  @override
  String get formIssueDepth => '腰を肩の高さに合わせましょう。';

  @override
  String get formIssueTorsoLean => '体幹に力を入れて背中をまっすぐに。';

  @override
  String get formIssueHeelLift => 'かかとの接地';

  @override
  String get formIssueKneeAlignment => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get formIssueBalance => '左右のバランス';

  @override
  String get formIssueDescentSpeed => '下がる速さ';

  @override
  String get formIssueAscentSpeed => '上がる速さ';

  @override
  String get formIssueControl => '体幹に力を入れて背中をまっすぐに。';

  @override
  String get formIssueStandingCompletion => '最後まで立つ';

  @override
  String get formIssueNotObservable => 'このカメラ角度では評価できません';

  @override
  String get formStrengthDepth => '安定した深さ';

  @override
  String get formStrengthControl => 'コントロールされた動き';

  @override
  String get formStrengthBalance => '安定したバランス';

  @override
  String get coachTrackingLost1 => '画面内に戻れば、そのまま続けられます。';

  @override
  String get coachTrackingLost2 => '姿が見えなくなりました。全身が映る位置に移動してください。';

  @override
  String get coachWholeBody1 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachWholeBody2 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachMultiplePeople1 => '正確に検出できるよう、画面には1人だけ入ってください。';

  @override
  String get coachReady1 => '位置はばっちりです。始めましょう。';

  @override
  String get coachReady2 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String coachStartSet(int set) {
    return '$setセット目、始めましょう。';
  }

  @override
  String coachSevenDayChallengeStart(int day) {
    return '7日間チャレンジの$day日目を開始します。';
  }

  @override
  String coachCumulativeChallengeStart(int completed, int remaining) {
    return '累積秒数チャレンジを開始します。現在$completed秒完了、残り$remaining秒です。';
  }

  @override
  String coachRepCount(int count) {
    return '$count秒';
  }

  @override
  String get coachDepth1 => '腰を肩の高さに合わせましょう。';

  @override
  String get coachDepth2 => '腰を肩の高さに合わせましょう。';

  @override
  String get coachTorso1 => '体幹に力を入れて背中をまっすぐに。';

  @override
  String get coachTorso2 => '体幹に力を入れて背中をまっすぐに。';

  @override
  String get coachHeel1 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachHeel2 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachKnees1 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachKnees2 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachBalance1 => '体幹に力を入れて背中をまっすぐに。';

  @override
  String get coachBalance2 => '体幹に力を入れて背中をまっすぐに。';

  @override
  String get coachDescendSlow1 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachDescendSlow2 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachDescendFaster1 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachDescendFaster2 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachAscendControlled1 => '腰を肩の高さに合わせましょう。';

  @override
  String get coachAscendControlled2 => '腰を肩の高さに合わせましょう。';

  @override
  String get coachAscendFaster1 => '腰を肩の高さに合わせましょう。';

  @override
  String get coachAscendFaster2 => '腰を肩の高さに合わせましょう。';

  @override
  String get coachControl1 => '体幹に力を入れて背中をまっすぐに。';

  @override
  String get coachControl2 => '体幹に力を入れて背中をまっすぐに。';

  @override
  String get coachStandTall1 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachStandTall2 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachGood1 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachGood2 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachGood3 => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get coachLastTwo => 'あと2秒です。そのまま！';

  @override
  String get coachLastOne => 'あと1秒です。最後まで！';

  @override
  String coachSetComplete(int set) {
    return 'いいですね。$setセット目が終わりました。';
  }

  @override
  String coachRestStart(int seconds) {
    return '$seconds秒休憩します。呼吸を整えましょう。';
  }

  @override
  String get coachRestTenSeconds => '休憩はあと10秒です。';

  @override
  String get coachRestComplete => '休憩終了です。次のセットを準備してください。';

  @override
  String coachWorkoutComplete(int reps) {
    return 'ワークアウト完了。プランクを$reps秒キープしました。';
  }

  @override
  String get notificationReminderTitle => '今日のプランクの時間です';

  @override
  String get notificationReminderBody => '短い時間でも大丈夫。準備ができたらMotionFitを開きましょう。';

  @override
  String get notificationReminderBodyVariant2 => '短時間のプランクでも、今日の良い運動になります。';

  @override
  String notificationStreakReminderBody(int days) {
    return '今日も短く運動して、$days日連続記録を守りましょう。';
  }

  @override
  String get semanticsIncrease => '増やす';

  @override
  String get semanticsDecrease => '減らす';

  @override
  String semanticsSelectedTab(String tab) {
    return '選択中のタブ：$tab';
  }

  @override
  String semanticsCalendarWorkoutDate(String date) {
    return '$date、ワークアウト記録あり';
  }

  @override
  String semanticsCalendarEmptyDate(String date) {
    return '$date、ワークアウト記録なし';
  }

  @override
  String semanticsCurrentRep(int current, int target) {
    return '現在$target秒中$current秒';
  }

  @override
  String get repVideoReviewTitle => 'ホールド区間動画レビュー';

  @override
  String get repVideoReviewDescription =>
      'ワークアウト動画をこの端末に保存し、あとで各ホールド区間を確認できます。';

  @override
  String get repVideoLocalOnly => '端末内のみ・アップロードなし';

  @override
  String get formReviewTitle => 'フォームレビュー';

  @override
  String get formReviewMainIssue => '主な課題';

  @override
  String get viewRepTimeline => 'ホールド区間タイムラインを見る';

  @override
  String get repTimelineTitle => 'ホールド区間レビュー';

  @override
  String get repTimelineAll => 'すべて';

  @override
  String get repTimelineImprove => '改善';

  @override
  String get repTimelineNoImprovement => '改善が必要なホールド区間はありません。';

  @override
  String repSetNumber(int number) {
    return 'セット $number';
  }

  @override
  String repNumber(int number) {
    return '$number秒区間';
  }

  @override
  String get repResultGood => '良いフォーム';

  @override
  String get repResultNeedsAttention => '要確認';

  @override
  String get repResultImproved => '前のホールド区間より改善';

  @override
  String get repResultNotAssessed => '評価が難しい';

  @override
  String get repIssueShallowDepth => '腰を肩の高さに合わせましょう。';

  @override
  String get repIssueForwardLean => '体幹に力を入れて背中をまっすぐに。';

  @override
  String get repIssueKneesInward => '膝が内側に動きました';

  @override
  String get repVideoNotSaved => '動画は保存されていません';

  @override
  String get repReplay => 'もう一度再生';

  @override
  String get repWhatHappened => '動きの確認';

  @override
  String get repHowToImprove => '改善のポイント';

  @override
  String get repWhatWentWell => '良かった点';

  @override
  String get repPrevious => '前のホールド区間';

  @override
  String get repNext => '次のホールド区間';

  @override
  String get repFeedbackGood => '肩、腰、かかとを一直線に保ちましょう。';

  @override
  String get repFeedbackDepth => '腰を肩の高さに合わせましょう。';

  @override
  String get repFeedbackTorso => '体幹に力を入れて背中をまっすぐに。';

  @override
  String get repFeedbackKnees => 'ホールド中に膝が曲がりました。脚をやさしく伸ばしましょう。';

  @override
  String repFeedbackGeneric(String area) {
    return 'このホールド区間では$areaを確認しましょう。';
  }

  @override
  String get deleteWorkoutVideo => 'ワークアウト動画を削除';

  @override
  String get deleteWorkoutVideoTitle => 'この動画を削除しますか？';

  @override
  String get deleteWorkoutVideoBody => '端末内の動画のみ削除されます。ホールド区間分析と記録は残ります。';

  @override
  String get workoutVideoDeleted => 'ワークアウト動画を削除しました';
}
