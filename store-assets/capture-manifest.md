# 캡처 매니페스트

## 빌드 정체

| 항목 | 값 |
|---|---|
| 앱 | MotionFit - Squat (`com.namslab.motionfit.squat`) |
| 버전 / 빌드 | 1.1.0 (10) — `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` |
| Git 커밋 | `eb0e807b13402a789499dfb4dc97f443663e63e8` (`eb0e807`, 2026-08-05 21:04 KST) |
| 커밋 외 변경 | `lib/core/ads/ad_eligibility.dart` 1건 (스크린샷 전용, 아래 참조) |
| Flutter | 3.41.9 stable (engine 9161402dc0) |
| Xcode | 26.1.1 (17B100) |
| 빌드 명령 | `flutter build ios --simulator --debug` |
| 빌드 산출물 | `build/ios/iphonesimulator/Runner.app` |
| 캡처 일시 | 2026-08-05 (KST) |

`debugShowCheckedModeBanner: false`([lib/app/app.dart:221](../lib/app/app.dart:221))이므로 디버그 빌드에도 디버그 배너가 없다.

## 캡처 기기

| 기기 | 종류 | UDID | OS | 네이티브 해상도 | App Store 슬롯 |
|---|---|---|---|---|---|
| iPhone 17 Pro Max | 시뮬레이터 | `D123AEA7-916C-49F9-BF7E-78F24EAD3D81` | iOS 26.1 (23B86) | 1320 × 2868 | 6.9" (필수) |
| StoreShot iPad 13 (iPad Pro 13-inch M4) | 시뮬레이터 | `FF645163-1A38-472E-8A31-6E155192DF66` | iOS 26.1 (23B86) | 2064 × 2752 | 13" (필수) |

두 기기 모두 **네이티브 해상도가 대상 슬롯 규격과 정확히 일치**하므로 앱 픽셀을 리샘플링하지 않는다.

## 캡처 방법

- 화면 캡처: `xcrun simctl io <UDID> screenshot --type=png` — iOS가 직접 생성하는 시스템 캡처.
- 화면 이동: 실제 앱 UI 탭 (하단 탭바, 목록 행, 시트). 좌표 입력만 사용했고 앱 코드는 건드리지 않았다.
- 상태 표시줄: `xcrun simctl status_bar <UDID> override --time "9:41" --batteryState charged --batteryLevel 100 --wifiMode active --wifiBars 3 --dataNetwork wifi` — 시뮬레이터가 제공하는 시스템 기능. 상태 표시줄 픽셀은 iOS가 렌더링했고 이미지 편집기로 그리지 않았다.
- 언어: 앱의 인앱 언어 설정(`user_preferences_v1.locale`)을 로케일별로 지정한 뒤 기기를 재부팅해 캡처. 앱이 지원하는 **7개 언어 전부**(ko/en/ja/de/fr/es/ar) 진행.
- 프리퍼런스는 `cfprefsd` 캐시 때문에 기기를 **종료한 상태**에서만 기록해야 반영된다. 부팅된 상태에서 쓰면 캐시가 덮어써서 이전 언어로 렌더된다.
- 비카메라 화면 3종은 `--dart-define=SHOT_ROUTE=<라우트>`로 앱이 해당 화면으로 바로 부팅하게 해 탭 없이 스크립트로 수집했다(임시 변경, 복구 완료).

## 시뮬레이터 상태 시드

앱 소스는 수정하지 않았다. 시뮬레이터 컨테이너(폐기 가능한 테스트 영역)에만 상태를 넣었다.

| 스크립트 | 대상 | 내용 |
|---|---|---|
| [`scripts/seed_demo_data.py`](scripts/seed_demo_data.py) | 앱이 만든 `Documents/motionfit.db` (schema v4) | 13개 완료 세션(2026-07-21 ~ 08-05, 총 350회), 세트·렙 레코드, 누적 챌린지 1건(목표 500회), 리마인더 월·수·금 07:00 |
| [`scripts/set_app_state.py`](scripts/set_app_state.py) | `Library/Preferences/…plist`의 `user_preferences_v1` | 로케일, 온보딩 완료, 운동 계획 3세트 × 10회 · 휴식 60초 |

- 화면에 보이는 **집계값은 전부 앱이 계산한다**. 연속 일수, 하루 합계, 자세 요약 %, 챌린지 진행률·남은 횟수·남은 기간, 총 운동 시간은 시드에 없으며 프로덕션 Dart 코드가 렌더 시점에 계산한 결과다.
- 저장한 원시값은 앱의 실제 파이프라인이 만들 수 있는 범위 안에 있다. 예: `overall_form_score`는 `FormAnalyzer`가 쓰는 0–100 스케일([lib/features/squat/domain/services/form_analyzer.dart:456](../lib/features/squat/domain/services/form_analyzer.dart:456)), `camera_angle`은 `CameraAngle.front`, 렙 지속시간 3.1–3.5초.
- 시뮬레이터 프리퍼런스는 `cfprefsd` 캐시 때문에 **기기를 종료한 상태에서만** 기록해야 반영된다.

## 시뮬레이터 시스템 설정 변경

| 항목 | 변경 | 이유 |
|---|---|---|
| iPad 멀티태스킹 | `윈도우형 앱` → `전체 화면 앱` | iPadOS 26의 윈도우 리사이즈 핸들이 화면 우하단(약 x 1980–2055, y 2680–2745)에 시스템 UI로 겹쳐 렌더링됐다. 전체 화면 모드로 바꿔 **원본 캡처 단계에서 제거**했고, 이미지 편집으로 지우지 않았다. |
| ATT 추적 동의 팝업 | `앱에 추적 금지 요청` 선택 | 첫 실행 시 시스템 팝업이 떠 캡처를 가렸다. 개인정보 보호 우선 선택지로 닫았다. |

## 원본 캡처 목록

경로: `store-assets/captures/ios/<locale>/<device>/<NN>-<screen>.png`

| 파일 | 화면 | 앱 라우트 | 도달 경로 | 사용 슬롯 |
|---|---|---|---|---|
| `01-home.png` | 홈 · 운동 계획 | `/squat` | 앱 실행 | 04 Sets & rest |
| `02-challenge.png` | 챌린지 | `/challenge` | 하단 탭 | 03 Challenge |
| `03-challenge-detail.png` | 챌린지 상세 | `/challenge/:id` | 챌린지 → 상세 보기 | (예비) |
| `04-records.png` | 기록 · 달력 + 결과 | `/records` | 하단 탭 | 05 Workout result (크롭) · 06 History (전체) |
| `05-voice-coaching.png` | 코칭 안내 설정 | `/settings` | 설정 → 음성 코칭 | 미사용 — 보조 기능이라 세트에서 제외 |
| `06-reminder.png` | 운동 리마인더 | `/settings` → 리마인더 | 설정 → 운동 리마인더 | 미사용 — 동일 |

로케일 ko·en × 기기 iphone·ipad × 6장 = **24장** 확보. 이 중 3개 화면을 최종 4개 슬롯에 사용한다.

모든 원본은 해당 기기의 네이티브 해상도(iPhone 1320 × 2868 / iPad 2064 × 2752)이며 리사이즈·합성·보정을 하지 않았다.

## 아직 확보하지 못한 원본

| 필요한 캡처 | 슬롯 | 조건 |
|---|---|---|
| 운동 중 자동 카운트 화면 | 01 | 실기기 + 실제 인물 + 앱이 렌더한 포즈 랜드마크·카운트가 한 프레임 |
| 운동 중 자세 피드백 화면 | 02 | 위와 동일, 피드백 UI가 표시된 순간 |
| 휴식 타이머 화면 | (04 대체안) | 활성 운동 세션 필요 |
| 운동 완료 요약 화면 | (05 대체안) | 완료된 운동 세션 필요 |

시뮬레이터는 `AVCaptureDevice`를 제공하지 않아 `NativePoseEngine`이 시작되지 않는다. 네 화면 모두 실기기 캡처로만 확보 가능하다. 절차는 [storyboard.md](storyboard.md)의 "How to unblock screens 1 and 2" 참조.

## 미포함 화면과 이유

| 화면 | 이유 |
|---|---|
| 코칭 안내 설정 시트 | 보조 기능. 핵심 운동 기능이 앞에 와야 한다는 원칙에 따라 세트에서 제외했다. |
| 운동 리마인더 | 동일. |
| 카메라 권한 안내 | 핵심 기능 슬롯에 권한 안내 화면을 넣지 않는다는 원칙. |
