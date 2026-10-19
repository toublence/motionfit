# MotionFit iOS 광고 복구와 계측 개선 계획

목표는 **표시가 허용되고 광고가 준비된 유효 기회를 코드가 놓치지 않는 것**, 그리고 광고가 안 나오는 모든 주요 경로를 사유별로 설명하는 것이다. 요청 수나 정책 제한을 무작정 늘려 노출 수를 올리는 방식은 사용하지 않는다.

현재 분석은 [원인 보고서](/Users/nam/projects/flutter/motionfit/reports/ios_1_6_6_ads_2026_10_17/analysis.md)와 [nasdaq 비교](/Users/nam/projects/flutter/motionfit/reports/ios_1_6_6_ads_2026_10_17/nasdaq_comparison.md)를 기준으로 한다. 다음 항목은 구현 순서와 합격 기준이며, 이번 작업에서 앱 소스에 적용하거나 실행한 테스트 목록이 아니다.

## 1 운영 대상을 분리하고 릴리스 기준을 고정

1. App Store Connect에서 공개된 1.6.6의 build가 66인지 확인하고, 발견한 아카이브의 9월 8일 업로드 기록과 연결한다. 새 릴리스부터 버전·빌드·Git SHA·광고 단위·SDK 버전 manifest를 남긴다.
2. AdMob에 **MotionFit iOS 앱 + 플랫폼 iOS + 앱 버전 1.6.6 + 2026-09-19~2026-10-16**을 동시에 적용한다. 광고 단위별 요청·일치 요청·노출·show rate·오류/제한 정보를 내보낸다. 광고 소스 차원 없는 광고 단위 보고서도 비교해 요약 차이를 확인한다.
3. iOS 광고 단위 `/1414718708`(native), `/2998795518`(interstitial)의 콘솔 소속을 확인한다. 숫자 ID로 연결하며 광고 이름만으로 연결하지 않는다.
4. GA4는 플랫폼·앱 버전뿐 아니라 iOS stream과 bundle ID도 맞춘다. `mf2_` 접두어만으로 플랫폼을 정하지 않는다. 날짜 경계는 GA 속성과 AdMob 계정 시간대를 확인해 통일한다.
5. [ios166_cohort.sql](/Users/nam/projects/flutter/motionfit/reports/ios_1_6_6_ads_2026_10_17/ios166_cohort.sql)의 dataset·stream을 설정해 플랫폼/버전/빌드별로 조회한다. BigQuery 연동이 당시 없었다면 과거 원시 데이터가 있다고 가정하지 않고 GA 탐색에서 가능한 차원만 분리한다.

SDK 자동 이벤트에는 custom `build_number`가 없을 수 있다. build 66만 필터링해 자동 impression을 지워서는 안 된다. 1.6.6 전체를 먼저 분리한 뒤 build 66 / build 미기록 / 다른 build / context 충돌을 각각 출력한다. `PackageInfo` 실패 시 custom version fallback이 달라질 수 있어 GA SDK의 `app_info.version`과 비교한다.

**완료 기준:** iOS 1.6.6과 다른 플랫폼·버전의 수치가 분리되고, build 및 시간대가 불명확한 자료는 별도 집계된다. 과거에 수집하지 않은 load/show 결과는 0건이 아니라 ‘계측 없음’으로 표시한다.

## 2 동의와 SDK 초기화 복구

수정 대상은 `lib/core/privacy/privacy_consent_service.dart`, `lib/core/ads/ad_service.dart`, `lib/app/app.dart`다.

- 동의 Future는 진행 중 작업 공유에 사용하고, **재시도 가능한 정보 갱신/양식 오류** 후에는 해제한다. 오류와 사용자의 정상 선택을 구분한다.
- 성공·기존 동의 사용 가능·기술 오류·동의 미허용을 구분하는 결과를 반환한다. 정보 갱신 성공만으로 전체 동의 절차 성공을 판단하지 않는다.
- SDK 초기화는 한 곳이 소유한다. 현재 privacy service와 ad service의 중복 initialize 책임을 합치고, 매 요청 허용 판단은 UMP 상태를 기준으로 한다.
- 화면 활성 상태에서 제한된 backoff로 재시도하고 앱 복귀에 복구 기회를 준다. 같은 프로세스에서 복구 가능한 오류가 재시작을 요구하지 않게 한다.
- 전체 운동 DB 조회는 전면 광고 횟수 정책에만 사용한다. 배너·네이티브와 동의/SDK 준비를 DB 실패로 막지 않는다.
- ATT 미결정 대기는 별도 상태로 관리한다. 필요한 동의 모달을 중복 표시하지 않고, UMP 미허용 상태에서 요청을 보내지 않는다.

**완료 기준:** 신규 설치의 일시적인 UMP 정보/양식 오류 뒤 네트워크가 복구되면 재실행 없이 SDK와 광고 준비가 회복된다. `canRequestAds=false`이면 요청 0건이다. 기록 조회 실패가 다른 광고 형식 초기화를 막지 않는다.

## 3 모든 광고 load 종료 경로를 통합

수정 대상은 `ad_service.dart`, `bottom_native_ad.dart`, `bottom_banner_ad.dart`다.

- SDK 성공 콜백, 실패 콜백, **load 호출 Future 예외**, 명시적인 대기 만료, dispose를 하나의 요청 수명 관리로 연결한다.
- 모든 실패 경로에서 loading·pending·Completer를 정리한다. retry timer는 슬롯/형식별 하나만 유지한다.
- 요청마다 generation 또는 request ID를 부여해 이전 시도의 늦은 콜백이 새 상태를 덮지 않게 한다. 오래된 광고 객체는 안전하게 폐기한다.
- load가 영구 pending으로 남지 않도록 timeout을 설계한다. SDK load가 취소되지 않는 경우에는 늦게 도착한 광고를 표시하지 않고 dispose한다. 초기 기준은 native 15초를 검토하되 실제 분포로 조정한다.
- no-fill, 연결 오류, 잘못된 단위/구성, 플랫폼 호출 예외를 구분한다. 잘못된 ID를 1분마다 무한 재시도하지 않는다.
- background·비활성 슬롯에서는 신규 retry를 중지하고 foreground에서 필요 시 재개한다.

**완료 기준:** 어떤 load 종료 방식에서도 다음 정상 요청이 가능하고, 요청 하나에 terminal 결과가 하나만 남는다. 이미 떠난 화면에 광고를 붙이거나 중복 요청을 시작하지 않는다.

## 4 전면 광고를 실제 표시 기회에 맞춰 준비

수정 대상은 `post_workout_interstitial.dart`, `ad_service.dart`, 세 운동 controller/summary 호출부다.

- 저장이 끝난 완료 이벤트의 snapshot으로 정책을 평가한다. `provider.value`가 갱신 중이라는 이유로 정책 판단을 조용히 누락하지 않는다.
- preload 허용과 show 허용을 구분한다. 다음 완료에서 정책을 충족할 사용자라면 운동 중 적절한 시점에 준비하고 실제 표시는 자연스러운 완료 전환에서만 한다.
- 결과 화면의 알림·리뷰 등 부가 작업이 완료 버튼이나 광고 준비를 막지 않도록 한다. 이전 구현으로 hotfix할 때도 같은 원칙을 적용한다.
- 캐시 만료·없음·최근 실패이면 다음 표시 기회를 위한 준비를 예약한다. foreground 복귀 시 SDK ready와 광고 cache ready를 따로 확인한다.
- 완료 버튼/뒤로가기/도전 이동 등의 진입점을 명시하고, 선택한 광고 정책과 skip 사유를 기록한다. 기존 첫 운동 보호나 쿨다운 변경은 안정화 패치와 분리한다.
- show 시작 직전 화면 활성·앱 foreground·full-screen 중복 여부를 확인하고, 이미 끝난 전환에 늦은 광고를 띄우지 않는다.
- cooldown은 정의한 실제 표시 콜백 기준으로 갱신한다. 반환값 true 또는 show 호출 시도만으로 갱신하지 않는다.
- show/dismiss 실패 시 화면 전환 completion은 정확히 한 번 실행한다. 표시 중인 광고를 timeout만으로 폐기하고 동시에 새 화면/광고를 열지 않는다.

**완료 기준:** 테스트에서 정책 충족·ready·foreground·유효 전환을 만족하면 show를 정확히 한 번 호출한다. 준비가 늦은 경우 기록된 사유로 이번 전환을 끝내고 다음 기회를 준비한다.

## 5 네이티브 슬롯과 iOS 배너 설정 보완

- 실제 `NativeAdPlacement`를 광고 요청까지 전달한다. 모든 위치를 `bottom_navigation`으로 기록하지 않는다.
- route 활성과 app foreground를 모두 관찰한다. 스크롤 밖 요청은 슬롯 필요 시점에 맞추고, mount·visibility·dispose 사유를 관찰한다.
- 슬롯 수명 동안 성공한 광고를 불필요하게 다시 요청하지 않는다. 같은 NativeAd를 여러 AdWidget에 동시에 연결하지 않는다.
- 네이티브 기술 오류·대기 만료 뒤 유효한 배너 단위로 대체하는 경로를 추가한다. 두 형식이 같은 슬롯에서 중복 표시되지 않게 한다.
- 후속 버전의 iOS 배너 ID는 AdMob 콘솔에서 확인한 값으로 설정한다. 현재 Android와 동일한 `/2773965626`을 검증 없이 그대로 사용하지 않는다.
- 개발·테스트에서는 공식 테스트 ID/테스트 기기를 사용하고, 운영 빌드는 앱·플랫폼·형식별 ID를 manifest와 대조한다.

**완료 기준:** native 실패 후 빈 슬롯이 영구 고착되지 않고, 늦은 콜백·탭 전환·화면 회전에서도 중복 표시/재요청이 통제된다. iPhone/iPad의 실제 AdWidget 크기와 impression 콜백을 확인한다.

## 6 누락 원인을 설명하는 이벤트 설계

기존 `mf2_ad_request_attempted`를 유지하면서 다음 진단 이벤트를 추가한다. GA 예약 이름인 `ad_impression`을 중복 발행해 매출/노출을 두 번 세지 않는다.

| 이벤트 또는 상태 | 기록 시점 |
| --- | --- |
| `mf2_ad_opportunity` | 정책 평가 전, 자연스러운 표시 전환의 시작 |
| `mf2_ad_decision` | allowed 또는 skip. 정책/SDK/캐시/화면 상태 사유 |
| `mf2_ads_init_result` | 동의/SDK 단계 결과와 소요 시간 |
| `mf2_ad_request_attempted` | 실제 SDK load 호출 직전 |
| `mf2_ad_load_result` | loaded / sdk_error / invocation_error / timeout |
| `mf2_ad_show_attempted` | 실제 show 호출 직전 |
| `mf2_ad_show_result` | showed / show_error / invocation_error |
| `mf2_ad_impression_callback` | SDK impression callback. 진단용이며 수익 이벤트와 구분 |
| `mf2_ad_disposed` | dismiss / screen_exit / expired / replaced / consent_change |

공통 식별자는 platform, app_version, build_number, release_sha, analytics_revision, ad_format, ad_placement, ad_unit_id, request_id다. 표시 기회에는 opportunity_id·workout_session_id를 연결한다. 오류 이벤트에는 code/domain·단계·재시도 횟수, 판단 이벤트에는 foreground·cache_age·완료 횟수·cooldown 사유를 기록한다. 이벤트당 필요한 파라미터만 넣어 SDK 제한을 넘기지 않는다.

운영에서는 `요청→로드`와 `정책을 충족한 기회→show→impression`을 별도로 계산한다. 서로 다른 이벤트 구현을 이름만 비슷하다고 합치거나, preload 요청 수를 표시 기회 수로 사용하지 않는다. 사용자 단위와 이벤트 단위 비율도 구분한다.

## 7 구현 후 필요한 검증과 배포 기준

이번 분석에서는 빌드·설치·광고 요청을 실행하지 않았다. 구현 후에는 fake SDK/clock으로 아래 장애 경로를 검증하고, iOS 테스트 광고로 짧은 실기기 확인을 수행한다.

| 시나리오 | 합격 기준 |
| --- | --- |
| UMP 정보 갱신 실패 후 복구, 양식 실패 후 복구 | 프로세스 재시작 없이 재시도·준비, 동의 미허용이면 요청 없음 |
| 각 형식 load Future 예외 | loading/pending 정리, 다음 요청 성공 |
| callback 미도착과 timeout 이후 늦은 성공 | 요청 종료 1회, 이전 광고 dispose, 늦은 show 없음 |
| 기록 DB 지연/실패 | native/banner 초기화 가능, 전면 횟수 불명은 명시적 skip |
| 최초 허용 완료 직후 빠른 완료 버튼 | 저장된 횟수로 판정, 준비된 광고 show 1회 |
| 캐시 만료·오프라인 후 foreground 복귀 | 광고 재준비, 무한 pending 없음 |
| 연속 탭·완료 중복 입력·show 실패 | 광고 중복 0건, 이동 completion 1회, 잘못된 cooldown 없음 |
| native timeout·배너 fallback·화면 이탈 | 대체 슬롯 1개, 늦은 콜백의 재삽입 없음 |
| 첫 완료 보호·쿨다운·동의 정책 | 정책 위반 0건 |
| 분석 이벤트 연결 | 요청별 결과/폐기 사유 연결, 테스트 광고 데이터 분리 |

기존 `test/core/ads/ad_eligibility_test.dart`는 횟수·쿨다운 중심이므로 위 복구 검증을 대신하지 못한다. 첫 배포 판단은 **허용·ready·foreground 기회 중 설명 없는 show 누락 0건, 영구 loading 고착 0건, 중복 show 0건**으로 한다. 재고 부족은 별도로 보고, 모든 운영 요청의 노출률 100%를 코드 합격 조건으로 삼지 않는다.

구현은 ‘동의/로드 복구 + 계측’, ‘전면 준비 타이밍’, ‘네이티브/배너 슬롯’의 작은 변경 단위로 나눈다. SDK 교체나 광고 빈도 정책 변경을 한 번에 섞지 않아 원인별 개선을 판별할 수 있게 한다.
