import 'package:flutter/material.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';

/// Fixed semantic colors that identify exercise data.
///
/// These values must not depend on the user-selected MotionFit color theme.
abstract final class ExerciseColors {
  static const Color squat = Color(0xFF3C7DB7);
  static const Color pushup = Color(0xFFC86A4A);
  static const Color plank = Color(0xFF2A8C7D);

  static Color of(ExerciseType type) => switch (type) {
    ExerciseType.squat => squat,
    ExerciseType.pushup => pushup,
    ExerciseType.plank => plank,
  };

  static Color tintOf(ExerciseType type, Brightness brightness) =>
      of(type).withValues(alpha: brightness == Brightness.dark ? .24 : .14);
}
