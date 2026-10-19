# MotionFit 공통 광고 안정화 구현·검증 기록

대상은 `/Users/nam/projects/flutter/motionfit`의 HEAD `0f608c59abbe59afe20da257f169a1ab48c54735` 위 작업 트리다. 새 MotionFit 프로젝트는 수정하지 않았다. NASDAQ은 소스 참조만 했으며 원본 소스 변경은 없다. 이번 변경은 실제 구현과 자동화 검증을 포함한다. 운영 재고·실기기까지 모든 합격 기준이 입증된 배포 승인 상태를 의미하지 않는다.

## 구현한 변경

| 파일 | 변경 및 복구 방식 |
| --- | --- |
| `lib/core/privacy/privacy_consent_service.dart` | UMP 정보·양식 오류와 정상 미허용을 구분한다. 진행 중 Future만 공유하고 기술 오류 후 재시도한다. ATT·양식이 제한 시간을 넘겨도 같은 native 모달을 겹쳐 열지 않는다. ATT 호출 완료 뒤 OS 상태가 여전히 미결정이면 재시도 가능한 `att_pending`으로 기록하며, 완료된 호출 Future를 권한 확정으로 영구 캐시하지 않는다. 실제 UMP `canRequestAds`를 확인한다. |
| `lib/core/ads/ad_service.dart` | SDK 초기화를 단독 소유한다. 동의·SDK 실패를 backoff와 foreground 복귀로 복구한다. 전면 preload, 캐시 만료, show 소유권, 실제 표시 시각을 통합 관리한다. |
| `lib/core/ads/ad_bootstrap.dart`, `lib/app/app.dart`, `lib/core/providers.dart` | 광고 초기화를 운동 DB await보다 먼저 시작한다. 기록 조회 실패·미완료가 네이티브/배너 준비를 막지 않는다. DB 횟수 미확정 시 전면은 사유를 남기고 보수적으로 생략한다. |
| `lib/core/ads/ad_sdk.dart`, `ad_failure.dart` | SDK adapter와 Fake 주입 경계를 마련했다. 플랫폼/domain/code에 따라 No Fill, 연결, 구성, 호출 오류를 구분한다. No Fill은 앱 코드 결함과 별도 분류한다. |
| `lib/core/ads/ad_loader.dart` | 모든 형식의 비동기 생성·load Future·실패 콜백·15초 timeout·취소·dispose를 통합했다. 세대 번호로 늦은 결과를 폐기하고, 실패 때 loading을 해제한다. 재시도는 5/15/30/60/120/300초 backoff, 슬롯당 타이머 하나다. 잘못된 구성은 무한 재시도하지 않는다. |
| `lib/core/ads/ad_slot_controller.dart`, `ad_slot.dart` | 네이티브 실패/timeout 시 배너 fallback을 사용한다. 화면·foreground·viewport를 관찰하고 광고를 보관한다. 회전 시 배너 크기 변경을 한 번 반영한다. 이전 AdWidget 분리 후 객체를 폐기해 동시 연결을 피한다. |
| `lib/core/ads/bottom_native_ad.dart`, `bottom_banner_ad.dart`, `lib/app/router.dart` | 중복 로딩 구현을 공통 슬롯으로 대체한다. 실제 placement를 전달하고 탭 비활성 시 신규 요청을 멈춘다. 기존 레이아웃 크기·광고 노출 대상 화면을 유지한다. |
| `lib/core/ads/ad_unit_ids.dart` | 사용자가 확인한 iOS 배너 `/9696065805`를 반영했다. iOS/Android/형식별 운영·공식 테스트 ID를 분리하고 검증한다. debug/profile 또는 `ADS_TEST_MODE=true`는 테스트 ID를 사용한다. 확인된 오프닝 ID는 상수로 기록했으며 새 노출 위치는 추가하지 않았다. |
| `lib/core/ads/ad_eligibility.dart`, `post_workout_interstitial.dart` | 첫 완료 뒤 다음 완료를 위한 preload를 허용한다. 실제 show는 기존처럼 두 번째 유효 완료부터, 쿨다운 10분을 유지한다. show 직전 동의·화면·foreground·중복 상태를 확인한다. |
| `lib/features/exercise/application/combined_workout_metrics.dart`, 세 운동의 `active_workout_screen.dart`, `rest_screen.dart`, `workout_summary_screen.dart` | 저장 완료 session key로 횟수를 보정하고 DB snapshot과 중복 계산하지 않는다. 유효 완료 전환을 전달한다. summary state를 광고 시도 전 지워 화면이 먼저 이탈하던 순서를 수정했다. 데이터 스키마·저장 방식·운동 판정 규칙은 변경하지 않았다. |
| `lib/features/settings/application/preferences_controller.dart` | 실제 `onAdShowedFullScreenContent` 시각을 저장한다. `show()` Future 성공이나 시도만으로 쿨다운을 갱신하지 않는다. |
| `lib/core/analytics/analytics_service.dart` | 요청·로드·기회·판단·show·impression 콜백·view 연결·폐기·복구 사유를 발행한다. request/opportunity/session ID, 플랫폼·버전·빌드·release SHA, 오류 종류/domain/code, 초기화 시간·캐시 나이를 남긴다. 광고 이벤트에만 telemetry revision을 추가하고 기존 전체 analytics revision은 유지했다. Google 자동 `ad_impression`을 직접 재발행하지 않는다. |
| `test/core/ads/*`, `integration_test/ads_sdk_smoke_test.dart`, `ads_sdk_driver.dart`, `pubspec.yaml`, `pubspec.lock` | Fake SDK·clock 기반 복구/경합 테스트와 실제 SDK 테스트 진입점을 추가했다. fake_async를 직접 dev dependency로 선언했다. |

기존 분석 문서와 자료는 보존했다. 이번 구현 이전부터 변경 중이던 `reports/ios_flutter_1_6_6_admob_root_cause_analysis.md` 및 기존 `reports/ios_1_6_6_ads_2026_10_17/` 자료를 구현 변경과 혼동하지 않는다.

## NASDAQ에서 참고한 방식

NASDAQ의 네이티브 15초 deadline, 실패 시 배너 대체, foreground 복귀 재준비, slot별 광고 소유권을 참고했다. MotionFit에는 첫 운동 보호·완료 횟수·쿨다운·운동 저장 완료 시점이 있으므로 NASDAQ 구현을 그대로 복사하지 않고 공통 AdLoader/AdSlot과 전면 소유권으로 통합했다. NASDAQ의 광고 정책이나 노출 빈도를 가져오지 않았다.

## 자동화 검증

| 검증 | 실행 결과 | 근거 |
| --- | --- | --- |
| Phase 1 동의·초기화·load 복구 | PASS, 26 tests | `verification/phase1.log` |
| Phase 2 전면 광고 경합·정책·캐시 | PASS, 40 tests | `verification/phase2.log` |
| Phase 3 네이티브·배너 수명·fallback | PASS, 45 tests | `verification/phase3.log` |
| 최종 광고·Analytics 회귀 | PASS, 56 tests | `verification/ads_final.log` |
| 전체 기존 테스트 | **FAIL: 251 PASS / 10 FAIL** | `verification/all_tests.log` |
| 변경 전 HEAD 동일 실패군 재현 | 동일한 실패 이름 10건 확인 | `verification/head_baseline.log`, `head_baseline_p0.log`, `test_results.json` |
| 광고 core/privacy/테스트 정적 분석 | PASS, No issues found | `verification/analyze_scoped.log` |
| 프로젝트 전체 정적 분석 | 오류·경고 없음, 기존 info 17건으로 exit 1 | `verification/analyze_all.log` |

전체 테스트 실패는 `rep_timeline_ui_test.dart` 8건과 `preparation_lifecycle_test.dart` 2건이다. HEAD 격리본과 실패 이름 집합이 정확히 같았다. 광고 외 기존 결함을 이번 작업에서 수정하지 않았으며 전체 테스트 PASS로 보고하지 않는다. 마지막 ATT 미결정 복구 보완 뒤 광고·Analytics 56건과 전체 테스트를 순차 재실행했다. 테스트 코드의 중괄호 lint 보완 후 관련 정적 분석도 재실행했다.

검증 시나리오는 UMP 정보/양식 실패 후 복구, 정상 미허용 요청 차단, ATT 오류, pending native 모달 중복 방지, 각 광고 형식 load Future 예외·timeout·늦은 결과 폐기, SDK 초기화 재시도, DB 실패/무한 대기와 광고 초기화 독립성, 저장 횟수 중복 보정, 첫 운동 보호·10분 쿨다운, 유효 기회 show 한 번, 동시 show·실패 콜백·Future 예외 경합, 전면 캐시 55분 만료 재준비, native→banner fallback, 비활성·회전·AdWidget 교체를 포함한다. 테스트가 다루는 입력·콜백 순서에서 loading 고착·중복 show·설명 없는 ready 기회 누락은 발생하지 않았다. 모든 실제 SDK 동작에 대한 무조건적 보장은 아니다.

| 최종 합격 기준 | 확인한 범위와 판정 |
| --- | --- |
| 영구 loading 고착 0 | Fake SDK의 세 형식 Future 예외·미응답·늦은 callback·복구 시나리오 PASS. 실제 기기의 모든 장애 조합은 미검증. |
| 중복 show 0 | 동시 호출·중복 callback 경합 Fake 테스트 PASS. Android 실제 전면 show 호출 1회 및 종료 확인 PASS. |
| 유효·허용·ready 기회의 설명 없는 누락 0 | Fake의 정상 기회 정확히 1회 show 및 생략 이유 계측 PASS. 실제 사용자 전체 기회/장기 통계는 미검증. |
| 주요 로딩 실패 경로 정상 복구 | 자동화 PASS. 잘못된 구성은 반복 요청하지 않고 명시적 오류로 남긴다. SDK가 전면 terminal callback을 영구 누락하는 경계는 아래 위험 참조. |
| DB 오류가 광고 초기화를 차단하지 않음 | 생산 bootstrap 함수의 DB error/pending 및 foreground 동의 복구 테스트 PASS. |
| Analytics로 미노출 이유 확인 | Fake event 연결과 Android 실제 SDK callback 로그 PASS. 실제 운영 GA4 수집·분석 화면 반영은 미검증. |
| 양 플랫폼 기존 기능 회귀 없음 | 빌드는 검증하되 전체 테스트는 FAIL(기존 실패 10건 동일). iOS 실기기 및 실제 운동 전체 UX는 미검증. 따라서 무조건적 전체 합격은 선언하지 않는다. |

## 빌드·실제 환경 검증

Android 검증 과정에서는 Gradle daemon 종료와 Flutter 3.41.9의 `--no-pub`에 따른 dev plugin registrant 잔존 오류도 확인했다. 메모리/worker 수를 제한하고 정상 모드별 registrant 재생성을 수행한 최종 Android release 빌드는 PASS다. 생성 Java 파일을 수동 패치하거나 native 운영 설정을 바꾸지 않았다.

| 빌드 | 결과 | 근거 |
| --- | --- | --- |
| Android release APK, 테스트 광고 | **PASS**, 62.9초, 152.7MB | `verification/android_build.log` |
| iOS release, `--no-codesign`, 테스트 광고 | **PASS**, Xcode 119.5초, 107.4MB | `verification/ios_build.log` |

최종 실행 결과·명령·제약은 `verification/test_results.json`과 빌드/기기 로그에 기록한다. 모든 빌드는 `ADS_TEST_MODE=true`를 사용한다. release SHA label은 `0f608c59-ads-validation`이며, 커밋하지 않은 작업 트리 검증용 표식이다. 정확한 소스 식별자는 `release_manifest.json`의 HEAD와 파일별 SHA256을 함께 사용한다.

iOS의 버전은 1.6.6/build 66, Android는 기존 1.6.15/build 2026091801이다. 버전 번호를 이번에 변경하지 않았다. iOS `--no-codesign` 성공은 컴파일·링크 검증이며 실제 iPhone/iPad 설치나 App Store 배포 검증을 뜻하지 않는다.

연결된 Android에 기존 운영 앱이 있어 실제 SDK 테스트는 `fit.motionfit.app.adsvalidation` 별도 패키지만 허용한다. 임시 Gradle init script로 테스트 host의 applicationId만 바꾸고 Firebase GoogleServices 작업은 비활성화한다. 본 프로젝트 native 설정과 운영 설치 데이터는 변경하지 않는다. 테스트는 실제 UMP 결과와 Google 공식 테스트 광고 load 및 형식별 impression callback, 전면 실제 show·종료 callback을 확인하며, 네이티브가 배너 fallback으로만 성공한 경우 네이티브 성공으로 집계하지 않는다.

Android SM-S926N, Android 16/API36 실기기에서 별도 패키지로 **SDK 시나리오 3건 PASS**(runner teardown 포함 4 PASS)를 확인했다. 배너·네이티브·전면 각각 공식 테스트 ID의 실제 impression을 받았으며, 전면은 실제 showed·dismissed callback과 show 호출 1회를 확인했다. 약 22초 실행 로그는 `verification/device_smoke.log`다. 검증 후 별도 패키지는 존재하지 않으며 기존 운영 패키지는 계속 설치된 상태임을 확인했다. 이 테스트 host는 Firebase 이벤트를 보내지 않으며 Analytics metadata 초기화도 하지 않아 로그의 app_version/build_number 기본값은 운영 버전 검증 근거로 사용하지 않는다. 실제 APK 버전은 manifest로 따로 확인했다. 운동 전체 UX 및 iOS 실기기 검증을 대신하지 않는다.

## 남은 위험과 배포 전 확인

- 실제 iOS 기기의 ATT/UMP 최초·기존 설치, 느린 연결, 오프라인 복구, native template 크기, foreground/회전과 impression을 추가 확인해야 한다. 미실행 항목을 PASS로 보지 않는다.
- 전면 SDK가 show 후 성공/실패/종료 콜백을 **전혀** 주지 않으면 30초 뒤 미확인 결과로 전환 대기를 해제하되 소유권 잠금을 보수적으로 유지한다. 늦은 native presentation과 두 번째 광고가 겹치는 것을 막기 위한 선택이다. 늦은 종료 콜백은 회복시키지만 콜백이 끝내 없으면 해당 프로세스의 전면 광고는 재표시하지 않는다. 다른 형식은 동작한다. 이 SDK 경계 위험은 제거 완료로 주장하지 않는다.
- 실제 UMP 미허용, 잘못된 콘솔 구성, AdMob No Fill/제한/네트워크 문제를 앱이 강제로 해결할 수는 없다. 오류 종류를 구분해 관찰한다.
- 실제 AdMob 계정/GA4 export 권한으로 역사적 iOS 1.6.6 cohort를 재집계하거나 App Store 공개 build 66 연결을 새로 확인하지 않았다. 제공 혼합 로그의 숫자를 iOS 1.6.6 확정 통계로 바꾸지 않는다. 기존 SQL/분석 자료를 사용해 운영 콘솔에서 추가 확인해야 한다.
- 기존 전체 테스트 실패 10건이 남아 있어 전체 회귀 PASS와 모든 플랫폼 실기기 무회귀를 선언하지 않는다.
- 운영 배포 시 `ADS_TEST_MODE`를 제거하고 실제 배포 commit SHA를 주입해야 한다. 운영 단위 ID는 사용자 확인값이며, 이번 테스트에서는 운영 광고 요청을 검증 용도로 사용하지 않는다.

## 저장 공간 복구

초기 빌드는 디스크 부족으로 실패했다. 사용자의 “크레쉬 데이터와 재생성 가능한 데이터만 삭제” 승인에 따라 Gradle 캐시, Xcode DerivedData, iOS DeviceSupport Symbols, 사용하지 않던 NASDAQ build 산출물, 이 작업의 임시 HEAD 검증본/실패 산출물 및 실기기 검증 후 자체 debug 중간 산출물/테스트 APK 사본, CocoaPods 다운로드 캐시, Sparkle 업데이트 다운로드 캐시, 사용하지 않고 Git에 추적되지 않은 steady/pixapdf/notiflow/vobrief의 표준 Gradle app/build 출력과 크래시 진단 12개만 정리했다. 소스·운영 앱 데이터·Xcode Archives·SDK 설치는 삭제하지 않았다. 캐시 제거로 처음 빌드 시간이 길어졌다.
