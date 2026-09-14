# 모션핏 코드 × Firebase Analytics: DAU 100 분석

분석일: 2026-09-14. 대상: 현재 작업 트리, `HEAD 8c53a7f`, `pubspec.yaml`의 `1.6.13+2026082073`. 제공된 Firebase 개요와 이벤트 표 132행을 함께 분석했다. 앱 코드는 수정하지 않았다.

현재 작업 트리에는 사용자가 수정한 `ios/Runner.xcodeproj/project.pbxproj`, `lib/core/privacy/privacy_consent_service.dart`가 있었다. 특히 동의 재시도 로직은 작업 트리의 내용이며 배포 여부를 알 수 없다. Android 1.6.13/iOS 1.6.6 및 이전 버전 전체에 현재 코드가 적용되었다고 가정하지 않는다. 실기기 재현, 원시 이벤트 조회, 빌드·테스트는 수행하지 않았다.

## 1. 결론과 확신 수준

**가장 먼저 고칠 것은 포즈 인식 전체가 아니라, 사용자가 준비 상태를 확인할 수 없는 진입 과정과 첫 성공 후 다음 방문으로 이어지는 경로다.** 광고는 진입 전 필수 게이트로 발견되지 않았지만, 첫 운동 완료 직후의 대기와 화면 전환을 방해할 수 있다.

현재 DAU 16의 가장 큰 원인으로 우선 조사·수정할 세 가지는 다음과 같다. 코드상의 문제는 확인했지만, 각 문제가 DAU를 몇 명 감소시켰는지까지 인과관계가 확인된 것은 아니다.

1. **첫 운동의 가치를 경험하기 전까지 준비 과정이 불투명하다.** 카운트다운 동안 카메라와 보정은 작동하지만 미리보기가 없고, 느리면 숫자 1에 머무른다. 보정은 무효 프레임 하나에도 누적을 지우며, 어떤 조건 때문에 초기화되었는지는 화면에 전달하지 않는다. 시작 탭 143명 대비 실제 운동 활성화 56명이라는 주변 집계 차이와 방향이 일치한다.
2. **첫 성공을 다음 날의 구체적 행동으로 연결하는 구조가 약하다.** 기록·스트릭·챌린지·알림은 존재한다. 그러나 일반 운동 결과의 주 행동은 ‘완료 → 홈’이고, 챌린지 추천은 챌린지 탭 안에 있다. 알림 카드를 무시하고 종료하면 재제안 조건에서도 빠질 수 있으며, 알림 payload를 목적 화면으로 전달하는 처리도 없다.
3. **첫 성공 직후 광고가 복귀 흐름에 끼어든다.** 첫 완료부터 전면광고 대상이며, 준비된 광고가 없으면 최대 8초의 로드 대기와 별도 동의/초기화 대기가 있다. 챌린지 운동은 결과 화면을 건너뛰고 이 경로를 거쳐 챌린지로 돌아간다. 실제 노출 사용자가 23명이므로 이것만으로 전체 이탈을 설명할 수는 없다.

지금 먼저 수정할 세 묶음은 **① 준비 미리보기·원인 안내·단계별 계측, ② 기존 결과 화면에서 내일 목표/챌린지/알림 연결, ③ 첫 성공 보호와 전면광고 대기 제거**다. ①에는 `exercise_type`, 정확한 첫 반복 완료, 실패 시 보정 진단 등 판단에 필요한 최소 계측을 포함한다.

**보정을 없애거나 인식 임계값을 일괄 낮추는 것은 아직 권하지 않는다.** 실제 평균 보정 시간과 실패 원인 분포가 없고, 운동 종류도 현재 이벤트에서 분리되지 않는다.

## 2. 수치를 먼저 올바르게 해석하기

### 2.1 아래 비율은 순차 퍼널 전환율이 아니다

붙여넣은 표는 이벤트별 기간 내 `총 사용자`다. 같은 사용자가 같은 시도에서 순서대로 수행했는지 확인되지 않는다. 실패 후 재시도한 사람은 여러 행에 들어가고, 도중에 시작한 기간·복구 운동·버전 교체도 섞일 수 있다.

| 단계 | 이벤트 수 | 총 사용자 | 앞 행 대비 사용자 수 비율 |
|---|---:|---:|---:|
| setup | 1,130 | 180 | — |
| start tapped | 437 | 143 | 79.4% |
| camera init started | 390 | 127 | 88.8% |
| camera init completed | 336 | 108 | 85.0% |
| calibration started | 289 | 104 | 96.3% |
| calibration completed | 161 | 56 | 53.8% |
| workout started | 155 | 56 | 100.0% |
| first rep detected | 150 | 54 | 96.4% |
| workout completed | 94 | 39 | 72.2% |
| second workout completed | 18 | 16 | 41.0% |

- `104 → 56`은 **48명의 주변 집계 차이**다. ‘보정 시작 후 48명 모두 보정 실패’로 확정할 수 없다.
- `camera_init_failed`는 29회/15명, `calibration_failed`는 11회/6명, `workout_cancelled`는 237회/102명이다. 타임아웃까지 남아 있던 사용자의 명시적 실패와, 먼저 나가거나 종료한 사용자를 구분해야 한다.
- 이벤트 횟수로는 보정 `161/289 = 55.7%`, 운동 완료 `94/155 = 60.6%`다. 사용자 기준보다 반복 실패가 더 크게 보일 수 있지만, 이것도 동일 시도 조인 전에는 전환율이 아니다.
- 완료 후 결과 화면은 94회/39명 대비 87회/37명이다. 챌린지에서는 결과 화면을 건너뛰므로 이 차이를 전부 화면 이탈로 볼 수 없다.
- 1,130회의 setup은 사용자의 1,130번 시작 의도가 아니다. 홈 화면 재생성·운동 종목 전환도 포함한다.

### 2.2 전체 지표의 한계

- DAU/MAU는 `16/278 = 5.8%`, DAU/WAU는 `18.4%`, WAU/MAU는 `31.3%`다. 동일 종료일 기준의 활동 밀도 지표이지 D1/D7 리텐션이 아니다. DAU 16은 제공된 한 시점 값이므로 최근 7일 평균 DAU와 구분해야 한다.
- 이벤트 표 총 사용자는 282, 개요의 MAU는 278이다. 총 사용자/활성 사용자 정의와 28일/30일/42일/6주 기간이 다르므로 같은 분모로 섞지 않는다.
- 1주차 6.9%는 제공된 주간 코호트 수치로 취급한다. 정확히 설치 7일 뒤 돌아온 비율과 같지 않다. 성숙한 코호트만 비교해야 하며, 5주째 0%도 최근 코호트가 아직 도달하지 않았는지 확인해야 한다. [Google 코호트 설명](https://support.google.com/analytics/answer/9670133)
- `first_open=227`은 사용자 이벤트 퍼널의 동일 신규 코호트 분모로 아직 연결되지 않았다. `39/227`을 신규 사용자 첫 운동 완료율로 보고하지 않는다.
- Crash-free 100%는 멈춤·권한 거절·비치명적 오류·취소 없음의 뜻이 아니다. 별도 표의 `app_exception=14회/7명`과 동일 플랫폼·버전·기간·치명성 기준인지 확인해야 한다.
- 평균 참여 시간과 세션 수만으로 운동 자체의 길이·만족도를 추정하지 않는다. 카메라 배치, 보정, 리뷰 탐색 시간이 포함될 수 있다.

## 3. 실제 코드의 이벤트 연결

제공된 **132개 이벤트 전체의 정의·호출 위치·발생 조건 또는 현 코드 미존재 판정**은 별도 [이벤트 매핑](/Users/nam/projects/motionfit/docs/analysis/2026-09-14-firebase-event-map-ko.md)에 기록했다. 아래는 핵심 흐름이다. 경로 링크의 줄 번호는 분석 시점 기준이다.

### 3.1 공통 전송 규칙

`AnalyticsService.workoutStartTapped()`에서 임의 UUID를 만들고 싱글턴 `_workoutSession`에 저장한다. 카메라·보정·운동 이벤트는 `_logWorkoutV2()`를 통해 이 ID를 공유한다. 세션이 없으면 전송하지 않는다. `oncePerSession` 이벤트는 같은 이벤트 이름을 시도당 한 번만 보내고, `completed/cancelled/failed` terminal 이벤트는 셋 중 최초 하나만 보낸다.

근거: [AnalyticsService](/Users/nam/projects/motionfit/lib/core/analytics/analytics_service.dart), [WorkoutAnalyticsSession](/Users/nam/projects/motionfit/lib/core/analytics/workout_analytics_session.dart).

공통 파라미터: `analytics_schema=2`, `platform`, `app_version`, `build_number`, `device_category`. 운동 문맥: `workout_session_id`, `entry_point`, `challenge_active`, `target_sets`, `target_reps`. **`exercise_type`와 반복/초 단위 구분은 없다.**

### 3.2 단계별 실제 의미

| 이벤트 | 호출 위치·함수 | 발생 조건 및 해석 |
|---|---|---|
| `mf2_workout_setup_viewed` | 각 종목 HomeScreen의 `initState()` post-frame | 홈 위젯 생성 후 저장된 계획을 읽어 전송. start의 session ID가 아직 없다. `entry_point=home`, `challenge_active=0` 고정 |
| `mf2_workout_start_tapped` | 각 종목 `openWorkoutPreparation()` | 권한 확인보다 먼저 생성·전송. 일반/복구/챌린지 진입 포함 |
| `mf2_camera_permission_requested/result` | launcher, PermissionScreen의 `_request`, `_refreshPermissionStatus`, `_recordPermissionResult` | 이미 허용된 경우에도 result 전송. OS 요청과 상태 확인은 다르며 result 횟수가 requested보다 큰 것이 정상 |
| `mf2_camera_init_started` | Controller `_startEngines()` | 카메라/포즈 모델/TTS 초기화 묶음을 시작하기 직전. 주로 카운트다운 prewarm에서 발생 |
| `mf2_camera_init_completed` | `_startEngines()` 끝 | `poseInitialization` 다음 `voiceInitialization`까지 await한 뒤 전송. 첫 유효 인체 프레임이나 보정 완료를 보장하지 않음 |
| `mf2_calibration_started` | Controller `start()` | 준비 세션 상태를 만든 뒤, DB create/journal/필요 시 엔진 시작/영상 시작보다 먼저 전송. 실제 보정 계산은 prewarm에서 이미 시작됐거나 완료됐을 수 있음 |
| `mf2_calibration_completed` | `_logCalibrationCompleted()` | 준비 중 만든 profile 재사용 또는 `_onPoseFrame()`의 `RepEventType.calibrated`. 같은 시도에서는 한 번 |
| `mf2_workout_started` | `_logCalibrationCompleted()` 내부 | 계획이 있고 아직 로그를 보내지 않았을 때 보정 완료와 함께 전송. 사용자가 실제로 몸을 움직였다는 뜻이 아님 |
| `mf2_first_rep_detected` | `_onPoseFrame()`의 `RepEventType.started`, `_handleRepCompleted()` → `_logFirstRep()` | **첫 반복 동작 시작에서도 전송**. 실제 카운트 1의 보장 아님. 플랭크에서는 유지 동작 진입 의미 |
| `mf2_workout_completed` | `_finishCompleted()` → `workoutComplete()` | `completed && !interrupted && totalReps>0`, 저장 성공 후. 일반 목표 완료 외 챌린지의 유효한 조기 종료도 포함 |
| `mf2_second_workout_completed` | `_logCompletionMilestone()` | **현재 종목 DB의** 완료·비중단 세션 개수가 정확히 2일 때. 전 종목 통합 두 번째·다음 날 복귀가 아님. session ID 없음 |

대표 실행 코드: [준비 launcher](/Users/nam/projects/motionfit/lib/features/squat/presentation/workout_preparation_launcher.dart), [카운트다운](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/workout_countdown_screen.dart), [세션 컨트롤러](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart), [반복 감지기](/Users/nam/projects/motionfit/lib/features/squat/domain/services/rep_detector.dart).

푸시업은 `lib/features/pushup/`, 플랭크는 `lib/features/plank/workout/`의 대응 파일에서 같은 AnalyticsService를 호출한다. 플랭크의 `totalReps/target_reps`는 사실상 유효 유지 초를 담는다. 3종목을 합친 현 표만으로 스쿼트 보정의 문제를 확정할 수 없다.

### 3.3 퍼널에 생기는 예외

- `recover()`는 원본 DB 세션을 이어가지만 start 탭에서는 새로운 분석 ID를 만든다. 원본 세션에 reps가 있으면 `_firstRepLogged`, `_workoutStartedLogged`를 true로 복구한다. 따라서 해당 시도에 보정 완료가 있어도 workout_started/first_rep가 없을 수 있다. `recover()`에는 일반 `start()`의 calibration_started 직접 호출도 없다. `161회 완료`와 `155회 시작` 차이를 곧바로 오류로 볼 수 없는 이유다.
- 카메라 재시도·보정 재시도는 새 start 탭이 아니므로 `oncePerSession`이 개별 시도들을 숨긴다. 실패 후 성공은 한 session 안에 함께 존재할 수 있다.
- guide에서 나가면 `before_first_rep`, countdown에서 나가면 `camera_initialization`으로 기록한다. 실제 단계보다 넓은 취소 분류다.
- 강제 종료에는 일반 취소 이벤트가 남는다고 보장할 수 없다. onboarding_abandoned도 다음 온보딩 진입 때 이전 미완료 기록을 보고 전송하므로 다시 오지 않은 사용자는 포착하지 못한다.

## 4. 운동 시작 전 UX와 calibration 심층 분석

### 4.1 현재 진입 경로

첫 설치는 3페이지 온보딩 → iOS ATT 요청 가능 → 홈 → 시작 → 카메라 권한 안내/OS 요청 → 최초 카메라 가이드 → 5초 카운트다운 → 활성 카메라 화면의 보정 → 실제 운동 순서다. 허용된 권한과 `cameraGuideSeen`은 다음 진입 때 안내를 생략한다. 기본 스쿼트 계획은 이미 **1세트 × 5회**이므로 첫 계획이 과도하게 크다고 주장할 근거는 없다.

| 구간 | 확인된 구현 | 사용자 현상 / 판정 |
|---|---|---|
| 홈 시작 | recoverableSession이 `AsyncData`여야 새 시작 가능 | 로컬 DB 로딩/오류가 시작 버튼에 영향. 일반적인 네트워크 구독 검사로 막는 코드는 없음 |
| 온보딩 완료 | 완료 이벤트·설정 저장 뒤 ATT를 await, 그 후 홈 이동 | 완료 이벤트는 홈 도달 보장 아님. ATT 부담은 iOS 구간별 측정 필요 |
| 카운트다운 | 5초 타이머 + prewarm 동시 실행; `_begin()`은 prewarm을 await | **미리보기 Texture가 없다.** 사용자는 몸이 잡히는지 볼 수 없음 |
| 느린 준비 | `_seconds=1`에서 `_starting=true`, 타이머 취소 후 await | 로딩 단계/진행 설명 없이 1이 남아 멈춘 것으로 보일 수 있음 |
| 카메라/음성 | 포즈 25초 timeout, TTS 8초 timeout, 동시에 시작 | 음성 구성 종료도 기다린 후 camera completed. 음성이 느리면 카메라 지연으로 오인 |
| prewarm 프레임 | 최소 0.75초, 추론 6프레임, 인체를 본 적 있으면 연속 3프레임; 최대 추가 4초 대기 | 안정된 추론 준비와 보정은 다른 조건. no-person도 prewarm 준비 통과 가능 |
| 영상 리뷰 | 기본 켜짐; `start()`에서 `_startWorkoutVideoIfAvailable()` await | 선택 기능이 운동 활성화 앞에 있음. Dart 수준 timeout 없음; 네이티브 콜백 지연 시 준비가 붙잡힐 수 있음 |
| 실제 운동 진입 후 | TTS enqueue는 unawaited | 음성 안내를 끝까지 들어야 운동이 시작되는 게이트는 없음 |

근거: [홈](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/squat_home_screen.dart), [온보딩](/Users/nam/projects/motionfit/lib/features/onboarding/presentation/onboarding_screen.dart), [기본 계획](/Users/nam/projects/motionfit/lib/features/squat/domain/models/workout_plan.dart), [기본 설정](/Users/nam/projects/motionfit/lib/features/settings/domain/user_preferences.dart), [컨트롤러](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart).

별도 cold-start 후보도 있다. `main()`은 `runApp()` 이전에 로컬 이관, 설정 로딩, Analytics 초기화와 appOpened 전송을 await한다. 앱 첫 화면 도달 시간을 계측하지 않아 영향은 알 수 없다. 구독 확인을 운동 시작 앞에서 기다리는 구현은 발견하지 않았다.

영상 시작은 iOS의 `pendingVideoStartCompletion`을 첫 영상 프레임 append 후 해제하며, Android는 `VideoRecordEvent`로 완료한다. 따라서 예외 처리만으로 ‘프레임/콜백이 오지 않는 대기’를 해결할 수 없다. 실제 발생 빈도는 계측되지 않았다. [iOS 엔진](/Users/nam/projects/motionfit/packages/motionfit_pose/ios/Classes/MotionfitPoseEngine.swift), [Android 엔진](/Users/nam/projects/motionfit/packages/motionfit_pose/android/src/main/kotlin/com/namslab/motionfit_pose/MotionfitPosePlugin.kt)

### 4.2 보정 완료 조건

공통: timestamp/sequence가 전진하는 프레임, 1명, 33개 landmark, tracking 또는 partialBody, 유효 관절/몸 크기 계산, 종목별 confidence 이상이 필요하다. **33개 landmark 배열이 있다는 것과 전신 모든 관절이 선명하다는 것은 다르다.** 스쿼트는 한쪽 어깨–골반–무릎이 유효하면 되고 발목 관측이 없어도 보정할 수 있다.

| 조건 | 스쿼트 | 푸시업 | 플랭크 |
|---|---|---|---|
| 최소 관측 시간 | 1.2초 | 1.2초 | 1.2초 |
| 최소 유효 샘플 | 24 | 24 | 24 |
| confidence floor | 0.35 | 0.25 | 0.35 |
| 기본 자세 | 관측 가능한 무릎 ≥145°, hip ≥145° | 팔꿈치 ≥125°, 어깨–골반–발목 body line ≥125° | 무릎 ≥145°, hip ≥150°, torso 45–135° |
| 수직 위치 최대 범위 | hipY 0.03 | shoulderY에 해당하는 필드 0.025 | hipY 0.03 |
| 각도 최대 범위 | 무릎/hip 각각 12° | 팔꿈치/body line 각각 10° | 무릎/hip 각각 12° |

푸시업은 기존 스키마를 재사용해 `kneeAngle`이 팔꿈치, `hipAngle`이 body line, `hipY`가 어깨 위치를 뜻한다. 이를 무릎 125° 조건으로 해석하면 잘못된 분석이다.

근거: 종목별 [스쿼트 accumulator](/Users/nam/projects/motionfit/lib/features/squat/domain/services/calibration_accumulator.dart), [푸시업 accumulator](/Users/nam/projects/motionfit/lib/features/pushup/domain/services/calibration_accumulator.dart), [푸시업 feature extractor](/Users/nam/projects/motionfit/lib/features/pushup/domain/services/pushup_feature_extractor.dart), [플랭크 accumulator](/Users/nam/projects/motionfit/lib/features/plank/workout/domain/services/calibration_accumulator.dart), 각 디렉터리의 detection_config와 pose_frame.

`progress = min(관측시간/1.2초, 샘플수/24)`. 자세/신뢰도 조건 위반이면 `_restart()`로 모든 샘플을 지우며, `rep_detector.addFrame()`에서도 invalid pose/metrics이면 `_calibration.interrupt()`를 호출한다. 24개와 1.2초를 채운 후 범위가 기준을 넘으면 현재 1프레임만 남기고 다시 시작한다. 이미 보정된 운동 중에는 짧은 추적 손실에 대한 별도 hold/reacquire가 있지만 보정 누적에는 같은 완충이 없다.

### 4.3 얼마나 걸리는가

**실제 평균·p50·p95는 이 집계표로 계산할 수 없다.** 코드상 정상 조건의 하한만 계산할 수 있다.

- 일정한 유효 샘플 빈도를 f FPS라 하면 첫 샘플 이후 대략 `max(1.2, 23/f)`초. 30/24/20 FPS에서는 약 1.2초 이상, 15 FPS에서는 약 1.53초, 10 FPS에서는 약 2.3초다. 실제 유효 프레임 빈도는 target FPS보다 낮을 수 있다.
- 카운트다운에서 이미 성공하면 이후 추가 보정 대기 없이 profile을 사용한다. 정상 카메라 준비가 5초 안에 끝나면 진입은 대체로 이 5초에 흡수될 수 있다. 이는 실측 평균이 아니다.
- 초기화가 느리면 대략 `max(5초, max(포즈 초기화≤25초, TTS 구성≤8초)+prewarm≤4초)` 뒤 DB/영상 준비 등이 더해진다. 최대 총시간은 이 수식으로 보장되지 않는다.
- 정식 calibrating 상태는 **45초**에 timeout, **12초마다** 안내한다. 재시도하면 다시 새 45초 창이다. prewarm/DB/영상 대기는 이 45초에 포함되지 않으므로 전체 준비가 45초 이내라고 볼 수 없다.
- 현재 elapsed bucket은 under_3s/3_10s/11_30s/over_30s뿐이다. 게다가 성공 시간은 accumulator의 최초 유효 metrics부터 마지막 유효 metrics까지여서 최초 no-person 구간이 빠질 수 있다. 준비 중에 생긴 시간도 포함될 수 있어 이벤트 타임스탬프 차이와 다르다.

### 4.4 엄격한가, 안내는 충분한가

‘신뢰도 임계값이 무조건 너무 높다’는 결론은 근거가 부족하다. 스쿼트 0.35, 푸시업 0.25이고 한쪽 관측도 허용한다. 오히려 **짧은 검출 공백에 전부 초기화되는 방식**, **최댓값–최솟값 범위로 전체 윈도우를 기각하는 방식**, **거리/화면 크기와 연결된 고정 좌표 범위**가 점검 대상이다. `hipY` 0.03은 실제 신체 3cm가 아니라 정규화 이미지 좌표 범위다.

현재 안내는 noPerson/lost, partialBody, multiplePeople을 구분하고 기본 자세 문구·진행바를 보여준다. 그러나 실제 실패 원인인 ‘각도 부족’, ‘신체 흔들림’, ‘신뢰도 부족’, ‘유효 프레임 부족’, ‘프레임 공백’은 accumulator 밖으로 전달하지 않는다. 화면 trackingState도 native frame 상태이고 detector의 유효 판정과 다를 수 있다. 사용자는 몸이 보이는데도 왜 0%인지 모를 수 있다. 오버레이의 confidence 0.60 기준은 색상 피드백용이며 보정 통과 기준과 다르다.

스쿼트의 ‘어깨부터 무릎’, 푸시업의 ‘한쪽 팔 전체·어깨부터 발목’, 플랭크의 ‘전신 측면’ 안내는 종목에 맞게 존재한다. 특정 거리(m)를 반드시 만족해야 하는 직접 조건은 발견하지 않았다. 방향도 스쿼트는 측면 권장이지 전면을 일괄 차단하는 조건은 아니다. Native 모델 `numPoses=1`이라 multiplePeople 분기는 제공 프레임에서 거의 발생하지 않을 수 있으므로 실제 다인 판별 능력과 안내를 동일시하지 않는다.

### 4.5 정확도를 보존하며 줄이는 방법

1. 카운트다운부터 기존 카메라 preview/overlay를 보여주고 준비 상태를 공유한다. 중복 엔진 초기화를 추가하지 않는다. 숫자 1 대기를 ‘카메라 연결 중/자세 확인 중’으로 바꾼다.
2. detector/accumulator에서 실패 이유 enum을 반환하고 가장 먼저 필요한 한 가지 행동을 안내한다. 상태 변화에만 기록하고 매 프레임 Analytics를 보내지 않는다.
3. 짧은 관측 공백은 샘플을 잠시 유지하되 **공백 시간을 안정 시간으로 계산하지 않고**, 유효 프레임 수·좌표 연속성·자세 검증은 유지하는 실험을 한다. 장시간 공백·카메라 변경·신체 위치 급변은 초기화한다.
4. 안정 범위의 robust 통계/슬라이딩 윈도우 또는 충분히 안정적인 pose의 빠른 경로는 후속 실험이다. corpus와 실기기에서 잘못된 baseline·첫 반복 오검출을 확인한 뒤 변경한다. 현재 분석에서는 임계값을 바꾸지 않았다.
5. TTS 완료와 옵션 영상 시작을 카메라 준비 완료의 필수 조건에서 분리한다. 영상은 제한 시간 내 준비되지 않으면 그 세션의 영상 리뷰만 중지하고, 늦은 콜백은 generation token으로 무시한다. 단순 `Future.timeout`만 추가하고 native 작업을 방치하지 않는다.

baseline 각도, hip/shoulder 위치, bodyScale, motionNoise를 실제 rep detector가 사용한다. 영구 저장 profile을 카메라 위치가 바뀐 다음날 무조건 재사용하거나 상수 profile로 건너뛰면 오검출 위험이 있다. **카메라 화면 안에서 자동으로 짧게 보정하는 흐름은 가능하지만, 현재 detector에서 보정 자체를 지우는 것은 작은 변경이 아니다.**

## 5. 운동이 시작된 이후의 품질

56명 중 54명에 동작 시작 이벤트가 있다는 것은 긍정적인 신호다. 그러나 ‘96.4%에서 정확한 첫 반복 성공’은 아니다. 스쿼트는 2개 이상의 하강 신호와 90ms dwell에서 started를 내고, 이후 의도 깊이·방향 전환·기립 복귀 등을 만족해야 completed가 나온다. 푸시업도 시작과 반복 완료가 구분되며, 플랭크는 350ms 진입 후 1초 checkpoint를 센다.

완료는 운동 시작 사용자 대비 `39/56 = 69.6%`, 이벤트 수 대비 `94/155 = 60.6%`의 주변 비율이다. 나머지 이탈은 무시할 크기가 아니다. `saveForLater()`의 interrupted는 나중에 복구할 수 있는 저장이며, 완전 포기와 다르다. 챌린지 종료 경로는 1회 이상에서 `finishContinuousWorkout()`을 통해 목표 전체를 채우지 않고도 완료가 된다. 완료 이벤트에 `completion_reason`, `actual_units`, `target_units`, `target_achieved`가 필요하다.

코드에는 세트별 저장, 저장 실패 재시도, 추적 복구, 자동 휴식/다음 세트, 로컬 결과 분석·영상 리뷰가 있다. 현재 근거는 **콘텐츠 전면 개편보다 준비 구간을 먼저 개선**하는 쪽을 지지한다. 다만 생존자 편향 때문에 운동 인식이 모든 기기에서 정상이라고 결론 내릴 수 없다.

`mf2_workout_detection_summary=94회/39명`이 완료 이벤트와 정확히 같다. 현재도 `_finishCompleted`와 `endInterrupted`에는 summary가 있으나, **0회 취소/실패의 `discardInvalidSession()`과 saveForLater에는 summary가 없다.** 가장 필요한 진입 실패자의 인식 진단이 빠지는 구조다.

기기 관련해서는 Android CPU 추론, full 모델 시작 후 45 latency 샘플을 모아 FPS 조정, 평균 65ms 이상에서 lite 전환이 있다. 영상 녹화 중에는 모델 전환을 피하므로 늦게 발견한 성능 저하가 유지될 수 있다. 특정 SM-S926N/iPhone 모델의 문제가 있다는 증거는 없다. 사용자 수 26명은 실패율이 아니며 OS·기기·종목·버전·전후면별 failure_reason과 실측 FPS를 비교해야 한다.

## 6. 리텐션과 챌린지

### 6.1 내일 다시 열 이유가 존재하는가

**존재하지만 완료 흐름에서 전달·설정되는 비율이 낮고 종목별로 분절되어 있다.**

| 항목 | 실제 구현 | 남은 문제 |
|---|---|---|
| 오늘 기록/연속 운동일 | HomeScreen의 오늘 기록, 주간 스트립, RetentionMetrics | 일반 홈은 주로 과거/오늘 실적. 내일 해야 할 행동과 active challenge 바로가기 없음 |
| 결과 보상 | 완료 hero, 스트릭, 첫 운동 표시, 폼 강점·점수·타임라인, 진동 | 일반 결과의 주 CTA는 완료→홈. 다음 목표/챌린지 CTA 없음 |
| 성장 기록 | 통합 달력, 3종목 기록, Form Progress/Body Progress 저장 기능 | 기능을 새로 만들 필요 없음. 첫 결과에서 다음 촬영/비교 의미를 연결하는 계측·행동은 약함 |
| 다음 운동 | 저장된 마지막 계획과 챌린지 오늘 목표 | 일반 완료 다음날 추천 계획을 자동 연결하지 않음 |
| 알림 | 완료 시각의 매일 알림; 설정에서 요일별 알림; 20시 스트릭 위험 알림 | opt-in 필요. 기본 전 요일 off. prompt 단순 무시는 defer로 저장 안 됨 |
| 챌린지 | 7일 증가 목표/기간 누적 목표, 오늘 남은 양, 내일 목표, 진행/완료 | 추천이 탭 안에 있고 결과에서 직접 제안하지 않음 |
| 두 번째 운동 | 종목별 완료 2회 milestone | 실제 다음 날 복귀나 전 종목 두 번째 운동을 측정하지 않음 |

### 6.2 리마인더의 구체적 결함

일반 결과의 `_loadPostCompletionActions()`는 활성 알림이 없을 때, 첫 완료 또는 ‘첫 제안을 미뤘고 정확히 3번째 완료’인 경우만 제안한다. `markReminderPromptShown()`은 노출 횟수 상태만 저장하고 `postWorkoutReminderDeferred`는 기본 false다. ‘나중에’를 눌러야 defer=true가 된다. **카드를 보았지만 완료 버튼으로 나간 사용자에게는 다음 기회가 보장되지 않는다.**

제공 데이터: shown 36명, accepted 1명, declined 5명. 단순한 집계 비율은 수락 2.8%다. 나머지 30명을 동일 노출 코호트의 무응답이라고 확정할 수는 없지만, 무응답 경로를 우선 다룰 근거는 충분하다. enabled 8명/30회는 설정 경로와 요일별 켜기를 포함하므로 ‘결과 제안으로 8명이 알림을 켰다’고 해석하면 안 된다.

추가로 결과 화면의 `PopScope(canPop:false)`와 완료 버튼은 `_postCompletionActionsLoading` 동안 막힌다. 이 안에서 알림 초기화·환경 갱신을 await한다. 알림은 부가 기능이므로 이 작업이 결과 화면 탈출을 막지 않도록 분리하는 것이 적절하다.

`NotificationService.initialize()`는 `onDidReceiveNotificationResponse`를 등록하지 않고, 저장소에서 `getNotificationAppLaunchDetails()` 소비도 발견되지 않았다. `motionfit://workout`, `motionfit://challenge/{종목}` payload는 저장하지만 읽어 라우팅하지 않는다. 따라서 ‘알림 탭 → 해당 종목 오늘 운동/챌린지’ 경로와 알림 기여 리텐션 측정이 없다. 앱 선택 종목도 현재 메모리에서 squat 기본값으로 시작한다.

근거: [결과 화면](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/workout_summary_screen.dart), [설정 컨트롤러](/Users/nam/projects/motionfit/lib/features/settings/application/preferences_controller.dart), [알림 컨트롤러](/Users/nam/projects/motionfit/lib/features/settings/application/reminder_controller.dart), [알림 서비스](/Users/nam/projects/motionfit/lib/core/notifications/notification_service.dart), [종목 선택](/Users/nam/projects/motionfit/lib/features/exercise/application/exercise_selection.dart).

### 6.3 챌린지는 고립 기능인가

데이터 연결은 고립되어 있지 않다. `ChallengeController.calculateProgress()`는 같은 종목의 유효 완료 세션 중 challenge 생성 이후 시작한 운동을 기간별로 합산한다. 챌린지 경로에서 시작했는지 여부만으로 필터하지 않으므로 **일반 운동도 기존 챌린지에 반영된다.** 세션 0회·중단은 `WorkoutSessionPolicy.canUpdateChallenge()`에서 제외한다.

`challenge_tab_viewed=115명 → selected=30명 → started=15명 → challenge_workout_started=15명`이다. 추천 노출은 19명뿐이다. 이는 모두 주변 집계다. `challenge_workout_started`는 실제 pose 시작이 아니라 **권한 확인 전 launcher**에서 보내므로 챌린지 시작자 100%가 실제 운동에 들어갔다고 볼 수 없다.

UX 연결은 약하다. 첫 완료 후 탭 배지가 생기지만, 일반 결과에는 추천 CTA가 없다. 추천 노출은 `active==null && hasWorkoutHistory && !dismissed` 조건으로 챌린지 탭에 들어온 뒤에만 생긴다. 새 challenge의 기본 알림도 false다. 챌린지 운동 완료는 850ms 뒤 일반 결과 화면 대신 광고→챌린지로 돌아가므로 결과 화면의 알림 제안이 실행되지 않는다.

7일 챌린지는 `firstDayGoal + index*5`로 매일 증가한다. 진행률은 일별 `min(목표, 실제)` 합계/총 목표여서 앞날 초과 수행으로 놓친 날을 메울 수 없다. 한 날을 놓치면 최종 100%에 도달할 수 없는 구조이며 기간이 지나면 ended가 된다. 실패 원인 데이터 없이 난도를 일괄 변경하지 말고, 초보에게 ‘완벽한 7일’만 성공으로 제시하는지와 재시작/오늘 복귀 문구를 점검한다.

근거: [챌린지 컨트롤러](/Users/nam/projects/motionfit/lib/features/challenges/application/challenge_controller.dart), [챌린지 화면](/Users/nam/projects/motionfit/lib/features/challenges/presentation/challenge_screen.dart), [활성 운동 화면](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/active_workout_screen.dart).

### 6.4 종목별 분절

스쿼트·푸시업·플랭크는 별도 DB다. 현재 second milestone, 홈/결과 RetentionMetrics는 종목별이고 알림 제안 이력은 공용 preferences다. ‘스쿼트 1회 + 푸시업 1회’는 second 이벤트가 아닐 수 있고, 다른 종목의 첫 알림 기회는 공용 노출 상태로 막힐 수 있다. 반면 광고 자격·앱 수준 일부 알림에는 이미 `combinedWorkoutMetricsProvider`가 있다. 이를 재사용해 앱 전체 운동일/완료 횟수 기준을 통일할 수 있다.

## 7. 광고: 요청량보다 첫 성공 보호가 우선

### 확인된 사실

- `1,646/174 = 9.46`회 요청/요청 경험 총 사용자. 표의 9.51은 활성 사용자당 수치여서 분모가 다르다.
- `102/1,646 = 6.2%`는 단순 이벤트 비율이다. 광고 형식·버전·사용자군이 섞여 있고, matched request 수가 없어 fill/match rate 또는 AdMob show rate가 아니다. 공식 show rate는 impressions/matched requests다. [AdMob 정의](https://support.google.com/admob/table/16327896?hl=en)
- request 이벤트는 실제 `NativeAd.load`/`InterstitialAd.load` 직전에 찍힌다. 단순 화면 build마다 무조건 전송하는 구조는 아니다. loading/loaded/ad 참조로 중복 요청을 막는다.
- 로드 실패 재시도는 5초→15초→30초→60초, 이후 **60초 간격이 계속 반복**된다. 화면을 새로 만들면 native retry 상태도 새로 시작한다. 상한과 앱 foreground/운동 중 상태를 충분히 반영하지 않는다.
- native는 홈·챌린지·설정 하단, 기록/상세/rep review 및 플랭크 결과에 존재한다. 실제 placement가 모두 `bottom_navigation`으로 기록되어 구분할 수 없다.
- 일반 start/preparation 경로에 광고 show나 구독 확인 await는 없다. 다만 앱 수준 광고 준비·재시도가 운동 중에도 남아 CPU/네트워크를 사용할 가능성은 있으며 실측 영향은 모른다.
- `adLoaded/adShown/adFailed/adDismissed/adClick` 메서드는 현재 no-op다. 실패 코드나 로드 성공 데이터가 Analytics에 없어 저노출 원인을 분해할 수 없다.

### 명확한 UX 문제

`minimumInterstitialCompletedWorkouts=1`: 첫 완료부터 자격이 있다. 10분 cooldown은 첫 성공을 보호하지 않는다. `showPostWorkoutInterstitial()`은 통합 기록 조회→동의 요청→SDK 초기화→전면광고 로드를 기다린다. `showInterstitialIfAvailable`이라는 이름과 달리 없는 광고도 최대 8초 기다린다. 동의의 UMP 20초 timeout 등은 별도이며 초기화·동의 UI를 포함한 전체 상한은 8초가 아니다.

또한 앱 `_runPrivacyConsentRefresh()`는 completedCount<1일 때 `ad_skipped_by_policy(format:all, before_first_workout)`를 보내지만 **return 없이 동의·광고 초기화를 계속 수행**한다. native 자격은 0회부터다. 따라서 이 이벤트를 ‘실제로 모든 광고를 생략한 사용자’로 해석하면 틀린다.

### 낮은 노출의 원인 판정

코드에서 확인된 원인 후보는 재시도 누적, preload 후 사용하지 않음, 화면 이탈/재생성, 정책 cooldown, 동의 미완료다. no-fill·AdMob serving 제한·특정 국가 수요·ad unit 설정이 실제 주원인인지는 자료가 없다. `$0.55`와 102회만으로 판단할 수 없다. 기존 `motionfit_ads_log=835회/9명`은 현 앱 호출이 아니므로 v2 요청과 합산하지 않는다.

가장 작은 수정은 첫 유효 완료의 전면광고 생략, 결과/챌린지 이동 시 ready 광고가 없으면 즉시 통과, 광고 재시도에 foreground/상한 조건 적용이다. 법정 동의를 우회하는 것이 아니라 동의·광고 준비를 운동 완료 CTA의 필수 대기에서 분리하는 것이다.

근거: [정책](/Users/nam/projects/motionfit/lib/core/ads/ad_eligibility.dart), [광고 서비스](/Users/nam/projects/motionfit/lib/core/ads/ad_service.dart), [완료 광고 경로](/Users/nam/projects/motionfit/lib/core/ads/post_workout_interstitial.dart), [native 광고](/Users/nam/projects/motionfit/lib/core/ads/bottom_native_ad.dart), [앱 동의 경로](/Users/nam/projects/motionfit/lib/app/app.dart), [동의 서비스](/Users/nam/projects/motionfit/lib/core/privacy/privacy_consent_service.dart).

## 8. Analytics 문제와 실제 UX 문제를 분리

| 문제 | 분류 | 영향 |
|---|---|---|
| 종목/단위 파라미터 없음 | 측정 결함 | 스쿼트와 팔굽혀펴기·플랭크 실패를 분리 못함 |
| first_rep가 동작 시작 | 측정 의미 불일치 | 첫 카운트 성공률 과대 해석 |
| second가 종목별 exact 2 | 측정 의미 불일치 | 전 종목 두 번째·다음 날 유지율과 다름. 종목별 최대 여러 번, 기록 삭제/이관 영향 가능 |
| calibration 이벤트 시작점과 계산 시작점이 다름 | 측정 의미 불일치 | 시간·퍼널 순서가 실제 처리와 불일치 |
| 실패자 detection summary 부재 | 측정 결함 | 성공자만 보고 detector 품질을 평가하게 됨 |
| 카메라 completed가 TTS await 뒤 발생 | 측정 의미 불일치 + UX 대기 | 카메라/음성 병목 혼동 |
| 카메라/guide screen_name 동일 | 측정 결함 | 권한 안내와 배치 안내 구분 어려움 |
| 재시도 once/session, 종료 terminal dedup | 의도된 중복 방지 + 상세 부족 | event count는 retry 횟수가 아니며 실패 뒤 성공도 가능 |
| setup/challenge viewed가 init/build 단위 | 측정 범위 한계 | StatefulShell 보존 탭의 매 재진입 횟수와 같지 않음 |
| legacy 수십 이벤트 혼재 | 버전/계측 혼재 | 지금도 옛 음성 trial/paywall/ad gate가 실행된다고 판단하면 오류 |
| reminder scheduling/failed/disabled no-op | 측정 결함 | 권한 허용 이후 예약 실패·해지·알림 유입 확인 불가 |
| ad skipped 기록 후 초기화 진행 | 잘못된 이벤트 의미 | 정책으로 차단한 양 과대 해석 |
| 미리보기 없는 준비, 무효 프레임 reset | 실제 UX/로직 | 위치 조정 어려움·보정 반복. 영향 크기는 추가 측정 필요 |
| 결과 알림 무응답 소실/광고 await | 실제 UX/로직 | 다음 행동 연결 누락·완료 후 이동 지연 |

현 소스에 없는 `workout_started`, `first_rep_counted`, `workout_completed` 등 비접두사 이벤트는 자동으로 mf2와 합치면 안 된다. `motionfit_app_open`은 이전 앱과 연속성을 위해 의도적으로 유지했고 `screen_view`는 Flutter 수동 화면명과 native 화면 클래스가 공존할 수 있다. `MotionFit` 3.3천 + MainActivity/FlutterViewController 등은 서로 다른 사용자 수가 아니다. SDK 자동 수집 여부는 SDK/콘솔 설정까지 확인해야 정확하다.

추가 주의: `_logWorkoutV2`는 null 문맥이면 조용히 버리고, 재시작에서는 새 UUID로 기존 문맥을 교체한다. launcher 재진입 방어와 시도별 terminal 일관성을 점검할 가치는 있지만 실제 중복 탭 빈도는 알 수 없다. 분석 전에는 이벤트 중복을 모두 버그로 간주하지 않는다.

## 9. DAU 100을 위한 수정 우선순위

아래 KPI 목표치는 **실험의 합격 기준 제안**이며 달성 예측이나 업계 기준이 아니다. 현재 계측 정의를 고친 후 같은 정의로 baseline을 다시 만든다.

### P0-1. 준비 과정의 미리보기·원인 안내·선택 작업 대기 분리

- **문제:** 보정 중 시각적 자기 위치 확인 불가, 숫자 1 정체, 정확한 reset 이유 부재. 옵션 TTS/영상 준비가 운동 활성화 앞에 있음.
- **데이터 근거:** start 143 → camera completed 108 → calibration completed 56명. camera failed 15명, calibration failed 6명. 주변 차이이며 원인별 기여도는 미확정.
- **코드 근거:** CountdownScreen `_begin/build`, Controller `_startEngines/_startWorkoutVideoIfAvailable`, Accumulator `add/_restart`, Detector `addFrame`.
- **현상:** 폰을 놓고 물러난 사람이 몸이 잡히는지 모르거나, 준비 실패를 반복하고 나감.
- **DAU/리텐션 영향:** 첫 유효 운동을 경험하는 사용자 기반 확대. 세 항목 중 가장 우선할 활성화 가설.
- **수정 방법:** 기존 preview를 준비 화면부터 공유, 단계별 상태 표시, 짧은 원인 안내, TTS/영상 준비에 독립 상태·제한시간·실패 시 통과. 감지 임계값은 우선 유지. 짧은 gap 완충은 원인 분포 확인 후 별도 작은 실험.
- **난이도:** 중간. preview 수명주기/화면 이동/늦은 callback 검토 필요. 임계값 변경까지 합치지 않음.
- **Firebase KPI:** 같은 `attempt_id`의 start→camera ready→첫 유효 pose→calibration ready→**첫 count commit** 전환; 전체 및 단계별 p50/p90/p95; calibration reset reason, zero-count exit. 초기 기준 예: camera start→ready 95%, 유효 pose→ready 75% 이상, 준비 p90 감소. 실제 baseline 후 조정.

### P0-2. 결과에서 기존 내일 목표·챌린지·리마인더로 연결

- **문제:** 일반 결과의 다음 행동 없음, prompt 무응답 재제안 누락, 알림 목적지 처리 없음. challenge 결과는 공용 제안 경로 우회.
- **데이터 근거:** 완료 39명, second milestone 16명(리텐션 정의 아님), 주간 6.9%, reminder shown 36/accepted 1명, challenge recommendation 19명.
- **코드 근거:** SummaryScreen `_loadPostCompletionActions/_finish`, preferences `markReminderPromptShown`, NotificationService `initialize`, ChallengeScreen 추천 guard, ActiveWorkoutScreen `_returnToChallenge`.
- **현상:** 첫 운동은 끝냈지만 내일 무엇을 할지 정하지 못함. 알림 탭에도 해당 종목/오늘 목표로 곧바로 연결되지 않음.
- **DAU/리텐션 영향:** 활성화 사용자의 다음 날 재방문과 반복 운동일 증가. DAU 확대에 직접 필요한 경로.
- **수정 방법:** 결과의 기존 완료 CTA 인근에 활성 챌린지 내일 목표 또는 기존 가벼운 챌린지 제안 하나를 연결. 일반/챌린지 완료 후 공용 후속 처리. 무응답을 dismiss/미정으로 저장하고 다음 적절한 완료에서 한 번만 재제안; OS 권한 거절은 반복 강요하지 않음. 알림 탭 cold/warm 경로에서 종목 선택+목적지 라우팅. 통합 완료 횟수/운동일 provider 재사용. 완료 버튼은 알림 갱신과 독립.
- **난이도:** 중간. 기존 기능 연결·상태 수정 중심이며 전체 UI 재설계 불필요.
- **Firebase KPI:** 첫 유효 완료 코호트의 D1/D7 앱 복귀, 7일 내 **다른 날짜 두 번째 운동 완료**, recommendation→challenge 실제 첫 count, prompt accept→permission→scheduled→opened→count. 첫 실험 목표는 수락 비율 10% 이상 및 성숙 코호트 D7 개선 방향 확인.

### P0-3. 첫 완료 보호와 광고 대기 제거

- **문제:** 첫 완료부터 전면광고, ready가 아니어도 동의·초기화·최대 8초 load 대기.
- **데이터 근거:** 광고 수익 $0.55, 102 impressions/23명, 완료 39명. 적은 수익을 위해 첫 성공 전환에 대기가 존재하나 실제 피해량은 미확정.
- **코드 근거:** `minimumInterstitialCompletedWorkouts=1`, `showPostWorkoutInterstitial`, `_waitForInterstitial`, Summary `_finish`, Active `_returnToChallenge`.
- **현상:** 끝났는데 화면 이동이 늦음. 챌린지 진행 결과를 보기 전에 광고/동의를 기다릴 수 있음.
- **DAU/리텐션 영향:** 첫 성공 경험 보호, 두 번째 행동·다음날 복귀 저해 요인 제거. P0-1/2보다 전체 영향 확신은 낮지만 수정 비용이 작음.
- **수정 방법:** 통합 첫 유효 완료는 전면광고 건너뛰기; 이후에도 consent/SDK/광고 ready가 아니면 완료 이동은 즉시 통과. 백그라운드 preload만 유지하고 정책을 실제 차단 조건과 맞춤.
- **난이도:** 낮음~중간. 늦은 광고 callback이 떠난 화면에 표시되지 않게 방어 필요.
- **Firebase KPI:** 완료 CTA→목적 화면 지연, 첫 완료 직후 종료, 첫 완료 코호트 D1/D7, 다음 유효 운동. 광고 로드 대기 0ms를 코드 정책으로 보장; 화면 이동 자체는 별도 측정.

### P0-공통. 세 변경과 함께 측정 정의 바로잡기

- **문제:** 종목 혼재, 첫 동작/첫 카운트 혼동, 성공자 진단 편향, second 의미 불일치.
- **데이터 근거:** calibration 161 vs workout start 155회, detection summary=completion=94회, second=18회/16명.
- **코드 근거:** AnalyticsService, WorkoutAnalyticsSession, 각 Controller `_logFirstRep/_logCompletionMilestone/discardInvalidSession`.
- **현상:** 사용자에게 직접 보이는 기능 문제는 아니지만 팀이 잘못된 원인을 최적화할 위험.
- **DAU/리텐션 영향:** 직접 상승 효과를 주장하지 않는다. 나머지 P0의 실제 효과를 판단하는 선행 조건이다.
- **수정 방법:** `exercise_type`, `target_unit`, `attempt_id`, `calibration_attempt_index`, `entry_point`를 일관되게 추가. 새 의미는 새 이벤트/계측 revision으로 구분. 실제 첫 count는 첫 rep 저장 성공 후 한 번, second는 통합 local 완료 milestone 및 다른 날짜 여부로 구분. 모든 종료 경로에 공통 준비 진단을 남기고 앱 종료 누락은 다음 시작에서 상태 정합성 보완. 실패 진단에는 저장소를 새로 무겁게 조회하지 않음.
- **난이도:** 중간. 3종목 동일 수정 필요.
- **Firebase KPI:** 필수 파라미터 누락률, attempt당 once/terminal 중복률, terminal 미관측률, 종목별 event order, 실패자 진단 커버리지. `analytics_schema=2`만으로 같은 의미라 가정하지 않도록 revision도 필터.

### P1-1. 보정 reset 완충과 저성능 경로의 제한적 개선

- **문제:** 한 프레임 손실로 baseline 누적 소실, full 모델/영상 조합에서 낮은 유효 FPS 가능.
- **데이터 근거:** calibration 사용자 수 차이와 camera failure. 특정 원인/기기는 아직 미확정.
- **코드 근거:** Accumulator `_restart`, Controller `_observeInferenceLatency/_applyPerformancePolicy`.
- **현상:** 진행바가 반복 초기화되거나 유효 프레임 수를 늦게 충족.
- **DAU/리텐션 영향:** P0 계측에서 이 원인이 큰 비중일 때 진입 개선 추가 효과.
- **수정 방법:** 유효 시간 보존 방식의 짧은 gap 완충, 실제 첫 유효 FPS를 보고 녹화 전에 성능 정책 결정. 모델/임계값 전체 교체 금지.
- **난이도:** 중간~높음. baseline 정확도 회귀 확인 필요.
- **Firebase KPI:** reset reason별 비중, ready latency, 첫 카운트 누락/오검출 진단, shallow attempt/추적 손실, 완료율; 앱 리뷰 점수만으로 인식 정확도 판정하지 않음.

### P1-2. 챌린지의 오늘 복귀와 홈 연결

- **문제:** 홈에서 활성 챌린지 목표가 안 보임; 놓친 날짜의 목표를 나중에 메울 수 없음; 종목별 스트릭 차이.
- **데이터 근거:** 탭 115명 대비 선택 30명/시작 15명; 완료 이벤트는 제공 표에 없음. 표에 없음은 완료자가 영원히 0명이라는 증거는 아님.
- **코드 근거:** HomeScreen, ChallengeController `_sevenDayGoals/calculateProgress`, combined metrics.
- **현상:** 기능을 찾아 들어가야 오늘 행동을 알 수 있고, 한 날 놓친 후 성취감이 낮아질 가능성.
- **DAU/리텐션 영향:** 챌린지 참가자 재방문을 확장하는 후속 개선.
- **수정 방법:** 기존 홈에 현재 챌린지의 오늘 남은 양/바로 시작 연결; 놓친 날 이후에도 오늘 목표 달성을 긍정적으로 표시. 초기 목표/증가량은 실제 완료별로 검토하며 성과 기준 변경 시 과거 진행 데이터 의미를 보존.
- **난이도:** 낮음~중간.
- **Firebase KPI:** 홈→challenge attempt→first count, 참가 코호트 다음날/7일 복귀, 일별 목표 성공·복귀·중단. 자발 참가자 편향을 고려해 비참가자와 단순 비교만 하지 않음.

### P2. 광고 요청 진단·재시도 상한 정리

- **문제:** 실패 재시도가 계속되고 결과 이벤트는 no-op; placement도 합쳐짐.
- **데이터 근거:** 1,646 requests vs 102 impressions. 이 비율로 no-fill을 확정할 수 없음.
- **코드 근거:** BottomNativeAd `_scheduleRetry`, AdService `_scheduleInterstitialRetry`, AnalyticsService의 빈 메서드.
- **현상:** 광고가 없는 화면에서도 요청이 반복될 가능성; 원인 진단 불가.
- **DAU/리텐션 영향:** 주효과는 자원 낭비·완료 대기 방지의 보조. 수익 증대는 후순위.
- **수정 방법:** 실제 화면 placement, load result/error code/domain, request ID, foreground·운동중 조건, 재시도 상한. 자동 ad_impression과 중복 수익 이벤트는 만들지 않음.
- **난이도:** 낮음~중간.
- **Firebase KPI:** format/placement/version별 request→loaded→impression, 요청/활성일, 앱 foreground 밖 요청, 오류별 비중. AdMob matched request 보고서와 별도 대조.

## 10. 측정 설계와 DAU 100의 현실적인 조건

### 분석에 추가로 필요한 최소 데이터

실행 전후 28일의 원시 이벤트/Exploration에서 `event_timestamp`, `user_pseudo_id`, `app version/build`, 플랫폼/기기/OS, `workout_session_id`, `entry_point`, target, cancel_stage/reason, failure_reason, elapsed/calibration buckets를 가져온다. 현재부터 추가되는 종목·정확한 시간·failure detail은 과거에 소급해 생기지 않는다. BigQuery export 유무도 현재 자료에서는 알 수 없다.

1. **신규 사용자 코호트:** first_open을 시작점으로 24시간 내 첫 유효 완료, D1(다음 calendar day), D7(7일 후), W1(다음 주) 복귀를 각각 구분. 프로젝트 timezone 고정.
2. **시도 퍼널:** user+attempt+종목+revision으로 조인하고 timestamp 순서 확인. 일반/챌린지/복구를 분리. 성공 후 재시도와 실패 후 성공을 개별 attempt index로 분석. 단계가 생략되는 valid 경로는 별도로 취급.
3. **보정:** 모든 진입자의 wall-clock 시간과 최초 유효 pose 이후 안정화 시간을 함께 측정. 성공자 p90뿐 아니라 제한 시간 내 ready 도달률, timeout, 조기 종료율도 본다.
4. **리텐션:** 첫 유효 완료 코호트의 다른 날짜 재운동을 핵심으로 두고, 앱 실행 DAU와 실제 운동 DAU를 함께 본다. second milestone 이벤트를 D7 대용으로 쓰지 않는다.
5. **실험:** 한 번에 많은 기능을 추가하지 않고 P0 묶음을 작은 릴리스로 나눈다. 7일 관찰이 끝난 코호트끼리 비교하고 표본 수·불확실성을 표시한다. 이 규모에서 1~2일의 상승으로 확정하지 않는다. 실제 DAU 목표는 최근 7일 평균 100으로 정의하는 편이 안정적이다.

### 리텐션 개선만으로 자동으로 100이 되지는 않는다

현재 WAU 87보다 DAU 목표 100이 크므로 주간 활동 사용자 기반 자체가 늘어야 한다. MAU가 278에 그대로 머문다면 DAU 100은 `35.97%`의 DAU/MAU를 요구한다. 현재 5.8%의 약 6.25배다. 이는 보정의 한 단계 비율을 올리는 것만으로 보장할 수 없다.

가령 같은 주간 사용자들이 평균 주 3일 앱을 이용하고 요일별 활동이 고르게 분포한다는 단순 가정이면 평균 DAU 100에는 약 `100×7/3 ≈ 233 WAU`가 필요하다. MAU 600과 평균 DAU/MAU 16.7%도 하나의 산술 조합일 뿐 예측은 아니다. **첫 완료율과 재운동일을 개선한 뒤, 기존 유입 채널에서 유효 첫 운동 사용자가 늘어나는지 함께 확인해야 한다.** 획득 채널별 비용/전환 데이터가 없어 광고 집행이나 특정 마케팅 채널을 추천할 근거는 없다.

현 자료가 지지하는 실행 순서는 ‘보정 임계값 일괄 완화’가 아니라 **첫 성공에 도달할 수 있게 준비를 보이게 만들고 → 성공 후 내일 행동을 연결하고 → 그 사이의 광고 대기를 제거하는 것**이다.

## 핵심 코드 위치 빠른 참조

| 판단 | 실제 파일·함수 위치 |
|---|---|
| 보이지 않는 카운트다운 / 초기화 await | [lib/features/squat/presentation/screens/workout_countdown_screen.dart:83](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/workout_countdown_screen.dart:83) |
| 보정 reset 조건 | [lib/features/squat/domain/services/calibration_accumulator.dart:38](/Users/nam/projects/motionfit/lib/features/squat/domain/services/calibration_accumulator.dart:38) |
| 무효 프레임에서 누적 초기화 | [lib/features/squat/domain/services/rep_detector.dart:141](/Users/nam/projects/motionfit/lib/features/squat/domain/services/rep_detector.dart:141) |
| 첫 rep 이벤트가 동작 시작에서 발생 | [lib/features/squat/application/workout_session_controller.dart:863](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:863) |
| 종목별 두 번째 완료 milestone | [lib/features/squat/application/workout_session_controller.dart:2568](/Users/nam/projects/motionfit/lib/features/squat/application/workout_session_controller.dart:2568) |
| 리마인더 재제안 조건 | [lib/features/squat/presentation/screens/workout_summary_screen.dart:374](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/workout_summary_screen.dart:374) |
| 알림 초기화와 tap callback 부재 | [lib/core/notifications/notification_service.dart:84](/Users/nam/projects/motionfit/lib/core/notifications/notification_service.dart:84) |
| 첫 완료부터 전면광고 자격 | [lib/core/ads/ad_eligibility.dart:5](/Users/nam/projects/motionfit/lib/core/ads/ad_eligibility.dart:5) |
| 전면광고 로드 대기 | [lib/core/ads/ad_service.dart:223](/Users/nam/projects/motionfit/lib/core/ads/ad_service.dart:223) |
| 챌린지 운동 후 결과 화면 우회 | [lib/features/squat/presentation/screens/active_workout_screen.dart:139](/Users/nam/projects/motionfit/lib/features/squat/presentation/screens/active_workout_screen.dart:139) |
| 광고 skip 이벤트 후 실제 초기화 계속 | [lib/app/app.dart:232](/Users/nam/projects/motionfit/lib/app/app.dart:232) |
