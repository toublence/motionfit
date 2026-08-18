# 평점·리뷰 요청 기능 감사 보고서

작성일: 2026-08-04

## 1. 기존 기능 존재 여부

기존에 `in_app_review`가 `pubspec.yaml`에 선언되어 있었고, 운동 결과 화면에서 `isAvailable()` 후 `requestReview()`를 호출하는 자동 요청 코드가 실제로 실행되는 상태였다. iOS Pod와 Android Flutter 플러그인 연결도 존재했다.

## 2. 기존 문제점과 수정 내용

기존 구현은 다음 문제가 있었다.

- 결과 화면 위에서 바로 리뷰 API를 호출함
- 정상 완료 횟수 3회만 확인하고 서로 다른 운동 날짜 2일 조건이 없음
- `reviewRequested` boolean 하나로 영구 차단하여 버전별·120일 재요청 정책이 없음
- 알림 제안 외의 화면 전환, 앱 lifecycle, 모달, 전면광고 충돌을 확인하지 않음
- 설정 화면의 수동 평가 메뉴가 없음
- Analytics가 `review_requested` 하나뿐이어서 실제 확인 가능한 단계가 구분되지 않음

결과 화면의 직접 호출을 제거하고 `ReviewPromptService`로 자동·수동 요청을 일원화했다. 결과 화면에서는 조건을 예약만 하고, 사용자가 메인 화면으로 돌아온 뒤 1.5초 후 UI 상태를 재검사해 공식 API를 호출한다.

## 3. 패키지

새 패키지는 추가하지 않았다. 기존 선언 `in_app_review: ^2.0.11`을 재사용했으며 현재 lockfile 해석 버전은 **2.0.12**다. 이 패키지가 iOS StoreKit 및 Android Google Play In-App Review API를 연결한다.

## 4. 자동 리뷰 요청 조건

다음을 모두 충족해야 한다.

- 저장된 유효 정상 완료 운동 3회 이상
- 유효 운동 날짜가 서로 다른 날짜 2일 이상
- 결과 화면에서 완료 버튼을 눌러 `/squat` 메인 화면으로 복귀
- 화면 전환 후 1.5초 경과
- 앱 lifecycle이 `resumed`
- root navigator에 다른 모달이 없음
- 전면광고가 표시 중이지 않음
- 같은 앱 실행 세션에 요청/예약/진행 중 요청이 없음
- 현재 앱 버전에서 요청을 시도하지 않음
- 마지막 자동 요청 시도 후 120일 이상 경과
- Release 빌드

세 번째 완료에서 알림 제안·권한 흐름이 있었다면 리뷰는 예약하지 않고 다음 유효 운동으로 미룬다. 리뷰가 예약된 완료 흐름에서는 전면광고를 표시하지 않는다.

## 5. 유효 운동 기준

기존 공통 `WorkoutSessionPolicy.canUpdateChallenge()`를 재사용한다.

- `session.completed == true`
- `session.interrupted == false`
- `session.totalReps > 0`
- 저장소에 정상 저장되어 조회되는 세션

따라서 권한/카메라/자세 엔진/캘리브레이션 실패, 0회, 첫 rep 전 종료, paused, interrupted, 저장 실패 세션은 횟수와 날짜에 포함되지 않는다. 과거 0회 기록도 저장소 필터와 공통 정책에서 제외한다.

## 6. 중복 요청 방지

서비스 내부의 `_pending`, `_requestInProgress`, `_requestedInCurrentSession` 가드로 예약·호출·동일 실행 세션 중복을 차단한다. 결과 완료 버튼의 기존 `_finishing` 가드도 유지한다. 메인 화면 rebuild나 lifecycle 복귀만으로 새 예약이 만들어지지 않는다.

## 7. 마지막 요청일과 버전 저장

`UserPreferences`에 다음 필드를 추가했다.

- `lastReviewRequestAttemptAt`
- `lastReviewRequestAppVersion`

공식 `requestReview()`를 호출하기 직전에 현재 버전과 시각을 로컬 preferences에 먼저 저장한다. 시스템 창 노출이나 리뷰 제출 여부는 저장하지 않는다. 기존 `reviewRequested`는 호환용으로만 유지하며, 과거 true 값은 현재 버전·현재 시각으로 보수적으로 마이그레이션하여 즉시 중복 요청하지 않는다.

## 8. 다른 팝업과 충돌 방지

- ATT는 온보딩 완료 후이므로 최소 3회 조건과 분리된다.
- 해당 운동에서 알림 제안/권한 흐름이 제시되면 리뷰를 다음 운동으로 연기한다.
- 메인 복귀 후 root navigator가 pop 가능한 상태이면 다른 모달이 있다고 보고 취소한다.
- 앱이 active가 아니거나 경로가 `/squat`이 아니면 취소한다.
- `AdService.fullScreenShowing`을 확인하고, 리뷰 예약 시 해당 완료의 전면광고를 건너뛴다.
- 챌린지 결과가 `/challenge`로 돌아가는 흐름에서는 리뷰를 예약하지 않는다.

## 9. 설정 화면 수동 평가 메뉴

기존 설정 ListTile 스타일로 별 아이콘과 다음 항목을 추가했다.

- 한국어: `앱 평가하기` / `MotionFit을 평가해 주세요`
- 영어: `Rate this app` / `Rate MotionFit`

연속 탭은 `_openingStoreReview` 및 서비스 `_openingStore` 가드로 차단한다. 열기 실패 시 현지화된 짧은 SnackBar만 표시하고 앱은 계속 동작한다. 수동 평가는 자동 요청의 버전·120일 제한을 변경하지 않는다.

## 10. iOS App Store 연결

Apple Lookup API에서 번들 ID `com.namslab.motionfit.squat`에 대응하는 App Store ID **6793439770**을 확인했다. 수동 메뉴는 다음 write-review URL을 외부 앱으로 연다.

`https://apps.apple.com/app/id6793439770?action=write-review`

자동 요청은 `in_app_review`의 StoreKit 연결을 사용한다.

## 11. Android Play Store 연결

런타임 `PackageInfo.packageName`을 사용해 먼저 `market://details?id=<package>`를 연다. Play Store 앱이 없거나 실행에 실패하면 `https://play.google.com/store/apps/details?id=<package>`로 fallback한다. 현재 Android 배포 applicationId는 `nam.memento.app`이다.

## 12. Analytics 이벤트

- `review_eligibility_met`: 횟수·날짜·기간 조건 충족
- `review_request_scheduled`: 메인 복귀 후 요청 예약
- `review_request_skipped`: 조건/UI/API 사유로 건너뜀
- `review_prompt_requested`: 공식 API 호출 직전 상태 저장 완료
- `review_request_completed`: API Future가 예외 없이 종료됨. 리뷰 작성 의미가 아님
- `manual_rate_tapped`: 설정 메뉴 선택
- `store_review_page_opened`: 외부 스토어 열기 성공
- `store_review_page_failed`: 외부 스토어 열기 실패

횟수·날짜·설치일·마지막 요청일은 bucket으로 전송하며 공통 계층이 platform/app version/device category를 추가한다. 시스템 창의 실제 노출, 별점, 리뷰 제출을 의미하는 이벤트는 만들지 않았다.

## 13. 현지화

영어, 한국어, 독일어, 스페인어, 프랑스어, 일본어, 아랍어 ARB와 생성 파일에 메뉴 제목·부제·오류 문구를 추가했다. `flutter gen-l10n`과 기존 7개 locale/RTL smoke test를 통과했다.

## 14. 수정 파일

신규:

- `lib/core/reviews/review_prompt_policy.dart`
- `lib/core/reviews/review_prompt_service.dart`
- `lib/core/reviews/review_prompt_provider.dart`
- `lib/core/reviews/store_listing_config.dart`
- `test/core/reviews/review_prompt_policy_test.dart`
- `test/core/reviews/review_prompt_service_test.dart`

수정:

- `lib/features/squat/presentation/screens/workout_summary_screen.dart`
- `lib/features/settings/domain/user_preferences.dart`
- `lib/features/settings/application/preferences_controller.dart`
- `lib/features/settings/presentation/settings_screen.dart`
- `lib/features/records/domain/retention_metrics.dart`
- `lib/core/analytics/analytics_service.dart`
- `lib/core/ads/ad_service.dart`
- `lib/app/localization/arb/app_{en,ko,de,es,fr,ja,ar}.arb`
- 생성된 `lib/app/localization/generated/app_localizations*.dart`
- 관련 preferences/retention 테스트

## 15. 단위 테스트

`flutter test` 전체 실행: **90개 통과**. 이후 팝업 충돌과 수동 스토어 테스트 2개를 추가했고 review service 대상 테스트 **6개 전체 통과**했다.

검증 범위에는 1·2회 미요청, 같은 날 3회 미요청, 2일/3회 eligible, 버전당 1회, 120일, 메인 복귀 전 미요청, idempotency, 다른 팝업, API 실패 non-fatal, 수동 평가의 자동 제한 독립성이 포함된다.

## 16. flutter analyze

`flutter analyze`: **No issues found**.

## 17. iOS Release 빌드

`flutter build ios --release --no-codesign`: **성공**

- Xcode build: 50.0초
- 결과: `build/ios/iphoneos/Runner.app`
- 크기: 102.2MB
- 코드 서명은 의도적으로 생략

## 18. Android App Bundle 빌드

`flutter build appbundle --release`: **성공**

- Gradle bundleRelease: 125.4초
- 결과: `build/app/outputs/bundle/release/app-release.aab`
- 크기: 124.9MB

기존 CupertinoIcons 폰트 탐색 경고, MaterialIcons tree-shaking 안내, `google_mobile_ads 9.0.0` 내부 deprecated API 경고가 있었다. 이번 리뷰 변경에서 발생한 분석/컴파일 경고는 없다.

## 19. 실기기 직접 확인 항목

- App Store/TestFlight 및 Play Store 설치본에서 시스템 리뷰 UI의 표시 가능 여부
- 세 번째 유효 운동을 2일에 걸쳐 완료한 뒤 결과 화면에는 리뷰가 없고 메인에서만 요청되는지
- 알림 권한을 요청한 운동에서는 리뷰가 연기되는지
- 시스템 리뷰 요청이 예정된 완료에서 전면광고가 나오지 않는지
- background 전환, 메인 전환 중 모달, 연속 완료 탭에서 중복이 없는지
- iOS write-review 페이지와 Android Play Store/웹 fallback
- 7개 언어, 특히 아랍어 RTL 설정 ListTile
- Firebase DebugView 이벤트와 bucket 값

## 20. 남은 위험 요소

- iOS와 Android 모두 시스템 정책상 리뷰 창이 실제로 표시됐는지, 사용자가 제출했는지 앱에서 확인할 수 없다.
- TestFlight와 Play Store 외 설치에서는 공식 시스템 리뷰 UI가 표시되지 않을 수 있다.
- legacy `reviewRequested == true` 데이터에는 과거 날짜·버전이 없어 현재 시점으로 보수적으로 마이그레이션한다. 이 사용자는 최소 120일 및 다음 앱 버전 전까지 자동 재요청되지 않는다.
- 앱 프로세스가 API 호출 직전 상태 저장 후 종료되면 창이 표시되지 않았어도 해당 버전 시도로 기록된다. 중복 방지를 우선한 의도된 선택이다.
- UI 모달 충돌은 root navigator 상태로 판정한다. 플랫폼이 앱 외부에서 표시하는 예외적인 시스템 UI는 앱이 완전히 식별할 수 없다.
