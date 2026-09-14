# DAU 100 P0 구현 — 2026-09-14

## 변경 내용

| 기존 문제 | 수정한 핵심 로직 | 주요 파일 / 함수 |
|---|---|---|
| 카운트다운 중 몸의 인식 상태가 보이지 않고 준비 지연이 숫자 1 정지로 보임 | 기존 엔진의 Texture/pose overlay를 카운트다운에서도 사용. 카운트다운 종료 뒤 spinner와 현재 보정 안내 표시 | 각 종목 `workout_countdown_screen.dart`, 공통 `upright_camera_preview.dart`, `preparation_feedback.dart` |
| 보정 중 진행도 초기화만 드러남 | detector → snapshot → controller state → 준비/보정 UI로 실패 원인 전달. 상태 전이와 실제 샘플 reset만 이벤트 기록 | 각 종목 `calibration_accumulator.dart`, `rep_detector.dart`, `workout_session_controller.dart::_observeCalibration` |
| TTS·영상 준비가 시작 경로를 막음 | 카메라만 필수 await. TTS 구성은 별도 비동기 실행, 영상 시작은 비동기 실행 후 2초 제한. 실패하면 해당 세션 영상만 취소. runtime/video generation으로 늦은 응답 차단 | 각 종목 controller의 `_startEngines`, `_startWorkoutVideoIfAvailable`; Android `MotionfitPosePlugin.kt` |
| 첫 완료에도 전면광고 가능, 미준비 광고 load를 기다림 | 앱 전체 유효 완료 2회부터만 허용. 완료 수 미확인/SDK 미준비/광고 미로드이면 즉시 건너뜀. 완료 이동에서 UMP·SDK 초기화·load 대기 제거 | `ad_eligibility.dart`, `ad_service.dart::showInterstitialIfAvailable`, `post_workout_interstitial.dart` |
| 챌린지 운동 결과를 건너뛰거나 결과 이후 행동이 불명확 | 챌린지도 결과 화면으로 연결. 알림 제안 또는 기존 챌린지/다음 목표 중 한 가지 주요 행동 표시. 챌린지 상세에서 기존 시작 흐름 사용 | 각 종목 `active_workout_screen.dart`, `workout_summary_screen.dart` |
| 알림 제안 무시도 영구 소진될 수 있음 | accepted/declined/dismissed/notDecided 저장. 무시/미결정이면 다음 유효 완료에 1회 재제안, declined는 2회 추가 완료 후 1회 재제안. 총 제안 최대 2회. 명시적 OS 거절/accepted는 재제안 제외 | `user_preferences.dart::shouldOfferWorkoutReminder`, `preferences_controller.dart`, 각 summary |
| 알림 payload가 화면 이동으로 연결되지 않음 | OS launch details와 notification response 콜백 통합, 초기화 이전 payload 보관. 종목 선택 후 홈/챌린지 이동. 일반 workout payload는 마지막 선택 종목 사용 | `notification_service.dart`, `notification_destination.dart`, `app.dart::_drainNotification`, `exercise_selection.dart` |
| 동작 시작과 실제 저장된 첫 성공이 혼재 | `saveProgress` 성공 직후 종목별 첫 count 이벤트. recovery에 기존 count가 있으면 재전송하지 않음 | 각 controller `_persistCompletedRep`, `analytics_service.dart::firstCountCommitted` |
| 두 번째 운동을 다음날 복귀처럼 해석할 수 있음 | 3종목 저장소를 합쳐 첫 완료·앱 전체 두 번째 완료·다른 날짜의 두 번째 완료·운동 날짜 수 분리 | `workout_retention.dart::retentionMilestones/recordWorkoutRetention` |
| 성공자 위주 진단 | 취소/실패/중단과 0회 종료 경로에도 stage/reason/유효 pose/보정/첫 저장 성공을 기록 | `analytics_service.dart::workoutExit`, 각 controller 종료 경로 |

## 정확도 및 동작 경계

- 보정 시간, 최소 프레임 수, confidence/angle/stability 임계값, rep/hold 판정 수식은 변경하지 않았다.
- `temporary_tracking_loss`와 `tracking_lost`를 구분한다. `CalibrationAccumulator.interrupt(reason: ...)`가 향후 원인별 완충 정책을 적용할 지점이다. 이번 패치에서는 짧은 손실에도 기존 reset 동작을 유지한다. 샘플 보존을 켰다고 해석하면 안 된다.
- UI는 기존 번역된 카메라/몸 맞추기/자세/유지 안내를 재사용한다. 관측되지 않은 거리 문제를 단정해 “뒤로 이동”이라고 안내하지 않는다.
- 영상 준비 실패/시간 초과 시 운동은 계속한다. 이미 정상 녹화 중인 영상의 종료·저장 처리는 기존 흐름을 유지한다.
- 알림은 운동 준비/진행/결과 화면을 강제로 덮어쓰지 않고 안전한 화면으로 이동한 뒤 처리한다. OS 프로세스 강제 종료 시 종료 이벤트 전달까지 보장할 수는 없다.
- 알림 설정/스케줄링 대기와 완료/뒤로 버튼을 분리했다. 실제 운동 데이터 저장 중에는 기존 저장 보호를 유지한다.
- 신규 챌린지를 자동 생성하지 않는다. 기존 챌린지 상세/시작 화면으로 연결한다.

## Analytics revision 3 정의

공통: 기존 `analytics_schema=2` 유지, `analytics_revision=3` 추가. `app_version`, `build_number`, platform 유지.

운동 시도: start tap에서 생성한 `attempt_id`는 기존 `workout_session_id`와 같은 익명 ID이다. camera/calibration/운동/종료까지 유지하며 새로운 시작/복구 시 새 attempt가 된다. `exercise_type=squat|pushup|plank`, `entry_point`, `target_unit=reps|seconds`, `is_first_workout` 추가.

- setup view는 아직 시작 시도가 아니므로 attempt ID를 부여하지 않는다. attempt funnel은 start tap부터 연결하고 setup → start는 사용자 기준 별도 비교한다.
- 첫 운동 여부는 앱 전체 저장된 유효 완료 수 기준. 캐시가 없으면 시작을 막지 않고 `is_first_workout=-1`(미확인)로 전송한 뒤 같은 attempt에 한해 비동기로 해석한다. `-1`을 재방문자로 집계하지 않는다. 정확한 첫 완료 분모는 아래 milestone을 사용한다.
- `mf2_first_count_committed`: squat/pushup은 rep 저장 성공, plank는 유효 hold의 저장 단위 성공. 기존 `mf2_first_rep_detected`는 비교를 위해 유지하되 실제 성공 KPI로 사용하지 않는다.
- `mf2_preparation_state_changed`: reason이 바뀔 때만 전송한다.
- `mf2_calibration_reset`: 유효 샘플이 실제로 폐기된 reset에만 기록한다. reason, reset_count, attempt_index 포함.
- `mf2_calibration_ready`: 준비 완료 시 attempt당 1회.
- `mf2_calibration_exit`: 보정을 관측한 attempt의 종료 시 1회.
- 진단 `elapsed_ms`는 start tap 이후 경과 시간이다. 기존 보정 이벤트의 duration bucket과 의미를 혼동하지 않는다.
- `mf2_workout_exit`: exit_stage, exit_reason, exercise_type, elapsed_ms, had_valid_pose, calibration_completed, first_count_completed 포함.
- `mf2_first_workout_completed`: 앱 전체 첫 유효 완료.
- `mf2_app_second_workout_completed`: 날짜 무관 앱 전체 두 번째 유효 완료.
- `mf2_second_workout_day_completed`: 첫 운동 날짜와 다른 두 번째 운동 날짜의 첫 유효 완료. `days_since_first_completion=1` 또는 `is_next_calendar_day=1`이면 다음 달력 날짜 복귀이다.
- `mf2_workout_day_completed`: 로컬 달력 날짜별 첫 유효 완료. `workout_day_count`는 누적 서로 다른 운동 날짜 수.
- 기존 `mf2_second_workout_completed` 호출을 제거했다. revision 3의 다음날 복귀 지표로 사용하지 않는다.
- milestone 중복 방지는 별도 preferences ledger로 직렬 처리한다. 저장 기록/설치 단위이며 계정의 여러 기기를 합치는 기능은 없다. 기록 삭제·재설치·기기 시간/시간대 변경·Analytics 미수신의 한계가 있다. 이벤트는 서버의 exactly-once 트랜잭션이 아니다.

## 배포 후 확인할 KPI

동일 app_version + `analytics_revision=3`로 필터링하고 종목/플랫폼을 분리한다. 서로 다른 버전의 사용자 집계만 나눠 퍼널 전환율이라고 해석하지 않는다.

1. **첫 운동 진입:** 고유 attempt 기준 start tap → camera complete → calibration ready → first count committed → workout completed 전환. 첫 count까지 elapsed_ms p50/p90.
2. **보정 병목:** reset reason별 attempt 비율, 준비 상태 체류시간, calibration exit 중 first_count_completed=0 비율. 프레임 수나 단순 이벤트 합계로 사용자 이탈률을 계산하지 않는다.
3. **첫 성공 보호:** 첫 유효 완료에서 전면광고 노출 0건. ready가 아닌 광고 때문에 완료 이동이 지연되는지 실제 기기에서 확인한다.
4. **다음날 재방문:** first_workout_completed 사용자 중 다음 날짜 관측 기간이 확보된 코호트를 분모로, second_workout_day_completed + days_since_first_completion=1 사용자 비율. 같은 날짜 두 번째 운동은 별도 KPI다.
5. **반복 운동:** app_second_workout_completed/first_workout_completed와 workout_day_count 분포를 분리한다.
6. **결과 이후 행동:** mf2_next_workout_action_tapped, reminder_prompt_shown/accepted/dismissed, reminder_scheduled, notification_opened → entry_point=notification 운동 완료 전환.
7. **최종 목표:** 동일 시간대의 DAU 7일 이동평균과 신규 사용자당 첫 유효 완료율/D1 운동 복귀율을 함께 본다. 이번 패치만으로 DAU 100 달성을 보장하지 않는다.

고유 attempt 분석은 원시 이벤트/BigQuery가 적합하다. attempt_id를 고카디널리티 GA 보고서 차원으로 무조건 등록하지 않는다. Firebase 콘솔/서버 설정은 이번 코드 변경에 포함되지 않는다.

## 검증 결과와 남은 확인

요청한 “저렴한 검증 최대 1회”에 따라 다음 명령을 1회 실행했다.

```sh
flutter test --no-pub test/p0_growth_test.dart test/core/ads/ad_eligibility_test.dart test/core/analytics/analytics_service_test.dart test/features/squat/domain/rep_detector_test.dart
```

- 기존 Analytics, 첫 광고 정책, 스쿼트 pose/rep 회귀 테스트 **35개 통과**.
- 신규 P0 통합 테스트는 3개 controller의 `PoseEngine` → `RecordablePoseEngine` 타입 접근 오류로 로드 실패했다. 명시적 변환 후 capability를 읽도록 수정했다.
- 수정 후 재실행하지 않았다. 따라서 전체 컴파일/신규 P0 테스트 통과를 확정하지 않는다. 신규 테스트에는 종목 간 날짜별 milestone, 알림 재제안/권한 거절, payload 종목 라우팅, 이벤트 중복 방지 사례가 있다.
- Dart 변경 파일 포맷 완료. Android/iOS 빌드와 실기기 실행은 하지 않았다.
- 출시 전 실기기: 준비 중 취소/재진입, 느린 TTS/영상 시작 실패, 정상 rep/hold, 첫 완료 광고 없음, 미로드 광고 즉시 이동, 결과 중 알림 설정 대기 상태에서 완료/뒤로, 알림 cold/background/foreground 및 각 종목, Firebase DebugView를 확인해야 한다.

## 변경 파일

기존 작업 중이던 `ios/Runner.xcodeproj/project.pbxproj`, `lib/core/privacy/privacy_consent_service.dart`는 이번 P0 변경에 포함하지 않았다.

- `lib/app/app.dart`
- `lib/core/ads/ad_eligibility.dart`
- `lib/core/ads/ad_service.dart`
- `lib/core/ads/post_workout_interstitial.dart`
- `lib/core/analytics/analytics_service.dart`
- `lib/core/analytics/calibration_feedback.dart`
- `lib/core/analytics/workout_analytics_session.dart`
- `lib/core/analytics/workout_retention.dart`
- `lib/core/notifications/notification_destination.dart`
- `lib/core/notifications/notification_service.dart`
- `lib/core/widgets/preparation_feedback.dart`
- `lib/core/widgets/upright_camera_preview.dart`
- `lib/features/exercise/application/exercise_selection.dart`
- `lib/features/plank/workout/application/workout_session_controller.dart`
- `lib/features/plank/workout/application/workout_session_state.dart`
- `lib/features/plank/workout/domain/services/calibration_accumulator.dart`
- `lib/features/plank/workout/domain/services/rep_detector.dart`
- `lib/features/plank/workout/presentation/screens/active_workout_screen.dart`
- `lib/features/plank/workout/presentation/screens/plank_home_screen.dart`
- `lib/features/plank/workout/presentation/screens/workout_countdown_screen.dart`
- `lib/features/plank/workout/presentation/screens/workout_summary_screen.dart`
- `lib/features/plank/workout/presentation/workout_preparation_launcher.dart`
- `lib/features/pushup/application/workout_session_controller.dart`
- `lib/features/pushup/application/workout_session_state.dart`
- `lib/features/pushup/domain/services/calibration_accumulator.dart`
- `lib/features/pushup/domain/services/rep_detector.dart`
- `lib/features/pushup/presentation/screens/active_workout_screen.dart`
- `lib/features/pushup/presentation/screens/pushup_home_screen.dart`
- `lib/features/pushup/presentation/screens/workout_countdown_screen.dart`
- `lib/features/pushup/presentation/screens/workout_summary_screen.dart`
- `lib/features/pushup/presentation/workout_preparation_launcher.dart`
- `lib/features/settings/application/preferences_controller.dart`
- `lib/features/settings/data/preferences_service.dart`
- `lib/features/settings/domain/user_preferences.dart`
- `lib/features/squat/application/workout_session_controller.dart`
- `lib/features/squat/application/workout_session_state.dart`
- `lib/features/squat/domain/services/calibration_accumulator.dart`
- `lib/features/squat/domain/services/rep_detector.dart`
- `lib/features/squat/presentation/screens/active_workout_screen.dart`
- `lib/features/squat/presentation/screens/squat_home_screen.dart`
- `lib/features/squat/presentation/screens/workout_countdown_screen.dart`
- `lib/features/squat/presentation/screens/workout_summary_screen.dart`
- `lib/features/squat/presentation/workout_preparation_launcher.dart`
- `packages/motionfit_pose/android/src/main/kotlin/com/namslab/motionfit_pose/MotionfitPosePlugin.kt`
- `test/core/ads/ad_eligibility_test.dart`
- `test/p0_growth_test.dart`
