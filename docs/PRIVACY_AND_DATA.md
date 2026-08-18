# 개인정보 및 데이터 처리

이 문서는 구현 기준의 데이터 흐름과 출시 전 개인정보 감사를 위한 기술 문서다. 스토어와 사용자에게 제공할 최종 법률 문서는 실제 배포 지역, SDK, 백업, 지원 채널을 반영해 별도로 검토한다.

## 구현 원칙

- 카메라 추론은 Android/iOS 기기에서 수행한다.
- 원본 영상, 이미지, 카메라 프레임을 앱 파일이나 SQLite에 저장하지 않는다.
- 원본 영상이나 프레임을 Flutter MethodChannel/EventChannel로 전달하지 않는다.
- 앱 코드에는 영상·프레임을 서버로 업로드하는 경로가 없다.
- 횟수 감지에 사용한 landmark와 world landmark는 런타임 처리 후 운동 DB에 저장하지 않는다.
- 로그인, 회원가입, 클라우드 동기화는 현재 앱 범위에 없다.
- Firebase Analytics에는 화면·퍼널·오류 상태를 전송하되 영상, landmark, 관절 각도, 자유 입력, 사용자 식별자, 정확한 운동 시각은 전송하지 않는다.
- 운동 횟수·운동 시간·추적 손실·confidence는 분석 이벤트에서 구간(bucket) 값으로만 전송한다.

## 데이터 흐름

| 데이터 | 처리 위치 | 영속 저장 | 네트워크 전송 |
|---|---|---:|---:|
| 카메라 픽셀 프레임 | 네이티브 camera/MediaPipe 메모리 | 아니요 | 앱 코드 기준 아니요 |
| normalized/world pose landmark | 네이티브→Flutter 런타임 stream | 아니요 | 앱 코드 기준 아니요 |
| 추적 상태·confidence·지연 | 런타임 controller | 운동 결과에 필요한 일부 수치만 | 앱 코드 기준 아니요 |
| 세션·세트·반복 기록 | SQLite `motionfit.db` | 예 | 아니요 |
| 반복별 점수·개선 항목 | SQLite `motionfit.db` | 예 | 아니요 |
| 리마인더 요일·시간 | SQLite + OS 알림 예약 | 예 | OS 알림 서비스 사용 |
| 언어·음성·카메라·마지막 계획 | SharedPreferences | 예 | 아니요 |
| 음성 문장 | 시스템 TTS 엔진 | 앱에 저장하지 않음 | 엔진/OS 정책은 기기별 확인 필요 |
| 퍼널·화면·권한 결과·광고 상태 | Firebase Analytics | Firebase 정책에 따름 | 예, 구간화·비식별 이벤트 |
| 비정상 종료·비치명 오류·앱 상태 | Firebase Crashlytics | Firebase 정책에 따름 | 예, 영상·landmark·사용자 입력 제외 |
| 광고 요청·노출 | Google Mobile Ads | SDK/동의 정책에 따름 | 네이티브는 첫 유효 운동 완료 후, 전면은 정상 운동 3회 완료 후 요청 |

개발용 `ReplayPoseEngine` fixture는 landmark-only JSON을 읽는다. 이는 테스트 자산이며 production 카메라 세션을 자동 기록하는 기능이 아니다. corpus를 수집할 때도 별도의 참여 동의, 비식별화, 보관 기간, 접근 통제를 정의해야 한다.

## 저장되는 운동 정보

- 운동 시작/종료 시각과 완료/중단 상태
- 계획한 세트, 횟수, 휴식 시간
- 완료 세트와 총 반복 수
- 실제 운동·휴식·전체 시간, 평균 반복 시간
- 반복 시작/바닥/완료 시각
- 깊이·제어·균형·전체 자세 점수 중 관찰 가능한 값
- 자세 개선 항목, 촬영 각도, detection confidence

영상·이미지·픽셀·landmark 배열을 위한 DB column은 없다. 관찰할 수 없는 자세 지표는 nullable 값 또는 `notObservable` 상태로 처리하며 추측값을 저장하지 않는 것이 원칙이다.

## 저장 위치, 보존, 삭제

- SQLite와 SharedPreferences는 운영체제 앱 sandbox에 저장된다.
- 앱 자체 데이터베이스 암호화 계층은 현재 없다. 잠금 화면, 파일 보호, 기기 암호화 등 운영체제 보호에 의존한다.
- 운동 기록은 사용자가 설정의 데이터 삭제를 실행하거나 앱을 제거할 때까지 보존된다.
- 설정의 데이터 삭제는 운동 반복·세트·세션·계획 테이블을 transaction으로 삭제한다. 언어/음성/카메라 선호와 리마인더 설정은 현재 그 동작의 삭제 범위가 아니다.
- 삭제 전에 확인 대화상자를 표시하며 삭제 실패를 사용자에게 알린다.

운영체제 백업 제외 정책은 현재 명시적으로 확정되지 않았다. Android Auto Backup 또는 iOS backup이 앱 데이터를 복원할 수 있는지 출시 전에 결정하고, 실제 동작·개인정보 처리방침·Data Safety/Privacy Nutrition Label을 일치시켜야 한다. 로컬 삭제가 이미 생성된 OS 백업 사본까지 즉시 삭제한다는 표현은 사용하지 않는다.

## 권한 최소화

| 권한/기능 | 요청 시점 | 목적 |
|---|---|---|
| 카메라 | 운동 시작 시 | 온디바이스 스쿼트 감지와 프리뷰 |
| 알림 | 첫 리마인더 활성화 시 | 사용자가 지정한 요일별 운동 알림 |
| 부팅 완료(Android) | 별도 prompt 없음 | 저장된 로컬 알림 재예약 |
| ATT(iOS) | 온보딩 완료 직후, 메인 화면 진입 전 | 광고 추적 선택 |
| UMP | 첫 유효 운동 완료 후, 네이티브 광고 SDK 초기화 전 | 지역별 광고 동의 |

마이크, 사진 라이브러리, 미디어, 저장소, 위치, 연락처, 건강 데이터 권한은 현재 요청하지 않는다. 권한이 거부되어도 기록과 설정은 계속 사용할 수 있다.

## TTS와 알림

코칭은 `flutter_tts`를 통한 시스템 TTS를 사용한다. 앱은 오프라인 사용 가능한 시스템 음성을 우선 구성하지만, 설치된 TTS provider가 실제로 네트워크를 사용하는지 여부는 기기와 사용자 설정에 따라 달라질 수 있다. 출시 QA는 지원 언어별 오프라인 음성 설치/미설치 상태와 fallback을 확인해야 한다.

리마인더는 OS 로컬 알림으로 예약한다. 알림 제목과 본문에는 민감한 운동 결과를 포함하지 않는다. Android에서는 exact alarm을 먼저 시도하고 운영체제가 허용하지 않으면 inexact allow-while-idle로 대체한다.

## 제3자 구성 감사

현재 주요 네이티브 구성은 MediaPipe Tasks Vision, CameraX, Firebase Analytics/Crashlytics, Google Mobile Ads, flutter_local_notifications, flutter_tts, sqflite다. 출시 시점의 실제 binary와 lockfile을 기준으로 다음을 확인한다.

- 각 SDK의 개인정보, telemetry, diagnostic, 데이터 수집 정책
- Apple privacy manifest와 required-reason API 선언
- Google Play SDK Index 및 Data Safety 답변
- 모델 및 SDK 라이선스/재배포 고지
- 네트워크 캡처로 운동 중 예상하지 않은 요청이 없는지 확인
- Analytics/Crashlytics/광고 SDK의 명시적 데이터 목록, 보존, consent 정책과 스토어 공개 항목 일치

플러그인의 `PrivacyInfo.xcprivacy`는 현재 tracking/수집 없음으로 선언되어 있다. 이 파일만으로 전체 앱과 모든 종속 SDK의 공개 의무가 충족된다고 간주하지 않는다.

## 출시 공개 문서에 포함할 내용

- 온디바이스 카메라 처리와 영상 비저장·비업로드 원칙
- 저장되는 운동 수치와 보존 기간
- 데이터 삭제 범위와 방법
- OS backup 사용 여부
- TTS/알림 및 제3자 SDK의 실제 데이터 관행
- Firebase Analytics/Crashlytics와 Google Mobile Ads 사용, ATT/UMP 요청 시점
- 문의처, 적용일, 변경 고지 방식
- 앱이 의료 진단·치료 기기가 아니며 자세 코칭이 전문 의료 조언을 대체하지 않는다는 안내

공개 문구는 구현과 네트워크/백업 실측 결과를 근거로 작성한다. 확인하지 않은 범위까지 “어떤 데이터도 외부로 나가지 않는다”라고 확장해 주장하지 않는다.
