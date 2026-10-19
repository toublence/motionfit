# 검증 명령과 범위

실행 위치는 `/Users/nam/projects/flutter/motionfit`이다. Flutter가 생성하는 plugin registrant의 dev dependency 구성이 다르므로 test와 release build는 같은 checkout에서 **순차 실행**한다. Flutter 3.41.9에서는 `build --no-pub`가 release용 registrant 재생성도 생략하므로 빌드 모드를 바꿀 때 이 옵션을 사용하지 않는다. 중간 실패 로그도 보존했다.

```sh
flutter test --no-pub test/core/ads test/core/analytics
flutter test --no-pub
flutter analyze --no-pub lib/core/ads lib/core/privacy test/core/ads integration_test/ads_sdk_smoke_test.dart integration_test/ads_sdk_driver.dart
flutter build ios --release --no-codesign --dart-define=ADS_TEST_MODE=true --dart-define=RELEASE_SHA=0f608c59-ads-validation
GRADLE_OPTS='-Dorg.gradle.jvmargs=-Xmx2g -Dorg.gradle.workers.max=2 -Dorg.gradle.parallel=false' flutter build apk --release --no-android-gradle-daemon --dart-define=ADS_TEST_MODE=true --dart-define=RELEASE_SHA=0f608c59-ads-validation
```

실기기 테스트의 APK는 별도 패키지 `fit.motionfit.app.adsvalidation`으로 만든다. `android_isolation.gradle`은 임시 GRADLE_USER_HOME의 `init.d/`에만 놓고 사용했다. 임시 Gradle home의 caches/native/wrapper는 기존 다운로드를 참조한다. 소스의 applicationId나 운영 Firebase 설정은 변경하지 않았다. APK manifest의 package가 정확히 위 값인지 확인한 다음에만 설치한다.

```sh
GRADLE_USER_HOME=/tmp/motionfit-ads-validation-gradle GRADLE_OPTS='-Dorg.gradle.jvmargs=-Xmx2g -Dorg.gradle.workers.max=2 -Dorg.gradle.parallel=false' flutter build apk --debug --target-platform android-arm64 --no-android-gradle-daemon --target integration_test/ads_sdk_smoke_test.dart --dart-define=ADS_TEST_MODE=true --dart-define=RELEASE_SHA=0f608c59-ads-validation
/Users/nam/Library/Android/sdk/build-tools/36.1.0/aapt dump badging build/app/outputs/flutter-apk/app-debug.apk
# 위 출력의 package가 fit.motionfit.app.adsvalidation인지 확인한 후 복사한다.
cp build/app/outputs/flutter-apk/app-debug.apk /tmp/motionfit-ads-validation.apk
flutter drive --no-pub --device-id R3CXB0JRT5V --driver integration_test/ads_sdk_driver.dart --target integration_test/ads_sdk_smoke_test.dart --use-application-binary /tmp/motionfit-ads-validation.apk
```

실제 기기 serial은 이 검증 환경에만 해당한다. 실행 여부·성공 여부는 `test_results.json`과 개별 로그를 기준으로 판단한다. 명령이 문서에 있다는 이유만으로 실행 완료를 의미하지 않는다. 테스트 APK의 패키지 검증 없이 운영 앱에 덮어 설치해서는 안 된다.
