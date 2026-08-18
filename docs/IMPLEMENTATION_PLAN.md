# MotionFit - Squat 구현 계획 및 요구사항 추적표

이 문서는 구현 중 계속 갱신하는 단일 체크리스트다.

- `[x]`는 해당 코드/문서/fixture가 저장소에 구현되어 있음을 뜻한다.
- `[ ]`는 구현이 남았거나, 문구 자체가 실기기·실영상·스토어 증빙을 요구해 아직 완료로 판정할 수 없음을 뜻한다.
- 코드 준비와 품질 실측은 별개다. Phase 항목이 체크되어도 아래 `원문 완료 기준`과 `실측 품질 게이트`를 자동으로 충족하지 않는다.
- 현재 97% 정확도는 검증되지 않았으며 완료로 주장하지 않는다.

## 핵심 출시 게이트

- [ ] 명확한 하강과 상승 후 기립 범위로 복귀하면 자세 문제와 무관하게 정확히 1회 증가한다.
- [ ] 자세 결과는 횟수 완료 조건 또는 유효성 판단에 절대 사용하지 않는다.
- [ ] 원본 영상/이미지/카메라 프레임을 저장하거나 업로드하지 않는다.
- [ ] 동일 반복 이중 카운트와 서 있는 상태의 작은 흔들림 오탐을 억제한다.
- [ ] production 경로에 fake data, mock engine, 미완성 표식이 남지 않는다.

## Phase 1 — 설계

- [x] Feature-first Clean Architecture 및 의존성 방향 결정
- [x] Riverpod 상태 관리, go_router 내비게이션, sqflite 저장소 결정
- [x] PoseEngine, RepDetector, FormAnalyzer, CoachVoiceEngine, WorkoutSessionController 경계 정의
- [x] 횟수 감지와 자세 분석의 독립 데이터 흐름 정의
- [x] 프레임 비저장·비전송 개인정보 원칙 정의
- [x] 위험 요소와 대응 방법 문서화
- [x] 전체 요구사항 추적표 작성

## Phase 2 — 앱 골격과 전체 UI 흐름

- [x] 앱 이름, 프로젝트 이름, Android namespace/applicationId, iOS Bundle ID 설정
- [x] 세로 화면 방향 고정
- [x] Material 3 디자인 토큰: 색상, 간격, radius, typography, motion
- [x] go_router 및 정확히 3개 하단 탭: 스쿼트, 기록, 설정
- [x] 기본 진입 탭을 스쿼트로 설정
- [x] 스쿼트 설정: 세트/횟수/휴식, 스테퍼, 직접 입력, 값 보정, 마지막 값 기억
- [x] 카메라 권한 안내 → 촬영 가이드 → 3초 카운트다운 → 캘리브레이션 흐름
- [x] 실시간 운동: 세트, 현재/누적 횟수, 경과 시간, 상태, 자막, 오버레이, pause/end
- [x] 자동 세트 완료 및 휴식 화면 전환
- [x] 휴식: 실제 DateTime 기반 카운트다운, 건너뛰기, +15초, 종료
- [x] 완료: 모든 요약 지표, 자세 요약, 저장 상태, 완료 버튼
- [x] 기록 캘린더/목록/통계/상세 화면과 loading/error/empty 상태
- [x] 설정 언어/음성/리마인더/카메라/개인정보/앱 정보 섹션

## Phase 3 — 로컬 데이터와 복구

- [x] WorkoutPlan 모든 필드 및 저장
- [x] WorkoutSession 모든 필드 및 저장
- [x] WorkoutSet 모든 필드 및 저장
- [x] RepRecord 모든 필드 및 저장
- [x] ReminderSchedule 및 UserPreferences 모든 필드 및 저장
- [x] 세션→세트→반복 FK, 인덱스, schema version gate, transaction
- [x] rep ID unique constraint와 idempotent 저장
- [x] 하루 복수 세션, 날짜 합계, 기간 통계, 개선 포인트 집계
- [x] 진행 세션 journal과 앱 재시작 후 중단 세션 복구
- [x] 마지막 계획과 마지막 기록 보기 복구
- [x] 관찰 불가 자세 항목을 nullable/미평가로 저장

## Phase 4 — 다국어와 RTL

- [x] English `en` ARB
- [x] 한국어 `ko` ARB
- [x] Deutsch `de` ARB
- [x] Español `es` ARB
- [x] Français `fr` ARB
- [x] 日本語 `ja` ARB
- [x] العربية `ar` ARB
- [x] 앱 내 사용자 문자열에 gen-l10n 사용
- [x] 재설치 없이 즉시 locale 변경
- [x] 날짜, 숫자, 단위, 캘린더 현지화
- [x] 아랍어 탭/아이콘/정렬/캘린더/오버레이 RTL 대응 코드
- [x] 스크롤/유연 레이아웃과 작은 화면·200% 글자 smoke test
- [x] 언어별 자연스러운 코칭 변형 문구

## Phase 5 — 요일별 로컬 리마인더

- [x] 월~일 각각 enabled/hour/minute 설정
- [x] 한 요일 시간 복사 및 전체 동일 시간 적용
- [x] 다음 예정 알림 표시
- [x] 알림 활성화 시점에만 권한 요청
- [x] 권한 거절과 시스템 설정 이동 안내
- [x] 언어별 알림 제목과 본문
- [x] 앱 재시작 후 스케줄 유지 코드
- [x] 비활성화 시 취소, 변경 시 취소 후 재등록
- [x] timezone/DST 환경 변경 시 재계산 코드

## Phase 6 — 네이티브 포즈 플러그인

- [x] `packages/motionfit_pose` Flutter API
- [x] Android Kotlin CameraX + MediaPipe Pose Landmarker
- [x] iOS Swift AVCaptureSession + MediaPipeTasksVision
- [x] Texture 기반 프리뷰와 네이티브 프레임 분석
- [x] 원본 프레임을 MethodChannel/EventChannel로 전달하지 않음
- [x] motion-fit3와 동일한 Lite 기본 모델, 1인 검출, 640×480 입력, 기본 30 FPS 적용
- [x] 추론 latency는 FPS 조절에만 사용하고 수신된 유효 33점 결과는 폐기하지 않음
- [ ] OS thermal signal과 실기기 측정 기반 임계값 보정
- [x] Lite/Full/Heavy 고정 체크섬 다운로드 및 플랫폼별 bundle
- [x] newest-frame-only 큐, 추론 15~30 FPS 설정 API
- [x] normalized/world landmarks, confidence, tracking, people count 전달
- [x] 전/후면 전환 및 전면 미러·회전·crop 좌표 계약
- [x] Android ImageReader Texture의 CameraX 회전 메타데이터 미적용 시 세로 프리뷰 보정
- [x] 0명, 전신 누락, 복수 인물, 카메라/모델 오류 상태 처리
- [x] background/interruption 시 안전 정지 코드

## Phase 7 — 자동 횟수 감지

- [x] calibrating → ready → descending → bottom → ascending → completed → ready
- [x] 명시적 paused 상태만 운동을 정지하고, 부분 인식·발목 누락·일시 추적 손실은 현재 운동 phase를 유지
- [x] 좌우 무릎·고관절, 엉덩이/어깨 상대 이동, 속도/방향/confidence/개인 기준
- [x] One Euro, 짧은 median, outlier, confidence 필터와 좌우 가중 결합
- [x] 신체 크기 정규화 및 촬영 각도 판정
- [x] 상태별 진입/이탈 히스테리시스
- [x] standing 복귀 완료와 refractory period
- [x] 짧은 추적 손실 유지, 장기 손실 중지, 손실 중 추측 금지
- [x] 자세 점수를 count 완료 조건에서 분리한 관대한 왕복 감지
- [x] 작은 흔들림/미세 굽힘/중복 완료 억제 로직
- [x] 모든 임계값을 SquatDetectionConfig에 집중
- [x] JSON ReplayPoseEngine 및 회귀 리포트 구조
- [x] 요구된 RepDetector 13개 단위 테스트

## Phase 8 — 자세 분석과 음성 코칭

- [x] Galaxy S24+ 실시간 10회 기록에서 자세 점수·문제 플래그·TTS 시점을 증거로 수집
- [x] 깊이 100점과 깊이 부족이 동시에 발생하던 bottom-window 판정 모순 제거
- [x] 뒤꿈치·무릎 정렬·좌우 균형을 캘리브레이션 기준 변화량으로 판정
- [x] MediaPipe world landmark 3D 관절각을 우선 사용하고 촬영 각도 흔들림 고정
- [x] 추적 공백이 포함된 반복의 속도·제어 코칭 보류
- [x] 카운트 완료 시점상 관찰할 수 없는 완전 기립 오판 코칭 제거
- [x] 최근 3회 누적 근거와 3회 간격으로 코칭 빈도 제어
- [x] 한국어 운동식 횟수 표현과 안내 종류별 속도·피치 적용
- [x] 정상 자세 8회에는 교정 0건, 단발 저신뢰 문제에는 확정 코칭 0건으로 오판 억제 실기기 확인
- [x] 최종 세트 완료와 운동 완료의 중복 음성 제거
- [x] 캘리브레이션을 0.3초/6프레임으로 단축하고 동작 중 기존 기준 프레임 유지
- [x] 재생 중인 안내·격려보다 숫자 카운트를 즉시 선점하도록 TTS queue 수정
- [x] 발목 없이 골반 하강량으로 깊이, 골반 대비 무릎 간격으로 무릎 모임 판정
- [x] 같은 잘못된 자세 2회 반복 시 상체·무릎 교정 음성 실기기 재검증
- [x] 모든 자세 코칭 사이에 최소 1회 간격을 두고 세트 마지막 반복의 뒤늦은 코칭 제거
- [x] 깊이, 상체, 뒤꿈치, 무릎/발끝, 균형, 속도, 제어, 완전 기립 분석
- [x] camera angle별 observability gate
- [x] 한 반복당 우선 개선 포인트 하나
- [x] 낮은 confidence/단일 프레임 문제를 확정하지 않음
- [x] 추적 > 세트 > 횟수 > 자세 > 격려 우선순위 CoachQueue
- [x] 음성 겹침 방지, 3~5초 cooldown, 동일 메시지 억제
- [x] 지속/2회 연속/고신뢰 조건을 만족할 때만 자세 코칭
- [x] 반복당 자세 음성 최대 1회
- [x] 화면 자막과 TTS 동기화
- [x] MediaPipe 33개 landmark와 표준 연결선 전체 표시
- [x] 판정용 tracking과 표시용 tracking 분리, confidence 기반 landmark EMA 안정화
- [x] 얼굴·어깨·상체만 검출되어도 신뢰 가능한 부분 landmark와 연결선 표시
- [x] 화면 밖/저신뢰 관절 연결을 숨겨 잘못된 장거리 연결선 방지
- [x] 실시간 자세 지표 기반 연두/노랑/빨강 pose guide
- [x] system TTS, 속도/테스트/세부 토글
- [x] TTS 미설치/미지원 시 자막 유지와 동일 언어 음성만 선택

## Phase 9 — 운영 품질과 출시 준비

- [x] 카메라 권한/초기화/점유, 모델 로딩, 사람/전신/복수 인물 오류 경로
- [x] 사람 미검출·부분 검출·단일 추론 frame 실패 시 화면을 이탈하지 않고 계속 재인식
- [x] Android 지연 영상과 motion-fit3 코드 비교 후 Lite/1인/640px/30 FPS 인식 경로 이식
- [x] motion-fit3 비교 분석과 공통 `BoxFit.cover` 좌표 계약 반영
- [x] Galaxy S24+ `rotationDegrees=270` 분석 좌표를 세로 normalized/world 좌표로 변환하고 0/90/180/270° 회귀 테스트 추가
- [x] 한쪽 어깨–골반–무릎 관절선만으로 calibration/counting 시작, 발목·발 관절은 선택적 자세 분석으로 분리
- [x] 운동 중 landmark가 잠시 가려져도 trackingLost/paused 전환·재개 안내·진행 중 반복 취소 금지
- [x] 반복 카운트와 자세 코칭 분리: 최저점 후 명확한 상승이면 불완전 기립·나쁜 자세도 카운트하고 문제는 코칭에만 기록
- [x] Galaxy S24+ 신규 세션 첫 3회 연속 동작을 1회차부터 누락 없이 카운트
- [x] Galaxy S24+ 숫자 TTS가 카운트 판정 후 0.005~0.13초 안에 시작됨을 로그로 확인
- [x] Galaxy S24+ 연속 5회 실기기 재검증: 자세 문제 플래그가 있는 5회 모두 개별 저장되고 목표 횟수 정상 종료
- [x] 실시간 카메라를 가리던 지속 텍스트·중앙 카드·그라데이션 제거
- [x] 동일 Android 실기기에서 세로 전신 overlay 지연·정렬 재검증
- [x] background/system interruption, 운동 중 종료 처리 코드
- [x] DB 저장, 알림 권한, TTS 오류 상태와 안내 코드
- [ ] VoiceOver/TalkBack semantics와 읽기 순서
- [ ] 48dp 이상 터치 영역, 충분한 명암비, 색 이외 상태 표현
- [x] UI/추론 분리, latest-frame-only, 15~30 FPS 설정 구조
- [ ] 발열 시 FPS 자동 조절 전후 카운팅 상태 유지
- [ ] Replay 조건별 corpus와 정확도/중복률/지연 리포트
- [x] README, 실행/생성/테스트 명령, 권한/네이티브 설정
- [x] 알려진 제한사항과 실기기 테스트 체크리스트
- [ ] Android/iOS 출시 설정 점검

## 원문 완료 기준 20개

아래는 사용자 관점의 인수 기준이다. source 구현만으로 체크하지 않고 자동 테스트, 실기기 또는 release-candidate 증빙이 있을 때 갱신한다.

- [ ] 1. 세트, 횟수, 휴식 시간을 설정할 수 있다.
- [ ] 2. 카메라에서 스쿼트가 자동 카운트된다.
- [ ] 3. 자세가 좋지 않아도 명확한 스쿼트면 카운트된다.
- [ ] 4. 자세 결과는 카운팅과 별도로 기록된다.
- [ ] 5. 한 동작이 두 번 카운트되지 않는다.
- [ ] 6. 작은 흔들림이 스쿼트로 오탐되지 않는다.
- [ ] 7. 목표 횟수 후 자동으로 휴식 화면으로 이동한다.
- [ ] 8. 휴식 후 다음 세트를 시작할 수 있다.
- [ ] 9. 마지막 세트 후 결과가 저장된다.
- [ ] 10. 기록 캘린더에 운동 날짜가 표시된다.
- [ ] 11. 날짜별 시간/휴식/세트/세트별 횟수/총 횟수가 표시된다.
- [ ] 12. 캘린더/목록/통계 보기를 전환할 수 있다.
- [ ] 13. 7개 언어가 동작한다.
- [ ] 14. 아랍어 RTL이 동작한다.
- [ ] 15. 요일별 알림이 예약/취소된다.
- [ ] 16. 원본 영상은 저장/업로드되지 않는다.
- [ ] 17. 재시작 후 설정과 운동 기록이 유지된다.
- [ ] 18. 모든 핵심 로직에 단위 테스트가 있다.
- [ ] 19. 핵심 화면에 loading/error/empty 상태가 있다.
- [ ] 20. 핵심 기능에 fake data나 미완성 표식이 없다.

## 실측 품질 게이트

- [ ] 지원 조건 Replay/실제 영상 corpus 카운팅 정확도 97% 이상
- [ ] 동일 반복 이중 카운트율 1% 미만
- [ ] 자세 문제가 있는 반복 누락률을 조건별로 측정하고 최소화
- [ ] 일반 standing 흔들림 오탐률을 측정하고 최소화
- [ ] 포즈 추적부터 화면 반영까지 p95 체감 지연 300ms 이내
- [ ] 여러 세트 연속 수행 시 crash와 지속 메모리 증가 없음
