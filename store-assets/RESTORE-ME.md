# 스크린샷용 임시 변경 — 복구 완료

## 앱 소스 변경 (전부 복구 완료 ✅)

| # | 파일 | 임시 변경 | 이유 | 상태 |
|---|---|---|---|---|
| 2 | `lib/features/squat/data/shot_replay_source.dart` | **신규 파일 추가** | 랜드마크 전용 스쿼트 시퀀스를 만들어 실제 렙 디텍터·자세 분석기·포즈 오버레이를 카메라 없이 구동 | ✅ **파일 삭제됨** |
| 3 | `lib/features/squat/application/workout_session_controller.dart` | `poseEngineFactoryProvider`가 `SHOT_REPLAY` 시 `ReplayPoseEngine` 반환 | 위 시퀀스를 주입 | ✅ **복구됨** |
| 5 | `lib/app/router.dart` | `initialLocation`을 `/prepare/countdown`으로, 기본 플랜을 `shotWorkoutPlan()`으로 | 언어 루프를 스크립트로 돌리기 위해 앱이 바로 운동 화면으로 부팅하도록 | ✅ **복구됨** |
| 4 | `lib/features/squat/presentation/screens/active_workout_screen.dart` | 카메라 텍스처 없이도 오버레이 분기가 렌더되도록 조건 변경 + 플레이스홀더 색상을 `SHOT_BG_WHITE`로 전환 | 시뮬레이터에 카메라 텍스처가 없어서 / 반투명 레이어 알파 복원용 흑백 2회 캡처 | ✅ **복구됨** |

빌드 플래그: `--dart-define=SHOT_REPLAY=true --dart-define=SHOT_INPUT_H=<1564|960> --dart-define=SHOT_POSE=<deep|coaching>_<iphone|ipad> [--dart-define=SHOT_BG_WHITE=true]`. 릴리스 빌드에는 절대 넣지 않는다.

## 광고 (복구 완료 ✅)

| # | 파일 | 원래 값 | 임시 값 | 이유 | 상태 |
|---|---|---|---|---|---|
| 1 | `lib/core/ads/ad_eligibility.dart` | `minimumNativeCompletedWorkouts = 1`<br>`minimumInterstitialCompletedWorkouts = 3` | `1000000` / `1000000` | 디버그 시뮬레이터 빌드는 Google 테스트 광고를 렌더링한다. 스토어 캡처에 광고가 들어가면 안 되므로 광고 게이트를 일시적으로 비활성화했다. | ✅ **복구됨** (`git checkout --`) |

### 복구 검증 (2026-08-06)

```
$ git diff HEAD --stat -- lib ios android pubspec.yaml l10n.yaml
(출력 없음 — 앱 소스가 커밋 eb0e807과 완전히 동일)

$ grep -rn "TEMP-SCREENSHOT|shotReplayEnabled|SHOT_REPLAY|shotPlaceholderColor|shotWorkoutPlan" lib
(출력 없음)

$ git status --short lib
(출력 없음 — 추적되지 않는 임시 파일도 남아 있지 않음)

$ flutter analyze
No issues found! (ran in 3.6s)
```

`store-assets/` 아래 산출물 외에 저장소에 남은 변경은 없다. **앱은 그대로 배포 가능한 상태다.**

## 앱 소스를 건드리지 않은 항목

아래는 시뮬레이터 컨테이너/시스템 설정만 바꾼 것이라 저장소나 배포 빌드에 영향이 없다.

| 항목 | 위치 | 복구 필요 |
|---|---|---|
| 데모 운동 기록·챌린지·리마인더 시드 | 시뮬레이터 앱 컨테이너의 `Documents/motionfit.db` | 불필요 — 시뮬레이터를 지우면 사라진다 |
| 로케일·온보딩·운동 계획 프리퍼런스 | 시뮬레이터 앱 컨테이너의 `Library/Preferences/*.plist` | 불필요 — 동일 |
| 상태 표시줄 오버라이드 (9:41 등) | `xcrun simctl status_bar override` | 불필요 — 시뮬레이터 전용. 되돌리려면 `xcrun simctl status_bar <UDID> clear` |
| iPad 멀티태스킹 `전체 화면 앱` | iPad 시뮬레이터 시스템 설정 | 불필요 — 개발 머신의 시뮬레이터 설정. 다음 캡처 때도 이 상태가 맞다 |

시뮬레이터를 완전히 초기화하려면:

```bash
xcrun simctl erase D123AEA7-916C-49F9-BF7E-78F24EAD3D81 FF645163-1A38-472E-8A31-6E155192DF66
```

## 별건 — 복구가 아니라 수정이 필요한 앱 버그

스크린샷 작업 중 발견했다. 임시 변경이 아니라 **실제 앱에 남아 있는 결함**이다.

`lib/app/theme/motionfit_theme.dart:103`의 `AppBarTheme`이 `backgroundColor: Colors.transparent`만 지정하고 `systemOverlayStyle`을 지정하지 않아, 라이트 테마에서 iOS 상태 표시줄 글리프가 흰색으로 렌더링된다. 배경이 `#F6F7F9`라 대비비가 약 1.03:1이고 시간·통신·배터리가 사실상 보이지 않는다.

스크린샷에서는 상태 표시줄을 잘라내 회피했지만 앱에는 그대로 남아 있다. 자세한 내용은 [qa-report.md](qa-report.md)의 "남은 리젝·품질 위험" 참조.
