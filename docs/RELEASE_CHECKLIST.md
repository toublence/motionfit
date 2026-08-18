# 실기기 및 스토어 출시 체크리스트

모든 항목은 실제 출시 후보 AAB/IPA와 동일한 commit, lockfile, 모델 체크섬으로 확인한다. 체크할 때 날짜, 담당자, 기기/OS, artifact SHA-256, 로그·영상·리포트 링크를 릴리스 기록에 남긴다. 코드가 존재한다는 사실만으로 실기기 또는 실측 항목을 완료 처리하지 않는다.

## 1. 릴리스 기준선

- [ ] 출시 commit/tag가 고정되어 있고 작업 트리가 깨끗하다.
- [ ] `pubspec.lock`, Pod lockfile, Gradle 의존성 결과가 출시 commit에 고정되어 있다.
- [ ] Flutter/Dart, Xcode, CocoaPods, Java, Android SDK/NDK 버전을 기록했다.
- [ ] 앱 버전 `versionName/versionCode`와 iOS version/build가 이전 배포보다 증가했다.
- [ ] `flutter pub get`이 clean 환경에서 성공했다.
- [ ] `flutter gen-l10n` 후 생성물 차이가 없다.
- [ ] `flutter analyze`가 오류와 경고 없이 성공했다.
- [ ] `flutter test`가 전체 성공했다.
- [ ] 네이티브 Android/iOS plugin 단위·통합 테스트 결과를 기록했다.
- [ ] dependency/license/security 검토 결과와 예외 승인자를 기록했다.

## 2. 포즈 모델과 공급망

- [ ] `./tool/download_pose_models.sh`가 clean 환경에서 성공했다.
- [ ] Lite SHA-256이 `59929e1d1ee95287735ddd833b19cf4ac46d29bc7afddbbf6753c459690d574a`다.
- [ ] Heavy SHA-256이 `64437af838a65d18e5ba7a0d39b465540069bc8aae8308de3e318aad31fcbc7b`다.
- [ ] Full SHA-256이 `4eaa5eb7a98365221087693fcc286334cf0858e2eb6e15b506aa4a7ecdcec4ad`다.
- [ ] Android와 iOS의 각 모델 사본이 바이트 단위로 동일하다.
- [ ] 출시 artifact 내부에 Lite, Full, Heavy 모델이 올바른 이름으로 포함되어 있다.
- [ ] 모델 누락/손상 시 앱이 crash 대신 현지화된 복구 안내를 표시한다.
- [ ] MediaPipe SDK와 모델의 라이선스·재배포 조건·고지 문구를 법무/출시 담당자가 승인했다.
- [ ] 모델 변경 시 이전 corpus 대비 정확도, 지연, 발열, 크기 회귀를 승인했다.

## 3. Android 배포 구성

- [ ] applicationId와 namespace가 `com.namslab.motionfit.squat`다.
- [ ] minSdk 24와 현재 Play target API 정책을 충족한다.
- [ ] release artifact가 debug signing을 참조하지 않는지 서명 정보를 확인했다.
- [ ] 업로드 키/keystore가 저장소 밖의 안전한 secret으로 관리된다.
- [ ] Play App Signing과 key rotation/recovery 담당자가 정해져 있다.
- [ ] AAB가 release certificate로 서명되고 `bundletool` 검사가 성공한다.
- [ ] 지원 ABI와 64-bit 요구사항을 충족하며 불필요한 native binary가 없다.
- [ ] `CAMERA`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`만 의도대로 포함된다.
- [ ] 병합 manifest에 마이크·사진·미디어·저장소·위치 권한이 추가되지 않았다.
- [ ] portrait와 edge-to-edge/SafeArea가 phone/tablet에서 정상이다.
- [ ] notification channel 이름·설명·아이콘이 출시 품질이다.
- [ ] launcher icon, adaptive icon, splash가 최종 브랜드 자산이다.
- [ ] minify/resource shrink 정책과 crash symbol/mapping 보관 방식을 확정했다.
- [ ] internal testing track 새 설치와 이전 버전 업그레이드를 통과했다.

## 4. iOS 배포 구성

- [ ] Bundle Identifier가 `com.namslab.motionfit.squat`다.
- [ ] deployment target iOS 15.0과 지원 기기 범위를 확인했다.
- [ ] 실제 배포 Team, Distribution certificate, App Store profile로 archive했다.
- [ ] version/build가 App Store Connect 값과 일치한다.
- [ ] `NSCameraUsageDescription`이 7개 지원 언어에서 자연스럽게 표시된다.
- [ ] portrait orientation이 iPhone/iPad 지원 정책과 일치한다.
- [ ] `motionfit_pose_models.bundle`에 세 모델이 포함되어 있다.
- [ ] 앱과 모든 Pods의 privacy manifest/required-reason API를 실제 archive 기준으로 감사했다.
- [ ] 최종 AppIcon, launch 화면, display name이 모든 locale에서 올바르다.
- [ ] archive validation과 TestFlight processing이 성공한다.
- [ ] TestFlight 새 설치와 이전 build 업그레이드를 통과했다.

## 5. 권한과 최초 실행

- [ ] 첫 실행만으로 카메라·알림 권한을 선요청하지 않는다.
- [ ] 운동 시작 시점에만 카메라 권한 안내와 OS prompt가 표시된다.
- [ ] 카메라 거부 후 기록·설정 탭을 계속 사용할 수 있다.
- [ ] 재요청 가능한 거부와 영구 거부/제한 상태의 문구와 동작이 다르다.
- [ ] 영구 거부에서 시스템 설정으로 이동하고 복귀 후 상태가 갱신된다.
- [ ] 첫 리마인더 활성화 시점에만 알림 권한을 요청한다.
- [ ] 알림 거부 후 스위치가 잘못 켜진 상태로 남지 않는다.
- [ ] 알림 거부에서 시스템 설정 안내와 복귀 동작이 정상이다.
- [ ] 마이크·사진·저장소 등 범위 밖 권한 prompt가 표시되지 않는다.

## 6. 핵심 운동 흐름

- [ ] 세트, 세트당 횟수, 휴식 시간을 stepper로 변경할 수 있다.
- [ ] 직접 숫자 입력이 가능하고 범위를 벗어난 값은 안전하게 보정된다.
- [ ] 마지막 운동 계획이 앱 재시작 후 복구된다.
- [ ] 카메라 권한→어깨·골반·무릎 촬영 가이드→3초 countdown→1~2초 calibration 순서가 정확하다.
- [ ] 가이드에 어깨부터 무릎, 안정된 카메라, 한 명, 측면/사선, 조명 안내가 모두 있다.
- [ ] 한쪽 어깨–골반–무릎 관절선이 올바르게 보일 때 calibration이 완료된다.
- [ ] calibration 실패/사람 없음/핵심 관절 누락/복수 인물에 올바른 안내가 표시된다.
- [ ] 현재 세트/전체 세트, 현재/목표 횟수, 누적 횟수, 시간, 상태, 자막이 보인다.
- [ ] 큰 횟수와 코칭 overlay가 사용자의 몸을 과도하게 가리지 않는다.
- [ ] 낮은 confidence에서 skeleton이 불안정하게 깜빡이지 않는다.
- [ ] pause/resume 후 횟수와 세션 시간이 안전하게 이어진다.
- [ ] 전·후면 전환 후 카운팅과 overlay 좌표가 유지된다.
- [ ] 목표 횟수에서 set 완료 이벤트가 한 번만 발생한다.
- [ ] 마지막 set이 아니면 자동으로 휴식 화면으로 이동한다.
- [ ] 휴식 countdown이 wall-clock 기준으로 정확하다.
- [ ] background 후 복귀해도 휴식 시간이 늘어나거나 멈추지 않는다.
- [ ] 휴식 건너뛰기, 15초 추가, 운동 종료가 각각 한 번만 처리된다.
- [ ] 다음 set 시작 시 set index와 현재 횟수가 정확히 초기화된다.
- [ ] 마지막 set 후 완료 화면과 DB 저장이 정확히 한 번 발생한다.
- [ ] 완료 화면의 총 횟수, 세트, 운동/휴식/전체 시간, 평균 반복, 개선점이 DB와 일치한다.
- [ ] 저장 실패 상태, 재시도, 성공 상태를 실제 fault injection으로 확인했다.
- [ ] 운동 중 종료가 interrupted session으로 보존된다.
- [ ] process kill 후 복구 카드에서 재개 또는 종료할 수 있고 중복 rep가 없다.

## 7. RepDetector 검증

- [ ] 정상 스쿼트 1회를 정확히 1회 카운트한다.
- [ ] 연속 10회를 정확히 10회 카운트한다.
- [ ] 얕지만 명확한 하강·상승은 카운트한다.
- [ ] 상체 숙임이 있어도 명확한 왕복은 카운트한다.
- [ ] 뒤꿈치 들림이 있어도 명확한 왕복은 카운트한다.
- [ ] 무릎 정렬/균형/속도 문제 플래그가 있어도 명확한 왕복은 카운트한다.
- [ ] 작은 무릎 굽힘과 standing jitter는 카운트하지 않는다.
- [ ] 좌우 몸 흔들림과 팔 움직임은 카운트하지 않는다.
- [ ] 카메라 흔들림은 카운트하지 않는다.
- [ ] 하강 중 멈춘 뒤 기립해도 이중 카운트하지 않는다.
- [ ] 완료 직후 refractory 구간에서 같은 반복을 다시 세지 않는다.
- [ ] 짧은 landmark 손실 후 복구해도 중복 카운트하지 않는다.
- [ ] 긴 landmark 손실 중 움직임을 추측해 카운트하지 않는다.
- [ ] pause 중 움직임을 카운트하지 않고 resume 시 기립 재획득 후 안전하게 시작한다.
- [ ] timestamp 역행/중복 frame을 무시하고 count가 바뀌지 않는다.
- [ ] 성능 저하로 FPS가 바뀌어도 detector count/state가 초기화되지 않는다.

## 8. FormAnalyzer와 코칭

- [ ] 자세 분석 결과가 RepDetector 완료 조건이나 count 감소에 사용되지 않는다.
- [ ] 깊이, 상체, 뒤꿈치, 무릎/발끝, 균형, 하강/상승 속도, 제어, 기립을 반복별로 기록한다.
- [ ] 측면에서 무릎 정렬처럼 관찰할 수 없는 항목은 미평가다.
- [ ] 정면에서 깊이/뒤꿈치처럼 신뢰하기 어려운 항목은 미평가다.
- [ ] 낮은 confidence 문제를 확정하거나 음성 코칭하지 않는다.
- [ ] 단일 frame 문제보다 지속 비율을 사용한다.
- [ ] 한 반복에서 primary 개선점 하나만 선택한다.
- [ ] 같은 문제가 2회 연속이거나 명확한 고신뢰일 때만 자세 음성이 나온다.
- [ ] 한 반복에서 자세 음성은 최대 한 번이다.
- [ ] 우선순위가 추적→세트/휴식→횟수→자세→격려 순서다.
- [ ] 음성이 겹치지 않고 오래된 메시지는 폐기된다.
- [ ] 동일 메시지 3~5초 cooldown이 지켜진다.
- [ ] 모든 음성 문장이 자막으로도 표시된다.
- [ ] 비난/실패 표현 대신 짧고 자연스러운 개선 문구를 사용한다.
- [ ] 횟수/자세/격려별 toggle과 전체 음성 toggle이 즉시 반영된다.
- [ ] TTS 속도와 음성 테스트가 7개 언어에서 동작한다.
- [ ] 현지어 음성 없음/엔진 미설치 시 crash하지 않고 자막을 유지한다.

## 9. 기록과 데이터 정확성

- [ ] session→set→rep FK와 unique 제약이 실제 DB에서 적용된다.
- [ ] 같은 rep event를 재전달해도 record와 count가 중복되지 않는다.
- [ ] 하루 여러 session이 분리되고 하루 총합이 정확하다.
- [ ] calendar에서 운동 날짜 강도 표시와 날짜 선택이 정상이다.
- [ ] 선택 날짜의 시작/종료, 운동/휴식/전체 시간, 세트별 횟수, 총 횟수, 자세 요약이 정확하다.
- [ ] 목록이 최신순이며 카드에서 detail로 이동한다.
- [ ] 통계 7일, 30일, 이번 달, 전체, 사용자 기간이 경계 timezone에서 정확하다.
- [ ] 총 횟수, 운동일, 총 시간, 평균 세트/횟수, 날짜별 chart, 빈도 높은 개선점이 원본 record와 일치한다.
- [ ] 마지막 calendar/list/statistics 보기 방식이 재시작 후 복구된다.
- [ ] 기록 loading/error/empty 상태와 운동 시작 행동이 정상이다.
- [ ] 설정의 데이터 삭제가 확인 후 workout tables만 삭제하고 UI를 갱신한다.
- [ ] DB 저장 공간 부족, 읽기 실패, 손상 상황의 사용자 안내를 확인했다.
- [ ] schema upgrade fixture로 기존 사용자 데이터 보존을 확인했다.

## 10. 리마인더와 시간대

- [ ] 월요일~일요일 각각 enabled, hour, minute를 저장한다.
- [ ] 한 요일 시간을 다른 요일에 복사한다.
- [ ] 한 시간을 모든 요일에 적용한다.
- [ ] 다음 예정 알림이 locale/timezone에 맞게 표시된다.
- [ ] 비활성화하면 해당 요일 알림이 취소된다.
- [ ] 시간을 변경하면 이전 예약이 제거되고 새 예약 하나만 남는다.
- [ ] 앱 재시작 후 예약이 유지된다.
- [ ] Android 재부팅과 앱 업데이트 후 예약이 복구된다.
- [ ] timezone 변경 후 enabled 알림이 새 local time으로 재등록된다.
- [ ] DST 시작/종료 경계에서 주간 알림의 wall-clock 시간이 의도와 일치한다.
- [ ] locale 변경 후 예약된 제목/본문이 새 언어로 갱신된다.
- [ ] 알림 tap이 cold/warm launch 모두에서 의도한 앱 화면을 연다.
- [ ] Android Doze/OEM 절전의 지연 특성을 문서와 사용자 기대에 반영했다.

## 11. 현지화, RTL, 접근성

- [ ] `en`, `ko`, `de`, `es`, `fr`, `ja`, `ar`의 모든 ARB key가 일치한다.
- [ ] 앱 재설치 없이 locale을 변경하고 시스템 locale로 복귀한다.
- [ ] 날짜, 시간, 숫자, 백분율, 단위가 locale에 맞다.
- [ ] 독일어/프랑스어 긴 문장에서 overflow나 잘림이 없다.
- [ ] 아랍어에서 NavigationBar, 뒤로가기, 텍스트, calendar, overlay가 올바른 RTL이다.
- [ ] 숫자와 단위의 bidi 읽기 순서가 아랍어에서 명확하다.
- [ ] 320dp급 작은 화면과 지원 최대 화면에서 핵심 행동이 보인다.
- [ ] 시스템 text scale 100%, 150%, 200%에서 시작/종료/횟수가 잘리지 않는다.
- [ ] light/dark/high-contrast 상태에서 텍스트와 overlay 대비를 측정했다.
- [ ] 주요 touch target이 최소 48dp다.
- [ ] 색 이외의 icon/text로 성공·경고·추적 상태를 구분한다.
- [ ] TalkBack과 VoiceOver에서 탭, stepper, calendar 날짜, 운동 control에 의미 있는 label이 있다.
- [ ] 운동 중 횟수→세트→상태→control의 읽기 순서가 명확하다.
- [ ] reduce motion/화면 회전/동적 글자 등 플랫폼 접근성 설정을 확인했다.

## 12. 카메라, lifecycle, 오류 복구

- [ ] 전면 카메라 portrait preview가 찌그러지지 않고 mirror 좌표가 overlay와 일치한다.
- [ ] 후면 카메라 portrait preview와 overlay가 일치한다.
- [ ] 서로 다른 sensor orientation/aspect ratio 기기에서 crop transform이 일치한다.
- [ ] 카메라가 다른 앱에서 사용 중일 때 crash하지 않고 재시도 안내가 나온다.
- [ ] 카메라 없는/비활성화/정책 제한 기기의 오류가 분리된다.
- [ ] 모델 로딩 실패가 count 추측 없이 안전하게 중단된다.
- [ ] 사람 없음, 핵심 관절 누락, 복수 인물 상태가 각각 안정적으로 처리되며 운동 중 자동 일시정지하지 않는다.
- [ ] 앱 background/foreground에서 camera와 inference가 안전하게 pause/resume된다.
- [ ] 전화, 화면 잠금, Control Center/notification shade, 오디오 interruption을 처리한다.
- [ ] 운동 중 앱 process 종료 후 DB가 손상되지 않는다.
- [ ] 반복적인 start/dispose와 카메라 전환에서 texture/executor/capture session 누수가 없다.

## 13. 성능과 안정성

- [ ] 지원 기기 목록과 최소 성능 등급을 정의했다.
- [ ] Flutter UI frame time에서 60 FPS 목표와 jank 비율을 측정했다.
- [ ] pose inference가 15~30 FPS 정책 안에서 UI thread를 차단하지 않는다.
- [ ] queue depth가 1이고 오래된 inference frame이 누적되지 않음을 profile로 확인했다.
- [ ] pose timestamp부터 화면 count 반영까지 p50/p95/p99를 측정했다.
- [ ] p95 반영 지연이 지원 조건에서 300ms 이내다.
- [ ] Lite의 10분/30분 운동 중 CPU, memory, battery, 온도, FPS를 기록했다.
- [ ] 저사양/고온에서 FPS 조절 기준과 복귀 기준을 확정했다.
- [ ] 모델 전환 전후 count, phase, calibration, set/session이 유지된다.
- [ ] 여러 set 연속 운동에서 crash가 없고 memory가 지속 증가하지 않는다.
- [ ] 저메모리, 저장 공간 부족, 앱 강제 종료 fault injection을 통과했다.
- [ ] release build에서 debug log에 landmark, 운동 기록, 민감 정보가 출력되지 않는다.

## 14. 실제 corpus 품질 게이트

- [ ] corpus 수집에 참여 동의, 사용 범위, 보관/삭제, 접근 통제가 있다.
- [ ] ground truth를 독립적으로 검수하고 label 기준을 문서화했다.
- [ ] 최소 100 clips, 10 subjects, 500 repetitions, 20 negative clips를 충족한다.
- [ ] 키/체형, 밝음/어두움, 넓은 옷, 가까움/멀음 조건이 포함된다.
- [ ] 정면, 측면, 사선 조건이 포함된다.
- [ ] 빠름, 느림, 얕음, 불안정 자세가 포함된다.
- [ ] standing 흔들림, 팔 움직임, 카메라 흔들림, 부분 동작 negative가 포함된다.
- [ ] train/tuning과 최종 holdout corpus를 분리했다.
- [ ] evaluator 입력에는 이미지/픽셀 payload가 없음을 검사했다.
- [ ] exact-count accuracy가 holdout에서 97% 이상이다.
- [ ] count precision이 holdout에서 97% 이상이다.
- [ ] count recall이 holdout에서 97% 이상이다.
- [ ] 동일 반복 이중 카운트율이 1% 미만이다.
- [ ] 자세 문제가 있는 반복의 누락률을 조건별로 보고했다.
- [ ] standing/negative clip 오탐률을 조건별로 보고했다.
- [ ] 카메라 각도별 form issue precision/recall과 notObservable 정확도를 보고했다.
- [ ] 모델/임계값 변경 전후 회귀 리포트를 승인했다.
- [ ] 최종 리포트에 corpus ID, commit, 모델 SHA-256, config, 기기군, 날짜가 있다.

97% 항목은 `tool/evaluate_pose_corpus.dart`의 자격 판정을 통과한 실제 human-labeled corpus 결과가 있을 때만 체크한다. synthetic 결과가 100%여도 체크하지 않는다.

## 15. 개인정보와 보안

- [ ] DB schema와 파일 검사를 통해 영상·이미지·픽셀·landmark가 영속 저장되지 않음을 확인했다.
- [ ] Method/EventChannel payload에 원본 frame bytes가 없음을 확인했다.
- [ ] 운동 중 네트워크 캡처에서 frame/landmark/운동 기록 업로드가 없음을 확인했다.
- [ ] 앱 binary의 모든 SDK telemetry와 데이터 수집을 감사했다.
- [ ] SQLite 앱 수준 암호화 여부와 threat model을 제품 정책으로 승인했다.
- [ ] Android Auto Backup/iOS backup 포함·제외 결정을 구현 및 검증했다.
- [ ] 데이터 삭제 범위, 보존 기간, backup 한계를 앱 문구와 공개 정책에 정확히 반영했다.
- [ ] 로그, crash report, support export에 개인 운동 데이터가 포함되지 않는다.
- [ ] Apple Privacy Nutrition Label이 실제 binary와 일치한다.
- [ ] Google Play Data Safety가 실제 binary와 일치한다.
- [ ] 공개 개인정보 처리방침 URL, 문의처, 적용일이 유효하다.
- [ ] 의료 기기 오인 방지와 운동 안전/의료 면책 문구를 검토했다.

## 16. 스토어 자료와 운영

- [ ] 앱 이름, subtitle/short description, long description을 7개 언어로 검수했다.
- [ ] 실제 앱 화면을 사용한 phone/tablet store screenshot을 검수했다.
- [ ] screenshot에 측정하지 않은 97% 정확도나 과장된 의료 효능 문구가 없다.
- [ ] feature graphic, app preview, icon이 각 스토어 규격을 충족한다.
- [ ] support URL, marketing URL, 개인정보 처리방침 URL이 공개 접근 가능하다.
- [ ] 카메라/알림 사용 목적이 store review note에 설명되어 있다.
- [ ] 연령 등급, 콘텐츠, 광고 여부, 건강/피트니스 category를 검토했다.
- [ ] 수출 규정/암호화 설문과 지역별 소비자·개인정보 의무를 검토했다.
- [ ] 오픈소스 라이선스 화면과 배포 artifact의 notice가 일치한다.
- [ ] crash/ANR 기준, staged rollout 비율, 중단/rollback 기준을 정했다.
- [ ] support/incident 담당자와 사용자 데이터 문의 대응 절차를 정했다.
- [ ] 출시 후 지표는 개인정보 원칙을 해치지 않는 범위로 정의했다.

## 17. 최종 승인

- [ ] Android 출시 후보 AAB의 SHA-256과 승인자를 기록했다.
- [ ] iOS 출시 후보 archive/IPA의 식별자와 승인자를 기록했다.
- [ ] 요구사항 추적표의 코드 완료 항목과 실측 게이트를 재대조했다.
- [ ] 알려진 제한사항을 제품·QA·개인정보·출시 담당자가 승인했다.
- [ ] P0/P1 결함이 없고 남은 결함의 영향과 우회책이 문서화되었다.
- [ ] 최종 smoke에서 설치→권한→운동→휴식→완료→기록→리마인더→삭제를 통과했다.
- [ ] App Store/Play Console 제출 직전 artifact가 검증한 artifact와 동일하다.
