import 'package:flutter/material.dart';
import 'package:motionfit_squat/features/settings/domain/theme_preferences.dart';

class MotionFitColorPalette {
  const MotionFitColorPalette({
    required this.displayColor,
    required this.primary,
  });

  final Color displayColor;
  final Color primary;
}

extension MotionFitColorThemePalette on MotionFitColorTheme {
  MotionFitColorPalette get palette => switch (this) {
    MotionFitColorTheme.byeokcheong => const MotionFitColorPalette(
      displayColor: Color(0xFF4F90CC),
      primary: Color(0xFF3C7DB7),
    ),
    MotionFitColorTheme.chuhyang => const MotionFitColorPalette(
      displayColor: Color(0xFFC19287),
      primary: Color(0xFFA56F64),
    ),
    MotionFitColorTheme.jangdan => const MotionFitColorPalette(
      displayColor: Color(0xFFE16350),
      primary: Color(0xFFD64F3B),
    ),
    MotionFitColorTheme.cheonghyeon => const MotionFitColorPalette(
      displayColor: Color(0xFF566A8E),
      primary: Color(0xFF566A8E),
    ),
    MotionFitColorTheme.haenghwang => const MotionFitColorPalette(
      displayColor: Color(0xFFF1A862),
      primary: Color(0xFFB96D22),
    ),
    MotionFitColorTheme.chunyu => const MotionFitColorPalette(
      displayColor: Color(0xFFDCEAA2),
      primary: Color(0xFF6F7F24),
    ),
    MotionFitColorTheme.seolbaek => const MotionFitColorPalette(
      displayColor: Color(0xFFE2E7E4),
      primary: Color(0xFF5F7370),
    ),
    MotionFitColorTheme.byeokja => const MotionFitColorPalette(
      displayColor: Color(0xFF8C9ED9),
      primary: Color(0xFF667BD0),
    ),
    MotionFitColorTheme.chwiram => const MotionFitColorPalette(
      displayColor: Color(0xFF68C7C1),
      primary: Color(0xFF1D8F89),
    ),
  };
}
