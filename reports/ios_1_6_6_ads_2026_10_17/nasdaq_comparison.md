# MotionFit과 nasdaq 광고 구현 비교

MotionFit의 복구 공백을 줄이는 데 직접 참고할 부분은 nasdaq의 **동의 재시도, load Future 예외 처리, 준비되지 않은 전면 광고의 재준비, 네이티브 timeout과 배너 대체**다. 화면 전환 빈도·앱 열기 광고처럼 제품 경험이 다른 부분을 그대로 복사할 필요는 없다.

비교 대상은 MotionFit `0f608c59` 및 이전 구현 `f899926`, nasdaq `/Users/nam/projects/flutter/nasdaq`의 `a4fb39d4a1cfd5fc8aceca8baf3420e67061a9ef`이다. nasdaq에서 미노출 문제가 없다는 설명은 사용자 제공 운영 맥락이며, 비교는 로컬 소스의 동작을 기준으로 했다.

## 가져올 수 있는 복구 방식

| 항목 | MotionFit | nasdaq | 적용 판단 |
| --- | --- | --- | --- |
| 초기화 의존성 | 전체 운동 기록 조회 후 ATT·UMP·SDK 시작 | [app.dart:63](/Users/nam/projects/flutter/nasdaq/lib/app.dart:63)에서 세션 기록·추적 요청·광고 시작을 분리 | SDK 준비와 운동 횟수 정책 분리 |
| 동의 일시 오류 | 이전 구현은 실패 Future도 memo 고정. 현재도 양식 오류 공백 | [admob_service.dart:315](/Users/nam/projects/flutter/nasdaq/lib/ads/admob_service.dart:315), :374, :403에서 허용 상태 확인·타이머 재시도·복귀 재시도 | 동시 요청 1개, 오류 유형별 제한된 backoff 도입 |
| ATT 대기 | ATT 응답 뒤 UMP 순차 진행 | [admob_service.dart:121](/Users/nam/projects/flutter/nasdaq/lib/ads/admob_service.dart:121), :344에서 SDK 준비 대기와 동의 모달 대기를 분리 | 지연은 줄이되 시스템 팝업 중복 표시와 UMP 우회 금지 |
| 전면 load 호출 예외 | 반환 Future 오류 처리 없음 | [admob_service.dart:554](/Users/nam/projects/flutter/nasdaq/lib/ads/admob_service.dart:554)에서 `.catchError`, loading 해제·재시도 | 우선 적용할 핵심 차이 |
| 네이티브 load 호출 예외 | `unawaited(ad.load())` 후 상태 잔류 가능 | [home_native_ad_slot.dart:110](/Users/nam/projects/flutter/nasdaq/lib/ads/home_native_ad_slot.dart:110)에서 오류를 `_failed`로 전달 | SDK 실패 콜백과 호출 예외를 공통 종료 처리 |
| 배너 load 호출 예외 | 현재 HEAD의 외부 try 안에서도 load는 unawaited | [banner_ad_loader.dart:214](/Users/nam/projects/flutter/nasdaq/lib/ads/banner_ad_loader.dart:214)에서 await/catch 후 pending 폐기 | 후속 배너 릴리스에 반영 |
| 준비 안 된 전면 광고 | 이전은 8초 대기. 현재는 재준비 없이 반환 가능 | [admob_service.dart:258](/Users/nam/projects/flutter/nasdaq/lib/ads/admob_service.dart:258)에서 `_loadInterstitial()`; [kospi_v2_ui.dart:416](/Users/nam/projects/flutter/nasdaq/lib/kospi_v2_ui.dart:416)에서도 prefetch | 화면을 막지 않고 다음 기회를 준비 |
| 네이티브 로드 지연 | timeout·대체 형식 없음 | [home_native_ad_slot.dart:117](/Users/nam/projects/flutter/nasdaq/lib/ads/home_native_ad_slot.dart:117)에서 15초 후 실패 처리, :155에서 배너 대체 | 유효한 iOS 배너 ID 확인 후 슬롯 단위 적용 |
| 활성 상태 | MotionFit native는 route를 일부 확인하지만 foreground 관리 없음 | native의 `_allowed`는 active·SDK ready·foreground 확인; 배너도 active·foreground·실측 폭 확인 | 비활성 화면의 요청/재시도를 멈추고 복귀 시 재개 |
| 슬롯 수명 | 제거되면 광고 dispose 후 다음 진입에서 재로드 | native keep-alive, 배너는 탭 전환에서 캐시 보존 | 같은 광고를 동시에 여러 AdWidget에 붙이지 않는 범위에서 유지 |
| 오래된 콜백 | native 일부 identity 검사; 공통 generation 관리 없음 | 배너 [banner_ad_loader.dart:173](/Users/nam/projects/flutter/nasdaq/lib/ads/banner_ad_loader.dart:173), :254에서 generation 사용 | 재시도·화면 이탈·리사이즈 이후 늦은 콜백 무효화 |
| 로드 결과 계측 | 요청·정책 skip 외 메서드는 빈 구현 | [ad_funnel.dart:30](/Users/nam/projects/flutter/nasdaq/lib/ads/ad_funnel.dart:30)에서 요청과 같은 tracked 표식을 로드 결과에 전달; 오류 code/domain/message | 요청·결과를 같은 식별자로 연결하는 패턴 적용 |
| SDK 버전 | plugin 9.0.0 / GMA 13.3.0 / UMP 3.1.0 | 동일 | SDK 교체보다 앱 복구 흐름부터 수정 |

## 그대로 가져오면 안 되는 부분

**광고 기회가 다르다.** nasdaq은 탭 전환마다 준비 상태를 확인하고 앱 열기 광고도 갖는다. MotionFit은 운동 완료라는 드문 전환에서 광고를 표시한다. 따라서 같은 요청 대비 노출 비율을 목표로 삼거나, 운동 도중 전면 광고를 넣어 차이를 메우는 것은 적절하지 않다.

**nasdaq의 `showInterstitial()` 반환값도 실제 표시 성공과 같지는 않다.** 이 함수는 `ad.show()`를 시작한 뒤 즉시 true를 반환한다([admob_service.dart:288](/Users/nam/projects/flutter/nasdaq/lib/ads/admob_service.dart:288)). 호출자는 이 값을 보고 전환 횟수를 초기화한다. 나중에 show가 실패하면 주석의 ‘실제 표시 후 초기화’와 어긋날 수 있다. MotionFit은 `onAdShowedFullScreenContent` 또는 명확하게 정의한 impression 기준으로만 성공/쿨다운을 갱신해야 한다.

**nasdaq도 전면 광고 캐시 나이 검사는 없다.** app-open 캐시 수명 관리는 있지만 전면 캐시에 같은 기준을 구현하지 않았다. MotionFit의 55분 캐시 검사를 제거하는 대신 만료 후 재준비를 추가한다.

**nasdaq의 분석 메서드가 모두 연결된 것은 아니다.** `reportSdkInitializing`, `reportSdkReady`, `reportFullScreenShown`, `reportFullScreenDismissed`는 정의되어 있지만 검사한 lib에서 호출 지점을 찾지 못했다. 요청/로드 실패 개선은 확인되지만 SDK~show 전체 계측이 완성됐다고 보지는 않는다.

**no-fill과 SDK 오류를 분리해야 한다.** nasdaq의 `reportLoadError`는 오류 종류에 관계없이 추가로 `ad_no_fill`도 기록한다. 이 이벤트를 순수한 광고 재고 부족으로 해석하면 안 된다. MotionFit에서는 SDK code/domain에 따른 분류를 사용한다.

**네이티브 구현 차이는 장애 증거가 아니다.** nasdaq은 `homeCompactNative` Swift factory, MotionFit은 공식 NativeTemplateStyle을 사용한다. 둘 다 plugin이 지원하는 경로다. factory 존재 여부보다 실제 view attach·화면 활성·impression 경로를 관찰해야 한다.

**요청 계측 제한에도 주의한다.** nasdaq AdFunnel은 형식별 최대 12요청을 추적하고 같은 요청의 결과도 함께 제한한다. 이 방식은 요청/결과 짝을 보존하지만 모든 AdMob 요청의 총수가 아니다. MotionFit의 조사 기간에는 과도한 샘플링 없이 정확한 요청 연결을 우선한다.

개선 대상은 검증된 복구 구조다. 세부 변경과 합격 기준은 [개선 계획](/Users/nam/projects/flutter/motionfit/reports/ios_1_6_6_ads_2026_10_17/improvement_plan.md)에 정리했다.
