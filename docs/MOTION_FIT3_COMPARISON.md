# motion-fit3 대비 실시간 포즈 비교 분석

비교 대상은 현재 Flutter 앱과 `/Users/nam/projects/motion-fit3/frontend/app/components/MediapipeRealtime.jsx`,
`realtime-mediapipe/poseWorker.js`, `realtime-mediapipe/squat/SquatRealtime.jsx`다.

| 항목 | motion-fit3 증거 | 기존 Flutter 앱의 잘못된 점 | 반영한 수정 |
|---|---|---|---|
| 실시간 모델 | `poseWorker.js`가 모바일 운동에서 `pose_landmarker_lite.task`를 CPU로 실행한다. 주석에도 Full CPU는 실시간 overlay를 유지하기 어렵다고 명시돼 있다. | CPU에서 Full을 기본 실행해 첨부 영상에서 결과가 수 초 늦게 도착했다. 두 앱의 Full 모델 파일도 SHA-256이 달랐다. | motion-fit3의 Lite 모델을 바이트 그대로 Android/iOS에 이식했다. SHA-256은 세 파일 모두 `59929e…574a`로 일치한다. |
| 검출 설정 | `numPoses: 1`, detection/presence/tracking `0.4/0.4/0.5`, worker 입력 최대 폭 640, 약 30 FPS다. | 2명을 960×720에서 `0.25/0.25/0.5`로 찾도록 해 연산량과 저신뢰 오검출이 증가했다. | 양 플랫폼을 1명, 640×480, `0.4/0.4/0.5`, 기본 30 FPS로 맞췄다. |
| 늦은 유효 결과 | 추론 결과 freshness는 캡처 시각이 아니라 결과 수신 시각을 기준으로 갱신하고, 유효 landmark는 즉시 display cache에 넣는다. | 추론 시간이 750ms를 넘으면 MediaPipe가 실제로 반환한 33점까지 화면과 detector에서 전부 폐기했다. | latency는 FPS 관측에만 사용하고, 유효한 33점 결과는 지연값과 무관하게 표시·판정 경로로 전달한다. |
| 카메라와 골격 좌표 | video와 canvas가 같은 intrinsic `videoWidth/videoHeight`를 사용하고, 같은 mirror wrapper 안에서 모두 `object-cover`로 렌더링한다. | Texture는 화면 전체로 늘리고 landmark도 `x * 화면 폭`, `y * 화면 높이`로 따로 계산해 카메라 원본 종횡비가 좌표 계약에 없었다. | 네이티브 입력 크기를 상태로 전달하고 Texture와 CustomPainter 모두 동일한 `BoxFit.cover` 수식으로 배치한다. |
| Android 프레임 기하 | 한 camera video frame을 화면과 추론의 공통 기준으로 사용한다. | Preview와 분석 프레임의 좌표 계약 없이 서로 다른 크기를 사용했고, Galaxy S24+ 실기기에서 `rotationDegrees=270`인 가로 버퍼 landmark를 세로 좌표처럼 전달해 33점 연결이 90° 뒤틀렸다. | Preview와 ImageAnalysis를 같은 640×480 4:3 selector로 묶고, 네이티브 payload 경계에서 normalized/world landmark를 0/90/180/270°별 세로 좌표로 변환한다. |
| 표시와 운동 판정 | 표시용 pose는 운동 readiness와 별도로 저장·스무딩한다. | 초기 구현은 RepDetector tracking 결과가 실패하면 유효한 부분 landmark도 숨겼다. | 현재 landmark payload만 있으면 얼굴·어깨·상체를 표시하고, 전신 조건은 calibration/counting에만 사용한다. |
| 저신뢰 관절 | 일반 자세의 선 표시 visibility 기준은 0.3이며 display 전용 One Euro filter를 사용한다. | 직전 부분 인식 대응에서 점 0.08, 선 0.12까지 낮춰 몸 밖 추정 관절과 긴 선이 표시될 위험이 컸다. | 점 0.20, 선 0.25로 복구하고 0.65를 넘는 비정상 normalized segment를 차단했다. 부분 어깨는 높은 shoulder confidence로 계속 표시된다. |
| 순간 검출 손실 | 마지막 display pose를 최대 1.8초 보존하고 별도 freshness를 관리한다. | 한 프레임만 `noPerson`이어도 골격을 즉시 지워 깜빡였다. | 판정용 원본 frame과 분리된 1.8초 표시 hold 및 display-only EMA를 적용했다. |
| 시각 명확성 | 선 폭 7, 점 반경 5와 glow를 사용한다. | 선 3, 점 3.4로 고해상도 휴대폰에서 골격이 흐릿했다. | 선 4.5, 검정 외곽선, 색상 glow, 점 4.5로 강화했다. |
| 카메라 가림 | 운동 정보 overlay가 있으나 카메라/캔버스 좌표와 별도 레이어다. | 첨부 영상에서 중앙 calibration card, 큰 횟수, 상태, 자막, 상단 pill이 몸과 골격을 직접 가렸다. | 실시간 카메라 화면의 모든 지속 텍스트·카드·그라데이션을 제거하고 하단 아이콘 버튼만 남겼다. |
| 얼굴 landmark | motion-fit3는 얼굴 선과 점을 의도적으로 그리지 않는다. | 기능 오류가 아니라 제품 선택 차이다. | 사용자의 33개 landmark 요구를 우선해 얼굴을 포함한 MediaPipe 33점을 유지한다. |
| 제한된 촬영 공간 | 전신 가시성은 정확도 권장 조건이지 세션을 중단하는 UI 상태가 아니다. | 발목·발이 화면 밖이면 `partialBody`로 분류하고 스쿼트 측정을 막았으며, 추적 손실 후 “다시 들어오면 이어서” 안내와 함께 진행 중 반복을 취소했다. | 한쪽 어깨–골반–무릎 체인만 보이면 측정을 시작한다. 발목 기반 무릎 각도·뒤꿈치·균형 평가는 선택적으로 생략하고, 운동 중 부분 인식은 phase와 타이머를 유지한다. |

## Galaxy S24+ 실기기 증거

- 수정 전 좌표 로그는 코 `y=0.80`, 어깨 `y=0.68`, 골반 `y=0.39`, 발목 `y≈0.00`으로 신체의 세로 순서가 역전돼 있었다.
- `rotationDegrees=270` 변환 후 코 `y=0.15~0.18`, 어깨 `y=0.26~0.32`, 골반 `y≈0.60`, 발목 `y≈1.03~1.06`으로 화면의 머리→어깨→골반→발 순서와 일치했다.
- 좌표 변환은 표시용 골격과 스쿼트 판정이 공유하는 native payload에 적용해 두 경로의 좌표계를 일치시켰다.
- 카운트 수정 전 40초 실영상에서는 약 7회의 하강–상승 중 새 기록이 4회뿐이었고, 두 기록의 길이가 `12.9초`, `8.0초`여서 연속 동작이 합쳐졌음을 DB로 확인했다.
- 원인은 자세 점수 자체가 아니라 반복 완료에도 완전 기립 조건을 재사용한 것이었다. 최저점 후 세로 이동·고관절·무릎 중 2개 이상이 명확히 회복되면 카운트하고, 완전 기립 여부는 코칭 분석에만 남겼다.
- 수정 APK 실기기 재검증에서 연속 5회가 각각 `2.50/1.90/1.60/2.14/2.27초` 기록으로 5/5 저장됐다. 모든 반복에 `incompleteLockout` 등 자세 문제가 있었지만 총 횟수는 10/10으로 정상 완료됐다.

## 남은 실기기 확인

- 전·후면 카메라에서 어깨선, 골반선, 팔·다리 선이 실제 관절 중심에 놓이는지 확인한다.
- 화면 모서리에서 `BoxFit.cover` crop 뒤에도 좌우 정렬이 유지되는지 확인한다.
- 얼굴/어깨만 보일 때 부분 골격은 표시되지만 calibration과 count가 진행되지 않는지 확인한다.
- 연두·노랑·빨강 변경 중 골격 좌표가 튀거나 과거 프레임에 남지 않는지 확인한다.
