import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

/// One completed workout, reduced to the numbers Form Progress plots.
///
/// Every field comes from analysis that already ran when the workout finished.
/// Nothing here re-analyses a past session.
class FormProgressPoint {
  const FormProgressPoint({
    required this.sessionId,
    required this.exerciseType,
    required this.workoutDate,
    required this.formScore,
    required this.accuracy,
    required this.reps,
    required this.durationSeconds,
    required this.issues,
  });

  final String sessionId;
  final ExerciseType exerciseType;
  final DateTime workoutDate;

  /// Mean rep form score on a 0-100 scale, null when no rep was assessable.
  final double? formScore;

  /// Mean rep detection confidence on a 0-1 scale.
  final double? accuracy;
  final int reps;
  final int durationSeconds;
  final List<FormIssue> issues;

  bool get isScored => formScore != null;

  String get detailRoute => switch (exerciseType) {
    ExerciseType.squat => '/records/session/$sessionId',
    ExerciseType.pushup => '/records/pushup/session/$sessionId',
    ExerciseType.plank => '/records/plank/session/$sessionId',
  };
}
