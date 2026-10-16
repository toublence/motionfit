# MotionFit Flutter iOS 1.6.6 — AdMob 전면광고 미노출 독립 감사

작성일: 2026-10-16 (Asia/Seoul). 분석 대상 저장소: `/Users/nam/projects/flutter/motionfit`.

**분석 전용 보고서다. 소스·설정·테스트·광고 정책·버전을 변경하지 않았다. 빌드, 설치, 앱 실행, 운영 광고 요청·강제 노출, 업로드·배포를 수행하지 않았다.** 아래 수정·테스트 항목은 후속 작업 제안이다.

## A. 최종 결론

### 네 가지 핵심 질문

1. **iOS 1.6.6에 실제 광고 미노출 코드 버그가 있는가?**
   iOS 버전을 처음 `1.6.6(66)`으로 설정한 **배포 후보 커밋 `f899926`에는 UMP 일시 오류 뒤 같은 프로세스에서 동의 흐름을 재시도하지 못하는 결함이 있다.** 현재 HEAD에서도 양식 오류 뒤 복구 공백이 남아 있다. 그러나 실제 App Store 배포 SHA를 확인하지 못했으므로, 이 결함이 운영 바이너리에 포함됐다고 확정하지 않는다. 또한 이 결함은 주로 **요청 이전**을 막는다. **매칭 958회 중 953회가 코드 때문에 표시되지 않았다는 증거는 없다.**
2. **포즈 501회 매칭 / 5회 노출을 설명하는 코드 경로는 무엇인가?**
   이 저장소의 공통 전면광고는 이전 완료 운동 수가 기준을 충족한 앱 실행 시 미리 로드되지만, 일반 운동에서는 **완료 → 결과 화면 → 주 완료 버튼**까지 도달해야 표시를 시도한다. 운동을 새로 완료하지 않거나 결과 화면에서 종료하면 캐시는 미사용이다. 10분 쿨다운도 표시만 제한한다. 따라서 요청과 표시 기회의 구조적 차이는 존재한다. 다만 두 운영 라벨 중 어느 것이 소스의 단일 iOS 전면 ID인지 미확인이고, 필터된 운영 기회·로드·show 로그도 없어 **501/5의 주원인이 기회 부족인지 코드/SDK 실패인지 수량으로 분해할 수 없다.**
3. **복싱 457회 매칭 / 0회 노출을 설명하는 코드 경로는 무엇인가?**
   HEAD와 `f899926` 모두 **복싱 기능·라우트·전용 광고 ID·전용 load/show 경로를 찾지 못했다.** 스쿼트·푸시업·플랭크가 하나의 전면 ID를 공유한다. 따라서 “사용하지 않는 복싱 광고를 이 코드가 457회 preload했다”는 설명은 증명되지 않는다. 복싱 표시 진입점 부재는 확인했지만 **457회의 요청 발생원도 함께 설명해야 하므로**, 이것만으로 운영 원인을 확정해서는 안 된다. 배포 SHA와 콘솔의 숫자 ID↔라벨 매핑이 우선 필요하다.
4. **가장 우선적인 문제는 무엇인가?**
   판단의 첫 병목은 **배포 소스·광고 단위 귀속 불명 + 표시 기회부터 impression까지의 로그 부재**다. 코드 측에서는 UMP 실패 복구, HEAD의 만료 캐시 재준비·현재 값 의존 경로가 후속 검토 대상이다. **동의/PRO 권리나 첫 운동 보호·쿨다운을 완화할 근거는 없다. READY 광고·정책 충족·표시 진입이라는 조건이 모두 확정됐는데도 정상 경로에서 show가 누락되는 P0 결함은 확인하지 못했다.**

### 운영 최종 판정

| 대상 | 선택한 최종 판정 | 이유 |
|---|---|---|
| 포즈 전면 501/5 | **INSUFFICIENT_EVIDENCE** | 기회 부족·정책 제외 경로는 확정. 해당 운영 단위와 배포 소스 귀속, 실제 load/show 결과는 미확인 |
| 복싱 전면 457/0 | **INSUFFICIENT_EVIDENCE** | 조사한 두 revision에 복싱 load/show가 모두 없음. 별도 단위의 요청 발생원을 설명할 배포·콘솔 증거 부족 |
| 전체 958/5 | **INSUFFICIENT_EVIDENCE** | 매칭은 SDK 로드 성공이나 표시 기회가 아니며, 혼합 Firebase 합계로 보완 불가 |

**핵심 질문의 답:** 요청과 표시 기회가 달라지는 구조는 실제 존재한다. 준비된 광고의 표시를 방해할 수 있는 복구·타이밍 위험도 존재한다. 그러나 현재 자료로 두 원인의 비중을 구분하거나 어느 하나를 운영 주원인으로 확정할 수 없다. 이를 “코드 정상” 또는 “전부 코드 버그”로 결론 내리는 것은 모두 증거를 넘는다.

### 감사 기준점과 배포 동일성

| 항목 | 읽기 전용 확인 결과 |
|---|---|
| 시작 Git 상태 | `## main...origin/main`, 변경·미추적 파일 없음 |
| HEAD | `6d9a3f72bb44332da9c96166048080d24abfac09` (`main`, `origin/main`) |
| HEAD 커밋 | 2026-09-18 02:35:04 UTC = 11:35:04 KST, Android 1.6.15 버전 증가 |
| pubspec | [pubspec.yaml:4](/Users/nam/projects/flutter/motionfit/pubspec.yaml:4): `1.6.15+2026091801` |
| iOS Runner Debug/Profile/Release | [project.pbxproj:554](/Users/nam/projects/flutter/motionfit/ios/Runner.xcodeproj/project.pbxproj:554), :738, :762: build 66 / marketing 1.6.6 / bundle `fit.motionfit.app` |
| iOS 버전 치환 | [Info.plist:242](/Users/nam/projects/flutter/motionfit/ios/Runner/Info.plist:242)–:247: `MARKETING_VERSION`, `CURRENT_PROJECT_VERSION` 사용. pubspec의 Android 버전을 곧바로 iOS 운영 버전으로 해석하지 않음 |
| 로컬 생성 설정 | `ios/Flutter/Generated.xcconfig:3,7–8`: 과거 경로 `/Users/nam/projects/motionfit`, Flutter name 1.6.15 / number 2026091801. 현재 실행 위치·배포 artifact 증명 자료가 아님 |
| 최초 iOS 1.6.6 설정 커밋 | `f8999266c3ee12c7f10fa3b0c3f2559809f06cb5`, 2026-09-09 11:18:29 KST. 직전 iOS 1.6.4(64)에서 변경 |
| 배포 커밋 증명 | Git 태그 없음. 저장소의 release/checklist 자료와 로컬 파일에서 해당 iOS 배포 IPA/xcarchive·업로드 기록·SHA 매핑 확보 못 함. `build/ios`도 없음. 별도 Xcode 전역 archive/사용자 계정의 존재 여부를 단정하지 않음 |
| 비교 범위 | 현재 HEAD와 최초 1.6.6 설정 커밋을 비교. `f899926`는 **후보**이며 실제 배포본이라고 부르지 않음 |

현재 HEAD는 후보보다 나중 커밋이고, 광고 로직도 다르다. **후보와 HEAD 모두 iOS 설정이 1.6.6이어도 동일 소스라는 뜻이 아니다.** 분석 제외 대상인 별도 Native iOS 1.7.0·Native Android 프로젝트는 열지 않았다. Flutter Android는 공통 이벤트·플랫폼 분기 확인에만 사용했으며 운영 수치에 혼합하지 않았다.

| 동작 | `f899926` 후보 | 현재 HEAD |
|---|---|---|
| 전면 최소 유효 완료 수 | 1회 | 2회, 첫 완료 보호 |
| 쿨다운 | 10분 | 10분 |
| 완료 시 metrics | 세 운동 기록과 통합 provider 무효화 후 최신 `.future` 대기 | 현재 `.value` 사용, null/2회 미만이면 즉시 반환 |
| 완료 시 광고 준비 | 동의·초기화 대기, 캐시가 없으면 최대 8초 로드 대기 | 이미 SDK·캐시가 준비된 경우만 시도 |
| 일반 결과 화면 | 주 완료 버튼으로 show; 부가 비동기 작업 중 버튼 비활성 | 주 완료 버튼으로 show; 부가 작업 의존 제거 |
| 결과 화면 뒤로가기 | `canPop:false`, 뒤로가기 차단 | `_finish(showInterstitial:false)` |
| 도전 운동 정상 종료 | Active → 자동 show 시도 → 도전 화면 | Active → 결과 화면; 주 완료 버튼에서 시도 |
| UMP 실패 메모 해제 | 없음 | info update 미완료일 때 해제; 양식 실패 공백은 잔존 |
| Debug/Profile 광고 ID | 공식 테스트 ID | 운영 ID |
| 메인 하단 광고 | 네이티브 | 배너로 변경 |

변경 이력: `d1a0896`(09-14)의 보호·대기·동의 로직 변경, `bf9ef60`(09-18)의 배너 변경, `b469411`(09-18)의 앱 복귀 초기화 복구가 HEAD에 포함된다. 이 변경이 App Store 1.6.6에 배포됐는지는 미확인이다.

### 운영 자료의 범위와 계산

사용자가 제공한 이미지·Firebase 텍스트만 운영 데이터로 사용했다. 사용자는 둘 다 지난 7일이며 AdMob은 iOS 1.6.6이라고 명시했다. 이미지 자체에는 기간·시간대·모든 필터가 보이지 않는다. 실제 시작/종료 날짜, AdMob 계정 시간대, GA 속성 시간대, iOS 스트림 ID, Debug/QA 제외 여부는 **미확인**이다. 현재 연결 도구에서 Firebase/BigQuery/AdMob 원시 데이터를 직접 조회하는 도구를 찾지 못했고 인증된 콘솔 조회도 수행하지 않았다. **iOS 1.6.6 Firebase 이벤트 건수는 전부 미확인**으로 취급한다.

| AdMob 행 | 요청 | 일치 요청 | 노출 | 노출/일치 요청 |
|---|---:|---:|---:|---:|
| POSE_NATIVE | 91 | 83 | 71 | 85.54% |
| 포즈 전면 | 501 | 501 | 5 | 0.998% |
| 복싱 전면 | 457 | 457 | 0 | 0% |
| 전면 두 행 합계 | 958 | 958 | 5 | **0.522%** |
| 표시된 세 행 합계 | 1,049 | 1,041 | 76 | 7.30% |
| 전체 요약 | 1,588 | 1,041 | 76 | 7.30% |

요약 일치율은 `1,041/1,588=65.55%`다. **전체 요청이 모두 매칭된 것이 아니다.** 요약 미매칭 수는 547, 표시된 세 행의 차이는 8, 남은 차이는 539다. 이것은 “539건의 미매칭 요청이 현재 행 차원에 귀속되지 않았다”는 설명과 산술적으로 일치하지만, 그 원인이 확정된 것은 아니다. 스크린샷의 광고 소스 차원과 요약 요청의 집계 범위, 다른 행/필터/분류 누락을 원본 보고서에서 확인해야 한다. Google도 소스 차원에서 요청과 요약의 집계 방식이 달라질 수 있다고 설명한다. [AdMob Ads Activity 지표 정의](https://support.google.com/admob/answer/10979428?hl=en)

확인 방법은 동일 기간·시간대·앱·플랫폼·버전 필터로 전체 CSV를 내보내고, (1) 소스 차원 포함 원본, (2) 소스 차원을 제거한 광고 단위별 요청/매칭, (3) 숫자 광고 단위 ID·요약 툴팁·미분류 행을 대조하는 것이다. **539건을 포즈·복싱에 임의 배분하지 않는다.**

Google의 matched requests는 광고 반환 지표이고 impression을 보장하지 않는다. SDK callback으로 확인한 `onAdLoaded`, 앱의 표시 기회, `show()`, 실제 impression을 별도 단계로 보아야 한다. [AdMob Reporting 정의](https://developers.google.com/admob/api/v1/report-overview)

## B. 코드에서 발견한 문제

분류는 요청한 일곱 범주를 사용한다. `CONFIRMED_CODE_BUG`도 **해당 revision·재현 조건에서 확정된 코드 결함**을 뜻하며, 운영 953건의 원인 확정을 뜻하지 않는다. P0는 직접 표시 실패, P1은 요청·준비·복구 구조, P2는 진단 부족으로 구분했다.

| 우선순위 | 파일:라인 / revision | 문제 | 영향 | 판정 | 수정 필요성 |
|---|---|---|---|---|---|
| P0 | 해당 없음 | 정상 READY·정책 충족·표시 진입 상태에서 show를 누락시키는 결함은 입증 못 함 | 운영 주원인 단정 불가 | NOT_VERIFIABLE | P0 패치의 근거부터 확보 |
| P1 | `f899926:lib/core/privacy/privacy_consent_service.dart:18–23,48–83` | 실패로 종료한 동의 Future도 계속 재사용 | canRequestAds=false인 일시 오류 후 같은 프로세스의 재시도 차단. 신규 요청 전 단계에 영향 | CONFIRMED_CODE_BUG | 후보가 운영본이면 복구 보완 필요 |
| P1 | [privacy_consent_service.dart:19](/Users/nam/projects/flutter/motionfit/lib/core/privacy/privacy_consent_service.dart:19), :26–31, :60, :99–119 | HEAD는 info update 성공만으로 memo 유지; 이후 필요 양식 오류를 재시도하지 않음 | 동의 미완료 세션의 광고 준비 차단 | HIGH_CONFIDENCE_RISK | 실패와 정상 사용자 선택을 구분한 복구 필요 |
| P1 | [ad_service.dart:121](/Users/nam/projects/flutter/motionfit/lib/core/ads/ad_service.dart:121), :206–214; [app.dart:127](/Users/nam/projects/flutter/motionfit/lib/app/app.dart:127) | HEAD show 시 55분 만료 캐시를 폐기하고 대체 요청 없이 반환; SDK ready면 복귀 refresh도 없음 | 다음 정책 갱신 전까지 준비 광고 없음. 후보에는 8초 재로드 경로가 있어 동일하게 적용 불가 | HIGH_CONFIDENCE_RISK | 표시를 기다리게 하지 않는 재준비 경로 검토 |
| P1 | [post_workout_interstitial.dart:10](/Users/nam/projects/flutter/motionfit/lib/core/ads/post_workout_interstitial.dart:10), :12–14 | HEAD는 metrics null·이전 횟수·SDK 미준비 시 즉시 종료 | 빠른 완료/결과 종료에서 기회 누락 가능. 기존 값이 있으면 refresh 중에도 보존되므로 항상 누락은 아님 | HIGH_CONFIDENCE_RISK | 최신 완료 스냅샷과 사유 로그 검토 |
| P1 | `f899926:lib/features/squat/presentation/screens/workout_summary_screen.dart:306–311,334–403` 및 pushup/plank 동형 | 알림 등 부가 비동기 작업 동안 완료 버튼 비활성 | 부가 await가 오래 걸리면 정상 표시 진입·이탈도 지연. 운영 발생은 미확인 | HIGH_CONFIDENCE_RISK | 후보 배포 여부 확인 후 필수 저장과 부가 작업 분리 검토 |
| P1 | [ad_service.dart:48](/Users/nam/projects/flutter/motionfit/lib/core/ads/ad_service.dart:48), :70, :133–140, :217–228, :293–300 | 표시 기회와 독립된 preload, 실패 시 장기 재시도 | 미사용 요청 또는 로드 실패 요청 누적 가능. READY 중 중복 load는 방지됨 | NO_SHOW_OPPORTUNITY | 실제 기회 데이터 확인 후 준비 시점·재시도 범위 검토 |
| P1 | [ad_unit_ids.dart:6](/Users/nam/projects/flutter/motionfit/lib/core/ads/ad_unit_ids.dart:6), :12, :24–31 | HEAD Debug/Profile도 운영 ID; iOS 배너 ID가 Android 배너와 같음 | QA 분리와 플랫폼 설정 확인 필요. 전면/네이티브가 잘못됐다는 증거는 아님 | HIGH_CONFIDENCE_RISK | 콘솔 매핑 확인 후 별도 설정 작업. 후보의 테스트 분기는 정상 |
| P2 | [analytics_service.dart:743](/Users/nam/projects/flutter/motionfit/lib/core/analytics/analytics_service.dart:743)–:789; 후보 :639–685 | loaded/shown/failed/dismissed/click 메서드가 빈 구현 | callback이 있어도 custom 결과 로그 없음 | LOGGING_GAP | 최소 funnel 이벤트 필요 |
| P2 | [post_workout_interstitial.dart:10](/Users/nam/projects/flutter/motionfit/lib/core/ads/post_workout_interstitial.dart:10)–:14; [ad_service.dart:117](/Users/nam/projects/flutter/motionfit/lib/core/ads/ad_service.dart:117)–:122 | metrics/SDK/cache/표시 중 제외를 기록하지 않음 | 기회 부족과 READY 후 호출 누락을 분리 못 함 | LOGGING_GAP | opportunity·결정 사유 필요 |
| P2 | [ad_unit_ids.dart:14](/Users/nam/projects/flutter/motionfit/lib/core/ads/ad_unit_ids.dart:14); 광고 이벤트 :791–801 | 숫자 단위↔콘솔 라벨·요청/캐시/기회 연결 정보 없음 | 별도 복싱 457건의 발생원 확인 불가 | NOT_VERIFIABLE | 배포 artifact·콘솔 매핑 확보가 선행 |

의도된 제외는 별도다. [AdEligibility:1–25](/Users/nam/projects/flutter/motionfit/lib/core/ads/ad_eligibility.dart:1)의 첫 완료 보호(HEAD)·10분 쿨다운은 **POLICY_BLOCK**이다. 결과 화면을 떠나지 않음, 운동 미완료, HEAD의 광고 없는 뒤로가기/도전 상세 이동은 **NO_SHOW_OPPORTUNITY** 또는 명시적 UX 분기다. 이를 버그로 바꾸어 횟수를 늘리는 수정은 제안하지 않는다.

## C. 포즈 계열 공통 전면광고 호출 경로

**아래 경로는 코드의 단일 전면 ID에 대한 것이다. 콘솔 라벨 “포즈 전면”과의 매핑은 아직 증명되지 않았다.** 세 운동은 같은 서비스를 사용한다. `ready`는 **MobileAds 초기화 완료**이며, 전면 캐시 READY와 다른 상태다.

### HEAD 요청 → 캐시

```text
main._startApp → ProviderScope → MotionFitApp
  [lib/main.dart:145–175]
MotionFitApp.initState / onboarding 완료 / 유효 운동 완료 listener
  [lib/app/app.dart:50–66,312–364]
→ _refreshPrivacyConsent → 첫 프레임 뒤 _runPrivacyConsentRefresh
  [:256–302]
→ combinedWorkoutMetricsProvider.future → updatePolicyContext
  [:275–285]
→ PrivacyConsentService.requestTrackingAndConsent
  [lib/core/privacy/privacy_consent_service.dart:19–31]
  → iOS ATT 미결정이면 요청 → UMP info update → 필요 양식 완료
  → canRequestAds=true일 때 MobileAds.initialize
→ AdService.initialize → canRequestAds 확인 → MobileAds.initialize
  [lib/core/ads/ad_service.dart:54–78]
→ SDK _ready=true → _loadInterstitial
  [:67–70,217–240]
  조건: 지원 플랫폼, 유효 ID, 미폐기, 완료>=2, 로딩 아님, 유효 캐시 없음
→ InterstitialAd.load(iOS /2998795518)
→ onAdLoaded → _interstitialAd=ad; loadedAt=now
  [:241–260]
```

앱 시작 때 **기존 완료 수가 기준 이상**이면 요청한다. 신규 사용자의 첫 실행부터 무조건 전면광고를 요청하는 구조는 아니다. 정책 갱신·완료 후 동의 refresh·dismiss/show failure 후에도 로드를 확인한다. 단순 모든 화면 이동마다 호출하는 loader는 없고, 진행 중 로드 또는 55분 이내 캐시가 있으면 다시 요청하지 않는다.

### HEAD 운동 완료 → show → impression → dismiss

```text
WorkoutSessionController._finishCompleted
  세션 저장·completed/saved 반영·workout 완료 이벤트
  [lib/features/squat/application/workout_session_controller.dart:1355–1430]
→ ActiveWorkoutScreen 완료 감지 → 850ms → context.go(summary)
  [lib/features/squat/presentation/screens/active_workout_screen.dart:99–110,141–150]
  이 시점에는 show 없음
→ WorkoutSummaryScreen 주 완료 버튼
  [lib/features/squat/presentation/screens/workout_summary_screen.dart:366–378]
→ _finish(completed && !interrupted)
  [:614–641]
→ clearCompletedSession → 기록 provider 무효화
→ await showPostWorkoutInterstitial(ref)  [:634]
  [lib/core/ads/post_workout_interstitial.dart:9–25]
  metrics 값 존재·유효 완료>=2·ads.ready 확인
→ AdService.showInterstitialIfAvailable
  [lib/core/ads/ad_service.dart:81–123]
  완료 수, 10분 cooldown, SDK ready, disposed, fullScreenShowing, 캐시 유효성 확인
→ 캐시에서 광고 분리, fullScreenShowing=true [:125–129]
→ FullScreenContentCallback 설정 [:143–184]
→ await loadedAd.show() [:187]
  onAdShowed → didShow=true, 메모리 표시 시각 저장 [:145–148]
  onAdImpression → AnalyticsService.adShown (현재 빈 구현) [:149–154]
  onAdDismissed / onAdFailedToShow / show 예외 → finish
→ dispose + fullScreenShowing=false + 다음 광고 preload [:133–140]
→ helper가 cooldown 저장 (성공했을 때)
→ 결과 화면 _finish의 context.go(destination) [:641]
```

Pushup 결과 파일은 [workout_summary_screen.dart:614](/Users/nam/projects/flutter/motionfit/lib/features/pushup/presentation/screens/workout_summary_screen.dart:614), Plank는 [workout_summary_screen.dart:621](/Users/nam/projects/flutter/motionfit/lib/features/plank/workout/presentation/screens/workout_summary_screen.dart:621)이며 각각 :634, :640에서 같은 helper를 호출한다. Rest의 도전 종료 경로도 존재한다([rest_screen.dart:213](/Users/nam/projects/flutter/motionfit/lib/features/squat/presentation/screens/rest_screen.dart:213)–:222, 나머지 운동 동형).

### `f899926` 후보 경로와 차이

```text
앱 초기화/정책 갱신 → canRequestAds → SDK initialize
→ 완료>=1이면 단일 iOS 전면 preload → 캐시 보관
일반 운동 완료·저장
  [f899926:lib/features/squat/application/workout_session_controller.dart:1212–1268]
→ Active 850ms 후 summary
  [f899926:lib/features/squat/presentation/screens/active_workout_screen.dart:137–149]
→ 결과 주 완료 버튼 → _finish → clear + 기록 무효화
  [f899926:lib/features/squat/presentation/screens/workout_summary_screen.dart:306–319,538–557]
→ helper가 세 운동+통합 metrics 무효화 후 최신 future 대기
  [f899926:lib/core/ads/post_workout_interstitial.dart:16–29]
→ 동의 흐름 대기 → ads.initialize → showInterstitialIfAvailable
  [:31–37]
→ 정책·10분 cooldown 확인
→ 캐시 없으면 _waitForInterstitial → 로드/기존 로드 최대 8초 대기
  [f899926:lib/core/ads/ad_service.dart:118–127,223–231]
→ show → impression callback → dismiss/fail 후 폐기·다음 요청
→ cooldown 저장 → 결과 화면에서 destination 이동
  [helper:38–41; summary:564]
```

후보의 도전 운동은 Active :144–147 → `_returnToChallenge` :152–184 → 저장 완료·비중단·유효 횟수 확인 후 :161에서 show를 자동 시도한다. Pushup은 같은 위치, Plank는 Active :149–152, :168이다. 일반 운동에만 필요한 “주 완료 버튼” 조건을 모든 도전 운동에 적용하면 안 된다.

## D. 복싱 전면광고 호출 경로

### 조사된 소스의 결과

| 단계 | HEAD 및 `f899926` 근거 | 판정 |
|---|---|---|
| 복싱 기능 선택 | [exercise_type.dart:1](/Users/nam/projects/flutter/motionfit/lib/features/exercise/domain/exercise_type.dart:1): squat/pushup/plank만 존재. [exercise_home_screen.dart:29](/Users/nam/projects/flutter/motionfit/lib/features/exercise/presentation/exercise_home_screen.dart:29)–:33도 세 종목 switch | 조사 범위에서 복싱 진입 불가 |
| 복싱 Navigation | HEAD [router.dart:269](/Users/nam/projects/flutter/motionfit/lib/app/router.dart:269)–:354, 후보 router :214–299에 세 운동 route만 존재 | 복싱 화면/완료 route 없음 |
| 복싱 ID·요청 | 단일 getter만 존재: HEAD ad_unit_ids :14–15,28–31; 후보 :11–12,33–40. AdService에 종목별 선택 인수 없음 | 독립 복싱 load 없음 |
| 복싱 객체 보관 | AdService의 `_interstitialAd` 하나 | 별도 복싱 cache 없음 |
| 복싱 완료→show | 전체 lib 및 관련 iOS 소스/후보에서 boxing/복싱 기능·호출부 발견 못 함 | 별도 show 진입점 없음 |
| 운영 457건 발생원 | 이미지에 숫자 ID·배포 SHA 없음 | NOT_VERIFIABLE |

```text
복싱 화면 → 복싱 광고 요청 → 복싱 캐시 → 복싱 완료 → show → impression
    조사한 두 revision에는 위 호출 체인이 존재하지 않음

실제 발견된 체인:
스쿼트/푸시업/플랭크 → 공통 AdService → iOS 전면 ID 하나
```

검색에서 나온 `SANDBOXING` 빌드 옵션은 복싱 기능 증거가 아니다. 과거에 복싱이 삭제됐다는 이력도 이번 근거로 확인하지 못했으므로 **“기능을 삭제하고 loader만 남겼다”는 결론을 내리지 않는다.** 단일 ID의 콘솔 이름이 복싱일 가능성도 현재 자료만으로 배제하지 않는다. 이름과 기능은 동일 개념이 아니다.

필요한 최소 증거는 콘솔의 두 전면 단위 숫자 ID·소속 앱/플랫폼, 같은 7일의 앱 버전/SDK 버전별 요청 CSV, App Store 1.6.6(66) archive와 소스 SHA다. 두 단위의 숫자 ID가 서로 다르면 현재의 단일 selector만으로 두 행의 요청을 모두 설명할 수 없으므로 **서로 다른 배포 코드/요청원 여부를 조사**해야 한다. 어느 쪽인지 미리 단정하지 않는다.

## E. 광고 요청 대비 표시 기회

| 상황 | 요청/캐시 동작 | 표시 기회 | 분류 |
|---|---|---|---|
| 완료 기록 충분한 사용자가 앱만 열고 종료 | 초기화 후 캐시 없으면 preload | 새 운동/결과 완료 동작 없으므로 없음 | NO_SHOW_OPPORTUNITY |
| 운동 시작 후 포기·중단 | 기존 캐시 유지 가능 | 정상 완료 조건 미충족 | NO_SHOW_OPPORTUNITY |
| 운동 완료 후 결과 화면에서 앱 종료 | 로드됐을 수 있음 | 일반 운동 주 완료 버튼까지 미도달 | NO_SHOW_OPPORTUNITY |
| HEAD의 첫 운동 | 전면 load 및 show 기준 미달 | 첫 완료 보호 | POLICY_BLOCK |
| 10분 이내 다음 완료 | 다음 캐시는 이미 preload될 수 있음 | cooldown으로 show 제외 | POLICY_BLOCK |
| READY 캐시 보유 중 반복 화면 이동·정책 갱신 | `_validInterstitialAd()!=null` guard | 새 요청 안 함 | 정상 캐시 유지 |
| load 실패 지속 | 5/15/30/60초 이후 60초 간격 재시도 | 표시 기회와 별개로 누적 | 복구 구조/SDK_OR_NETWORK_UNKNOWN |
| HEAD에서 첫 적격 완료 직후 빠르게 종료 | async 준비보다 버튼 실행이 빠를 수 있음 | not-ready/cache-miss 즉시 제외 | HIGH_CONFIDENCE_RISK |
| 후보에서 load가 8초를 초과 | 완료 시 대기를 끝내고 false | 로드 callback은 나중에 캐시를 채울 수 있으나 그 전환에서는 미표시 | NO_SHOW_OPPORTUNITY / SDK_OR_NETWORK_UNKNOWN |

**무조건 매 실행 두 개의 전면 단위를 로드하거나 READY 광고를 버리며 반복 요청하는 코드는 없다.** 요청 낭비가 가능한 구조와 “과도하게 발생했다”는 운영 비율 판정은 다르다. 한 프로세스의 미사용 캐시 1건은 여러 화면 이동에서도 유지되며, 프로세스 종료 후 다음 실행에서는 다시 요청될 수 있다.

분모도 구분해야 한다. 501 matched는 501개의 운동 완료가 아니고, `mf2_workout_completed=21`·`mf2_workout_summary_viewed=19`·요청 이벤트 124회는 혼합 플랫폼 합계다. **이 수치를 서로 나누어 iOS show 전환율을 계산하지 않았다.**

## F. Flutter 객체 수명과 Navigator 위험

### 객체와 상태 전이

서비스는 [core/providers.dart:57](/Users/nam/projects/flutter/motionfit/lib/core/providers.dart:57)–:63의 일반 `Provider<AdService>`로 앱 ProviderScope에 속한다. `autoDispose`/화면별 생성이 아니고 root에서 실제 analytics/crash 서비스가 주입된다. 결과 Widget이 전면광고를 직접 소유하지 않는다. 정상 화면 이동만으로 전면 cache가 소멸한다는 근거는 없다.

```text
SDK_NOT_READY → SDK_READY + EMPTY
EMPTY → LOADING → CACHED(loadedAt)
                  ↘ 실패 → EMPTY + retry timer
CACHED → show에서 분리 → SHOWING → dismiss/fail/exception → dispose → 다음 load
CACHED → 55분 경과 뒤 접근 → dispose → EMPTY
서비스 종료 → timer cancel + cached ad dispose
```

`onAdLoaded`는 참조·시각을 저장한다. 별도 READY 플래그는 없으며 cache 존재와 age로 판정하므로 “성공 후 READY=true 누락” 결함은 없다. `_interstitialLoading` guard로 정상 중복 load/늦은 callback 덮어쓰기를 방지하고, 사용 광고는 show 전에 cache에서 분리해 재사용하지 않는다. [ad_service.dart:217](/Users/nam/projects/flutter/motionfit/lib/core/ads/ad_service.dart:217)–:282

| 구분 | 확인 결과 |
|---|---|
| 정상 캐시 유지 | 화면 이동·결과 생성 동안 전역 서비스가 참조 유지 |
| 의도적 폐기 | 55분 만료, 표시 종료/실패/예외, 서비스 dispose, 이미 서비스가 종료된 뒤 load callback 도착 |
| 비정상 폐기 | 로드 직후 무조건 dispose하거나 결과 Widget dispose가 전면 cache를 지우는 경로는 발견 못 함 |
| 표시 기회 없는 미사용 | 앱 종료·운동 포기·결과 완료 미실행 등 가능. 운영 발생량 미확인 |
| 만료 후 복구 | 후보는 on-demand load 대기 존재. HEAD는 show 분기에서 대체 load가 없으며 다음 policy update/reload 기회 필요 |

### 화면 이동 순서

주 완료 경로는 **clearCompletedSession → await 광고 helper → context.go**다. `Navigator.pop()` 후 show를 호출하는 구조가 아니다. 상태를 지우면 결과 세션이 null이 될 수 있지만, HEAD summary :109–115는 `_finishing` 중 조기 이동을 막는다. 광고 진행 중 `_finishing`은 재클릭도 막는다. **정상 완료 버튼 경로에서 Navigation이 광고보다 먼저 실행된다는 결함은 확인되지 않았다.**

반면 HEAD summary의 뒤로가기 :161–165 및 도전 상세 CTA :282–305는 명시적으로 `showInterstitial:false`다. 광고 cache가 있어도 그 이탈 경로에서는 show하지 않는다. 후보는 뒤로가기를 차단하고 자동 도전 종료 show가 있으므로 이 설명을 후보에 소급하지 않는다.

HEAD helper는 최신 비동기 metrics를 기다리지 않아 초기 null/이전 count 1이 남은 두 번째 완료에서 누락될 수 있다. 단, 설치된 Riverpod 3.3.2의 `AsyncValue`는 refresh/reload 때 이전 `.value`를 보존한다. **무효화 직후 무조건 null이 되어 항상 광고가 누락된다는 주장은 틀리다.** 조건을 확정하려면 해당 종료 순간의 metrics 값/갱신 상태가 필요하다.

show failure callback과 throw catch는 모두 연결돼 `finish()`에서 dispose·reload·완료 Future 해제를 수행한다. dismiss 이후 정상 destination 이동도 이 Future를 통해 연결된다. 다만 다음 외부 실패 위험은 증거가 없어 **SDK_OR_NETWORK_UNKNOWN**으로 남긴다.

- `InterstitialAd.load()`의 `Future<void>`를 await/catch하지 않는다. 플랫폼 채널 오류가 load-failed callback 없이 Future로만 전달되면 loading 플래그와 복구가 남을 수 있다. 일반 네트워크 load 실패는 callback 재시도로 처리되므로 해당 채널 오류와 혼동하지 않는다. HEAD ad_service :237–282, 후보 :254–299.
- show 완료는 dismiss/fail callback을 기다리며 자체 timeout이 없다. callback이 사라지면 navigation/fullScreenShowing이 멈출 가능성은 있으나 실제 누락 증거는 없다. HEAD :129–140,202.
- 리뷰 요청은 [review_prompt_service.dart:127](/Users/nam/projects/flutter/motionfit/lib/core/reviews/review_prompt_service.dart:127)–:181에서 화면/active 검사 뒤 추가 await를 거친다. 광고와 공유하는 presentation lock은 확인하지 못했다. 리뷰/백그라운드 전환과 show의 경합 여부는 실기기 로그가 필요하다.

쿨다운 시각도 별개다. 서비스는 showed callback에서 메모리 시각을 기록하지만, helper의 영구 저장은 dismiss 후 `DateTime.now()`다([preferences_controller.dart:108](/Users/nam/projects/flutter/motionfit/lib/features/settings/application/preferences_controller.dart:108)). 둘 중 나중 시각을 사용하므로 실제 제외는 시청 시간만큼 길어질 수 있다. 501/5의 주원인 근거는 없으며, 의도 확인 없이 기준을 변경하는 수정은 제안하지 않는다.

네이티브 광고는 전면과 별도 수명이다. [bottom_native_ad.dart:112](/Users/nam/projects/flutter/motionfit/lib/core/ads/bottom_native_ad.dart:112)–:190에서 Widget이 객체를 소유하고, 화면 비활성/late callback 시 dispose할 수 있다. 네이티브 dispose를 전면 cache 소멸의 증거로 사용하지 않는다.

## G. ATT / UMP / PRO 및 운영 설정

### ATT

HEAD privacy :35–48과 후보 :26–39는 iOS `notDetermined`일 때만 권한을 요청한다. authorized/denied/restricted/notSupported 등 나머지 상태에서 **승인 여부를 조건으로 전체 광고를 return하지 않고 UMP로 진행**한다. ATT 예외도 nonfatal 기록 뒤 계속 진행한다. ATT 거부로 광고 전체 차단하는 코드 결함은 확인되지 않았다. ATT 승인율과 광고 개인화/수익의 관계는 이번 수치로 판정하지 않는다.

### UMP

정상 순서는 ATT 처리 → consent info update → 필요한 양식의 완료 → `canRequestAds()` 확인 → SDK 초기화다. 과거 동의가 유효하면 오류 시에도 `canRequestAds()`를 확인하는 경로가 있다. canRequestAds=false를 무시하고 로드하는 수정은 필요하지 않다. [Google UMP Flutter 흐름](https://developers.google.com/admob/flutter/privacy)

**후보 확정 결함의 재현 조건:** 유효한 과거 동의가 없는 세션에서 info update 일시 실패/20초 timeout/필수 양식 오류로 동의가 완료되지 않음 → canRequestAds=false → `_requestOperation`은 이미 종료한 Future를 계속 보관 → 이후 운동 완료가 `requestTrackingAndConsent()`를 호출해도 새 update/form이 실행되지 않음. timeout은 최초 callback을 취소하지 않으므로 늦은 성공 callback으로 회복할 수는 있다. **새 동의 재시도는 시작되지 않으며, 최초 요청의 늦은 성공 callback이나 별도 직접 refresh가 없으면 다음 프로세스까지 복구되지 않을 수 있다.** 이 코드에서 정상 호출부는 memo를 사용하는 public wrapper를 통한다.

HEAD는 `_consentInfoResolved=false`일 때 memo를 비우지만, update 성공 callback이 먼저 true로 만든 뒤 required form이 실패하면 해제되지 않는다. 이는 같은 실패 유형이 아직 가능함을 뜻한다. HEAD 앱 복귀 시 `!ads.ready`이면 refresh하지만, 이미 완료한 consent Future를 그대로 받으면 양식을 복구하지 못한다.

이 결함은 **미요청 세션**을 설명하며, 이미 매칭된 광고의 미표시 원인과 구분해야 한다. 정상 사용자 선택 때문에 허용되지 않는 상태와 일시 오류를 분리해서만 재시도를 설계해야 한다.

설치된 google_mobile_ads 9.0.0의 Dart `consent_form.dart:64–69`, `user_messaging_channel.dart:149–155` 및 iOS `FLTUserMessagingPlatformManager.m:95–110`도 읽었다. native Future는 UMP load/present 완료 callback에서 반환한다. 따라서 앱이 이 Future를 await한 뒤 initialize하는 순서를 **“양식 dismiss 전 초기화 경합”으로 잘못 판정하지 않았다.**

PrivacyConsentService와 AdService 양쪽에서 SDK initialize가 호출되지만, 서비스의 Future memo·ready/load guard가 정상 중복 전면 요청을 막는다. initialize 호출 수를 광고 요청 수로 계산할 수 없다.

### FREE / PRO

조사한 Flutter 광고 service/eligibility/units, preferences, 의존성에는 entitlement/PRO 기반 광고 제거 판정이 없다. 따라서 “FREE가 권리 조회 실패로 PRO로 분류되어 광고 차단”되는 호출 경로도 찾지 못했다. 혼합 자료의 `anonymous_auth_failed`, `entitlement_changed` 등으로 현재 Flutter iOS 광고 제외를 증명할 수 없다.

**기존 유료 이용자의 광고 제거 권리가 실제로 어떻게 보존되는지는 NOT_VERIFIABLE**이다. 이 부재를 근거로 기존 권리를 약화시키거나 PRO에 광고를 추가하라는 제안은 하지 않는다. 배포본의 권리 정책과 별도 구매 이력을 먼저 확인해야 한다.

### ID·SDK·iOS 빌드 설정

| 항목 | 확인 값·코드 | 판정 |
|---|---|---|
| iOS AdMob App ID | [Info.plist:29](/Users/nam/projects/flutter/motionfit/ios/Runner/Info.plist:29)–:32 `ca-app-pub-6169297934919363~5425389550`, measurement delay=true | 값 존재. 콘솔 소속·준비 상태 미확인 |
| iOS 전면 ID | [ad_unit_ids.dart:14](/Users/nam/projects/flutter/motionfit/lib/core/ads/ad_unit_ids.dart:14)–:15 `ca-app-pub-6169297934919363/2998795518` | 단일 ID. 포즈/복싱 콘솔 라벨 미확인 |
| iOS 네이티브 ID | :13 `ca-app-pub-6169297934919363/1414718708` | NativeAd API 사용. POSE_NATIVE 라벨 매핑은 콘솔 필요 |
| iOS HEAD 배너 ID | :12 `/2773965626`, Android :6–7과 동일 | 플랫폼/형식 매핑 위험. 후보에 없던 HEAD 변경이며 전면 원인과 분리 |
| Android 전면/네이티브 | :8–11 `/8790349687`, `/4174749653` | iOS 분기에서는 이 값들을 선택하지 않음 |
| Debug / Release | 후보 kReleaseMode 분기, iOS 테스트 전면 `/4411468910`; HEAD는 전 모드 운영값 | 후보 Release에 테스트 ID 혼용 근거 없음. HEAD QA 분리 필요 |
| Bundle | `fit.motionfit.app`; [GoogleService-Info.plist:9](/Users/nam/projects/flutter/motionfit/ios/Runner/GoogleService-Info.plist:9)–:10과 PBX 일치 | 로컬 설정 일치. 업로드 바이너리 확인 아님 |
| Flutter Ads plugin | [pubspec.yaml:20](/Users/nam/projects/flutter/motionfit/pubspec.yaml:20), [Podfile.lock:79](/Users/nam/projects/flutter/motionfit/ios/Podfile.lock:79): 9.0.0 | 후보/HEAD lock 동일 |
| GMA iOS / UMP | [Podfile.lock:77](/Users/nam/projects/flutter/motionfit/ios/Podfile.lock:77)–:81, :113: 13.3.0 / 3.1.0 | 실제 배포 SDK는 artifact/콘솔 필요 |
| ATT plugin | pubspec :10 `2.0.7`; Info.plist :238–239 usage description | 설정 존재 |
| iOS deployment | [Podfile:1](/Users/nam/projects/flutter/motionfit/ios/Podfile:1): 15.0; Debug debug, Profile/Release release (:6–9) | 이 설정만으로 미노출 결론 불가 |
| Archive 구성 | [Runner.xcscheme:98](/Users/nam/projects/flutter/motionfit/ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme:98) 부근 ArchiveAction=Release | 실제 업로드 수행/설정 증거 아님 |
| AppDelegate/SceneDelegate | [AppDelegate.swift:16](/Users/nam/projects/flutter/motionfit/ios/Runner/AppDelegate.swift:16)–:18 Firebase, :27–28 plugin 등록; [SceneDelegate.swift:4](/Users/nam/projects/flutter/motionfit/ios/Runner/SceneDelegate.swift:4) FlutterSceneDelegate | 별도 native 복싱 광고 show 구현 없음 |
| SKAdNetwork | Info.plist :33–235 | 항목 존재. 서버 수요·승인 상태 보장은 아님 |

ID 숫자 형태만으로 서버의 실제 광고 형식·플랫폼·승인 상태를 검증할 수 없다. AdMob 정책 센터, 앱 준비 상태, 제한, 단위 승인/매핑을 확인했다고 주장하지 않는다. 테스트 ID로 표시된다는 사실 역시 운영 코드 결함 부재의 증거가 아니다. [Google 전면광고 callback·객체 사용 가이드](https://developers.google.com/admob/flutter/interstitial)

기존 `ADMOB_FIX_PLAN_KO.md`는 07-31의 다른 버전·요청 0 상황에 대한 문서다. 그 문서의 “광고 문제가 아니다”, 과거 3회/하루 1회 정책, 테스트 분기 설명을 현재 운영 사실로 재사용하지 않았다.

## H. Firebase 로그 유효성과 부족 사항

### 현재 소스의 이벤트 생산 여부

| 이벤트/메서드 | 발생 코드·조건 | iOS/Android | 구분 가능한 내용·한계 |
|---|---|---|---|
| `mf2_ad_request_attempted` | [analytics_service.dart:728](/Users/nam/projects/flutter/motionfit/lib/core/analytics/analytics_service.dart:728)–:741; AdService :231–240, Native :130–141, Banner :94–107에서 load 직전 | 양쪽 공통 | format·placement·완료 수·온보딩. 실제 SDK 수신/성공/노출은 아님 |
| `mf2_ad_skipped_by_policy` | analytics :772–786; AdService :87–115, App :287–299 | 양쪽 공통 | 첫 완료 보호·쿨다운 사유. 초기화 단계의 보호 로그는 실제 표시 기회가 아님 |
| `motionfit_ads_log` | 현재 lib/ios/android에 producer 없음 | 현재 Flutter iOS 생산 근거 없음 | 제공 103건의 플랫폼/버전/이전 구현 귀속 미확인 |
| `ad_request_started`, `ad_load_succeeded`, `ad_load_failed` | 현재 Flutter custom producer 없음 | 미확인 | 혼합 표의 347/170/134를 iOS funnel로 사용 불가 |
| `ad_show_attempted`, `ad_show_succeeded` | 현재 Flutter producer 없음 | 미확인 | 표의 79/78로 iOS 정상 show 비율 계산 불가 |
| `interstitial_request_started`, `interstitial_load_succeeded`, `interstitial_load_failed` | 현재 Flutter producer 없음 | 미확인 | 표의 82/48/22를 이 저장소 iOS로 귀속 불가 |
| `ad_impression` / `ad_click` | analytics :788 주석대로 SDK/Firebase 자동 수집에 의존 | 자동 수집은 양쪽 가능 | 표의 166건은 혼합. format·unit·platform·version 필터 전까지 전면 5건과 비교 불가 |
| `adLoaded`, `adShown`, `adDismissed`, `adFailed`, `adClick` | analytics :743–789는 빈 메서드. SDK callback 호출부는 존재 | 양쪽에서 호출되나 custom event 없음 | load success/show failure/impression callback을 custom funnel로 남기지 않음 |

후보에서도 `AnalyticsService:624–685`가 같은 요청/정책 이벤트와 빈 결과 메서드 구조다. 현재 이벤트명만의 차이로 로그 공백을 HEAD 전용이라고 처리하지 않는다.

공통 custom context는 analytics :966–982의 `analytics_schema`, revision, `platform`, `app_version`, `build_number`, `device_category`다. 버전/빌드는 PackageInfo에서 읽는다(:76–90). 요청·정책 이벤트의 광고 파라미터는 :791–801이며 **숫자 ad unit, request/cache/opportunity ID, 종목, cache age, SDK error/response ID가 없다.** 광고 메서드에 workout session ID도 자동 연결되지 않는다. Native는 여러 위치를 `bottom_navigation`으로 기록하므로 실제 화면 구분도 제한된다.

따라서 `mf2_`라는 이름은 iOS 증거가 아니며, 124회 요청·29회 정책 제외·103회 motionfit_ads_log·166회 impression 중 어느 것도 현재 자료에서 iOS 1.6.6 건수로 확정할 수 없다. `$0.03` 역시 플랫폼을 분리하지 않은 Firebase 합계이므로 AdMob 수익과 직접 대조하지 않았다.

### A와 B를 구분할 수 있는가?

**LOGGING_GAP: 구분 불가.**

- A: request → load success → 이후 유효한 완료/주 완료 버튼 없음.
- B: load success → 유효 기회·정책 통과·cache READY → show 미호출.

두 흐름 모두 현재 custom 로그에는 요청 하나만 남을 수 있다. `ready=false`, metrics 미확인, cache 없음/만료, 이미 표시 중은 기록 없이 return한다. Crashlytics의 `ad_state`는 하나의 덮어쓰는 키이고 요청별 funnel이 아니다. callback에 impression 메서드가 있어도 메서드가 비어 있으므로 수집됐다고 간주하면 안 된다.

### 후속 단계의 최소 이벤트 제안 — 이번에는 구현하지 않음

| 제안 | 필수 의미·파라미터 |
|---|---|
| 기존 request 확장 | `request_id`, `ad_unit_key`, 실제 `placement`, `exercise`, `load_reason` |
| `mf2_ad_load_result` | 요청 ID, success/error, error code/domain, latency, cache ID, 가능한 response ID |
| `mf2_ad_opportunity` | 유효 완료/결과 종료마다 opportunity ID, workout ID, metrics 값/갱신 상태, eligibility, SDK initialized, cache 존재/age, lifecycle, 결정 `show`/`skip`와 사유 |
| `mf2_ad_show_attempted` | SDK show 호출 직전, request/cache/opportunity ID |
| `mf2_ad_show_result` | showed / failed / exception / dismissed callback 결과 및 오류 |
| `mf2_ad_impression` | 실제 onAdImpression에서 연결 ID 기록. 자동 impression과 별도 진단 지표로 관리 |
| `mf2_ad_cache_disposed` | 만료·사용 종료·서비스 종료 등 사유와 cache age |

공통으로 플랫폼·실제 버전·빌드·schema·QA 식별을 유지한다. 개인정보·사진·원시 동작 데이터는 필요하지 않다. 유저가 결과 화면을 이탈한 사유도 opportunity 결과에 남겨야 완료 수와 실제 기회를 분리할 수 있다.

운영 분석은 iOS + 1.6.6 + MotionFit iOS stream + 동일 7일 + 시간대 확인 + QA 별도 조건으로 수행해야 한다. 기본 자동 `ad_impression`에 자체 request ID가 붙는다고 가정하지 않는다. Google 문서는 자동 impression의 BigQuery export 제한도 명시하므로, 요청과 impression을 원시 데이터에서 연결하려면 별도 callback 진단 이벤트가 필요하다. [Firebase/GA 자동 수집 이벤트](https://support.google.com/analytics/answer/9234069?hl=en)

## I. 제안하는 수정 작업

**아래 내용은 수정 승인 전 검토안이다. 실제 적용하지 않았다. 광고 횟수·쿨다운 변경, 동의 우회, 기존 PRO 권리 약화는 포함하지 않는다.**

| 작업 | 근본 원인·수정 대상 | 권장 방식 | 예상 영향·회귀 위험 | 후속 테스트 방법 | 미수정 영향 |
|---|---|---|---|---|---|
| 0. 배포/단위 귀속 확정 | 배포 SHA·숫자 ID 매핑 부재. 소스 변경 대상 없음 | Store build66 archive/업로드 기록→SHA, 콘솔 두 전면 ID→소속 앱/이름/형식 대조 | 관련 없는 HEAD 수정의 배포 위험 방지. 계정 설정은 읽기 전용 | 같은 기간 CSV를 단위·버전·SDK·플랫폼으로 대조 | 복싱 요청원과 실제 적용 로직 계속 불명 |
| 1. UMP 실패 복구 | 실패 Future memo. `privacy_consent_service.dart`, 필요시 `app.dart` | info/양식/최종 허용 결과를 분리. 일시 오류만 in-flight 종료 후 memo 해제 및 제한된 재시도. canRequestAds 최종 gate 유지 | 일시 오류 세션 복구. 중복 양식·foreground 경합·무한 재시도 위험 | 테스트 기기/동의 환경에서 info 오류→복구, required form 오류→복구, 정상 선택 시 재요청 없음, cached consent, timeout 후 늦은 callback | 실패 세션이 다음 실행까지 미준비로 남음 |
| 2. HEAD cache 재준비 | 만료/빈 캐시 show 분기의 보충 누락. `ad_service.dart`, `app.dart` | 완료 화면을 기다리게 하지 않으면서 빈/만료 캐시의 준비를 별도 시작. load/ready/foreground guard 유지 | 다음 기회 준비 회복. 불필요 preload·중복 timer 위험 | 테스트 ID/fake SDK로 54:59/55:00, background→resume, load-in-progress, dismiss/fail 후 1회 보충 | 장시간 세션의 다음 전환에서 준비 부족 지속 |
| 3. 완료 스냅샷 안정화 | HEAD metrics 현재 값과 async 준비의 시간차. helper/combined metrics/세 운동 summary | 저장 성공으로 확정된 최신 유효 완료 스냅샷을 전달하거나 UI와 독립된 준비 상태 유지. 불명 시 보호 유지, 사유 기록 | 빠른 종료의 판단 정확도 향상. 첫 완료 오노출·잘못된 이중 count 위험 | 첫/두 번째 완료, 늦은 DB refresh, mixed 운동, DB 오류, 매우 빠른 완료 버튼, 첫 완료 보호 유지 | 경계 상황의 기회 누락과 원인 불명 지속 |
| 4. 후보 결과 이탈 의존 분리 | 부가 알림 await가 Finish 차단. 세 운동 `workout_summary_screen.dart` | 배포본이 후보인지 확인 후 필수 저장과 부가 작업 분리, mounted/finishing 검사 유지 | 이탈 지연 완화. 중복 완료·늦은 UI callback 회귀 위험 | 부가 Future 지연/실패 상태에서도 저장 완료 후 정상 전환. ad dismiss 후 1회 이동 | 부가 작업 지연이 광고 기회/이탈을 막을 수 있음 |
| 5. 재시도·채널 실패 복구 | 기회 독립 무기한 실패 retry, load Future 오류 처리 부재. `ad_service.dart` | callback과 Future 오류를 일관되게 정리하고 foreground·필요성에 맞춰 retry 관리. 정책 수치는 유지 | 로딩 고착·낭비 완화. 중복 실패 처리/기회 전 로드 지연 위험 | callback load fail, Future만 fail, 늦은 callback, dispose, 복귀에서 정확히 1회 복구 | 희귀 채널 오류 고착, 표시 없는 retry 누적 가능 |
| 6. 진단 funnel 추가 | 빈 결과 메서드/무기록 return. `analytics_service.dart`, 광고 service/helper/Widget | H의 최소 이벤트, 연결 ID와 공통 context, outcome/skip 사유. 자동 impression 중복 집계 방지 | A/B 원인 분리. 이벤트량·중복·고유 ID cardinality 위험 | mock sink로 각 branch 이벤트 의미 검토 후 QA/DebugView, 필터된 운영 표본 대조 | 다음 운영 분석도 요청 수와 노출 차이만 보임 |
| 7. QA/플랫폼 ID 점검 | HEAD 전 모드 운영값, 배너 플랫폼 ID 공용. `ad_unit_ids.dart` | 콘솔 매핑 확인 후 Debug/Profile 테스트 ID/테스트 기기 분리. Release의 검증된 단위 유지 | QA 수치 오염·플랫폼 오류 방지. 운영에 테스트 ID 유입 위험 | 앱을 요청 실행하지 않는 정적 구성 검토 후 테스트 ID만으로 플랫폼별 확인 | QA 구분·배너 설정 불확실성 지속 |

show callback 누락/리뷰 경합은 **발생 증거를 먼저 확보**한다. 단순 timeout 뒤 광고가 화면에 남아 있을 수 있는데 navigation/fullScreenShowing을 무조건 해제하는 수정은 제안하지 않는다. 실제 foreground·presentation 상태를 확인한 안전한 복구 설계가 필요하다.

## J. 수정 우선순위와 검증 범위

- **P0 — 코드상 표시 실패를 직접 일으키는 결함:** 이번 증거로 READY·정책 충족·실제 기회에서의 확정 P0를 특정하지 못했다. 배포/ID 귀속 후 해당 조건의 show 미호출이 확인되면 최우선이다.
- **P1 — 요청 낭비·준비·복구 구조:** UMP 일시 오류 복구가 먼저다. 이어 실제 배포 revision에 맞춰 만료 cache·완료 스냅샷·부가 await·retry/채널 오류를 좁혀 검토한다. HEAD에 이미 달라진 부분을 후보 결함처럼 다시 고치지 않는다.
- **P2 — 운영 진단 로그 부족:** 최소 load/opportunity/show/impression 연결 로그가 필요하다. 명확한 P1 개선과 함께 배포해야 실제 원인 분해가 가능하다. 정책 보호 로그를 show opportunity로 오인하지 않도록 정의한다.

기존 [ad_eligibility_test.dart:5](/Users/nam/projects/flutter/motionfit/test/core/ads/ad_eligibility_test.dart:5)–:44는 최소 완료 수와 9:59/10:00 쿨다운을 검사한다. SDK 로드·만료·객체 수명·Navigator·UMP·show callback을 검증하는 테스트가 아니다. 제목의 “last impression”과 실제 cooldown 저장 시점 차이도 F에 구분했다. 기존 analytics 테스트는 sink/schema 검증 자료이며 빈 결과 메서드가 운영 funnel을 제공한다는 증거가 아니다.

관련 테스트 파일과 저장소 내 결과 artifact 후보를 읽었으나 이번 광고 lifecycle에 대응하는 기존 실행 결과를 확보하지 못했다. **새 테스트 코드를 작성하거나 기존 테스트·빌드를 실행하지 않았다.** 위 테스트들은 후속 승인 범위에서 테스트 ID/fake SDK를 사용해 진행할 제안이다. 이번 작업의 최종 저비용 확인은 보고서만 추가됐는지 Git 변경 범위를 확인하는 것이다.

## K. 최종 판단과 종료 질문 답변

**운영 단위별 최종 선택은 모두 INSUFFICIENT_EVIDENCE다.** 이 판정은 확인한 결함을 부정하지 않는다. 후보의 UMP 오류 memo는 코드에서 확정됐고, HEAD의 별도 복구·현재 값 의존 위험도 실제 분기로 확인했다. 다만 어느 소스가 운영본인지와 요청/기회/표시 연결 증거가 없으므로 `CODE_BUG_CONFIRMED`를 501/5 또는 457/0의 운영 주원인 판정으로 올릴 수 없다. `MOSTLY_POLICY_OR_OPPORTUNITY`나 `MOSTLY_EXTERNAL_OR_SDK` 역시 현재 자료로 비중을 증명하지 못한다.

| 종료 질문 | 답변 |
|---|---|
| 1. 포즈는 언제 로드? | 소스의 공통 전면은 동의·SDK 초기화 뒤 유효 완료 기준 충족·캐시 없음 시. 앱 실행/완료 정책 갱신/dismiss 후 재준비. 후보>=1, HEAD>=2. “포즈” 라벨 매핑 미확인 |
| 2. 언제 표시? | 일반 운동 저장 완료 후 결과 주 완료 버튼. 후보 도전 완료는 자동 시도; HEAD는 주로 결과 경유. 정책·캐시·SDK 조건 추가 |
| 3. 복싱은 언제 로드? | 조사한 HEAD/후보에 독립 loader 없음. 457건 요청원 미확인 |
| 4. 복싱은 어디서 표시? | 복싱 화면/전용 show 진입점 없음. 단일 ID의 콘솔 이름이 무엇인지도 미확인 |
| 5. 표시 함수 도달 가능? | 세 운동 공통 helper→AdService→loadedAd.show 경로 존재. 복싱 전용 경로는 없음 |
| 6. 객체가 중간에 소멸? | 화면 이동 폐기 근거 없음. 만료·사용 종료·서비스 종료의 의도적 폐기 존재. HEAD 만료 후 보충 공백 있음 |
| 7. 불필요 반복 요청? | READY/로딩 중 중복 방지. 사용 안 할 세션 preload·실패 retry 누적 가능; 운영 과도성 수량 미확인 |
| 8. 완료와 광고 정확히 연결? | 완료 자체가 매번 show는 아님. 일반 결과 완료 동작/도전 분기와 정책까지 충족 필요 |
| 9. Navigator/async 누락 가능? | 정상 주 버튼은 show 대기 후 이동. HEAD 즉시 준비 검사/캐시 만료, 후보 부가 await 지연 위험 존재. 외부 callback 누락은 미확인 |
| 10. ATT/UMP/PRO 오차단? | ATT 거부 전체 차단 없음. UMP 오류 재시도 결함/위험 있음. PRO 차단 코드 없으며 기존 권리 정상성은 미확인 |
| 11. Firebase로 원인 분리? | 현 자료로 불가. 플랫폼 혼합과 결과·기회 로그 공백 |
| 12. 가장 큰 표시 방해 문제? | 운영의 최대 기여 원인은 미확정. 실제 소스는 표시 기회를 제한하고 있으며 UMP/캐시 복구 위험도 존재 |
| 13. 무엇부터 수정? | 배포/단위 귀속 확보→해당 revision의 UMP 복구→근거 있는 준비 경로 보완과 최소 funnel 로그 |
| 14. 예상 부작용? | 중복 동의 폼/로드·비적격 첫 완료 노출·추가 지연·늦은 callback·이벤트 중복. 기존 보호와 권리를 유지하며 검증 필요 |
| 15. 원시 로그 없이는? | iOS 요청/SDK load success/실제 기회/정책 통과/캐시 폐기/show 호출·오류/impression별 건수, QA 영향, 539건 귀속, 외부 승인/네트워크·SDK 원인 |

작업 결과물은 이 보고서 한 파일이다. 코드 패치·버전 증가·정책 변경·배포 없이 분석을 종료한다. 후속 수정 범위는 이 증거와 남은 불확실성을 검토한 뒤 사용자가 결정한다.
