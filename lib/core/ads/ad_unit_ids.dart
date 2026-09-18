import 'dart:io';

import 'package:flutter/foundation.dart';

abstract final class MotionFitAdUnits {
  static const _androidProductionBanner =
      'ca-app-pub-6169297934919363/2773965626';
  static const _androidProductionNative =
      'ca-app-pub-6169297934919363/4174749653';
  static const _androidProductionInterstitial =
      'ca-app-pub-6169297934919363/8790349687';
  static const _iosProductionBanner = 'ca-app-pub-6169297934919363/2773965626';
  static const _iosProductionNative = 'ca-app-pub-6169297934919363/1414718708';
  static const _iosProductionInterstitial =
      'ca-app-pub-6169297934919363/2998795518';

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static String? get banner => isSupported
      ? (Platform.isAndroid ? _androidProductionBanner : _iosProductionBanner)
      : null;

  static String? get native => isSupported
      ? (Platform.isAndroid ? _androidProductionNative : _iosProductionNative)
      : null;

  static String? get interstitial => isSupported
      ? (Platform.isAndroid
            ? _androidProductionInterstitial
            : _iosProductionInterstitial)
      : null;
}
