# MotionFit Squat Analytics Schema v2

## 기준

- Analytics schema version: `2`
- custom event prefix: `mf2_`
- Day 0: 이 변경이 포함된 앱 버전의 최초 배포 시점
- 구버전은 기존 legacy custom event를 전송하고, 이 버전부터는 `mf2_`만 전송한다. dual logging은 하지 않는다.
- Firebase 자동 이벤트(`first_open`, `session_start`, `screen_view`, `user_engagement`, `app_open`, `app_update`, `app_remove`)와 AdMob 자동 이벤트(`ad_impression`, `ad_click`)는 복제하거나 이름을 바꾸지 않는다.

모든 `mf2_` 이벤트에는 중앙 `AnalyticsService`가 다음 값을 붙인다.

| parameter | type | definition |
|---|---|---|
| `analytics_schema` | int | 항상 `2` |
| `platform` | string | Flutter runtime이 Android면 `android`, iOS면 `ios`, 그 외 `unsupported` |
| `app_version` | string | `package_info_plus`의 runtime `version` |
| `build_number` | string | `package_info_plus`의 runtime `buildNumber` |
| `device_category` | string | 기존 coarse device 분류(`phone`/`tablet`/`unknown`) |

지원 대상이 아닌 Web/macOS 등에서는 custom Analytics 전송을 시작하지 않는다. 플랫폼 이름은 이벤트명에 넣지 않는다.

## Workout session

사용자가 Start를 탭할 때 개인정보와 무관한 UUID v7 `workout_session_id`를 새로 만든다. 권한 확인, 카메라 초기화, 캘리브레이션, 반복 감지, 완료/취소/실패까지 같은 ID를 사용한다. 새 Start 탭은 새 ID를 만든다.

운동 이벤트에는 가능한 경우 아래 값도 붙는다.

| parameter | definition |
|---|---|
| `workout_session_id` | 한 운동 시도용 익명 UUID |
| `entry_point` | `home`, `challenge`, `resume`, `other` |
| `challenge_active` | `0` 또는 `1` |
| `target_sets` | 목표 세트 수 |
| `target_reps` | 전체 목표 반복 수 |

랜드마크, 신체/관절 좌표, 프레임 데이터, 영상/이미지, Firebase UID와 device ID는 보내지 않는다.

`WorkoutAnalyticsSession`이 아래 이벤트를 세션당 한 번으로 차단한다.

- `mf2_camera_init_started`, `mf2_camera_init_completed`, `mf2_camera_init_failed`
- `mf2_calibration_started`, `mf2_calibration_completed`, `mf2_calibration_failed`
- `mf2_workout_started`, `mf2_first_rep_detected`
- `mf2_workout_completed`, `mf2_workout_cancelled`, `mf2_workout_failed`

`completed`, `cancelled`, `failed`는 terminal event이며 한 세션에는 셋 중 최초 하나만 허용한다. `interrupted`는 “나중에 계속”처럼 재개 가능한 체크포인트를 뜻하며 terminal이 아니다. 정상 저장이 끝나고 reps가 1개 이상인 경우에만 `completed`를 허용한다. 카메라 준비 실패와 0-rep 종료는 `completed`가 아니다.

## Canonical funnel

| event | condition | once/session | terminal | replaces |
|---|---|---:|---:|---|
| `mf2_onboarding_started` | 온보딩 최초 화면 시작 | 화면 lifecycle당 1회 | no | `onboarding_started` |
| `mf2_onboarding_step_viewed` | 실제 단계가 표시됨 | 단계 전환당 | no | `onboarding_step_viewed` |
| `mf2_onboarding_completed` | 온보딩 저장 완료 | 온보딩당 1회 | no | `onboarding_complete` |
| `mf2_workout_setup_viewed` | 운동 설정 화면 표시 | 화면 진입당 | no | `workout_setup_viewed` |
| `mf2_workout_start_tapped` | 설정 화면의 Start 실제 탭, session ID 생성 | yes | no | `workout_start_tapped` |
| `mf2_camera_permission_result` | 카메라 권한 상태 확인/요청 결과 | 결과 전환당 | no | `camera_permission_result` |
| `mf2_camera_init_started` | camera initialization Future 실제 시작 | yes | no | `camera_initialization_started` |
| `mf2_camera_init_completed` | camera/pose engine 초기화 성공 반환 | yes | no | `camera_initialization_completed` |
| `mf2_camera_init_failed` | 초기화/초기화 재시도 실패 | yes | no | `camera_initialization_failed` |
| `mf2_calibration_started` | 운동용 calibration 시작 | yes | no | `calibration_started` |
| `mf2_calibration_completed` | calibration 성공 상태 전환 | yes | no | `calibration_completed` |
| `mf2_calibration_failed` | calibration 단계 실패로 운동 종료 | yes | no | 신규 canonical |
| `mf2_workout_started` | 유효 rep 감지가 가능한 active 상태 진입 | yes | no | `workout_start`, `workout_started` |
| `mf2_first_rep_detected` | 유효 squat rep #1 최초 감지 | yes | no | `first_rep_detected` |
| `mf2_workout_completed` | 1+ reps의 정상 record 저장 완료 | yes | yes | `workout_complete`, `workout_completed` |
| `mf2_workout_cancelled` | 사용자가 운동 시도를 종료 | yes | yes | `workout_cancelled` |
| `mf2_workout_failed` | 기술 실패로 운동 시도 종료 | yes | yes | `workout_failed` |
| `mf2_workout_interrupted` | 유효 진행 상태를 저장해 나중에 재개 가능 | yes | no | `workout_interrupted` |

권장 Firebase funnel:

`first_open` → `mf2_onboarding_started` → `mf2_onboarding_completed` → `mf2_workout_setup_viewed` → `mf2_workout_start_tapped` → `mf2_camera_init_completed` → `mf2_calibration_completed` → `mf2_workout_started` → `mf2_first_rep_detected` → `mf2_workout_completed`

## Feature events

### Challenge

| event | condition |
|---|---|
| `mf2_challenge_tab_viewed` | challenge dashboard 데이터가 표시됨 |
| `mf2_challenge_selected` | challenge card 선택; 기존 card/selected/recommendation tap 중복을 통합 |
| `mf2_challenge_started` | challenge record 생성 성공 |
| `mf2_challenge_workout_started` | challenge 경로에서 운동 Start 탭 후 session 생성 |
| `mf2_challenge_completed` | active challenge가 목표 달성 상태로 저장됨 |
| `mf2_challenge_cancelled` | active challenge 취소 저장 성공 |

추천 노출/닫기는 각각 `mf2_challenge_recommendation_viewed`, `mf2_challenge_recommendation_dismissed` 한 종류만 유지한다. badge 노출은 분석 가치보다 노이즈가 커 v2에서 보내지 않는다.

### Reminder

| event | condition |
|---|---|
| `mf2_reminder_prompt_shown` | 앱 자체 reminder CTA가 실제 표시됨 |
| `mf2_reminder_prompt_accepted` | 사용자가 CTA를 수락함 |
| `mf2_reminder_permission_result` | OS 권한 결과; `result=granted/denied/permanentlyDenied/restricted/unavailable` |
| `mf2_reminder_enabled` | 알림 일정 저장 및 scheduling 성공 |

requested/granted/denied/scheduled를 별도 이벤트로 중복 전송하지 않는다. 플랫폼 차이는 공통 `platform`과 `result`로 분석한다.

### Review

| event | condition |
|---|---|
| `mf2_review_requested` | 공식 in-app review API 호출 직전 |
| `mf2_manual_rate_tapped` | 설정의 수동 평가 버튼 탭 |
| `mf2_store_review_page_opened` | 외부 store review URL open 성공 |
| `mf2_store_review_page_failed` | 외부 store review URL open 실패 |

`mf2_review_request_completed`는 API Future가 반환됐다는 뜻일 뿐 팝업 표시나 리뷰 제출을 뜻하지 않는다. 확인할 수 없는 `review_prompt_shown`, `review_submitted`는 만들지 않는다.

### Ads

앱 정책 분석용 `mf2_ad_request_attempted`와 `mf2_ad_skipped_by_policy`만 유지한다. load/show/impression/click/dismiss 결과는 AdMob/Firebase 자동 이벤트를 source of truth로 사용하며 custom v2로 복제하지 않는다.

### Exceptions

기존 코드에 Analytics `app_exception` 전송은 없었다. 상세 오류는 Crashlytics non-fatal이 source of truth이므로 `mf2_app_exception`을 추가하지 않았다. Analytics에는 raw exception message나 stack trace를 보내지 않는다.

## Legacy implementation audit

모든 legacy 이벤트 정의는 변경 전 `lib/core/analytics/analytics_service.dart`에 있었고, Firebase 직접 호출은 그 서비스의 dispatch 한 곳에만 있었다. 아래 “단위”는 변경 전 호출 의미다.

| legacy event | call site | condition / unit | duplicate or semantic risk | v2 disposition |
|---|---|---|---|---|
| `onboarding_started` | `features/onboarding/presentation/onboarding_screen.dart` | onboarding widget 시작 / 진입당 | widget 재생성 시 가능 | `mf2_onboarding_started` |
| `onboarding_step_viewed` | same | page 변경 / 단계당 | 동일 page callback 재진입 가능 | `mf2_onboarding_step_viewed` |
| `onboarding_next_tapped` | same | Next 탭 / 행동당 | 낮음 | `mf2_onboarding_next_tapped` 보조 이벤트 |
| `onboarding_back_tapped` | same | Back 탭 / 행동당 | 낮음 | `mf2_onboarding_back_tapped` 보조 이벤트 |
| `onboarding_skipped` | same | skip / 행동당 | 낮음 | `mf2_onboarding_skipped` 보조 이벤트 |
| `onboarding_complete` | same | preference 완료 저장 / onboarding당 | 낮음 | `mf2_onboarding_completed` |
| `onboarding_abandoned` | same | 미완료 dispose / 진입당 | 완료/route dispose 경합 가능 | `mf2_onboarding_abandoned` 보조 이벤트 |
| `workout_setup_viewed` | `features/squat/presentation/screens/squat_home_screen.dart` | setup 표시 / 화면 진입당 | rebuild 방지는 post-frame lifecycle에 의존 | `mf2_workout_setup_viewed` |
| `workout_start_tapped` | `features/squat/presentation/workout_preparation_launcher.dart` | Start 탭 / 행동당 | 중복 탭 방어가 호출자 UI에 의존 | `mf2_workout_start_tapped`, session 생성 |
| `camera_permission_result` | launcher, `camera_permission_screen.dart` | status 확인 또는 요청 결과 / 상태당 | resume/status refresh 중복 가능 | `mf2_camera_permission_result` |
| `camera_permission_requested` | `camera_permission_screen.dart` | 실제 OS request 직전 / 요청당 | result와 퍼널 의미 중복 | `mf2_camera_permission_requested` 보조 이벤트 |
| `workout_initialization_started` | `workout_countdown_screen.dart` | countdown dependency 시작 / 화면 진입당 | 실제 camera Future와 의미 불일치 | v2 미전송 |
| `camera_initialization_started` | `workout_session_controller.dart` | engine start / 초기화당 | prewarm/retry에서 반복 | `mf2_camera_init_started`, service once guard |
| `camera_initialization_completed` | same | engine start 성공 / 초기화당 | retry/재진입에서 반복 | `mf2_camera_init_completed`, service once guard |
| `camera_initialization_failed` | same | 변경 전 init뿐 아니라 pause/stream 오류에도 사용 / 오류당 | 의미 혼합, retry 반복 | init/retry 실패만 `mf2_camera_init_failed` |
| `calibration_started` | same | session DB 생성 직전 / 운동 세션당 | 재시작 경로와 로컬 상태 의존 | `mf2_calibration_started`, service once guard |
| `calibration_completed` | same | detector calibrated 전환 / pose callback | 프레임 callback 중복 위험 | `mf2_calibration_completed`, controller+service guard |
| `first_rep_detected` | same | 첫 completed rep callback / pose callback | 프레임 callback 중복 위험 | `mf2_first_rep_detected`, controller+service guard |
| `workout_start` | same | 첫 rep 때 / 세션당 | `workout_started`와 의도적 dual logging | 제거, `mf2_workout_started` |
| `workout_started` | same | 첫 rep 때 / 세션당 | `workout_start`와 중복, 이름 의미와 시점 불일치 | active 진입 시 `mf2_workout_started` |
| `workout_complete` | same | 정상 저장 완료 / 세션당 | `workout_completed`와 의도적 dual logging | 제거 |
| `workout_completed` | same | 정상 저장 완료 / 세션당 | `workout_complete`와 중복 | `mf2_workout_completed` 하나로 통합 |
| `workout_interrupted` | same | 유효 미완료 session 종료 / 세션당 | cancelled도 연속 호출되어 의미 중복 | 재개 가능 저장만 `mf2_workout_interrupted` |
| `workout_cancelled` | controller, permission/guide/countdown screens | 사용자 이탈 / 세션당 또는 준비 화면당 | 여러 화면과 controller에서 terminal 중복 가능 | `mf2_workout_cancelled`, terminal guard |
| `workout_failed` | controller | invalid session의 error 종료 / 세션당 | cancelled/completed와 경합 가능 | `mf2_workout_failed`, terminal guard |
| `workout_detection_summary` | controller | 종료 진단 요약 / 세션당 | 별도 로컬 guard만 존재 | `mf2_workout_detection_summary`, 익명 bucket만 유지 |
| `workout_screen_viewed` | `active_workout_screen.dart` | 화면 진입당 | screen_view와 유사 | `mf2_workout_screen_viewed` 보조 이벤트 |
| `workout_summary_viewed` | `workout_summary_screen.dart` | summary 진입당 | 재진입 가능 | `mf2_workout_summary_viewed` 보조 이벤트 |
| `recovery_resume` | controller | 저장 session recovery 성공 / resume당 | 새 시도와 기존 session 의미 혼합 | `mf2_workout_resumed`, `entry_point=resume` |
| `second_workout_completed` | controller | 저장소 완료 수가 정확히 2 / milestone | async 재평가 중복 가능 | `mf2_second_workout_completed` 보조 이벤트 |
| `reminder_prompt_shown` | workout summary | 자체 CTA 표시 / prompt당 | 낮음 | `mf2_reminder_prompt_shown` |
| `reminder_prompt_accepted` | workout summary | CTA 수락 / 행동당 | 낮음 | `mf2_reminder_prompt_accepted` |
| `reminder_prompt_declined` | workout summary | CTA 거절 / 행동당 | 낮음 | `mf2_reminder_prompt_declined` 보조 이벤트 |
| `reminder_permission_requested` | reminder/challenge controllers | OS request 직전 / 요청당 | result와 중복 | v2 미전송 |
| `reminder_permission_result` | same | status/request 결과 / 결과당 | status check와 request result가 섞일 수 있음 | `mf2_reminder_permission_result`, `source/result` 구분 |
| `reminder_permission_granted` | service 내부 | granted result에서 추가 전송 | result와 완전 중복 | 제거 |
| `reminder_permission_denied` | service 내부 | denied result에서 추가 전송 | result와 완전 중복 | 제거 |
| `reminder_enabled` | reminder controller | save/schedule 성공 / 변경당 | `reminder_scheduled`와 중복 | `mf2_reminder_enabled` |
| `reminder_scheduled` | reminder/challenge controllers | schedule 성공 / 변경당 | enabled와 중복 | v2 미전송 |
| `reminder_schedule_failed` | same | schedule 예외 / 오류당 | 반복 retry 노이즈 | v2 미전송; 오류 추적은 Crashlytics |
| `reminder_disabled` | same | disable / 행동당 | 핵심 funnel 밖 | v2 미전송 |
| `review_eligibility_met` | `core/reviews/review_prompt_service.dart` | 정책 통과 / 평가당 | scheduled와 근접 중복 | `mf2_review_eligibility_met` 보조 이벤트 |
| `review_request_scheduled` | same | navigation 후 요청 예약 / 요청당 | requested와 근접 중복 | `mf2_review_request_scheduled` 보조 이벤트 |
| `review_request_skipped` | same | policy skip / 평가당 | 반복 평가 가능 | `mf2_review_request_skipped` 보조 이벤트 |
| `review_prompt_requested` | same | 공식 API 호출 직전 / 요청당 | 실제 prompt 표시를 보장하지 않음 | `mf2_review_requested`로 의미 명시 |
| `review_requested` | 없음 | 요청된 이름이나 코드에 정의/호출 없음 | 해당 없음 | `mf2_review_requested` canonical |
| `review_request_completed` | same | 공식 API Future 반환 / 요청당 | 리뷰 제출로 오해 가능 | `mf2_review_request_completed`, 문서상 API 반환으로 제한 |
| `manual_rate_tapped` | same | 설정 버튼 탭 / 행동당 | 낮음 | `mf2_manual_rate_tapped` |
| `store_review_page_opened` | same | URL open 성공 / 행동당 | 낮음 | `mf2_store_review_page_opened` |
| `store_review_page_failed` | same | URL open 실패 / 행동당 | retry 반복 가능 | `mf2_store_review_page_failed` |
| `challenge_tab_viewed` | `features/challenges/presentation/challenge_screen.dart` | dashboard 표시 / 화면 진입당 | async rebuild guard에 의존 | `mf2_challenge_tab_viewed` |
| `challenge_recommendation_viewed` | same | recommendation 표시 / 화면 진입당 | shown과 중복 | `mf2_challenge_recommendation_viewed` 하나 유지 |
| `challenge_recommendation_shown` | service 내부 | viewed와 동시에 전송 | 완전 중복 | 제거 |
| `challenge_recommendation_tapped` | service 내부 | 추천 card 선택 시 추가 전송 | selected와 중복 | `mf2_challenge_selected` parameter로 통합 |
| `challenge_card_selected` | challenge screen | card 탭 / 행동당 | selected와 완전 중복 | 제거 |
| `challenge_selected` | service 내부 | card selected와 동시에 전송 | 완전 중복 | `mf2_challenge_selected` |
| `challenge_started` | challenge controller | DB 생성 성공 / challenge당 | 낮음 | `mf2_challenge_started` |
| `challenge_workout_started` | challenge screen | 변경 전 준비 flow 진입 전 / 행동당 | workout start session보다 먼저 발생 | session 생성 후 `mf2_challenge_workout_started` |
| `challenge_cancelled` | 없음 | 변경 전 미전송 | 상태 전환 분석 누락 | `mf2_challenge_cancelled` 추가 |
| `challenge_completed` | 없음 | 변경 전 미전송 | 상태 전환 분석 누락 | `mf2_challenge_completed` 추가 |
| `challenge_tab_badge_viewed` | challenge screen | badge 소비 / 화면당 | 제품 funnel 가치 낮음 | v2 미전송 |
| `challenge_recommendation_dismissed` | challenge screen | 추천 닫기 / 행동당 | 낮음 | `mf2_challenge_recommendation_dismissed` 보조 이벤트 |
| `ad_requested` | `core/ads/ad_service.dart`, `bottom_native_ad.dart` | SDK load 요청 / attempt당 | load retry로 반복 | `mf2_ad_request_attempted` |
| `ad_loaded` | same | SDK load callback / load당 | AdMob 자동 신호와 중복 가능 | v2 미전송 |
| `ad_shown` | same | impression callback / impression당 | `ad_impression`과 중복 | v2 미전송 |
| `ad_clicked` | same | click callback / click당 | `ad_click`과 중복 | v2 미전송 |
| `ad_dismissed` | same | full-screen dismiss / 표시당 | 핵심 정책 funnel 밖 | v2 미전송 |
| `ad_failed` | same | load/show failure / 오류당 | retry 노이즈 | v2 미전송; Crashlytics 사용 |
| `ad_skipped_by_policy` | ad service | eligibility/frequency cap / 시도당 | 정책 branch별 반복 가능 | `mf2_ad_skipped_by_policy` |
| `app_exception` | 없음 | Analytics 정의/호출 없음 | Crashlytics와 역할 중복 우려 | 추가하지 않음 |

## Firebase filters

- 신규 Analytics 전체: `event_name starts with mf2_`
- Android 신규: 위 조건 AND `platform = android`
- iOS 신규: 위 조건 AND `platform = ios`
- 특정 Android 릴리스: 위 조건 AND `platform = android` AND `app_version = 1.2.6` (필요하면 `build_number = 126` 추가)
- 특정 iOS 릴리스: 위 조건 AND `platform = ios` AND `app_version = <version>` (필요하면 `build_number` 추가)

동일 event name으로 platform segment를 나눠 funnel을 비교한다. 과거 legacy event와 `mf2_`를 합쳐 새 funnel을 만들지 않는다.

## DebugView

Debug build는 dispatch 직전에 다음 coarse context만 출력한다.

`AnalyticsV2: mf2_workout_started session=<anonymous-id> platform=android version=1.2.6`

Release build에는 이 로그가 없다.
