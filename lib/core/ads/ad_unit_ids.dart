import 'dart:io';

import 'package:flutter/foundation.dart';

abstract final class MotionFitAdUnits {
  static const _androidProductionNative =
      'ca-app-pub-6169297934919363/4174749653';
  static const _androidProductionInterstitial =
      'ca-app-pub-6169297934919363/8790349687';
  static const _iosProductionNative = 'ca-app-pub-6169297934919363/1414718708';
  static const _iosProductionInterstitial =
      'ca-app-pub-6169297934919363/2998795518';

  static const _androidTestNative = 'ca-app-pub-3940256099942544/2247696110';
  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestNative = 'ca-app-pub-3940256099942544/3986624511';
  static const _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  /// Forces Google's sample ad units in every build, release included.
  ///
  /// Debug and profile builds already use test units on their own. This flag
  /// exists so a release build can be exercised on a device without serving
  /// live ads. Set it back to `false` before shipping: a store build left with
  /// test units serves sample creatives and earns nothing.
  ///
  /// The AdMob application IDs in `AndroidManifest.xml` and `Info.plist` are
  /// switched to the matching sample IDs alongside this flag and have to be
  /// restored at the same time.
  static const useTestAds = true;

  static bool get _useTestUnits => useTestAds || !kReleaseMode;

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static String? get native => isSupported
      ? (_useTestUnits
            ? Platform.isAndroid
                  ? _androidTestNative
                  : _iosTestNative
            : Platform.isAndroid
            ? _androidProductionNative
            : _iosProductionNative)
      : null;

  static String? get interstitial => isSupported
      ? (_useTestUnits
            ? Platform.isAndroid
                  ? _androidTestInterstitial
                  : _iosTestInterstitial
            : Platform.isAndroid
            ? _androidProductionInterstitial
            : _iosProductionInterstitial)
      : null;
}
