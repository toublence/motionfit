# 퍼널·Analytics 개선 완료 보고서 (2026-08-03)

## 1. 조사 결과와 이탈 가능 원인

### 온보딩

- 화면 수는 이미 3개였지만 두 번째 화면에 설치·촬영·개인정보 설명이 한꺼번에 들어가 문장이 길었다.
- 마지막 CTA가 단순한 “시작하기”였고, Android에서는 완료 과정에서 카메라 권한을 요청한 뒤 ATT/UMP와 광고 초기화까지 이어질 수 있었다.
- 온보딩 완료 직후 홈의 네이티브 광고가 표시될 수 있었다.
- 완료 여부만 저장해 중간 단계 이탈과 다음 실행 재진입 지점을 구분할 수 없었다.
- 화면은 `SafeArea`와 하단 고정 CTA를 사용해 기본 구조상 스크롤 뒤에 버튼이 숨지는 않았지만, 긴 본문이 작은 화면과 큰 글꼴에서 콘텐츠 공간을 압박할 가능성이 있었다.

### 온보딩 완료 → 첫 운동 시작

- 신규 기본 계획이 3세트 × 10회, 휴식 60초여서 첫 사용자가 즉시 시작하기에는 부담이 컸다.
- 홈 시작 버튼을 누르면 별도 설명 화면 없이 OS 카메라 권한 팝업을 즉시 요청했다.
- `workout_start`가 실제 운동 가능 시점보다 이른, 세션 DB 생성 직후 기록됐다. 카메라 초기화나 캘리브레이션 실패도 시작 사용자로 집계됐다.
- 카메라 준비 중에는 카운트다운과 프리워밍이 있었지만 이를 설명하는 퍼널 이벤트가 없었다.

### 운동 시작 → 완료

- 기존 `workout_start`가 너무 빨라 완료율의 분모가 부풀려졌다.
- 캘리브레이션, 첫 rep 전, 세트 진행 중, 휴식, 카메라 오류가 하나의 중단 흐름으로 뭉쳐 있었다.
- 빨간 종료 버튼은 진행 상태를 복구 가능 세션으로 저장했지만 `workout_cancelled`가 없어 이탈 단계가 측정되지 않았다.
- 휴식 화면에 네이티브 광고가 표시될 수 있었다.
- 얕은 스쿼트 안내, 추적 손실 안내, TTS 실패 표시, 카메라 로딩, 카메라 오류 재시도는 이미 구현돼 있었다. 이번 변경은 이 상태들을 별도 이벤트와 취소 원인으로 측정한다.

## 2. 수정한 화면과 흐름

- 온보딩을 다음 3개 핵심 메시지로 정리했다.
  1. 카메라 자동 카운트
  2. 실시간 자세 코칭
  3. 기록과 챌린지를 통한 지속
- 마지막 CTA를 “운동 시작하기”로 변경하고 명시적 뒤로 버튼을 추가했다.
- 카메라 권한은 운동 시작 시 요청한다. iOS ATT는 온보딩 완료 직후 메인 화면 진입 전에 요청하고, UMP와 광고 초기화는 첫 유효 운동 완료 후 처리한다.
- 신규 기본 운동값을 1세트 × 5회, 휴식 15초로 변경했다. 기존 사용자의 저장 계획과 상세 설정 기능은 유지한다.
- 운동 시작 탭 후 카메라 권한 안내 화면을 먼저 표시하고, 사용자가 안내 CTA를 누른 경우에만 OS 권한을 요청한다.
- 거부 또는 제한 상태에서는 앱을 종료하거나 빈 화면으로 보내지 않고 설정 이동 또는 재시도를 제공한다.
- 온보딩 완료 후에는 운동 설정 화면으로 바로 이동한다.
- 휴식 화면 광고와 중단 요약 광고를 제거했다.

## 3. 이벤트 호환과 의미

| 기존 이벤트 | 처리 | 현재 의미 |
|---|---|---|
| `first_open`, `app_open`, `session_start` | Firebase 자동 수집만 사용 | 직접 `app_open` 중복 전송 제거 |
| `onboarding_complete` | 이름 유지 | 완료 플래그 저장 성공 후 한 번 |
| `workout_start` | 이름 유지 | 첫 실제 rep 동작 시작 시 한 번으로 의미 교정 |
| `workout_complete` | 이름 유지 | 운동 기록 저장 성공 후 한 번 |
| `workout_detection_summary` | 이름 유지 | 완료/중단 진단 집계가 준비된 뒤 한 번 |
| `challenge_recommendation_viewed` | 유지 | 신규 `challenge_recommendation_shown`과 동시 전송 |
| `challenge_card_selected` | 유지 | 신규 `challenge_selected`와 동시 전송 |
| `reminder_permission_result` | 유지 | granted/denied 분리 이벤트와 동시 전송 |
| `reminder_enabled` | 유지 | OS 예약 성공 후에만 전송 |
| `ad_impression`, `ad_click` | Firebase/AdMob 자동 수집만 사용 | 직접 중복 대신 `ad_shown`, `ad_clicked` 사용 |

`workout_complete`와 신규 `workout_completed`는 마이그레이션 기간에 함께 전송한다. Analytics 전송 큐를 직렬화해 같은 세션에서 `workout_completed` 뒤에 `workout_detection_summary`가 전송되도록 했다. 완료 요약 화면은 별도 `workout_summary_viewed`로 기록한다.

## 4. 신규 이벤트와 주요 파라미터

### 온보딩

- `onboarding_started`
- `onboarding_step_viewed`
- `onboarding_next_tapped`
- `onboarding_back_tapped`
- `onboarding_skipped` (명시적 skip 흐름용 API, 현재 UI에는 혼란을 줄 skip 버튼을 두지 않음)
- `onboarding_abandoned`
- 기존 `onboarding_complete`

파라미터: `step_index`, `step_name`, `total_steps`, `elapsed_time_bucket`, `exit_reason`, 공통 컨텍스트.

### 첫 운동과 운동 상태

- `workout_setup_viewed`
- `workout_start_tapped`
- `camera_permission_result`
- `workout_screen_viewed`
- `workout_initialization_started`
- `calibration_started`
- `calibration_completed`
- `first_rep_detected`
- `workout_started`
- `workout_cancelled`
- `workout_completed`
- `workout_summary_viewed`
- `second_workout_completed`

`workout_cancelled` 파라미터: `cancel_stage`, `cancel_reason`, `elapsed_time_bucket`, `detected_rep_bucket`, `tracking_loss_bucket`, 공통 컨텍스트.

### 챌린지

- `challenge_recommendation_shown`
- `challenge_recommendation_tapped`
- `challenge_recommendation_dismissed`
- `challenge_selected`
- `challenge_started`
- 기존 `challenge_tab_viewed`, `challenge_recommendation_viewed`, `challenge_card_selected`, `challenge_workout_started` 유지

### 알림

- `reminder_permission_requested`
- `reminder_permission_granted`
- `reminder_permission_denied`
- `reminder_scheduled`
- `reminder_schedule_failed`
- `reminder_disabled`
- 기존 prompt/result/enabled 이벤트 유지

### 광고

- `ad_requested`
- `ad_loaded`
- `ad_shown`
- `ad_dismissed`
- `ad_failed`
- `ad_skipped_by_policy`
- `ad_clicked`

파라미터: `ad_format`, `ad_placement`, `skip_reason` 또는 `failure_stage`, `workout_completion_count`, `onboarding_completed`, 공통 컨텍스트.

### 화면

Firebase `screen_view`의 `screen_name`으로 `onboarding`, `workout_setup`, `camera_permission_guide`, `calibration`, `active_workout`, `rest`, `workout_summary`, `challenge`, `records`, `settings`, `reminder_settings`를 기록한다.

모든 커스텀 이벤트에는 `platform`, 실제 패키지 `app_version`, `build_number`, `device_category`가 공통으로 추가된다. 국가는 정확한 위치를 직접 수집하지 않고 Firebase의 기본 국가 차원을 사용한다.

## 5. 중복 방지

- Firebase 자동 `app_open`, `ad_impression`, `ad_click`을 직접 전송하던 코드를 제거했다.
- Analytics 전송을 하나의 직렬 큐로 처리하며 전송 실패는 앱 흐름으로 전파하지 않는다.
- 온보딩 시작·단계·완료 상태를 State와 SharedPreferences에 저장한다.
- `onboarding_abandoned`는 일시적 background 전환 때 보내지 않는다. 완료되지 않은 이전 세션 표식이 다음 앱 실행에서 발견될 때 한 번 기록하고 새 세션 표식으로 교체한다.
- 캘리브레이션 완료, 첫 rep, 운동 시작, 탐지 요약은 세션 컨트롤러의 1회 플래그로 보호한다.
- 화면은 State 초기 진입과 1초 중복 방지로 rebuild·회전 중복을 막는다. 탭 재진입은 실제 진입으로 다시 기록한다.
- 알림 변경은 직렬화하며 예약 성공 후에만 scheduled/enabled를 기록한다.

## 6. 광고·알림·챌린지 정책

### 광고

- 온보딩 중, 카메라 권한 직후, 운동 중, 휴식 중, 운동 취소 직후에는 광고를 표시하지 않는다.
- 네이티브 광고는 첫 유효 운동 완료 후 일반 화면에 표시할 수 있으며 운동 결과 화면에서는 숨긴다.
- 전면 광고만 정상 운동 3회 완료 전까지 차단하며, 이후에도 정상 완료 뒤 하루 1회 제한을 유지한다.
- 자동 `ad_impression`과 직접 이벤트 중복을 제거했다.

### 알림

- 첫 정상 운동 완료 뒤 제안하는 기존 흐름을 유지한다.
- 거절 표식이 있으면 OS 권한 팝업을 다시 요청하지 않고 현재 권한만 확인한다.
- 권한 허용 뒤 실제 로컬 예약이 모두 성공한 경우에만 `reminder_scheduled`와 `reminder_enabled`를 기록한다.
- 예약 실패는 상태를 복구하고 `reminder_schedule_failed`를 기록한다.
- 제목·본문은 현재 앱 언어, 예약 시간은 기기 현지 시간대를 사용한다.

### 챌린지

- 첫 정상 운동 전에는 추천 표시와 추천 이벤트를 만들지 않는다.
- 첫 정상 운동 완료 뒤 챌린지 탭 신규 배지를 한 번 표시한다.
- 추천은 강제 화면이 아니라 챌린지 탭 카드로만 표시한다.
- 추천 닫기 선택은 DB `app_state`에 저장해 반복 노출하지 않는다.

## 7. 개인정보와 심사 영향

- Analytics에 카메라 이미지·영상, landmark, 관절 각도, 정확한 위치, 사용자 식별자, 정확한 운동 시각, 자유 입력을 보내지 않는다.
- reps, duration, tracking loss, confidence, 설치 경과일은 구간 값으로 축소했다.
- 기기 분류는 `phone`/`tablet`만 사용한다.
- 카메라 권한 목적과 `NSCameraUsageDescription`의 온디바이스 처리·영상 비저장 설명은 기존 목적과 일치한다.
- ATT는 온보딩 완료 직후 메인 화면 진입 전에 요청한다. UMP와 네이티브 광고 초기화는 첫 유효 운동 완료 후 처리하며 전면 광고 로드는 정상 운동 3회 완료 전까지 막는다.
- App Store Privacy Nutrition Label, Google Play Data Safety, 공개 개인정보 처리방침에는 Firebase Analytics/Crashlytics와 Google Mobile Ads, 광고 식별자/동의 흐름을 실제 배포 설정에 맞게 반영해야 한다. 심사 메모에는 “ATT는 온보딩 완료 후 메인 화면 전에 요청하고, 카메라는 운동 시작 의사 표시 뒤, UMP는 첫 유효 운동 완료 후 광고 활성화 전에 요청”한다고 적는 것이 좋다.

상세 구현 기준은 `docs/PRIVACY_AND_DATA.md`도 갱신했다.

## 8. 검증 결과

- `flutter analyze`: 성공, 이슈 없음
- `flutter test`: 성공, 73개 테스트 통과
- `flutter build ios --release --no-codesign`: 성공, `build/ios/iphoneos/Runner.app` 102.2MB
- `flutter build appbundle --release`: 성공, `build/app/outputs/bundle/release/app-release.aab` 124.8MB

Android 빌드에는 CupertinoIcons 폰트 미포함 안내가 있었지만 빌드를 막지 않았다. 현재 UI는 MaterialIcons만 사용한다.

자동 테스트에는 작은 화면 200% 글꼴 레이아웃, 데이터 저장·복구, 감지·추적 손실·얕은 스쿼트, 다국어, Analytics bucket 경계가 포함된다. OS 권한 팝업, 실제 카메라 인식, ATT/UMP, 광고 실노출은 시뮬레이터/실기기와 Firebase DebugView에서 다음 조합을 수동 확인해야 한다.

- 신규 설치, 온보딩 첫/중간 단계 종료 후 재실행
- iPhone 소형 화면과 iPad, Android phone/tablet
- 카메라 허용·거절·영구 거절·설정에서 재허용
- 캘리브레이션 실패, 첫 rep 전 종료, 세트 중 종료, 정상 완료
- 알림 허용·거절·설정에서 재허용
- 세 번째 정상 운동 전후 광고 정책
- 앱 회전·rebuild·background/resume의 이벤트 중복

## 9. 배포 후 Firebase 확인 퍼널

기본 비교는 `platform`, `app_version`, Firebase 기본 `country`, 필요 시 `device_category`로 분할한다.

```text
first_open
→ onboarding_started
→ onboarding_complete
→ workout_setup_viewed
→ workout_start_tapped
→ camera_permission_result
→ calibration_completed
→ first_rep_detected
→ workout_started
→ workout_completed
→ reminder_prompt_shown
→ reminder_scheduled
→ second_workout_completed
```

보조 진단:

- 온보딩: `onboarding_step_viewed`의 step별 사용자 수와 `onboarding_abandoned.exit_reason`
- 시작 전: `workout_start_tapped → camera_permission_result → calibration_completed`
- 운동 중: `first_rep_detected → workout_started → workout_completed`
- 취소: `workout_cancelled`의 `cancel_stage × cancel_reason`
- 감지: `workout_detection_summary`의 tracking/calibration/confidence bucket
- 챌린지: `recommendation_shown → tapped → selected → started`
- 광고: `ad_skipped_by_policy → requested → loaded → shown → dismissed/failed`

표본이 작으므로 최소 1~2개 앱 버전 기간 동안 기존/신규 호환 이벤트를 함께 관찰하고, 성공 판단보다 이벤트 누락·순서·중복 여부를 DebugView와 BigQuery export에서 먼저 확인한다.
