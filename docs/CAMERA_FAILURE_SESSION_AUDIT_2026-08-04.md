# 카메라 시작 실패 및 첫 운동 흐름 감사 보고서

작성일: 2026-08-04  
대상: iOS 1.0.6 / Android 공통 Flutter 코드

## 1. 실제 원인

운동 컨트롤러가 카메라 및 자세 분석 엔진을 초기화하기 전에 DB 세션을 생성했다. 이후 카메라 오류 화면의 `Stop for now`가 정상 운동 중단과 같은 `saveForLater()` 경로를 호출하여, 0회 세션을 paused/recoverable 상태로 저장했다. 이 상태가 기록·챌린지·결과 화면의 입력으로 사용되면서 시작 실패가 운동 완료처럼 보였다.

## 2. 잘못된 운동 기록 저장 경로

기존 경로는 `운동 화면 진입 → 세션 선생성 → 카메라 초기화 실패 → Stop for now → saveForLater/endInterrupted → checkpoint 및 결과 화면`이었다. 현재는 첫 유효 rep가 없는 준비/카메라/캘리브레이션 오류에서 `discardInvalidSession()`만 호출하며, 세션과 journal을 삭제하고 설정 화면으로 돌아간다.

## 3. Paused workout 생성 원인

`saveForLater()`에 실제 운동 시작 및 최소 1회 감지 조건이 없었다. 현재 paused 저장은 `workoutStarted == true && totalReps > 0`인 경우에만 가능하다. recoverable 조회도 `total_reps > 0`만 반환한다.

## 4. 챌린지 오갱신 원인

챌린지 진행 및 결과 배너가 유효한 완료 기록이 아니라 세션 종료/화면 진입 문맥에 의존했다. 현재 챌린지는 `completed && !interrupted && totalReps > 0`인 저장 세션만 계산하고, 결과 배너도 같은 유효성 조건을 통과해야 표시한다.

## 5. 수정한 상태 모델

기존 상태 enum(`idle`, `preparing`, `calibrating`, `active`, `paused`, `resting`, `completed`, `interrupted`, `error`)은 유지하고 `workoutStarted`를 명시적으로 추가했다. 권한 요청은 세션 생성 전 별도 화면, 카메라 초기화는 `preparing`, 실패는 `error`로 관리한다. 최소 변경 원칙상 enum을 전면 교체하지 않고, 준비된 세션과 실제 시작된 운동을 유효성 플래그로 분리했다.

종료 처리는 `_finalizing`/`_finalized` 가드가 있는 컨트롤러 경로로 일원화해 재시도·뒤로 가기·완료 연속 탭의 중복 저장 및 중복 이동을 차단했다.

## 6. 유효 운동 판정 조건

사용 가능한 기록의 최소 조건은 다음과 같다.

- 실제 운동 흐름 진입(`workoutStarted == true`)
- 감지 완료된 스쿼트 1회 이상(`totalReps > 0`)
- 완료 저장 시 `completed == true && interrupted == false`

0회 세션은 일반 운동 기록, paused workout, resume 카드, 챌린지, 완료 이벤트의 대상이 아니다. 감지 실패 0회 진단 세션은 사용자 기록과 섞지 않고 Analytics 실패 이벤트로만 남긴다.

## 7. 수정한 파일

핵심 코드:

- `lib/features/squat/application/workout_session_controller.dart`
- `lib/features/squat/application/workout_session_state.dart`
- `lib/features/squat/domain/services/workout_session_policy.dart`
- `lib/features/squat/domain/services/workout_repository.dart`
- `lib/features/squat/data/sqlite_workout_repository.dart`
- `lib/features/squat/presentation/screens/active_workout_screen.dart`
- `lib/features/squat/presentation/screens/camera_permission_screen.dart`
- `lib/features/squat/presentation/screens/workout_summary_screen.dart`
- `lib/features/challenges/application/challenge_controller.dart`
- `lib/features/challenges/presentation/challenge_screen.dart`
- `lib/core/analytics/analytics_service.dart`
- `lib/core/ads/ad_eligibility.dart`
- `lib/core/ads/ad_service.dart`
- `lib/app/app.dart`
- `lib/app/router.dart`
- `lib/features/onboarding/presentation/onboarding_screen.dart`

번역·문서·테스트:

- `lib/l10n/app_*.arb` 및 생성된 localization 파일
- `docs/PRIVACY_AND_DATA.md`
- `docs/FUNNEL_ANALYTICS_AUDIT_2026-08-03.md`
- `test/features/squat/domain/workout_session_policy_test.dart`
- `test/features/squat/data/sqlite_workout_repository_test.dart`
- `test/features/challenges/application/weekly_challenge_progress_test.dart`
- `test/core/ads/ad_eligibility_test.dart`

## 8. Analytics 변경

추가/정리한 이벤트는 `camera_permission_requested`, `camera_initialization_started`, `camera_initialization_completed`, `camera_initialization_failed`, `workout_failed`, `workout_cancelled`이다. `workout_started`는 첫 실제 운동 진입에서 한 번, `first_rep_detected`는 첫 감지에서 한 번 전송한다. `workout_completed`는 유효 기록 저장 성공 후에만 전송하며 시작 실패에는 전송하지 않는다.

실패 이벤트에는 안전하게 분류한 `failure_stage`, `failure_reason`, `camera_state`, `permission_state`, `session_state`를 포함한다. 공통 Analytics 계층이 `platform`, `app_version`, `device_category`를 추가한다. 영상, 랜드마크 좌표, 사용자 식별 정보는 보내지 않는다.

## 9. 온보딩 마지막 버튼

방안 A를 적용했다. 7개 언어의 `Start workout` 계열 문구를 `Get started`/`시작하기` 의미로 변경했다. 현재 동작이 온보딩 완료 저장 후 홈/설정 흐름으로 이동하므로 문구와 실제 이동을 일치시키고, 카메라 권한 흐름을 자동 시작하지 않는다.

## 10. ATT 요청 시점

ATT는 온보딩 완료 저장 직후 요청하고, 시스템 권한 처리가 끝난 다음 메인 화면으로 이동한다. UMP와 광고 SDK 초기화는 첫 유효 운동 완료 후까지 지연하므로 ATT와 UMP가 연속 또는 동시에 나타나지 않는다. OS가 ATT 거절 상태를 기억하므로 반복 시스템 요청도 발생하지 않는다.

실제 팝업 표시 순서와 App Store 개인정보 표시의 최종 일치는 배포 빌드 실기기에서 확인해야 한다.

## 11. 첫 운동 전 광고 정책

공통 `AdEligibility` 정책을 추가했다.

- 완료 운동 0회: 네이티브·전면 광고 모두 숨김
- 완료 운동 1회 이상: 메인 화면 네이티브 광고 허용
- 완료 운동 3회 이상: 전면 광고 허용
- 온보딩, 권한, 카메라 오류, 운동 진행, 첫 챌린지 설정, 운동 결과 화면: 광고 없음

광고 위젯 자체를 만들지 않으므로 숨김 상태에서 빈 광고 공간이 남지 않는다.

## 12. 카메라 안내 단계

최초 카메라 설명 화면에 자동 카운트, 전신 배치, 휴대폰 고정, 기기 내 영상 처리 안내를 통합했다. `Allow camera and continue` 후 권한이 허용되면 기존의 두 번째 `I'm in position` 탭을 생략하고 바로 카메라 준비/카운트다운으로 진행한다. 최초 안내를 이미 본 사용자는 기존 동작을 유지한다.

오류 버튼은 `Try again`과 `Back to setup`으로 변경했다. 시작 전 `Back to setup`은 리소스와 임시 세션을 정리하고 결과 화면 없이 설정으로 이동한다.

## 13. 주 3회 챌린지

도메인 enum과 계산 로직은 있었지만 컨트롤러가 weekly 데이터를 삭제하고 선택 UI가 노출하지 않아 실제로 사용할 수 없었다. 삭제 로직을 제거하고 주 3회 카드를 복구했으며, 사용자가 알림 요일 3개를 선택할 수 있게 했다.

진행도는 선택 요일과 무관하게 같은 주의 유효 운동 날짜를 인정하고, 같은 날 여러 운동은 1일 1회로 계산한다. 4주간 12일을 목표로 하며 0회·실패·중단 기록은 제외한다. 과거 버전에서 이미 삭제된 weekly 데이터는 안전하게 복원할 근거가 없어 자동 복구하지 않는다.

## 14. 단위 테스트 결과

`flutter test`: **81개 전체 통과**

추가 검증 범위:

- 카메라 실패/0회 세션 저장 및 paused 생성 차단
- 유효 조기 종료와 완료/챌린지 판정
- workout completed 전송 가능 조건
- DB discard 및 recoverable 필터
- 주 3회 챌린지의 동일 날짜 중복 제외
- 첫 운동 전 광고 차단, 1회/3회 임계값

권한 시스템 팝업, 실제 카메라 장치 오류, 앱 강제 종료는 단위 테스트로 재현하지 않았으며 실기기 검증 항목이다.

## 15. 정적 분석

`flutter analyze`: **No issues found** (5.5초)

## 16. iOS Release 빌드

`flutter build ios --release --no-codesign`: **성공** (Xcode build 49.4초)

- 결과: `build/ios/iphoneos/Runner.app`
- 크기: 102.2MB
- 코드 서명을 생략했으므로 배포/실기기 설치 전 서명이 필요하다.

## 17. Android App Bundle 빌드

`flutter build appbundle --release`: **성공** (155.4초)

- 결과: `build/app/outputs/bundle/release/app-release.aab`
- 크기: 124.9MB

경고:

- `CupertinoIcons` 폰트를 찾지 못했다는 아이콘 폰트 경고
- `google_mobile_ads 9.0.0` 내부 deprecated Android API 경고
- MaterialIcons tree-shaking 안내

이번 변경 코드의 컴파일/정적 분석 경고는 아니다. 의존성 조회에서는 제약과 호환되지 않는 최신 패키지 35개가 있다는 기존 안내가 있었다.

## 18. 실기기 추가 확인 항목

- 신규 설치/기존 거절/제한 상태별 카메라 권한 및 설정 복귀
- 카메라 없음, 초기화 실패·시간 초과, 초기화 중 앱 종료
- 캘리브레이션 실패/중 종료와 첫 rep 전 종료
- Retry/Back/완료 버튼 연속 탭 및 Navigator 중복 여부
- 백그라운드/강제 종료 후 resume 카드 및 숨은 0회 row 여부
- 정상 1회 이상 조기 종료, 목표 완료의 기록·챌린지·이벤트 정확히 1회
- Firebase DebugView의 실패/완료 이벤트 파라미터
- 온보딩 완료 뒤 ATT → 메인 화면 순서와 첫 유효 운동 완료 뒤 UMP 표시
- 네이티브 광고 1회 이후, 전면 광고 3회 이후 노출
- iOS/Android에서 주 3회 선택 및 주간 경계 계산

## 19. 남은 위험 요소

- DB 세션은 아직 카메라 초기화 전에 생성된다. 제어된 실패에서는 삭제하고 모든 사용자 조회에서 0회를 숨기지만, 첫 rep 전 강제 종료는 숨은 0회 row를 남길 수 있다. 기존 실제 사용자 데이터를 오삭제하지 않기 위해 자동 일괄 삭제는 하지 않았다.
- 캘리브레이션 오류는 시작 전 실패로 폐기되지만, 별도 시간 제한을 강제하는 watchdog은 없다.
- ATT 시스템 팝업의 실제 표시 시점과 온보딩 화면 복귀 후 메인 화면 전환을 배포 빌드에서 확인해야 한다.
- 단위 테스트는 정책과 저장소를 검증했지만 실제 카메라 하드웨어, OS 권한 UI, 광고 네트워크 응답은 대체하지 못한다.

## 최종 흐름

`카메라 초기화 실패 → 오류 안내 → Try again 또는 Back to setup → 임시 세션 폐기 → 운동 기록/paused/resume/챌린지/workout_completed/결과 화면 없음`
