import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release identity remains attached to the existing MotionFit app', () {
    const packageId = 'fit.motionfit.app';
    final androidBuild = File(
      'android/app/build.gradle.kts',
    ).readAsStringSync();
    final androidManifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final iosProject = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();
    final iosInfo = File('ios/Runner/Info.plist').readAsStringSync();
    final adUnits = File('lib/core/ads/ad_unit_ids.dart').readAsStringSync();
    final storeListing = File(
      'lib/core/reviews/store_listing_config.dart',
    ).readAsStringSync();

    expect(androidBuild, contains('applicationId = "$packageId"'));
    expect(androidBuild, contains('namespace = "$packageId"'));
    expect(androidManifest, contains('ca-app-pub-6169297934919363~8413894487'));
    expect(androidManifest, contains('android:allowBackup="false"'));
    expect(iosProject, contains('PRODUCT_BUNDLE_IDENTIFIER = $packageId'));
    expect(iosProject, contains('DEVELOPMENT_TEAM = 2CZQR7Q423'));
    expect(iosInfo, contains('ca-app-pub-6169297934919363~5425389550'));
    expect(adUnits, contains('ca-app-pub-6169297934919363/4174749653'));
    expect(adUnits, contains('ca-app-pub-6169297934919363/1414718708'));
    expect(adUnits, contains('ca-app-pub-6169297934919363/8790349687'));
    expect(adUnits, contains('ca-app-pub-6169297934919363/2998795518'));
    expect(storeListing, contains("iosAppStoreId = '6754861354'"));

    final androidFirebase =
        jsonDecode(File('android/app/google-services.json').readAsStringSync())
            as Map<String, dynamic>;
    final projectInfo = androidFirebase['project_info'] as Map<String, dynamic>;
    expect(projectInfo['project_id'], 'motionfit-e75b9');
    expect(projectInfo['project_number'], '246191989101');
    expect(
      File('ios/Runner/GoogleService-Info.plist').readAsStringSync(),
      allOf(contains('motionfit-e75b9'), contains(packageId)),
    );
  });
}
