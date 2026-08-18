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

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static String? get native => isSupported
      ? (kReleaseMode
            ? Platform.isAndroid
                  ? _androidProductionNative
                  : _iosProductionNative
            : Platform.isAndroid
            ? _androidTestNative
            : _iosTestNative)
      : null;

  static String? get interstitial => isSupported
      ? (kReleaseMode
            ? Platform.isAndroid
                  ? _androidProductionInterstitial
                  : _iosProductionInterstitial
            : Platform.isAndroid
            ? _androidTestInterstitial
            : _iosTestInterstitial)
      : null;
}
