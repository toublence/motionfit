# Firebase 이벤트 전체 매핑 — 2026-09-14

대상: 제공된 이벤트 표 132행과 현재 작업 트리. 호출 위치는 정적 코드 조사이며 실행 여부·해당 과거 배포 버전의 실제 호출을 보증하지 않는다. 자동 SDK 이벤트는 아래 공식 정의를 기준으로 분류했다. 현 코드에 없는 과거 이벤트는 이름만 보고 발생 조건을 만들어내지 않았다.

[Google 자동 수집 이벤트 정의](https://support.google.com/analytics/answer/9234069?hl=en-AU). 광고·SDK 자동 이벤트의 BigQuery export 여부는 이벤트별로 다르므로 콘솔/AdMob 보고서와 구분한다.

## 전체 목록

| 원본 순위 | 이벤트 | 횟수 | 총 사용자 | 현 코드 분류 |
|---:|---|---:|---:|---|
| 1 | `screen_view` | 4,371 | 262 | 수동 화면 + SDK 화면 |
| 2 | `user_engagement` | 2,044 | 227 | SDK 자동 수집 계열 |
| 3 | `mf2_ad_request_attempted` | 1,646 | 174 | 직접 연결: 아래 상세 |
| 4 | `mf2_workout_setup_viewed` | 1,130 | 180 | 직접 연결: 아래 상세 |
| 5 | `motionfit_ads_log` | 835 | 9 | 현 코드 직접 발생 없음 |
| 6 | `mf2_onboarding_step_viewed` | 554 | 194 | 직접 연결: 아래 상세 |
| 7 | `mf2_onboarding_next_tapped` | 467 | 170 | 직접 연결: 아래 상세 |
| 8 | `mf2_workout_start_tapped` | 437 | 143 | 직접 연결: 아래 상세 |
| 9 | `mf2_camera_permission_result` | 421 | 134 | 직접 연결: 아래 상세 |
| 10 | `motionfit_app_open` | 391 | 232 | 직접 연결: 아래 상세 |
| 11 | `mf2_camera_init_started` | 390 | 127 | 직접 연결: 아래 상세 |
| 12 | `session_start` | 379 | 261 | SDK 자동 수집 계열 |
| 13 | `mf2_camera_init_completed` | 336 | 108 | 직접 연결: 아래 상세 |
| 14 | `mf2_challenge_tab_viewed` | 300 | 115 | 직접 연결: 아래 상세 |
| 15 | `mf2_workout_screen_viewed` | 296 | 103 | 직접 연결: 아래 상세 |
| 16 | `mf2_ad_skipped_by_policy` | 295 | 179 | 직접 연결: 아래 상세 |
| 17 | `mf2_calibration_started` | 289 | 104 | 직접 연결: 아래 상세 |
| 18 | `mf2_workout_cancelled` | 237 | 102 | 직접 연결: 아래 상세 |
| 19 | `first_open` | 227 | 227 | SDK 자동 수집 계열 |
| 20 | `mf2_onboarding_started` | 196 | 193 | 직접 연결: 아래 상세 |
| 21 | `mf2_onboarding_completed` | 168 | 168 | 직접 연결: 아래 상세 |
| 22 | `mf2_calibration_completed` | 161 | 56 | 직접 연결: 아래 상세 |
| 23 | `mf2_workout_started` | 155 | 56 | 직접 연결: 아래 상세 |
| 24 | `mf2_first_rep_detected` | 150 | 54 | 직접 연결: 아래 상세 |
| 25 | `mf2_rep_clip_played` | 144 | 12 | 직접 연결: 아래 상세 |
| 26 | `exercise_card_impression` | 138 | 9 | 현 코드 직접 발생 없음 |
| 27 | `mf2_rep_timeline_viewed` | 130 | 39 | 직접 연결: 아래 상세 |
| 28 | `mf2_camera_permission_requested` | 110 | 110 | 직접 연결: 아래 상세 |
| 29 | `ad_impression` | 102 | 23 | SDK 자동 수집 계열 |
| 30 | `mf2_workout_completed` | 94 | 39 | 직접 연결: 아래 상세 |
| 31 | `mf2_workout_detection_summary` | 94 | 39 | 직접 연결: 아래 상세 |
| 32 | `mf2_workout_summary_viewed` | 87 | 37 | 직접 연결: 아래 상세 |
| 33 | `app_remove` | 75 | 75 | SDK 자동 수집 계열 |
| 34 | `mf2_review_request_skipped` | 62 | 31 | 직접 연결: 아래 상세 |
| 35 | `mf2_challenge_selected` | 50 | 30 | 직접 연결: 아래 상세 |
| 36 | `mf2_reminder_permission_result` | 45 | 13 | 직접 연결: 아래 상세 |
| 37 | `mf2_challenge_recommendation_viewed` | 39 | 19 | 직접 연결: 아래 상세 |
| 38 | `main_tab_view` | 37 | 9 | 현 코드 직접 발생 없음 |
| 39 | `motionfit_screen_view` | 37 | 9 | 현 코드 직접 발생 없음 |
| 40 | `route_view` | 37 | 9 | 현 코드 직접 발생 없음 |
| 41 | `mf2_reminder_prompt_shown` | 36 | 36 | 직접 연결: 아래 상세 |
| 42 | `mf2_challenge_workout_started` | 34 | 15 | 직접 연결: 아래 상세 |
| 43 | `mf2_workout_interrupted` | 31 | 21 | 직접 연결: 아래 상세 |
| 44 | `mf2_reminder_enabled` | 30 | 8 | 직접 연결: 아래 상세 |
| 45 | `mf2_camera_init_failed` | 29 | 15 | 직접 연결: 아래 상세 |
| 46 | `app_update` | 26 | 25 | SDK 자동 수집 계열 |
| 47 | `native_ad_request_started` | 24 | 3 | 현 코드 직접 발생 없음 |
| 48 | `home_view` | 23 | 9 | 현 코드 직접 발생 없음 |
| 49 | `mf2_challenge_started` | 21 | 15 | 직접 연결: 아래 상세 |
| 50 | `mf2_workout_failed` | 20 | 14 | 직접 연결: 아래 상세 |
| 51 | `app_open` | 19 | 9 | 현 코드 직접 발생 없음 |
| 52 | `device_media_volume_checked` | 19 | 3 | 현 코드 직접 발생 없음 |
| 53 | `entry_source_resolved` | 19 | 9 | 현 코드 직접 발생 없음 |
| 54 | `mf2_second_workout_completed` | 18 | 16 | 직접 연결: 아래 상세 |
| 55 | `mf2_manual_rate_tapped` | 17 | 16 | 직접 연결: 아래 상세 |
| 56 | `native_ad_eligible` | 16 | 3 | 현 코드 직접 발생 없음 |
| 57 | `app_exception` | 14 | 7 | SDK 자동 수집 계열 |
| 58 | `workout_ad_failed` | 14 | 1 | 현 코드 직접 발생 없음 |
| 59 | `mf2_review_request_eligible` | 13 | 10 | 직접 연결: 아래 상세 |
| 60 | `mf2_review_store_opened` | 13 | 13 | 직접 연결: 아래 상세 |
| 61 | `os_update` | 13 | 12 | SDK 자동 수집 계열 |
| 62 | `audio_readiness_card_shown` | 12 | 3 | 현 코드 직접 발생 없음 |
| 63 | `volume_hint_not_counted_as_voice_trial` | 12 | 3 | 현 코드 직접 발생 없음 |
| 64 | `volume_hint_shown` | 12 | 3 | 현 코드 직접 발생 없음 |
| 65 | `workout_ad_request_started` | 12 | 1 | 현 코드 직접 발생 없음 |
| 66 | `ad_preload_failed` | 11 | 1 | 현 코드 직접 발생 없음 |
| 67 | `ad_preload_started` | 11 | 1 | 현 코드 직접 발생 없음 |
| 68 | `mf2_calibration_failed` | 11 | 6 | 직접 연결: 아래 상세 |
| 69 | `native_ad_failed` | 10 | 2 | 현 코드 직접 발생 없음 |
| 70 | `exercise_card_click` | 9 | 4 | 현 코드 직접 발생 없음 |
| 71 | `mf2_review_request_attempted` | 9 | 9 | 직접 연결: 아래 상세 |
| 72 | `pose_detection_started` | 9 | 4 | 현 코드 직접 발생 없음 |
| 73 | `pose_detection_waiting` | 9 | 4 | 현 코드 직접 발생 없음 |
| 74 | `workout_screen_entered` | 9 | 4 | 현 코드 직접 발생 없음 |
| 75 | `workout_selected` | 9 | 4 | 현 코드 직접 발생 없음 |
| 76 | `device_media_volume_low_detected` | 7 | 1 | 현 코드 직접 발생 없음 |
| 77 | `mf2_workout_resumed` | 7 | 6 | 직접 연결: 아래 상세 |
| 78 | `voice_coaching_volume_warning_shown` | 7 | 1 | 현 코드 직접 발생 없음 |
| 79 | `workout_session_start` | 7 | 1 | 현 코드 직접 발생 없음 |
| 80 | `workout_volume_hint_shown` | 7 | 3 | 현 코드 직접 발생 없음 |
| 81 | `camera_permission_granted` | 6 | 1 | 현 코드 직접 발생 없음 |
| 82 | `camera_permission_requested` | 6 | 1 | 현 코드 직접 발생 없음 |
| 83 | `workout_session_created` | 6 | 1 | 현 코드 직접 발생 없음 |
| 84 | `workout_started` | 6 | 1 | 현 코드 직접 발생 없음 |
| 85 | `category_tab_click` | 5 | 1 | 현 코드 직접 발생 없음 |
| 86 | `mf2_reminder_prompt_declined` | 5 | 5 | 직접 연결: 아래 상세 |
| 87 | `workout_session_exit` | 5 | 1 | 현 코드 직접 발생 없음 |
| 88 | `camera_setup_exit_before_ready` | 4 | 1 | 현 코드 직접 발생 없음 |
| 89 | `mf2_onboarding_abandoned` | 4 | 4 | 직접 연결: 아래 상세 |
| 90 | `rep0_exit_with_camera_issue` | 4 | 1 | 현 코드 직접 발생 없음 |
| 91 | `voice_coaching_session_unlocked` | 4 | 1 | 현 코드 직접 발생 없음 |
| 92 | `voice_trial_reserved` | 4 | 1 | 현 코드 직접 발생 없음 |
| 93 | `workout_pose_blocked` | 4 | 1 | 현 코드 직접 발생 없음 |
| 94 | `ad_show_blocked` | 3 | 1 | 현 코드 직접 발생 없음 |
| 95 | `camera_setup_volume_hint_shown` | 3 | 1 | 현 코드 직접 발생 없음 |
| 96 | `first_workout_abandoned` | 3 | 3 | 현 코드 직접 발생 없음 |
| 97 | `first_workout_exit_reason` | 3 | 3 | 현 코드 직접 발생 없음 |
| 98 | `settings_view` | 3 | 1 | 현 코드 직접 발생 없음 |
| 99 | `workout_pose_ready` | 3 | 2 | 현 코드 직접 발생 없음 |
| 100 | `audio_readiness_volume_changed` | 2 | 1 | 현 코드 직접 발생 없음 |
| 101 | `mf2_challenge_cancelled` | 2 | 2 | 직접 연결: 아래 상세 |
| 102 | `mf2_store_review_page_failed` | 2 | 2 | 직접 연결: 아래 상세 |
| 103 | `mf2_store_review_page_opened` | 2 | 1 | 현 코드 직접 발생 없음 |
| 104 | `premium_tab_view` | 2 | 1 | 현 코드 직접 발생 없음 |
| 105 | `ad_click` | 1 | 1 | SDK 자동 수집 계열 |
| 106 | `ad_eligible` | 1 | 1 | 현 코드 직접 발생 없음 |
| 107 | `first_rep_counted` | 1 | 1 | 현 코드 직접 발생 없음 |
| 108 | `first_workout_onboarding_viewed` | 1 | 1 | 현 코드 직접 발생 없음 |
| 109 | `first_workout_skipped` | 1 | 1 | 현 코드 직접 발생 없음 |
| 110 | `first_workout_volume_hint_shown` | 1 | 1 | 현 코드 직접 발생 없음 |
| 111 | `mf2_challenge_recommendation_dismissed` | 1 | 1 | 직접 연결: 아래 상세 |
| 112 | `mf2_reminder_prompt_accepted` | 1 | 1 | 직접 연결: 아래 상세 |
| 113 | `native_ad_skipped_pose_not_ready` | 1 | 1 | 현 코드 직접 발생 없음 |
| 114 | `paywall_view` | 1 | 1 | 현 코드 직접 발생 없음 |
| 115 | `paywall_view_source_resolved` | 1 | 1 | 현 코드 직접 발생 없음 |
| 116 | `save_result_cta_shown` | 1 | 1 | 현 코드 직접 발생 없음 |
| 117 | `set_completed` | 1 | 1 | 현 코드 직접 발생 없음 |
| 118 | `voice_coaching_option_shown` | 1 | 1 | 현 코드 직접 발생 없음 |
| 119 | `voice_trial_not_charged_camera_setup_exi` | 1 | 1 | 현 코드 직접 발생 없음 |
| 120 | `voice_trial_not_consumed` | 1 | 1 | 현 코드 직접 발생 없음 |
| 121 | `voice_trial_released_before_use` | 1 | 1 | 현 코드 직접 발생 없음 |
| 122 | `workout_ad_gate_entered` | 1 | 1 | 현 코드 직접 발생 없음 |
| 123 | `workout_complete_feedback_prompt_dismiss` | 1 | 1 | 현 코드 직접 발생 없음 |
| 124 | `workout_completed` | 1 | 1 | 현 코드 직접 발생 없음 |
| 125 | `workout_helpfulness_prompt_shown` | 1 | 1 | 현 코드 직접 발생 없음 |
| 126 | `workout_report_close_clicked` | 1 | 1 | 현 코드 직접 발생 없음 |
| 127 | `workout_report_home_clicked` | 1 | 1 | 현 코드 직접 발생 없음 |
| 128 | `workout_report_opened_directly` | 1 | 1 | 현 코드 직접 발생 없음 |
| 129 | `workout_report_viewed` | 1 | 1 | 현 코드 직접 발생 없음 |
| 130 | `workout_result_save_skipped` | 1 | 1 | 현 코드 직접 발생 없음 |
| 131 | `workout_result_view` | 1 | 1 | 현 코드 직접 발생 없음 |
| 132 | `workout_session_complete` | 1 | 1 | 현 코드 직접 발생 없음 |

## 현재 코드에서 직접 연결되는 이벤트

운동 공통 guard: `_workoutSession==null`이면 생략. oncePerSession=true인 이벤트는 이름별 한 번. terminal=true는 completed/cancelled/failed 중 최초 하나. setup, second milestone, 일반 challenge/알림/리뷰/광고 이벤트는 이 운동 once guard를 공통 적용하지 않는다.

### 3. `mf2_ad_request_attempted` — 1,646회 / 174명

- 정의: [AnalyticsService.adRequested](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:624).
- 발생 조건: NativeAd.load/InterstitialAd.load 직전. 형식/placement/완료 횟수 문맥; 실패 재시도 포함.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/core/ads/ad_service.dart:248](/Users/nam/projects/motionfit/lib/core/ads/ad_service.dart:248)
  - [lib/core/ads/bottom_native_ad.dart:132](/Users/nam/projects/motionfit/lib/core/ads/bottom_native_ad.dart:132)

### 4. `mf2_workout_setup_viewed` — 1,130회 / 180명

- 정의: [AnalyticsService.workoutSetupViewed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:211).
- 발생 조건: 종목 홈 initState post-frame에서 계획 조회 후. 위젯 인스턴스 생성 기준; 세션 ID 없음; home/challenge_active=0 고정.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/plank/workout/presentation/screens/plank_home_screen.dart:39](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/plank_home_screen.dart:39)
  - [lib/features/pushup/presentation/screens/pushup_home_screen.dart:41](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/pushup_home_screen.dart:41)
  - [lib/features/squat/presentation/screens/squat_home_screen.dart:39](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/squat_home_screen.dart:39)

### 6. `mf2_onboarding_step_viewed` — 554회 / 194명

- 정의: [AnalyticsService.onboardingStepViewed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:139).
- 발생 조건: 첫 페이지 0과 PageView onPageChanged 때. 앞뒤 이동/재노출을 포함한다.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/onboarding/presentation/onboarding_screen.dart:135](/Users/nam/projects/motionfit/lib/features/onboarding/presentation/onboarding_screen.dart:135)
  - [lib/features/onboarding/presentation/onboarding_screen.dart:153](/Users/nam/projects/motionfit/lib/features/onboarding/presentation/onboarding_screen.dart:153)

### 7. `mf2_onboarding_next_tapped` — 467회 / 170명

- 정의: [AnalyticsService.onboardingNextTapped](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:151).
- 발생 조건: 계속 버튼 _continue 진입 즉시. 마지막 페이지 저장 실패여도 탭 이벤트는 이미 발생한다.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/onboarding/presentation/onboarding_screen.dart:170](/Users/nam/projects/motionfit/lib/features/onboarding/presentation/onboarding_screen.dart:170)

### 8. `mf2_workout_start_tapped` — 437회 / 143명

- 정의: [AnalyticsService.workoutStartTapped](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:223).
- 발생 조건: openWorkoutPreparation 진입 즉시, 권한 조회 전에 새 분석 UUID 생성. 일반·챌린지·복구 포함.
- 전송 규칙: 운동 문맥 필수.
- production 호출 위치:
  - [lib/features/plank/workout/presentation/workout_preparation_launcher.dart:17](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/workout_preparation_launcher.dart:17)
  - [lib/features/pushup/presentation/workout_preparation_launcher.dart:16](/Users/nam/projects/motionfit/lib/features/pushup/presentation/workout_preparation_launcher.dart:16)
  - [lib/features/squat/presentation/workout_preparation_launcher.dart:16](/Users/nam/projects/motionfit/lib/features/squat/presentation/workout_preparation_launcher.dart:16)

### 9. `mf2_camera_permission_result` — 421회 / 134명

- 정의: [AnalyticsService.cameraPermissionResult](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:250).
- 발생 조건: 이미 허용된 launcher 경로 또는 PermissionScreen의 요청/상태 갱신 결과. requested=false도 포함. 화면 안에서는 같은 상태 중복을 억제한다.
- 전송 규칙: 운동 문맥 필수.
- production 호출 위치:
  - [lib/features/plank/workout/presentation/screens/camera_permission_screen.dart:109](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/camera_permission_screen.dart:109)
  - [lib/features/plank/workout/presentation/screens/camera_permission_screen.dart:145](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/camera_permission_screen.dart:145)
  - [lib/features/plank/workout/presentation/workout_preparation_launcher.dart:40](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/workout_preparation_launcher.dart:40)
  - [lib/features/pushup/presentation/screens/camera_permission_screen.dart:107](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/camera_permission_screen.dart:107)
  - [lib/features/pushup/presentation/screens/camera_permission_screen.dart:143](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/camera_permission_screen.dart:143)
  - [lib/features/pushup/presentation/workout_preparation_launcher.dart:39](/Users/nam/projects/motionfit/lib/features/pushup/presentation/workout_preparation_launcher.dart:39)
  - [lib/features/squat/presentation/screens/camera_permission_screen.dart:107](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/camera_permission_screen.dart:107)
  - [lib/features/squat/presentation/screens/camera_permission_screen.dart:143](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/camera_permission_screen.dart:143)
  - [lib/features/squat/presentation/workout_preparation_launcher.dart:39](/Users/nam/projects/motionfit/lib/features/squat/presentation/workout_preparation_launcher.dart:39)

### 10. `motionfit_app_open` — 391회 / 232명

- 정의: [AnalyticsService.appOpened](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:123).
- 발생 조건: main()의 Firebase 초기화 후, runApp 이전 flutter_bootstrap 호출. 프로세스 bootstrap이며 모든 foreground 복귀를 뜻하지 않는다.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/main.dart:151](/Users/nam/projects/motionfit/lib/main.dart:151)

### 11. `mf2_camera_init_started` — 390회 / 127명

- 정의: [AnalyticsService.cameraInitializationStarted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:261).
- 발생 조건: Controller._startEngines 시작. 카메라/모델/TTS를 구성하기 전. prewarm, 재시도 등 공통 함수이나 시도당 한 번만 기록.
- 전송 규칙: 운동 문맥 필수, 이벤트명별 once/session.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:659](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:659)
  - [lib/features/pushup/application/workout_session_controller.dart:659](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:659)
  - [lib/features/squat/application/workout_session_controller.dart:662](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:662)

### 13. `mf2_camera_init_completed` — 336회 / 108명

- 정의: [AnalyticsService.cameraInitializationCompleted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:264).
- 발생 조건: _startEngines에서 pose 초기화와 voice 구성 Future를 기다린 뒤. 실제 pose 검출/보정 완료는 보장하지 않음.
- 전송 규칙: 운동 문맥 필수, 이벤트명별 once/session.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:723](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:723)
  - [lib/features/pushup/application/workout_session_controller.dart:723](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:723)
  - [lib/features/squat/application/workout_session_controller.dart:726](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:726)

### 14. `mf2_challenge_tab_viewed` — 300회 / 115명

- 정의: [AnalyticsService.challengeTabViewed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:562).
- 발생 조건: ChallengeScreen.build에서 dashboard AsyncData를 처음 읽을 때 _viewLogged guard. 탭 재클릭마다 아님.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/challenges/presentation/challenge_screen.dart:54](/Users/nam/projects/motionfit/lib/features/challenges/presentation/challenge_screen.dart:54)
  - [lib/features/plank/challenges/presentation/challenge_screen.dart:54](/Users/nam/projects/motionfit/lib/features/plank/challenges/presentation/challenge_screen.dart:54)
  - [lib/features/pushup/challenges/presentation/challenge_screen.dart:54](/Users/nam/projects/motionfit/lib/features/pushup/challenges/presentation/challenge_screen.dart:54)

### 15. `mf2_workout_screen_viewed` — 296회 / 103명

- 정의: [AnalyticsService.workoutScreenViewed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:292).
- 발생 조건: ActiveWorkoutScreen.initState. 보정/에러 상태로 화면에 들어와도 발생; 운동 실제 시작 아님.
- 전송 규칙: 운동 문맥 필수, 이벤트명별 once/session.
- production 호출 위치:
  - [lib/features/plank/workout/presentation/screens/active_workout_screen.dart:42](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/active_workout_screen.dart:42)
  - [lib/features/pushup/presentation/screens/active_workout_screen.dart:40](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/active_workout_screen.dart:40)
  - [lib/features/squat/presentation/screens/active_workout_screen.dart:39](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/active_workout_screen.dart:39)

### 16. `mf2_ad_skipped_by_policy` — 295회 / 179명

- 정의: [AnalyticsService.adSkippedByPolicy](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:668).
- 발생 조건: 전면광고 최초 완료 전/10분 cooldown에서 실제 return. 별도로 App._runPrivacyConsentRefresh는 completed<1 이벤트를 보내지만 광고 초기화를 계속하므로 format=all skip이 실제 전체 생략과 다름.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/app/app.dart:237](/Users/nam/projects/motionfit/lib/app/app.dart:237)
  - [lib/core/ads/ad_service.dart:91](/Users/nam/projects/motionfit/lib/core/ads/ad_service.dart:91)
  - [lib/core/ads/ad_service.dart:109](/Users/nam/projects/motionfit/lib/core/ads/ad_service.dart:109)

### 17. `mf2_calibration_started` — 289회 / 104명

- 정의: [AnalyticsService.calibrationStarted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:299).
- 발생 조건: 일반 Controller.start에서 세션 준비 후, createSession/journal/영상 시작 전. 물리적 보정은 prewarm에서 먼저 시작 가능. recover에는 대응 직접 호출 없음.
- 전송 규칙: 운동 문맥 필수, 이벤트명별 once/session.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:354](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:354)
  - [lib/features/pushup/application/workout_session_controller.dart:354](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:354)
  - [lib/features/squat/application/workout_session_controller.dart:357](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:357)

### 18. `mf2_workout_cancelled` — 237회 / 102명

- 정의: [AnalyticsService.workoutCancelled](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:372).
- 발생 조건: Permission/Guide/Countdown에서 사용자가 나가거나 Controller에서 유효 중단 종료·0회 오류 없는 폐기. stage/reason/시간은 경로별로 다름. terminal 중복 방지 적용.
- 전송 규칙: 운동 문맥 필수, terminal 중복 방지.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:1786](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:1786)
  - [lib/features/plank/workout/application/workout_session_controller.dart:1878](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:1878)
  - [lib/features/plank/workout/presentation/screens/camera_guide_screen.dart:41](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/camera_guide_screen.dart:41)
  - [lib/features/plank/workout/presentation/screens/camera_permission_screen.dart:61](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/camera_permission_screen.dart:61)
  - [lib/features/plank/workout/presentation/screens/workout_countdown_screen.dart:201](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/workout_countdown_screen.dart:201)
  - [lib/features/pushup/application/workout_session_controller.dart:1782](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:1782)
  - [lib/features/pushup/application/workout_session_controller.dart:1874](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:1874)
  - [lib/features/pushup/presentation/screens/camera_guide_screen.dart:37](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/camera_guide_screen.dart:37)
  - [lib/features/pushup/presentation/screens/camera_permission_screen.dart:59](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/camera_permission_screen.dart:59)
  - [lib/features/pushup/presentation/screens/workout_countdown_screen.dart:199](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/workout_countdown_screen.dart:199)
  - [lib/features/squat/application/workout_session_controller.dart:1787](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:1787)
  - [lib/features/squat/application/workout_session_controller.dart:1879](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:1879)
  - [lib/features/squat/presentation/screens/camera_guide_screen.dart:37](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/camera_guide_screen.dart:37)
  - [lib/features/squat/presentation/screens/camera_permission_screen.dart:59](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/camera_permission_screen.dart:59)
  - [lib/features/squat/presentation/screens/workout_countdown_screen.dart:197](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/workout_countdown_screen.dart:197)

### 20. `mf2_onboarding_started` — 196회 / 193명

- 정의: [AnalyticsService.onboardingStarted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:136).
- 발생 조건: _startOnboardingSession에서 시작. 이전 미완료 기록이 있으면 먼저 abandoned를 전송한다.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/onboarding/presentation/onboarding_screen.dart:134](/Users/nam/projects/motionfit/lib/features/onboarding/presentation/onboarding_screen.dart:134)

### 21. `mf2_onboarding_completed` — 168회 / 168명

- 정의: [AnalyticsService.onboardingComplete](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:188).
- 발생 조건: 마지막 페이지에서 completeOnboarding 저장 성공 후. iOS ATT 요청과 홈 이동보다 먼저 발생한다.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/onboarding/presentation/onboarding_screen.dart:192](/Users/nam/projects/motionfit/lib/features/onboarding/presentation/onboarding_screen.dart:192)

### 22. `mf2_calibration_completed` — 161회 / 56명

- 정의: [AnalyticsService.calibrationCompleted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:302).
- 발생 조건: _logCalibrationCompleted에서 준비 profile 재사용 또는 calibrated event로 active 전환. camera switch/retry 등도 once/session으로 접힌다.
- 전송 규칙: 운동 문맥 필수, 이벤트명별 once/session.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:2556](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:2556)
  - [lib/features/pushup/application/workout_session_controller.dart:2522](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:2522)
  - [lib/features/squat/application/workout_session_controller.dart:2545](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:2545)

### 23. `mf2_workout_started` — 155회 / 56명

- 정의: [AnalyticsService.workoutStarted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:320).
- 발생 조건: _logCalibrationCompleted에서 plan!=null이고 _workoutStartedLogged==false. 보정된 active 상태 전환이며 신체 동작 시작 아님.
- 전송 규칙: 운동 문맥 필수, 이벤트명별 once/session.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:2562](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:2562)
  - [lib/features/pushup/application/workout_session_controller.dart:2528](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:2528)
  - [lib/features/squat/application/workout_session_controller.dart:2551](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:2551)

### 24. `mf2_first_rep_detected` — 150회 / 54명

- 정의: [AnalyticsService.firstRepDetected](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:314).
- 발생 조건: _logFirstRep는 RepEventType.started와 첫 completed에서 호출. 일반 반복에서는 하강 시작만으로 기록 가능. 플랭크는 유지 진입이며 1초 완료와 다름.
- 전송 규칙: 운동 문맥 필수, 이벤트명별 once/session.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:2574](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:2574)
  - [lib/features/pushup/application/workout_session_controller.dart:2540](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:2540)
  - [lib/features/squat/application/workout_session_controller.dart:2563](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:2563)

### 25. `mf2_rep_clip_played` — 144회 / 12명

- 정의: [AnalyticsService.repClipPlayed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:352).
- 발생 조건: RepReviewScreen에서 만든 RepClipPlaybackController.play()가 seek/play 성공 후 onPlay 콜백으로 전송. replay()도 play()를 호출하므로 재재생마다 발생. 실제 완주를 뜻하지 않음.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/plank/workout/presentation/screens/rep_review_screen.dart:138](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/rep_review_screen.dart:138)
  - [lib/features/pushup/presentation/screens/rep_review_screen.dart:138](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/rep_review_screen.dart:138)
  - [lib/features/squat/presentation/screens/rep_review_screen.dart:138](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/rep_review_screen.dart:138)

### 27. `mf2_rep_timeline_viewed` — 130회 / 39명

- 정의: [AnalyticsService.repTimelineViewed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:347).
- 발생 조건: 결과/기록 상세에서 분석 데이터가 있고 최초 로드될 때, 또는 타임라인 화면 진입. 실제 사용자가 목록을 눌렀거나 스크롤로 봤음을 보장하지 않음.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/plank/records/presentation/workout_session_detail_screen.dart:51](/Users/nam/projects/motionfit/lib/features/plank/records/presentation/workout_session_detail_screen.dart:51)
  - [lib/features/plank/workout/presentation/screens/rep_timeline_screen.dart:35](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/rep_timeline_screen.dart:35)
  - [lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:131](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:131)
  - [lib/features/pushup/presentation/screens/rep_timeline_screen.dart:35](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/rep_timeline_screen.dart:35)
  - [lib/features/pushup/presentation/screens/workout_summary_screen.dart:128](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/workout_summary_screen.dart:128)
  - [lib/features/pushup/records/presentation/workout_session_detail_screen.dart:51](/Users/nam/projects/motionfit/lib/features/pushup/records/presentation/workout_session_detail_screen.dart:51)
  - [lib/features/records/presentation/workout_session_detail_screen.dart:51](/Users/nam/projects/motionfit/lib/features/records/presentation/workout_session_detail_screen.dart:51)
  - [lib/features/squat/presentation/screens/rep_timeline_screen.dart:35](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/rep_timeline_screen.dart:35)
  - [lib/features/squat/presentation/screens/workout_summary_screen.dart:128](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/workout_summary_screen.dart:128)

### 28. `mf2_camera_permission_requested` — 110회 / 110명

- 정의: [AnalyticsService.cameraPermissionRequested](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:258).
- 발생 조건: PermissionScreen._request에서 현재 권한이 granted가 아니어 requestCamera()를 호출하기 직전.
- 전송 규칙: 운동 문맥 필수.
- production 호출 위치:
  - [lib/features/plank/workout/presentation/screens/camera_permission_screen.dart:98](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/camera_permission_screen.dart:98)
  - [lib/features/pushup/presentation/screens/camera_permission_screen.dart:96](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/camera_permission_screen.dart:96)
  - [lib/features/squat/presentation/screens/camera_permission_screen.dart:96](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/camera_permission_screen.dart:96)

### 30. `mf2_workout_completed` — 94회 / 39명

- 정의: [AnalyticsService.workoutComplete](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:329).
- 발생 조건: _finishCompleted의 유효 완료(positive units, completed, not interrupted)를 DB에 저장한 뒤. challenge 수동 조기 종료도 포함. 목표 전량 완료와 동일하지 않음.
- 전송 규칙: 운동 문맥 필수, terminal 중복 방지.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:1356](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:1356)
  - [lib/features/plank/workout/application/workout_session_controller.dart:1368](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:1368)
  - [lib/features/pushup/application/workout_session_controller.dart:1352](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:1352)
  - [lib/features/pushup/application/workout_session_controller.dart:1364](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:1364)
  - [lib/features/squat/application/workout_session_controller.dart:1357](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:1357)
  - [lib/features/squat/application/workout_session_controller.dart:1369](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:1369)

### 31. `mf2_workout_detection_summary` — 94회 / 39명

- 정의: [AnalyticsService.workoutDetectionSummary](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:430).
- 발생 조건: _finishCompleted 또는 endInterrupted. guard로 한 번. 0회 discard, saveForLater에는 호출 없음; 성공자 중심 진단 편향.
- 전송 규칙: 운동 문맥 필수.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:2537](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:2537)
  - [lib/features/pushup/application/workout_session_controller.dart:2503](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:2503)
  - [lib/features/squat/application/workout_session_controller.dart:2526](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:2526)

### 32. `mf2_workout_summary_viewed` — 87회 / 37명

- 정의: [AnalyticsService.workoutSummaryViewed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:344).
- 발생 조건: SummaryScreen 첫 post-frame, session!=null이면 completed bool과 전송. challenge는 일반 흐름에서 summary를 우회한다.
- 전송 규칙: 운동 문맥 필수.
- production 호출 위치:
  - [lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:61](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:61)
  - [lib/features/pushup/presentation/screens/workout_summary_screen.dart:58](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/workout_summary_screen.dart:58)
  - [lib/features/squat/presentation/screens/workout_summary_screen.dart:58](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/workout_summary_screen.dart:58)

### 34. `mf2_review_request_skipped` — 62회 / 31명

- 정의: [AnalyticsService.reviewRequestSkipped](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:496).
- 발생 조건: 이미 요청/앱 비활성/결과 안 보임/최소 완료 횟수 미달/버전·cooldown/Review API 불가 등의 사유. skip_reason 확인.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/core/reviews/review_prompt_service.dart:221](/Users/nam/projects/motionfit/lib/core/reviews/review_prompt_service.dart:221)

### 35. `mf2_challenge_selected` — 50회 / 30명

- 정의: [AnalyticsService.challengeCardSelected](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:587).
- 발생 조건: challenge 생성 옵션을 여는 _selectChallenge 시작. 목표 선택/생성 성공 전.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/challenges/presentation/challenge_screen.dart:699](/Users/nam/projects/motionfit/lib/features/challenges/presentation/challenge_screen.dart:699)
  - [lib/features/plank/challenges/presentation/challenge_screen.dart:699](/Users/nam/projects/motionfit/lib/features/plank/challenges/presentation/challenge_screen.dart:699)
  - [lib/features/pushup/challenges/presentation/challenge_screen.dart:699](/Users/nam/projects/motionfit/lib/features/pushup/challenges/presentation/challenge_screen.dart:699)

### 36. `mf2_reminder_permission_result` — 45회 / 13명

- 정의: [AnalyticsService.reminderPermissionResult](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:416).
- 발생 조건: ReminderController/ChallengeController에서 실제 요청 또는 이전 거절 이후 상태 확인 결과. source와 result로 분리해야 한다.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/challenges/application/challenge_controller.dart:299](/Users/nam/projects/motionfit/lib/features/challenges/application/challenge_controller.dart:299)
  - [lib/features/plank/challenges/application/challenge_controller.dart:305](/Users/nam/projects/motionfit/lib/features/plank/challenges/application/challenge_controller.dart:305)
  - [lib/features/pushup/challenges/application/challenge_controller.dart:305](/Users/nam/projects/motionfit/lib/features/pushup/challenges/application/challenge_controller.dart:305)
  - [lib/features/settings/application/reminder_controller.dart:250](/Users/nam/projects/motionfit/lib/features/settings/application/reminder_controller.dart:250)
  - [lib/features/settings/application/reminder_controller.dart:256](/Users/nam/projects/motionfit/lib/features/settings/application/reminder_controller.dart:256)

### 37. `mf2_challenge_recommendation_viewed` — 39회 / 19명

- 정의: [AnalyticsService.challengeRecommendationViewed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:574).
- 발생 조건: dashboard active==null, hasWorkoutHistory, !recommendationDismissed, 해당 화면 인스턴스에서 미기록일 때.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/challenges/presentation/challenge_screen.dart:68](/Users/nam/projects/motionfit/lib/features/challenges/presentation/challenge_screen.dart:68)
  - [lib/features/plank/challenges/presentation/challenge_screen.dart:68](/Users/nam/projects/motionfit/lib/features/plank/challenges/presentation/challenge_screen.dart:68)
  - [lib/features/pushup/challenges/presentation/challenge_screen.dart:68](/Users/nam/projects/motionfit/lib/features/pushup/challenges/presentation/challenge_screen.dart:68)

### 41. `mf2_reminder_prompt_shown` — 36회 / 36명

- 정의: [AnalyticsService.reminderPromptShown](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:397).
- 발생 조건: 일반 결과에서 no enabled reminders, 권한 거절 상태 아님, 첫 완료 미노출 또는 deferred인 정확히 3번째 완료 미노출. shown marker 저장 뒤 카드 state 노출.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:399](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:399)
  - [lib/features/pushup/presentation/screens/workout_summary_screen.dart:393](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/workout_summary_screen.dart:393)
  - [lib/features/squat/presentation/screens/workout_summary_screen.dart:393](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/workout_summary_screen.dart:393)

### 42. `mf2_challenge_workout_started` — 34회 / 15명

- 정의: [AnalyticsService.challengeWorkoutStarted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:606).
- 발생 조건: openWorkoutPreparation에서 challenge 문맥이 있으면 start tapped 직후, 카메라 권한 확인 전 전송. 실제 ready/rep 아님.
- 전송 규칙: 운동 문맥 필수.
- production 호출 위치:
  - [lib/features/plank/workout/presentation/workout_preparation_launcher.dart:28](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/workout_preparation_launcher.dart:28)
  - [lib/features/pushup/presentation/workout_preparation_launcher.dart:27](/Users/nam/projects/motionfit/lib/features/pushup/presentation/workout_preparation_launcher.dart:27)
  - [lib/features/squat/presentation/workout_preparation_launcher.dart:27](/Users/nam/projects/motionfit/lib/features/squat/presentation/workout_preparation_launcher.dart:27)

### 43. `mf2_workout_interrupted` — 31회 / 21명

- 정의: [AnalyticsService.workoutInterrupted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:362).
- 발생 조건: saveForLater가 유효 운동을 checkpoint하고 런타임 해제한 후. 나중에 복구 가능한 중단, terminal 아님.
- 전송 규칙: 운동 문맥 필수, 이벤트명별 once/session.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:1836](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:1836)
  - [lib/features/pushup/application/workout_session_controller.dart:1832](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:1832)
  - [lib/features/squat/application/workout_session_controller.dart:1837](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:1837)

### 44. `mf2_reminder_enabled` — 30회 / 8명

- 정의: [AnalyticsService.reminderEnabled](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:386).
- 발생 조건: 설정에서 특정 요일이 off→on이고 저장/예약 성공, 또는 결과의 enableEveryDayAtTime 전체 예약 성공. 후자는 한 이벤트; 설정에서 요일 여러 개는 여러 이벤트.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/settings/application/reminder_controller.dart:62](/Users/nam/projects/motionfit/lib/features/settings/application/reminder_controller.dart:62)
  - [lib/features/settings/application/reminder_controller.dart:108](/Users/nam/projects/motionfit/lib/features/settings/application/reminder_controller.dart:108)

### 45. `mf2_camera_init_failed` — 29회 / 15명

- 정의: [AnalyticsService.cameraInitializationFailed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:267).
- 발생 조건: _recordCameraFailure의 camera_prewarm/workout_start/workout_recovery/camera_retry 사유. DB나 start 오류도 이 경로로 묶일 수 있으며 실제 카메라만의 오류가 아님.
- 전송 규칙: 운동 문맥 필수, 이벤트명별 once/session.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:2857](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:2857)
  - [lib/features/pushup/application/workout_session_controller.dart:2823](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:2823)
  - [lib/features/squat/application/workout_session_controller.dart:2846](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:2846)

### 49. `mf2_challenge_started` — 21회 / 15명

- 정의: [AnalyticsService.challengeStarted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:603).
- 발생 조건: ChallengeController._start의 challenge DB 저장과 dashboard 갱신 성공 뒤. 실제 운동 시작 아님.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/challenges/application/challenge_controller.dart:249](/Users/nam/projects/motionfit/lib/features/challenges/application/challenge_controller.dart:249)
  - [lib/features/plank/challenges/application/challenge_controller.dart:251](/Users/nam/projects/motionfit/lib/features/plank/challenges/application/challenge_controller.dart:251)
  - [lib/features/pushup/challenges/application/challenge_controller.dart:251](/Users/nam/projects/motionfit/lib/features/pushup/challenges/application/challenge_controller.dart:251)

### 50. `mf2_workout_failed` — 20회 / 14명

- 정의: [AnalyticsService.workoutFailed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:278).
- 발생 조건: 0회 세션 discardInvalidSession에서 errorCode가 있으면 terminal 전송. 발생 순간 모든 오류를 빠짐없이 나타내는 지표는 아님.
- 전송 규칙: 운동 문맥 필수, terminal 중복 방지.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:1870](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:1870)
  - [lib/features/pushup/application/workout_session_controller.dart:1866](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:1866)
  - [lib/features/squat/application/workout_session_controller.dart:1871](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:1871)

### 54. `mf2_second_workout_completed` — 18회 / 16명

- 정의: [AnalyticsService.secondWorkoutCompleted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:342).
- 발생 조건: 각 종목 repository.loadSessions의 completed&&!interrupted 개수가 정확히 2일 때. 3개 DB로 분리. 전 종목/다른 날짜/동일 신규 코호트 조건과 영구 dedup 없음.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:2589](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:2589)
  - [lib/features/pushup/application/workout_session_controller.dart:2555](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:2555)
  - [lib/features/squat/application/workout_session_controller.dart:2578](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:2578)

### 55. `mf2_manual_rate_tapped` — 17회 / 16명

- 정의: [AnalyticsService.manualRateTapped](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:548).
- 발생 조건: 설정의 수동 평가 링크 처리 시작. _openingStore 중복 방어 이후.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/core/reviews/review_prompt_service.dart:194](/Users/nam/projects/motionfit/lib/core/reviews/review_prompt_service.dart:194)

### 59. `mf2_review_request_eligible` — 13회 / 10명

- 정의: [AnalyticsService.reviewEligibilityMet](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:462).
- 발생 조건: ReviewPromptPolicy를 통과한 뒤. 유효 운동 3회 이상, 동일 버전 미요청, 90일 cooldown 등. API 가능 여부 확인 전.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/core/reviews/review_prompt_service.dart:160](/Users/nam/projects/motionfit/lib/core/reviews/review_prompt_service.dart:160)

### 60. `mf2_review_store_opened` — 13회 / 13명

- 정의: [AnalyticsService.storeReviewPageOpened](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:551).
- 발생 조건: 수동 설정 평가 링크 gateway 성공. 제출한 리뷰 아님.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/core/reviews/review_prompt_service.dart:198](/Users/nam/projects/motionfit/lib/core/reviews/review_prompt_service.dart:198)

### 68. `mf2_calibration_failed` — 11회 / 6명

- 정의: [AnalyticsService.calibrationFailed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:308).
- 발생 조건: calibrating 45초 timeout 때, 또는 errorCode가 calibration인 0회 폐기 경로. 단순 조기 종료는 이 이벤트가 아님.
- 전송 규칙: 운동 문맥 필수, 이벤트명별 once/session.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:1868](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:1868)
  - [lib/features/plank/workout/application/workout_session_controller.dart:2299](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:2299)
  - [lib/features/pushup/application/workout_session_controller.dart:1864](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:1864)
  - [lib/features/pushup/application/workout_session_controller.dart:2294](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:2294)
  - [lib/features/squat/application/workout_session_controller.dart:1869](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:1869)
  - [lib/features/squat/application/workout_session_controller.dart:2317](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:2317)

### 71. `mf2_review_request_attempted` — 9회 / 9명

- 정의: [AnalyticsService.reviewPromptRequested](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:514).
- 발생 조건: Review API 사용 가능 확인 및 요청 이력 저장 후 requestReview 호출 직전. OS가 실제 리뷰 UI를 보였거나 사용자가 평가했음을 보장하지 않음.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/core/reviews/review_prompt_service.dart:174](/Users/nam/projects/motionfit/lib/core/reviews/review_prompt_service.dart:174)

### 77. `mf2_workout_resumed` — 7회 / 6명

- 정의: [AnalyticsService.recoveryResume](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:452).
- 발생 조건: recover가 pose/rest/보정 상태 복구를 성공한 뒤. 실제 카운트가 늘어난 것은 아님.
- 전송 규칙: 운동 문맥 필수.
- production 호출 위치:
  - [lib/features/plank/workout/application/workout_session_controller.dart:637](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:637)
  - [lib/features/pushup/application/workout_session_controller.dart:637](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:637)
  - [lib/features/squat/application/workout_session_controller.dart:640](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:640)

### 86. `mf2_reminder_prompt_declined` — 5회 / 5명

- 정의: [AnalyticsService.reminderPromptDeclined](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:407).
- 발생 조건: 결과 카드 나중에 클릭. 완료 버튼으로 그냥 나가는 동작은 기록하지 않음.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:528](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:528)
  - [lib/features/pushup/presentation/screens/workout_summary_screen.dart:522](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/workout_summary_screen.dart:522)
  - [lib/features/squat/presentation/screens/workout_summary_screen.dart:522](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/workout_summary_screen.dart:522)

### 89. `mf2_onboarding_abandoned` — 4회 / 4명

- 정의: [AnalyticsService.onboardingAbandoned](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:198).
- 발생 조건: 다음 온보딩 진입에서 이전 startedAt이 남고 완료하지 않았으면 app_closed 사유로 전송. 다시 오지 않는 이탈자는 누락된다.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/onboarding/presentation/onboarding_screen.dart:126](/Users/nam/projects/motionfit/lib/features/onboarding/presentation/onboarding_screen.dart:126)

### 101. `mf2_challenge_cancelled` — 2회 / 2명

- 정의: [AnalyticsService.challengeCancelled](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:618).
- 발생 조건: Controller.cancel에서 활성 challenge를 취소 상태로 저장하고 dashboard 갱신 성공 뒤.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/challenges/application/challenge_controller.dart:273](/Users/nam/projects/motionfit/lib/features/challenges/application/challenge_controller.dart:273)
  - [lib/features/plank/challenges/application/challenge_controller.dart:279](/Users/nam/projects/motionfit/lib/features/plank/challenges/application/challenge_controller.dart:279)
  - [lib/features/pushup/challenges/application/challenge_controller.dart:279](/Users/nam/projects/motionfit/lib/features/pushup/challenges/application/challenge_controller.dart:279)

### 102. `mf2_store_review_page_failed` — 2회 / 2명

- 정의: [AnalyticsService.storeReviewPageFailed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:554).
- 발생 조건: 수동 store 링크 열기 실패(false 또는 예외).
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/core/reviews/review_prompt_service.dart:200](/Users/nam/projects/motionfit/lib/core/reviews/review_prompt_service.dart:200)
  - [lib/core/reviews/review_prompt_service.dart:207](/Users/nam/projects/motionfit/lib/core/reviews/review_prompt_service.dart:207)

### 111. `mf2_challenge_recommendation_dismissed` — 1회 / 1명

- 정의: [AnalyticsService.challengeRecommendationDismissed](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:598).
- 발생 조건: 추천 dismiss 클릭으로 추천 숨김 처리 시.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/challenges/presentation/challenge_screen.dart:685](/Users/nam/projects/motionfit/lib/features/challenges/presentation/challenge_screen.dart:685)
  - [lib/features/plank/challenges/presentation/challenge_screen.dart:685](/Users/nam/projects/motionfit/lib/features/plank/challenges/presentation/challenge_screen.dart:685)
  - [lib/features/pushup/challenges/presentation/challenge_screen.dart:685](/Users/nam/projects/motionfit/lib/features/pushup/challenges/presentation/challenge_screen.dart:685)

### 112. `mf2_reminder_prompt_accepted` — 1회 / 1명

- 정의: [AnalyticsService.reminderPromptAccepted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:402).
- 발생 조건: 결과 카드 enable 버튼 클릭 즉시; 권한/스케줄 성공 전.
- 전송 규칙: 일반 이벤트; 운동 session ID 자동 부착 없음.
- production 호출 위치:
  - [lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:426](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:426)
  - [lib/features/pushup/presentation/screens/workout_summary_screen.dart:420](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/workout_summary_screen.dart:420)
  - [lib/features/squat/presentation/screens/workout_summary_screen.dart:420](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/workout_summary_screen.dart:420)

## 화면·자동 이벤트

`screen_view`는 다음 `AnalyticsService.screenView()`의 수동 요청에서 `logScreenView(screenName, screenClass: MotionFit)`로 전달된다. 동일 화면명 1초 이내 호출만 service에서 막는다. Native Activity/ViewController 자동 추적과 중첩 가능한 별도 계열이다.

[screenView 중복 억제](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:110) · [Firebase 화면 sink](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:891)

| 수동 화면명/표현식 | 호출 위치 |
|---|---|
| `switch (index` | [lib/app/router.dart:437](/Users/nam/projects/motionfit/lib/app/router.dart:437) |
| `'body_progress_capture'` | [lib/features/body_progress/presentation/screens/body_progress_capture_screen.dart:27](/Users/nam/projects/motionfit/lib/features/body_progress/presentation/screens/body_progress_capture_screen.dart:27) |
| `'body_progress_compare'` | [lib/features/body_progress/presentation/screens/body_progress_compare_screen.dart:33](/Users/nam/projects/motionfit/lib/features/body_progress/presentation/screens/body_progress_compare_screen.dart:33) |
| `'body_progress'` | [lib/features/body_progress/presentation/screens/body_progress_screen.dart:29](/Users/nam/projects/motionfit/lib/features/body_progress/presentation/screens/body_progress_screen.dart:29) |
| `'body_progress_timelapse'` | [lib/features/body_progress/presentation/screens/body_progress_timelapse_screen.dart:31](/Users/nam/projects/motionfit/lib/features/body_progress/presentation/screens/body_progress_timelapse_screen.dart:31) |
| `'challenge'` | [lib/features/challenges/presentation/challenge_screen.dart:34](/Users/nam/projects/motionfit/lib/features/challenges/presentation/challenge_screen.dart:34) |
| `'form_progress_detail'` | [lib/features/form_progress/presentation/screens/form_progress_detail_screen.dart:35](/Users/nam/projects/motionfit/lib/features/form_progress/presentation/screens/form_progress_detail_screen.dart:35) |
| `'form_progress'` | [lib/features/form_progress/presentation/screens/form_progress_screen.dart:32](/Users/nam/projects/motionfit/lib/features/form_progress/presentation/screens/form_progress_screen.dart:32) |
| `'form_progress_timelapse'` | [lib/features/form_progress/presentation/screens/form_progress_timelapse_screen.dart:36](/Users/nam/projects/motionfit/lib/features/form_progress/presentation/screens/form_progress_timelapse_screen.dart:36) |
| `'onboarding'` | [lib/features/onboarding/presentation/onboarding_screen.dart:123](/Users/nam/projects/motionfit/lib/features/onboarding/presentation/onboarding_screen.dart:123) |
| `'challenge'` | [lib/features/plank/challenges/presentation/challenge_screen.dart:34](/Users/nam/projects/motionfit/lib/features/plank/challenges/presentation/challenge_screen.dart:34) |
| `'records'` | [lib/features/plank/records/presentation/records_screen.dart:28](/Users/nam/projects/motionfit/lib/features/plank/records/presentation/records_screen.dart:28) |
| `'calibration'` | [lib/features/plank/workout/application/workout_session_controller.dart:353](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:353) |
| `'active_workout'` | [lib/features/plank/workout/application/workout_session_controller.dart:2559](/Users/nam/projects/motionfit/lib/features/plank/workout/application/workout_session_controller.dart:2559) |
| `'camera_permission_guide'` | [lib/features/plank/workout/presentation/screens/camera_guide_screen.dart:33](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/camera_guide_screen.dart:33) |
| `'camera_permission_guide'` | [lib/features/plank/workout/presentation/screens/camera_permission_screen.dart:41](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/camera_permission_screen.dart:41) |
| `'workout_setup'` | [lib/features/plank/workout/presentation/screens/plank_home_screen.dart:38](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/plank_home_screen.dart:38) |
| `'rest'` | [lib/features/plank/workout/presentation/screens/rest_screen.dart:32](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/rest_screen.dart:32) |
| `'workout_summary'` | [lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:57](/Users/nam/projects/motionfit/lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:57) |
| `'calibration'` | [lib/features/pushup/application/workout_session_controller.dart:353](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:353) |
| `'active_workout'` | [lib/features/pushup/application/workout_session_controller.dart:2525](/Users/nam/projects/motionfit/lib/features/pushup/application/workout_session_controller.dart:2525) |
| `'challenge'` | [lib/features/pushup/challenges/presentation/challenge_screen.dart:34](/Users/nam/projects/motionfit/lib/features/pushup/challenges/presentation/challenge_screen.dart:34) |
| `'camera_permission_guide'` | [lib/features/pushup/presentation/screens/camera_guide_screen.dart:29](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/camera_guide_screen.dart:29) |
| `'camera_permission_guide'` | [lib/features/pushup/presentation/screens/camera_permission_screen.dart:39](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/camera_permission_screen.dart:39) |
| `'workout_setup'` | [lib/features/pushup/presentation/screens/pushup_home_screen.dart:40](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/pushup_home_screen.dart:40) |
| `'rest'` | [lib/features/pushup/presentation/screens/rest_screen.dart:30](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/rest_screen.dart:30) |
| `'workout_summary'` | [lib/features/pushup/presentation/screens/workout_summary_screen.dart:54](/Users/nam/projects/motionfit/lib/features/pushup/presentation/screens/workout_summary_screen.dart:54) |
| `'records'` | [lib/features/pushup/records/presentation/records_screen.dart:28](/Users/nam/projects/motionfit/lib/features/pushup/records/presentation/records_screen.dart:28) |
| `'records'` | [lib/features/records/presentation/records_screen.dart:32](/Users/nam/projects/motionfit/lib/features/records/presentation/records_screen.dart:32) |
| `'reminder_settings'` | [lib/features/settings/presentation/reminder_screen.dart:28](/Users/nam/projects/motionfit/lib/features/settings/presentation/reminder_screen.dart:28) |
| `'settings'` | [lib/features/settings/presentation/settings_screen.dart:41](/Users/nam/projects/motionfit/lib/features/settings/presentation/settings_screen.dart:41) |
| `'calibration'` | [lib/features/squat/application/workout_session_controller.dart:356](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:356) |
| `'active_workout'` | [lib/features/squat/application/workout_session_controller.dart:2548](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:2548) |
| `'camera_permission_guide'` | [lib/features/squat/presentation/screens/camera_guide_screen.dart:29](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/camera_guide_screen.dart:29) |
| `'camera_permission_guide'` | [lib/features/squat/presentation/screens/camera_permission_screen.dart:39](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/camera_permission_screen.dart:39) |
| `'rest'` | [lib/features/squat/presentation/screens/rest_screen.dart:30](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/rest_screen.dart:30) |
| `'workout_setup'` | [lib/features/squat/presentation/screens/squat_home_screen.dart:38](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/squat_home_screen.dart:38) |
| `'workout_summary'` | [lib/features/squat/presentation/screens/workout_summary_screen.dart:54](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/workout_summary_screen.dart:54) |

| 자동 이벤트 | 발생 조건/주의 |
|---|---|
| `user_engagement` | SDK의 사용자 참여 시간 이벤트. 개별 workout 코드에서 직접 전송하지 않는다. |
| `session_start` | SDK Analytics 세션 시작. workout_session_id로 나누는 운동 시도와 다른 개념. |
| `first_open` | 설치/재설치 후 최초 사용 시 SDK 수집. 다운로드 완료 자체 이벤트 아님. |
| `ad_impression` | Google Mobile Ads/Firebase 연동의 광고 노출 이벤트. AnalyticsService.adShown은 빈 함수라 수동 mf2 노출을 추가하지 않는다. |
| `ad_click` | Mobile Ads 연동의 광고 클릭. AnalyticsService.adClick은 빈 함수. |
| `app_remove` | Android 패키지 제거 자동 수집. 양 플랫폼 전체 사용자 동일 코호트의 이탈률 분모로 쓰지 않는다. |
| `app_update` | 업데이트 후 실행 관련 SDK 이벤트. 버전별 집계 필요. |
| `app_exception` | Crashlytics 연동 예외 이벤트. fatal 파라미터/버전/플랫폼/기간을 확인해야 한다. |
| `os_update` | OS 업데이트 관련 SDK 이벤트. 운동 UX 자체 행동이 아님. |

## 현 코드에 없는 이벤트의 해석

전체 목록에서 ‘현 코드 직접 발생 없음’으로 표시한 각 이벤트는 현재 AnalyticsService 및 lib production 호출에서 대응하는 발신이 없다. 현재 저장소의 네이티브 Firebase 직접 logEvent 호출도 발견되지 않았다. 이전 앱/이전 배포/콘솔 파생 이벤트 등 출처를 app_version/build/source로 확인해야 하며, 현재 checkout만으로 과거 파일·함수·조건을 확정할 수 없다.

- `motionfit_ads_log`, `main_tab_view`, `motionfit_screen_view`, `route_view`, `workout_session_*`, `voice_trial_*`, `workout_ad_*`, `paywall_*` 등의 수치를 현재 mf2 퍼널에 더하지 않는다. 옛 음성 과금/광고 게이트가 현재도 작동한다는 증거가 아니다.
- `mf2_store_review_page_opened`도 현 이름과 다르다. 현재 발신 이름은 `mf2_review_store_opened`. 접두사 mf2만으로 현재와 동일한 의미/구현이라 보장할 수 없다.
- `workout_started/workout_completed/first_rep_counted`와 mf2 동명 의미는 별도 버전으로 유지한다.

## 소스에는 정의가 있으나 제공 표에 없는 이벤트

표에 없다는 것이 발생 횟수 0임을 보장하지 않는다. 현재 호출부가 없는 정의는 명시했다.

| 이벤트 | 함수 | 현재 호출 여부/조건 |
|---|---|
| `mf2_onboarding_back_tapped` | [onboardingBackTapped](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:163) | 정의는 있으나 현재 production 호출부 없음. production 호출 없음 |
| `mf2_onboarding_skipped` | [onboardingSkipped](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:175) | 정의는 있으나 현재 production 호출부 없음. production 호출 없음 |
| `mf2_review_request_scheduled` | [reviewRequestScheduled](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:479) | 정의는 있으나 현재 production 호출부 없음. production 호출 없음 |
| `mf2_review_request_completed` | [reviewRequestCompleted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:531) | 정의는 있으나 현재 production 호출부 없음. production 호출 없음 |
| `mf2_challenge_completed` | [challengeCompleted](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart:615) | dashboard build에서 활성 challenge의 계산 progress>=1로 상태 전환·DB update한 뒤. 화면/데이터 갱신 시점의 완료 감지. [lib/features/challenges/application/challenge_controller.dart:130](/Users/nam/projects/motionfit/lib/features/challenges/application/challenge_controller.dart:130); [lib/features/plank/challenges/application/challenge_controller.dart:130](/Users/nam/projects/motionfit/lib/features/plank/challenges/application/challenge_controller.dart:130); [lib/features/pushup/challenges/application/challenge_controller.dart:130](/Users/nam/projects/motionfit/lib/features/pushup/challenges/application/challenge_controller.dart:130) |

## 이름은 있지만 의도적으로 아무 이벤트도 보내지 않는 메서드

`workoutInitializationStarted`, `reminderPermissionRequested`, `reminderScheduled`, `reminderScheduleFailed`, `reminderDisabled`, `challengeTabBadgeViewed`, `adLoaded`, `adShown`, `adDismissed`, `adFailed`, `adClick`은 현재 no-op다. 따라서 이를 호출하는 UX가 있어도 같은 의미의 mf2 로그가 자동으로 생기지 않는다.

중요 결과: 광고 load 성공/실패, 알림 예약 성공/실패/해지의 Analytics 진단 공백이 있고, badge viewed도 계측되지 않는다. 오류의 일부는 Crashlytics nonfatal 또는 debugPrint에만 남는다.
