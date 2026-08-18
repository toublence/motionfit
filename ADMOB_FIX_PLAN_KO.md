# 스쿼트 카운터 AI AdMob 계획 (2026-07-31)

> 상위 분석: `~/projects/ADMOB_ACCOUNT_ANALYSIS_2026-07-31_KO.md`
> 콘솔 증상: iOS 1.0.6 = 요청 0, Android 1.2.2 = 요청 0 + **수익 -US$0.00**(무효 트래픽 차감 흔적).

## 1. 진단: 광고 문제가 아니다

**요청 자체가 0이다.** 광고 코드는 요청을 보낸 뒤에야 실패할 수 있다. 요청 0 = 앱을 실행한 활성 사용자가 사실상 0이라는 뜻이다. 코드 검토 결과도 이를 뒷받침한다:

- 초기화 체인 정상: [app.dart:113-125](lib/app/app.dart) 첫 프레임 후 `requestTrackingAndConsent()` → `AdService.initialize()`, 온보딩 완료 시에도 동일 재시도.
- UMP 정상: [privacy_consent_service.dart](lib/core/privacy/privacy_consent_service.dart) `requestConsentInfoUpdate` → 필요 시 폼 → `canRequestAds()` 확인 후 `MobileAds.initialize()`.
- 실유닛/테스트유닛 분리 정상: [ad_unit_ids.dart](lib/core/ads/ad_unit_ids.dart) `kReleaseMode`에서만 실유닛. 테스트 ID 유출 없음.
- 노출면 존재: 메인 4개 탭 하단 네이티브([router.dart:141-146](lib/app/router.dart)), 휴식·요약 화면 네이티브, 요약 후 전면.
- 전면 게이트가 보수적일 뿐: 완료 운동 3회 이상 + 하루 1회([ad_service.dart:12](lib/core/ads/ad_service.dart) `_minimumCompletedWorkoutCount = 3`, `_isSameLocalDate`) — 사용자가 생기기 전엔 논점 아님.

**결론: 이 앱의 병목은 설치/리텐션(ASO·마케팅)이지 AdMob이 아니다.** 광고 튜닝에 시간을 쓰지 말 것.

## 2. 그래도 할 일 (우선순위순)

### 2-1. [P1] 콘솔 상태 점검 (코드 밖, 10분)
- AdMob 앱 준비 상태가 "준비됨"인지, 정책 센터에 게재 제한이 없는지.
- **-US$0.00 차감의 출처**: 무효 트래픽 조정 내역 확인. 개발/테스트 시 실기기에서 실유닛 광고를 띄우지 않았는지 돌아볼 것 — release 빌드를 본인 기기에서 반복 실행하면 무효 트래픽으로 잡힌다. 테스트 기기 등록(`MobileAds.instance.updateRequestConfiguration`의 `testDeviceIds`) 또는 debug 빌드 사용.

### 2-2. [P2] 첫 사용자 유입 대비 소수정 (반나절)
1. **UMP 실패 세션 복구**: `requestConsentInfoUpdate`가 오프라인 등으로 실패하면 해당 세션은 광고가 영영 죽는다. `AppLifecycleState.resumed`에서 `_ready == false`면 1회 재초기화 (zupzup에 이미 이식된 패턴 재사용).
2. **ATT 순서**: 현재 iOS에서 ATT를 UMP보다 먼저 요청한다([privacy_consent_service.dart:14-23](lib/core/privacy/privacy_consent_service.dart)). Google 권장은 UMP 폼(IDFA 설명 포함) → ATT. 순서 교체.
3. 전면 게이트 완화(3회→1회)는 **DAU 두 자릿수가 되고 나서** 데이터 보고 결정.

### 2-3. [P3] 위생
- 패키지명 `nam.memento.app`(과거 앱 리스팅 재활용) — 이미 출시된 이상 변경 불가. 인지만 해둘 것: 이 리스팅의 과거 설치 기반에서 유령 버전 요청이 나타날 수 있다(모션핏·줍줍에서 이미 발생 중인 패턴). 나타나면 계정 분석서 §3의 판별 절차 적용.
- 로컬 `flutter.versionName=1.0.0`([android/local.properties](android/local.properties))과 gradle 하드코딩 1.2.4의 이원화 정리 — 배포 버전의 단일 출처를 build.gradle.kts로 통일.

## 3. 검증
- 사용자 유입 시작 후: 세션당 요청 1~3건, 요청→노출 40%+ 확인. 유령 버전 행 감시.
