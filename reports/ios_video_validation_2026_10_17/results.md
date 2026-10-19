# iOS 운동 영상 및 광고 실기기 검증

## 판정

**앱 전체 정상 판정은 FAIL이다.** 종목별 실제 영상 2개씩, 총 6개를 검사했다. 영상 처리 무결성은 6/6 통과했지만 운동 동작 기준은 2/6 통과, 4/6 실패했다. 준비 자세 인식 실패 3건과 플랭크 자세 종료 후 카운트 지속 1건이 확인됐다. 이 결과만으로 광고 미노출 해결을 입증할 수 없다. 광고 실기기 실행 결과는 아래에 별도로 기록한다.

## 환경과 검증 범위

- 대상: 기존 MotionFit HEAD `0f608c59abbe59afe20da257f169a1ab48c54735` 위 광고 안정화 작업 트리.
- 기기: iPad Air 11-inch (M2), iOS 26.6.2. MediaPipeTasksVision 0.10.35, 운영 기본 lite 모델.
- 별도 네이티브 호스트 `fit.motionfit.app.videovalidation`에서 AVAssetReader로 원본 영상을 읽고 실제 iPad에서 추론했다. 운영 Swift의 모델 옵션·추적 분류·payload 변환을 사용했다. 임시 복사본에만 오프라인 접근 hook을 추가했다.
- 영상 방향 변환을 적용했다. 스쿼트 2개는 회전 메타데이터가 있다. 원본 영상과 운영 운동/native 소스는 변경하지 않았다.
- 차이점: MediaPipe `.video` 동기 실행이며 운영 `.liveStream` 카메라 입력이 아니다. 카메라 권한, 실시간 프레임 누락, Flutter bridge, 실제 운동 화면·저장까지 통합한 UI 테스트는 포함하지 않는다.
- 추론한 실제 landmark를 변경하지 않은 Dart detector·form analyzer에 전달했다. 기본 자동 calibration을 사용했으며 성공시키기 위한 강제 calibration, 추가 정지 프레임, 임계값 변경은 하지 않았다.
- 네이티브 4,213프레임 처리 완료, 처리시간 합계 51.748초. 추론 P95 11–12ms. 오프라인 수치이므로 앱의 실시간 FPS 보장으로 해석하지 않는다.
- 원본 SHA256, 운영 소스 SHA256, 모델 SHA256은 `provenance.json`, 원시 landmark는 `native_replays/*.json.gz`에 보관했다. 네이티브 호스트는 정상 종료했고 검증 후 제거했다. 기기의 기존 MotionFit 1.7.0/build 67은 덮어쓰지 않았다. 이번 테스트 대상 소스의 iOS 버전은 1.6.6/build 66이다.

## 영상별 결과

| 종목 | 영상 | 실제 길이 | 결과 | 관찰 |
| --- | --- | ---: | --- | --- |
| 스쿼트 | `squat_fast_10.mp4` | 23.50초 | PASS | 자동 calibration 완료, 눈으로 확인한 10회와 판정 10회 일치 |
| 스쿼트 | `squat_depth_after_5.mp4` | 22.84초 | FAIL | calibration 14회 재시도, 완료 실패, 0회 |
| 푸쉬업 | `pushup_good_repeat_10.mp4` | 27.33초 | FAIL | calibration 20회 재시도, 완료 실패, 10회 동작에 판정 0회 |
| 푸쉬업 | `pushup_shallow_10.mp4` | 24.66초 | FAIL | calibration 16회 재시도, 완료 실패. 얕은 동작 필터 정확도를 평가할 준비 상태에 진입하지 못함 |
| 플랭크 | `plank_near_20s.mp4` | 17.33초 | FAIL | 1초 체크포인트 6개. 두 무릎을 바닥에 댄 뒤에도 15.435초·16.435초 체크포인트 생성 |
| 플랭크 | `plank_hip_high_20s.mp4` | 24.66초 | PASS(제한적) | 높은 엉덩이의 잘못된 시작 자세를 거절, 0초. 올바른 플랭크 유지 판정 전체의 통과를 의미하지 않음 |

파일명은 정답 라벨로 단정하지 않았다. `pushup_shallow_10`에서는 12번의 얕은 움직임이 보이며, `plank_near_20s`는 전체 길이부터 20초 미만이다. 시간별 contact sheet를 함께 저장했다. 플랭크 종료 기준은 보수적으로 두 무릎이 내려간 15.0초로 잡았다.

자동 검사는 `checks.json`에 저장했으며 실패를 숨기지 않고 exit code 2를 반환한다. 네이티브 입력의 timestamp 역행·비유한 landmark 값은 모두 0건이다. 이는 동작 정확도나 전체 앱 무결성을 뜻하지 않는다.

## 확인된 운동 경로 문제

### 1. 준비 자세 calibration을 통과하지 못하는 영상

스쿼트 `lib/features/squat/domain/services/calibration_accumulator.dart`는 1.2초/24프레임 준비 구간과 hipY 범위 0.03, 관절각 범위 12도 제한을 적용한다. `squat_depth_after_5`는 추적 자체는 684/685프레임 정상인데 준비 창이 계속 초기화됐다. 예를 들어 약 3.737초 초기화 직전 구간에서 hip 각도 변화가 약 17도로 제한을 넘었다.

푸쉬업 `lib/features/pushup/domain/services/calibration_accumulator.dart`는 1.2초/24프레임, hipY 범위 0.025, 관절각 범위 10도 제한을 적용한다. 정상 반복 영상은 785/820프레임에서 추적됐지만 준비 창이 초기화됐다. 약 4.233초 초기화 직전 몸통 각도 변화 약 12.765도·팔꿈치 약 11.85도가 제한을 넘었다. 얕은 반복 영상도 같은 준비 단계에서 끝났다.

이 세 영상으로 현재 자동 준비 절차가 완료되지 않는 사실을 재현했다. 영상에 앱이 요구하는 충분한 정지 준비 구간이 없을 가능성도 있으므로, 유효 calibration 이후 반복 검출까지 모두 잘못됐다고 확대 해석하지 않는다. 그러나 사용자가 제공한 영상에서 정상 운동 진입을 입증하지 못했으므로 PASS 처리하지 않는다. 준비 안내·안정 구간과 측정 흔들림의 허용 범위를 별도 회귀 사례로 검토해야 한다.

### 2. 플랭크 종료 뒤 체크포인트가 지속됨

`lib/features/plank/workout/domain/services/rep_detector.dart`의 `_advance`는 `_isGoodPlank`가 false여도 이미 시작한 hold의 `_completeDueCheckpoints`를 호출한다. `tick`도 hold 종료 판정 없이 체크포인트를 진행한다. 이번 영상에서는 실제 자세 종료 후 체크포인트 두 개가 생성됐다. 경고 정책상 나쁜 자세 시간을 어떻게 처리할지와 바닥에 내려앉은 종료 상태를 구분해 hold를 중단해야 한다.

이번 요청은 영상 검증 및 결과 보고이고 기존 작업 범위도 광고와 무관한 운동 기능 변경을 제한한다. 따라서 운동 임계값·카운트 로직을 임의 수정하지 않고 재현 증거를 저장했다.

## 광고 검증의 해석

운동 영상이 정상 처리됐다는 사실은 광고 요청·impression·전면 표시/종료 성공을 의미하지 않는다. calibration 실패로 운동이 완료되지 않는 경우는 유효 완료 뒤의 광고 show 누락과 구분해야 한다.

이전에 저장된 광고 자동화 56건 PASS 및 Android 실기기 SDK 시나리오 3건 PASS는 `../ads_stabilization_2026_10_17/implementation.md`의 기존 결과다. 이번 iOS 검증을 대신하지 않는다. 운영 No Fill·UMP 미허용·ATT 미결정 상태를 코드 결함과 합쳐 PASS/FAIL 판단하지 않는다.

### 이번 iOS 광고 실행 결과: 미검증

| 항목 | 결과 | 확인한 범위 |
| --- | --- | --- |
| 영상/광고 테스트 Dart 정적 분석 | PASS | 새 통합 테스트·SDK smoke 테스트·replay 도구 |
| 별도 iOS Debug 및 Profile 테스트 앱 빌드 | PASS | 실제 기기 대상으로 컴파일·링크·서명 완료 |
| Debug 테스트 앱 설치 | PASS | 별도 `fit.motionfit.app.adsvalidation`, 1.6.6/build 66 |
| Debug Flutter 통합 테스트 실행 | 미실행 | LLDB 시작/VM Service 검색 지연. 환경 변수로 LLDB를 끈 Xcode 방식도 실행 완료에 도달하지 못함 |
| Profile 앱 설치·직접 실행 | 미완료 | 디버거를 피하기 위해 빌드했으나 devicectl 설치·launch가 완료되지 않아 중단 |
| iPad Flutter Dart에서 6개 landmark 재생 | 미검증 | Documents에는 입력 `VideoReplays`만 있고 `ios_detector_results.json` 없음. 위 운동 결과는 **iPad native 추론 + Mac Dart replay** 결과임 |
| 실제 iOS 배너·네이티브 load/impression | 미검증 | 이번 실행의 실제 SDK 콜백 증거 없음 |
| 영상 완료 → 운영 전면 helper → 실제 show/impression/dismiss | 미검증 | `ios_ads_trace.json`, `ios_video_ad_completion.json` 미생성 |
| iOS 실제 쿨다운 저장·중복 표시 방지 | 미검증 | 자동화 코드가 존재해도 실행 결과가 없으므로 PASS 아님 |

Profile 호스트는 실제 기기에서 디버거 없이 실행하려고 준비했지만 실행이 완료되지 않았다. 기기 조회 시 passcodeRequired=false였으며, 연결 도구는 무선 연결을 안내했다. 이 현상을 광고 코드 오류·No Fill로 분류하지 않는다. ATT/UMP 창이 실제로 표시됐다는 증거도 확보하지 못했다. 사용자는 현재 기기 조작이 어렵다고 답했으므로 권한 선택·광고 닫기를 요청하거나 대신 가정하지 않았다.

전역 Flutter 설정을 바꾸지 않고 프로세스 환경 변수 `FLUTTER_LLDB_DEBUGGING=false`로만 대체 디버깅을 시도했다. Profile 테스트 산출물의 Firebase 자동 수집을 끄고, CLI bundle ID override가 전파된 framework 23개의 ID는 기존 검증된 release 산출물에서 원래 값으로 복원·재서명했다. 운영 설정과 운영 광고 ID는 이 테스트 때문에 변경하지 않았다. 모든 요청은 실행된다면 공식 테스트 광고를 사용하도록 구성했다.

결론: **광고 안정화 소스 변경 및 기존 자동화 검증은 남아 있지만, 이번 영상 기반 iOS 검증으로 광고 미노출이 해결됐다고 확정할 수 없다.** 추후 실제 기기에서 ATT/UMP 상태 확정 후 테스트 앱 실행, 형식별 impression, 영상 완료에 따른 전면 표시/종료 및 쿨다운 저장을 확인해야 한다. 실시간 운동 UI·저장까지 연결한 검증과 운영 재고 관찰도 남아 있다.

정리 상태: 네이티브 영상 호스트는 제거했다. 광고 검증 호스트는 제거 명령도 30초 timeout이 발생해 **`fit.motionfit.app.adsvalidation`이 기기에 남아 있다.** 자동 실행은 중단했다. 기존 운영 앱 `fit.motionfit.app`은 최종 조회에서도 1.7.0/build 67로 유지됐다. 연결 복구 후 별도 광고 검증 앱만 제거하거나 다시 검증해야 한다. 제거 실패를 완료로 보고하지 않는다. 정리 로그와 최종 설치 조회는 `ads/`에 보관했다.

## 재현 도구

- `benchmark/ios/prepare_harness.py`, `VideoHost.swift`: 별도 iOS 네이티브 영상 추론 호스트 생성.
- `benchmark/ios/evaluate_replays.dart`: 실제 landmark를 운영 운동 detector에 재생.
- `benchmark/ios/assert_video_results.py`: 영상별 동작 기준 검사 및 실패 exit code.
- `integration_test/ios_video_ads_test.dart`: 같은 landmark의 iOS Dart 처리와 성공한 스쿼트 10회 결과를 이용한 운영 전면 광고 helper 검증. 이전 완료 1건은 명시적 fixture이며 전체 운동 DB/UI 테스트를 뜻하지 않는다.
- `benchmark/ios/prepare_ad_host.py`: 별도 테스트 앱 산출물의 Firebase 수집 비활성화·framework ID 복원·재서명. 운영 소스나 기존 앱의 서명/데이터를 변경하지 않는다.

저장된 데이터로 detector 및 판정을 재현하는 명령:

```sh
dart run benchmark/ios/evaluate_replays.dart reports/ios_video_validation_2026_10_17/native_replays reports/ios_video_validation_2026_10_17/detector_results.json
python3 benchmark/ios/assert_video_results.py reports/ios_video_validation_2026_10_17
```

두 번째 명령의 현재 기대 결과는 4개 실패 및 exit code 2다.
