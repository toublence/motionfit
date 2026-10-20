import 'package:flutter/foundation.dart';
import 'ad_sdk.dart';

abstract final class MotionFitAdUnits {
  static const iosAppId = 'ca-app-pub-6169297934919363~5425389550';
  // Supplied and confirmed by the app owner. Android app-open is unconfigured.
  static const iosAppOpen = 'ca-app-pub-6169297934919363/9732714503';
  static const _ios = {
    AdFormat.appOpen: iosAppOpen,
    AdFormat.banner: String.fromEnvironment(
      'ADMOB_IOS_BANNER',
      defaultValue: 'ca-app-pub-6169297934919363/9696065805',
    ),
    AdFormat.native: 'ca-app-pub-6169297934919363/1414718708',
    AdFormat.interstitial: 'ca-app-pub-6169297934919363/2998795518',
  };
  static const _android = {
    AdFormat.banner: 'ca-app-pub-6169297934919363/2773965626',
    AdFormat.native: 'ca-app-pub-6169297934919363/4174749653',
    AdFormat.interstitial: 'ca-app-pub-6169297934919363/8790349687',
  };
  static const _testIos = {
    AdFormat.appOpen: 'ca-app-pub-3940256099942544/5575463023',
    AdFormat.banner: 'ca-app-pub-3940256099942544/2934735716',
    AdFormat.native: 'ca-app-pub-3940256099942544/3986624511',
    AdFormat.interstitial: 'ca-app-pub-3940256099942544/4411468910',
  };
  static const _testAndroid = {
    AdFormat.banner: 'ca-app-pub-3940256099942544/6300978111',
    AdFormat.native: 'ca-app-pub-3940256099942544/2247696110',
    AdFormat.interstitial: 'ca-app-pub-3940256099942544/1033173712',
  };
  static const testMode =
      !kReleaseMode || bool.fromEnvironment('ADS_TEST_MODE');
  static bool get isSupported =>
      !kIsWeb &&
      {
        TargetPlatform.iOS,
        TargetPlatform.android,
      }.contains(defaultTargetPlatform);
  static bool valid(String id) =>
      RegExp(r'^ca-app-pub-\d{16}/\d{10}$').hasMatch(id);
  static String? resolve(
    AdFormat format, {
    required TargetPlatform platform,
    required bool isWeb,
    required bool useTestAds,
  }) {
    if (isWeb ||
        !{TargetPlatform.iOS, TargetPlatform.android}.contains(platform)) {
      return null;
    }
    final units = platform == TargetPlatform.iOS
        ? (useTestAds ? _testIos : _ios)
        : (useTestAds ? _testAndroid : _android);
    final id = units[format];
    return id != null && valid(id) ? id : null;
  }

  static String? forFormat(AdFormat format) => resolve(
    format,
    platform: defaultTargetPlatform,
    isWeb: kIsWeb,
    useTestAds: testMode,
  );
  static String? get appOpen => forFormat(AdFormat.appOpen);
  static String? get banner => forFormat(AdFormat.banner);
  static String? get native => forFormat(AdFormat.native);
  static String? get interstitial => forFormat(AdFormat.interstitial);
  static Map<String, String> releaseUnits(TargetPlatform platform) => {
    for (final format in AdFormat.values)
      if (format != AdFormat.appOpen || platform == TargetPlatform.iOS)
        format.name:
            resolve(
              format,
              platform: platform,
              isWeb: false,
              useTestAds: false,
            ) ??
            'unconfigured',
  };
  static List<String> validateReleaseUnits(TargetPlatform platform) {
    final units = releaseUnits(platform);
    return [
      for (final entry in units.entries)
        if (!valid(entry.value) ||
            entry.value.startsWith('ca-app-pub-3940256099942544/'))
          '${entry.key}: invalid release unit',
      if (platform == TargetPlatform.iOS &&
          units['banner'] == _android[AdFormat.banner])
        'iOS banner duplicates Android unit',
    ];
  }
}
