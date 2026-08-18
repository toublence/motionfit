import 'package:flutter/material.dart';

@immutable
class MotionFitTokens extends ThemeExtension<MotionFitTokens> {
  const MotionFitTokens({
    required this.spaceXs,
    required this.spaceSm,
    required this.space12,
    required this.spaceMd,
    required this.space20,
    required this.spaceLg,
    required this.spaceXl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.motionFast,
    required this.motionStandard,
    required this.success,
    required this.warning,
    required this.unavailable,
    required this.cameraOverlay,
  });

  const MotionFitTokens.standard()
    : spaceXs = 4,
      spaceSm = 8,
      space12 = 12,
      spaceMd = 16,
      space20 = 20,
      spaceLg = 24,
      spaceXl = 32,
      radiusSm = 12,
      radiusMd = 16,
      radiusLg = 22,
      radiusXl = 24,
      motionFast = const Duration(milliseconds: 150),
      motionStandard = const Duration(milliseconds: 220),
      success = const Color(0xFF197A4A),
      warning = const Color(0xFF9A6400),
      unavailable = const Color(0xFF737B84),
      cameraOverlay = const Color(0xB8000000);

  final double spaceXs;
  final double spaceSm;
  final double space12;
  final double spaceMd;
  final double space20;
  final double spaceLg;
  final double spaceXl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final Duration motionFast;
  final Duration motionStandard;
  final Color success;
  final Color warning;
  final Color unavailable;
  final Color cameraOverlay;

  @override
  MotionFitTokens copyWith({
    double? spaceXs,
    double? spaceSm,
    double? space12,
    double? spaceMd,
    double? space20,
    double? spaceLg,
    double? spaceXl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    Duration? motionFast,
    Duration? motionStandard,
    Color? success,
    Color? warning,
    Color? unavailable,
    Color? cameraOverlay,
  }) => MotionFitTokens(
    spaceXs: spaceXs ?? this.spaceXs,
    spaceSm: spaceSm ?? this.spaceSm,
    space12: space12 ?? this.space12,
    spaceMd: spaceMd ?? this.spaceMd,
    space20: space20 ?? this.space20,
    spaceLg: spaceLg ?? this.spaceLg,
    spaceXl: spaceXl ?? this.spaceXl,
    radiusSm: radiusSm ?? this.radiusSm,
    radiusMd: radiusMd ?? this.radiusMd,
    radiusLg: radiusLg ?? this.radiusLg,
    radiusXl: radiusXl ?? this.radiusXl,
    motionFast: motionFast ?? this.motionFast,
    motionStandard: motionStandard ?? this.motionStandard,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    unavailable: unavailable ?? this.unavailable,
    cameraOverlay: cameraOverlay ?? this.cameraOverlay,
  );

  @override
  MotionFitTokens lerp(ThemeExtension<MotionFitTokens>? other, double t) {
    if (other is! MotionFitTokens) return this;
    return MotionFitTokens(
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t),
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t),
      space12: lerpDouble(space12, other.space12, t),
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t),
      space20: lerpDouble(space20, other.space20, t),
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t),
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t),
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t),
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t),
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t),
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t),
      motionFast: Duration(
        microseconds: lerpDouble(
          motionFast.inMicroseconds.toDouble(),
          other.motionFast.inMicroseconds.toDouble(),
          t,
        ).round(),
      ),
      motionStandard: Duration(
        microseconds: lerpDouble(
          motionStandard.inMicroseconds.toDouble(),
          other.motionStandard.inMicroseconds.toDouble(),
          t,
        ).round(),
      ),
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      unavailable: Color.lerp(unavailable, other.unavailable, t)!,
      cameraOverlay: Color.lerp(cameraOverlay, other.cameraOverlay, t)!,
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

extension MotionFitThemeContext on BuildContext {
  MotionFitTokens get tokens =>
      Theme.of(this).extension<MotionFitTokens>() ??
      const MotionFitTokens.standard();
}
