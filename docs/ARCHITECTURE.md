# MotionFit - Squat 아키텍처

## 1. 핵심 아키텍처

Feature-first Clean Architecture를 사용한다. 화면은 Riverpod controller를 통해 use case와 repository에 접근하고, 네이티브 포즈 플러그인은 `PoseEngine` 인터페이스 뒤에 둔다. 운동 이벤트는 controller에서 단일 직렬 큐로 처리하고 SQLite transaction과 unique ID로 중복 저장을 막는다.

의존성 방향은 `presentation → application/domain ← data/platform`이다. 도메인 계층은 Flutter widget, SQLite, MediaPipe, TTS 구현을 알지 못한다.

## 2. 데이터 흐름

```text
Native Camera Texture ─────────────────────────→ Flutter preview
        │
        └→ latest-frame scheduler → MediaPipe Pose Landmarker
             → mirror/rotation/crop coordinate transform
             → normalized/world landmark stream
                 → metric filter + personal calibration
                    ├→ RepDetector ─────→ RepCompleted(repCycleId)
                    └→ FormAnalyzer ────→ FormResult(repCycleId)
                                               │
WorkoutSessionController ←──────────────────────┘
        ├→ SQLite transaction → Rep/Set/Session → Records/Statistics UI
        ├→ CoachQueue → System TTS
        └→ Subtitle state → Workout overlay
```

`RepDetector`는 포즈 문제나 자세 점수를 입력받지 않는다. `FormAnalyzer`가 실패하거나 항목을 관찰할 수 없어도 `RepCompleted`는 취소되지 않고 반복 데이터는 저장된다.

카메라 frame은 네이티브 내부에서만 잠시 사용하며 큐 길이는 1이다. Flutter로는 숫자 좌표와 추적 메타데이터만 전송하고 저장소에는 운동 요약 수치만 기록한다.

## 3. 폴더 구조

```text
lib/
  app/
    app.dart
    router.dart
    localization/arb/
    theme/
  core/
    database/
    notifications/
    permissions/
    time/
    utils/
    widgets/
  features/
    squat/{data,domain,application,presentation}/
    records/{data,domain,application,presentation}/
    settings/{data,domain,application,presentation}/
packages/
  motionfit_pose/
    lib/
    android/
    ios/
test/
  core/
  features/
  fixtures/
tool/
```

## 4. 고정 패키지와 선택 이유

| 패키지 | 버전 | 용도와 선택 이유 |
|---|---:|---|
| flutter_riverpod | 3.3.2 | 테스트 가능한 상태/의존성 관리 |
| go_router | 17.3.0 | shell 탭과 전체 화면 운동 흐름 |
| sqflite | 2.4.2+1 | 설치된 Dart 3.11과 호환되는 SQLite 및 transaction |
| shared_preferences | 2.5.5 | 중요하지 않은 UI 선호값의 async 저장 |
| flutter_local_notifications | 21.0.0 | 요일별 offline 로컬 알림 |
| timezone | 0.11.1 | DST를 반영하는 TZDateTime 계산 |
| flutter_timezone | 5.1.0 | 운영체제 IANA timezone 확인 |
| permission_handler | 12.0.3 | camera/notification 권한 상태와 설정 이동 |
| flutter_tts | 4.2.5 | 교체 가능한 offline system TTS 구현 |
| intl | 0.20.2 | Flutter SDK와 호환되는 날짜/숫자 현지화 |
| uuid | 4.6.0 | session/set/rep idempotency key |
| motionfit_pose | local | 네이티브 카메라/MediaPipe 캡슐화 |

런타임 의존성은 정확한 버전으로 고정하고 `pubspec.lock`을 함께 관리한다.

## 5. 포즈 추론 구조

- Android: CameraX ImageAnalysis `KEEP_ONLY_LATEST`, Kotlin worker executor, MediaPipe Tasks Vision live-stream mode, Flutter Texture preview.
- iOS: AVCaptureVideoDataOutput `alwaysDiscardsLateVideoFrames`, 전용 serial queue, MediaPipe Tasks Vision live-stream mode, Flutter Texture preview.
- motion-fit3 모바일 경로와 동일하게 `numPoses = 1`, 640×480 입력, Lite 모델, 기본 30 FPS를 사용한다.
- 최근 45개 추론 latency 평균으로 FPS를 15~30 범위에서 조절하되, 수신된 유효 33점 결과는 latency 때문에 폐기하지 않는다.
- Dart stream 계약: timestamp, normalized/world landmarks, visibility/presence, tracking state, people count, input size, mirror/rotation metadata.
- MoveNet 등은 같은 `PoseEngine` 구현으로 추가할 수 있다.

## 6. RepDetector와 FormAnalyzer 분리

`RepDetector`는 개인 기립 기준과 움직임의 왕복만 판단한다. 좌우 무릎/고관절 각도, 정규화된 엉덩이 하강량, 어깨-엉덩이 상대 이동, 속도/방향, confidence를 사용하며 히스테리시스와 refractory period를 적용한다.

`FormAnalyzer`는 detector가 모은 동일 반복 구간을 독립적으로 평가한다. 깊이, 상체, 뒤꿈치, 정렬, 균형, 속도, 제어, lockout을 계산하되 촬영 각도에서 관찰할 수 없는 항목은 `notEvaluated`로 둔다. 가장 중요한 개선점 하나만 선택한다.

controller는 `repCycleId`로 두 결과를 연결하지만 자세 결과를 기다리느라 횟수 증가를 늦추거나 무효화하지 않는다. 분석 오류 시 중립 점수와 미평가 사유를 저장한다.

## 7. 구현 순서

요구사항의 Phase 1~9를 그대로 따른다. 각 Phase 완료 때 `IMPLEMENTATION_PLAN.md`와 원문 완료 기준을 함께 갱신한다. 네이티브 실기기 검증이 필요한 항목은 코드 완료와 실측 완료를 분리해서 표시한다.

## 8. 주요 위험과 대응

| 위험 | 대응 |
|---|---|
| 전면 mirror/회전/crop 좌표 불일치 | 네이티브와 Flutter가 공유하는 좌표 계약 및 전후면 fixture 검증 |
| 97% 정확도 근거 부족 | Replay corpus에서 TP/FP/FN, 중복률, latency를 자동 산출하고 회귀 비교 |
| 실시간 모델 발열/저사양 지연 | Lite 기본, latest-frame-only, 640px 입력과 동적 FPS를 적용하고 실기기에서 확정 |
| 복수 인물 동시 등장 | 실시간성을 위해 한 pose만 선택하므로 안내 단계에서 한 명만 화면에 있도록 요구 |
| 뒤꿈치/무릎 정렬 관찰 한계 | camera-angle/visibility observability gate로 추측 코칭 금지 |
| lifecycle 중복 이벤트 | 단조 timestamp, repCycleId, controller 직렬화, DB unique constraint |
| 벽시계/백그라운드 휴식 오차 | 저장된 absolute rest-end DateTime으로 남은 시간을 계산 |
| timezone/DST 변경 | resume 시 IANA timezone 재확인 후 모든 enabled 알림 재등록 |
| offline TTS 음성 부재 | locale 음성 지원 확인, 지원 음성 fallback, 자막은 항상 유지 |
| 실영상 없이 정확도 단정 | 코드 준비와 실제 corpus 검증을 분리하고 미검증 수치를 완료로 표시하지 않음 |

네이티브 모델 설치와 체크섬은 [네이티브 설정](NATIVE_SETUP.md), 데이터 경계는 [개인정보 및 데이터 처리](PRIVACY_AND_DATA.md), 실측 게이트는 [출시 체크리스트](RELEASE_CHECKLIST.md)를 단일 기준으로 사용한다.
