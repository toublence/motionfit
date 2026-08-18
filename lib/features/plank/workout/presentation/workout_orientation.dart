import 'package:flutter/services.dart';

abstract final class WorkoutOrientation {
  static Future<void> useLandscape() => SystemChrome.setPreferredOrientations(
    const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  );

  static Future<void> usePortrait() => SystemChrome.setPreferredOrientations(
    const [DeviceOrientation.portraitUp],
  );
}
