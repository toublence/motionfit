# MotionFit - Squat

카메라 기반 실시간 스쿼트 자동 카운팅, 반복별 자세 분석, 로컬 TTS 코칭을 제공하는 Android/iOS Flutter 앱이다. 카메라 추론은 네이티브 MediaPipe Pose Landmarker로 기기 안에서 수행하며, 앱 저장소에는 영상 대신 운동 세션·세트·반복의 수치 데이터만 저장한다.

이 저장소는 출시 지향 구현 기반을 포함하지만, 실기기·실영상 corpus·스토어 심사를 통과한 출시본을 의미하지 않는다. 특히 97% 카운팅 정확도는 아직 실측 근거가 없으며 현재 상태에서 주장하지 않는다. 남은 게이트는 [알려진 제한사항](docs/KNOWN_LIMITATIONS.md)과 [출시 체크리스트](docs/RELEASE_CHECKLIST.md)를 따른다.

## 핵심 설계

- `RepDetector`는 명확한 하강→바닥→상승→기립 복귀만으로 횟수를 확정한다.
- `FormAnalyzer`는 같은 반복 구간을 별도로 분석한다. 자세 문제가 있어도 완료된 횟수를 취소하지 않는다.
- Android는 CameraX, iOS는 AVFoundation으로 Texture 프리뷰와 네이티브 추론을 제공한다.
- 추론 큐는 최신 프레임만 유지하며 Flutter에는 랜드마크와 추적 메타데이터만 전달한다.
- SQLite에 운동 기록을, SharedPreferences에 UI 선호값을 저장하는 offline-first 구조다.
- 하단 메뉴는 Material 3 기반 `스쿼트 / 기록 / 설정` 3개이며, `en`, `ko`, `de`, `es`, `fr`, `ja`, `ar`와 RTL을 지원하도록 구성했다.

상세 경계와 데이터 흐름은 [아키텍처](docs/ARCHITECTURE.md), 구현 상태는 [요구사항 추적표](docs/IMPLEMENTATION_PLAN.md)에서 확인한다.

## 개발 환경

- Flutter SDK: Dart 3.11 호환 버전 (`pubspec.yaml`: `>=3.11.0 <4.0.0`)
- Android: minSdk 24, Java 17, Android SDK/NDK는 Flutter 설정 사용
- iOS: iOS 15.0 이상, 최신 호환 Xcode와 CocoaPods
- 실제 카메라·TTS·알림·성능 검증에는 Android/iOS 실기기가 필요하다.

현재 고정된 Flutter/Dart 패키지는 `pubspec.yaml`, 네이티브 MediaPipe 버전은 `packages/motionfit_pose/android/build.gradle.kts`와 `packages/motionfit_pose/ios/motionfit_pose.podspec`이 단일 기준이다. 의존성 업데이트는 릴리스 단위로 검토하고 lockfile을 함께 커밋한다.

## 처음 실행하기

저장소 루트에서 다음 순서로 실행한다.

```sh
flutter --version
flutter pub get
flutter gen-l10n
./tool/download_pose_models.sh
```

모델 설치 스크립트는 Google MediaPipe의 float16 Lite/Full/Heavy 모델을 내려받아 고정 SHA-256을 검증한 뒤 Android와 iOS 자산 경로에 동일한 바이트를 복사한다. 실시간 기본값은 motion-fit3와 동일한 Lite다.

```text
Lite   59929e1d1ee95287735ddd833b19cf4ac46d29bc7afddbbf6753c459690d574a
Heavy  64437af838a65d18e5ba7a0d39b465540069bc8aae8308de3e318aad31fcbc7b
Full   4eaa5eb7a98365221087693fcc286334cf0858e2eb6e15b506aa4a7ecdcec4ad
```

모델 파일 경로와 네이티브 설정은 [네이티브 설정](docs/NATIVE_SETUP.md)을 참고한다. 모델 및 MediaPipe SDK의 라이선스, 재배포 조건, 스토어 고지는 매 출시 전에 별도로 검토해야 한다.

## 코드 생성과 검사

별도 `build_runner` 생성물은 없다. ARB 현지화 코드는 Flutter gen-l10n으로 생성한다.

```sh
flutter gen-l10n
flutter analyze
flutter test
```

랜드마크 replay smoke 평가:

```sh
dart run tool/evaluate_pose_corpus.dart \
  --manifest test/fixtures/corpus/synthetic_smoke_manifest.json \
  --format markdown
```

커밋된 synthetic fixture는 결정성·회귀만 확인하며 97% 품질 근거로 인정되지 않는다. 실제 corpus의 자격 조건과 지표 계산은 [Pose corpus 평가](tool/CORPUS_EVALUATION.md)에 정의되어 있다.

## 앱 실행

연결된 기기를 먼저 확인한다.

```sh
flutter devices
```

Android 실기기:

```sh
flutter run -d <android-device-id>
```

iOS 의존성을 수동으로 설치해야 할 때:

```sh
cd ios
pod install --repo-update
cd ..
```

iOS 실기기 또는 Simulator:

```sh
flutter run -d <ios-device-id>
```

Simulator는 UI 흐름 확인용이다. 카메라 좌표, MediaPipe 지연, 발열, TTS, 알림은 실기기에서 판정한다.

## 릴리스 빌드

Android release는 debug key로 대체하지 않으며 `android/key.properties`가 없으면 구성 단계에서 실패한다. 업로드 keystore는 저장소 밖에 두고 아래 키를 CI secret 또는 로컬 비추적 파일로 제공한다. iOS도 올바른 Team, provisioning profile, 배포 인증서를 먼저 확인한다.

```properties
storeFile=/secure/path/upload-keystore.jks
storePassword=...
keyAlias=...
keyPassword=...
```

서명과 출시 게이트를 모두 완료한 뒤 실행한다.

```sh
flutter build appbundle --release
flutter build ipa --release
```

출시 전에는 생성된 AAB/IPA로 새 설치와 업그레이드 경로를 다시 검증한다. 전체 항목은 [출시 체크리스트](docs/RELEASE_CHECKLIST.md)에 있다.

## 권한

앱은 운동을 시작할 때 카메라 권한을, 사용자가 리마인더를 활성화할 때 알림 권한을 요청한다.

- Android manifest: `CAMERA`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`
- iOS: `NSCameraUsageDescription`; 알림 권한은 런타임 요청
- 마이크, 사진, 미디어, 저장소 권한은 요청하지 않는다.

카메라가 거부되어도 기록과 설정은 사용할 수 있다. 영구 거부 시 시스템 설정 이동을 안내한다. Android/iOS 세부 설정은 [네이티브 설정](docs/NATIVE_SETUP.md)에 정리되어 있다.

## 데이터와 개인정보

앱 코드에는 카메라 영상·프레임을 파일이나 DB에 저장하거나 서버로 전송하는 경로가 없다. 저장 대상은 운동 시각, 세트/횟수, 시간, 반복별 점수와 개선 항목, 리마인더, 앱 선호값이다. 설정 화면에서 로컬 운동 기록을 삭제할 수 있다.

SQLite 자체 암호화, 운영체제 백업 제외 정책, 제3자 SDK 데이터 관행, 스토어 공개용 개인정보 처리방침은 별도의 출시 판단이 필요하다. 정확한 범위와 감사 항목은 [개인정보 및 데이터 처리](docs/PRIVACY_AND_DATA.md)를 따른다.

## 문서

- [아키텍처와 데이터 흐름](docs/ARCHITECTURE.md)
- [구현 계획 및 요구사항 추적표](docs/IMPLEMENTATION_PLAN.md)
- [네이티브 설정과 모델 설치](docs/NATIVE_SETUP.md)
- [개인정보 및 데이터 처리](docs/PRIVACY_AND_DATA.md)
- [알려진 제한사항](docs/KNOWN_LIMITATIONS.md)
- [실기기·스토어 출시 체크리스트](docs/RELEASE_CHECKLIST.md)
- [Replay corpus 평가 방법](tool/CORPUS_EVALUATION.md)
