# 알려진 제한사항

이 문서는 현재 구현과 출시 완료 사이의 차이를 명시한다. 체크가 필요한 항목을 숨기거나 실측되지 않은 품질 수치를 완료로 간주하지 않는다.

## 품질 근거

- 97% 카운팅 정확도, 1% 미만 이중 카운트율, p95 300ms 이내 반영 지연은 목표이며 아직 실제 영상 corpus와 실기기 측정으로 입증되지 않았다.
- 커밋된 corpus는 synthetic smoke fixture다. 결정성과 평가기 동작은 확인할 수 있지만 production 정확도 주장의 근거가 아니다.
- 실제 corpus는 최소 100 clips, 10 subjects, 500 labeled repetitions, 20 negative clips를 충족하고 human-labeled provenance를 가져야 97% qualification 대상으로 인정된다.
- RepDetector 단위 테스트는 정상 1회/10회, 얕은 왕복, 상체/뒤꿈치/복합 bad-form, standing jitter, 좌우 흔들림, 짧고 긴 추적 손실, pause/resume, refractory, 중단 하강을 포함한다. 카메라 흔들림과 다양한 실제 촬영 조건은 영상 corpus로 추가 검증해야 한다.
- 데이터 테스트는 저장·재시작 복구·하루 복수 세션·일별 집계·시간·중단 처리를 포함한다. process kill, 저장 공간 부족, DB 손상은 fault injection이 남아 있다.
- 7개 언어 로딩, Arabic RTL, 320×568/200% 글자 smoke test가 있다. 전체 화면의 golden, dark mode, VoiceOver/TalkBack 실제 접근성 감사는 남아 있다.

## 포즈와 자세 분석

- 2D landmark 기반 깊이, 뒤꿈치, 무릎 정렬, 좌우 균형은 카메라 각도·의복·조명·가림에 영향을 받는다. observability gate가 있더라도 실제 조건별 false coaching을 측정해야 한다.
- motion-fit3와 같은 실시간성을 위해 Lite 모델에서 한 pose만 찾는다. 여러 사람이 화면에 있으면 가장 우세한 한 명이 선택될 수 있으므로 안내 단계에서 한 명만 촬영하도록 요구한다.
- 최근 45개 추론 지연 평균으로 FPS를 15~30 범위에서 조정한다. OS thermal signal을 직접 반영하는 정책과 기기별 임계값 실측은 남아 있다.
- 모델 전환 중 detector 상태 유지 계약은 코드에 있으나 장시간 실기기 세션으로 메모리·발열·상태 연속성을 확인해야 한다.
- 전면 mirror, sensor rotation, preview crop과 landmark overlay 정렬은 Android/iOS 기기·카메라별 fixture 검증이 필요하다.
- pose guide의 연두/노랑/빨강은 현재 frame에서 관찰 가능한 지표를 빠르게 분류한 보조 피드백이다. 저장되는 최종 자세 평가는 반복 전체 구간을 별도로 분석하므로 색상 하나를 의학적·절대적 판정으로 해석하면 안 된다.
- 지원하기로 결정한 최소 조명, 카메라 거리, 체형/신장, 복장, 촬영 각도 범위가 실측 데이터로 아직 고정되지 않았다.

## TTS와 알림

- 시스템 TTS 음성 품질과 오프라인 가능 여부는 OS, 설치 음성, 기본 TTS provider에 따라 다르다. 지원 언어 음성이 없을 때 자막은 유지되지만 기대한 현지어 음성이 재생되지 않을 수 있다.
- Android 로컬 알림은 `inexactAllowWhileIdle`를 사용하므로 Doze/OEM 절전 정책에 따라 정확한 분 단위보다 늦게 표시될 수 있다.
- 재부팅, 앱 업데이트, timezone 변경, DST 전환, 알림 권한 변경은 실제 Android/iOS 환경에서 확인해야 한다.
- 알림 tap payload가 원하는 스쿼트 탭으로 이동하는지 cold/warm launch 모두 검증해야 한다.

## 저장과 복구

- SQLite schema version은 1이며 실제 구버전→신버전 migration 사례는 아직 없다. schema를 변경하기 전에 migration과 upgrade fixture를 먼저 추가해야 한다.
- SQLite는 앱 수준으로 암호화되지 않는다.
- 운동 기록 삭제는 운동 plan/session/set/rep만 대상으로 하며 리마인더와 일반 선호값은 유지된다.
- Android/iOS 운영체제 백업 포함/제외 정책은 출시 전에 명시적으로 결정해야 한다.
- 앱 강제 종료, 저장 중 process kill, 저장 공간 부족, DB 손상 후 복구 UX는 실기기 fault injection이 필요하다.

## 출시 구성

- Android release는 debug key로 fallback하지 않고 `android/key.properties`가 없으면 실패한다. 실제 업로드 키와 Play App Signing 설정 전에는 Play Console 배포 artifact가 아니다.
- 전용 iOS AppIcon과 Android legacy launcher icon 원본은 포함되어 있다. Android adaptive icon, splash, 스토어 screenshot/feature graphic, 최종 앱 이름·설명·지원 URL·개인정보 처리방침 URL은 출시 브랜드 자산으로 확정해야 한다.
- iOS Team 값은 로컬 프로젝트 값이므로 실제 배포 계정, provisioning, certificate와 일치하는지 확인해야 한다.
- MediaPipe 모델 세 개가 각 플랫폼 artifact에 포함되어 앱 크기가 증가한다. 모델/SDK 라이선스, 재배포, 고지, 다운로드 크기를 검토해야 한다.
- App Store Privacy Nutrition Label, Google Play Data Safety, 연령 등급, 수출 규정, 건강/운동 면책 문구는 실제 배포 설정을 기준으로 작성해야 한다.
- crash-free 장시간 운동, 저메모리, 전화/화면 잠금/멀티태스킹 interruption, 카메라 점유 오류를 지원 OS와 주요 OEM에서 반복 검증해야 한다.

완료 판단과 증빙 위치는 [출시 체크리스트](RELEASE_CHECKLIST.md)에 기록한다.
