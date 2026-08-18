# 네이티브 설정과 포즈 모델

이 문서는 현재 저장소의 Android/iOS 네이티브 구성과 MediaPipe 모델 설치 절차를 설명한다. 모델 파일은 소스 코드와 별개로 체크섬 검증 후 배치한다.

## 공통 준비

- Flutter/Dart 의존성 설치: `flutter pub get`
- ARB 코드 생성: `flutter gen-l10n`
- MediaPipe 모델 설치: `./tool/download_pose_models.sh`
- 연결 기기 확인: `flutter devices`

모델 설치가 끝나야 네이티브 Pose Landmarker가 시작된다. 모델이 없거나 손상되면 앱은 `model_unavailable` 또는 모델 초기화 오류를 표시하고 운동을 시작하지 않는다.

## 모델 다운로드와 무결성

`tool/download_pose_models.sh`는 다음 순서로 동작한다.

1. Google MediaPipe 저장소에서 float16 Pose Landmarker Lite/Full/Heavy를 임시 디렉터리에 다운로드한다.
2. 다운로드 파일을 아래 고정 SHA-256과 비교한다.
3. 체크섬이 일치할 때만 Android와 iOS 자산 경로에 설치한다.
4. 두 플랫폼 사본이 바이트 단위로 동일한지 `cmp`로 확인한다.

| 모델 | SHA-256 |
|---|---|
| Lite | `59929e1d1ee95287735ddd833b19cf4ac46d29bc7afddbbf6753c459690d574a` |
| Heavy | `64437af838a65d18e5ba7a0d39b465540069bc8aae8308de3e318aad31fcbc7b` |
| Full | `4eaa5eb7a98365221087693fcc286334cf0858e2eb6e15b506aa4a7ecdcec4ad` |

설치 경로:

```text
packages/motionfit_pose/android/src/main/assets/pose_landmarker_lite.task
packages/motionfit_pose/android/src/main/assets/pose_landmarker_heavy.task
packages/motionfit_pose/android/src/main/assets/pose_landmarker_full.task
packages/motionfit_pose/ios/Assets/pose_landmarker_lite.task
packages/motionfit_pose/ios/Assets/pose_landmarker_heavy.task
packages/motionfit_pose/ios/Assets/pose_landmarker_full.task
```

수동 무결성 확인이 필요할 때:

```sh
shasum -a 256 packages/motionfit_pose/android/src/main/assets/pose_landmarker_lite.task
shasum -a 256 packages/motionfit_pose/android/src/main/assets/pose_landmarker_heavy.task
shasum -a 256 packages/motionfit_pose/android/src/main/assets/pose_landmarker_full.task
shasum -a 256 packages/motionfit_pose/ios/Assets/pose_landmarker_lite.task
shasum -a 256 packages/motionfit_pose/ios/Assets/pose_landmarker_heavy.task
shasum -a 256 packages/motionfit_pose/ios/Assets/pose_landmarker_full.task
```

스크립트의 URL이 `latest` 별칭을 사용하더라도 체크섬은 고정되어 있으므로 공급자가 내용을 변경하면 설치가 실패한다. 이 경우 체크섬을 즉시 바꾸지 말고 새 모델의 출처, 릴리스 정보, 라이선스, 정확도·성능 회귀를 검토한 별도 변경으로 갱신한다.

모델과 MediaPipe SDK의 라이선스 및 스토어 재배포 조건은 출시 담당자가 매 버전 확인한다. 모델 출처와 체크섬은 릴리스 증빙에 기록한다.

## Android

현재 구성:

- applicationId/namespace: `com.namslab.motionfit.squat`
- minSdk: 24
- Java/Kotlin JVM target: 17
- 플러그인 compileSdk: 36
- CameraX: `camera-core`, `camera-camera2`, `camera-lifecycle` 1.4.2
- MediaPipe Tasks Vision: 0.10.35
- 화면 방향: portrait

앱 manifest 권한:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

마이크·사진·미디어·저장소 권한은 없다. 카메라 권한은 운동 시작 흐름에서, Android 13 이상 알림 권한은 리마인더 활성화 시점에 요청한다. `RECEIVE_BOOT_COMPLETED`와 알림 플러그인 receiver는 재부팅/앱 업데이트 후 예약 복구에 사용한다.

네이티브 포즈 경로:

- CameraX Preview가 Flutter `Texture`에 연결된다.
- ImageAnalysis는 `STRATEGY_KEEP_ONLY_LATEST`를 사용한다.
- worker executor에서 MediaPipe live-stream 추론을 수행한다.
- 목표 추론 속도는 15~30 FPS 범위이며 기본 30 FPS다.
- motion-fit3와 동일하게 Lite 모델, 640×480 입력, 1개 pose, `0.4/0.4/0.5` confidence 설정을 사용한다.
- Flutter EventChannel에는 원본 프레임이 아니라 normalized/world landmark와 confidence, 추적/미러/회전/crop 메타데이터만 보낸다.

개발 실행:

```sh
flutter run -d <android-device-id>
```

release build는 debug signing으로 fallback하지 않는다. `android/key.properties`가 없으면 release task 구성 단계에서 실패하며, 다음 값을 저장소 밖의 업로드 키에 연결해야 한다.

```properties
storeFile=/secure/path/upload-keystore.jks
storePassword=...
keyAlias=...
keyPassword=...
```

출시 전 차단 항목:

- 실제 업로드 키/keystore, Play App Signing, CI secret을 배포 계정에 맞게 설정해야 한다.
- App Bundle의 applicationId, versionCode/versionName, targetSdk, 64-bit ABI, 난독화/매핑 정책을 확인해야 한다.
- 실제 전·후면 카메라에서 회전, mirror, crop, 전신 overlay 정렬을 확인해야 한다.

## iOS

현재 구성:

- Bundle Identifier: `com.namslab.motionfit.squat`
- deployment target: iOS 15.0
- MediaPipeTasksVision: 0.10.35
- AVFoundation + FlutterTexture
- 화면 방향: iPhone portrait, iPad portrait 계열
- 카메라 사용 설명은 `en`, `ko`, `de`, `es`, `fr`, `ja`, `ar` InfoPlist 문자열로 포함

Pod 설치가 필요할 때 저장소 루트에서 다음을 실행한다.

```sh
flutter pub get
cd ios
pod install --repo-update
cd ..
```

`motionfit_pose.podspec`은 `Assets/*.task`를 `motionfit_pose_models.bundle`로 묶는다. `model_manifest.json`은 Lite/Full/Heavy 파일명을 명시하며 Swift model locator는 이 resource bundle에서 `.task` 파일을 찾는다.

네이티브 포즈 경로:

- AVCaptureSession 프리뷰를 FlutterTexture로 전달한다.
- AVCaptureVideoDataOutput의 `alwaysDiscardsLateVideoFrames`가 활성화되어 있다.
- 전용 capture/inference queue에서 추론하고 동시에 하나의 추론만 허용한다.
- 앱 background, 비활성화, 카메라 interruption/runtime error를 관찰해 프레임 수락을 중지하거나 상태 이벤트를 전달한다.
- Flutter로 보내는 데이터 계약은 Android와 동일한 landmark/추적 메타데이터 중심이다.

개발 실행:

```sh
flutter run -d <ios-device-id>
```

출시 전 Xcode에서 확인한다.

- Runner target의 Team이 실제 배포 계정과 일치하는지 확인한다.
- App Store provisioning profile과 Distribution certificate로 archive한다.
- Bundle Identifier, version/build, deployment target, supported orientations를 확인한다.
- `NSCameraUsageDescription` 현지화가 모든 지원 언어에서 표시되는지 확인한다.
- 알림 permission prompt와 주간 알림을 실기기에서 확인한다.
- Pod privacy manifest와 전체 앱 Privacy Report를 실제 포함 SDK 기준으로 감사한다.

## 채널 계약

Flutter plugin 공개 API는 다음 동작을 제공한다.

- `start(camera, model, targetFps)` → texture ID
- `pause()` / `resume()` / `dispose()`
- `switchCamera(front|back)`
- `setModel(lite|full|heavy)`
- `setTargetFps(15..30)`
- frame event → timestamp, 33개 normalized/world landmarks, visibility/presence, tracking state, person count, 미러/회전/preview transform, 추론 지연

모델 또는 FPS를 전환하더라도 Dart의 RepDetector/WorkoutSession 상태를 새로 만들지 않는 계약이다. 최근 추론 지연으로 FPS를 자동 조절하며, OS thermal signal 연동과 임계값은 별도 실기기 측정 후 보정해야 한다.

## 흔한 오류

- `model_unavailable`: 모델 설치 스크립트를 실행하고 네 플랫폼 경로/체크섬을 확인한다.
- `permission_denied`: 카메라 권한을 시스템 설정에서 허용한다.
- `camera_in_use`: 다른 카메라 앱/통화를 종료한 뒤 재시도한다.
- `camera_unavailable` 또는 초기화 실패: 실제 지원 기기, 카메라 상태, lifecycle을 확인한다.
- overlay 불일치: 전/후면별 mirror, sensor rotation, preview crop/scale fixture를 확인한다. 좌표를 임의로 보정해 출시하지 않는다.
- CocoaPods resolve 실패: Flutter 지원 Xcode/CocoaPods 버전과 MediaPipeTasksVision 0.10.35 호환성을 확인한 뒤 Pod 설치를 다시 수행한다.
