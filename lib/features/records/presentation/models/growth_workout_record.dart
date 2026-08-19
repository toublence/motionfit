import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/plank/records/domain/workout_session_details.dart'
    as plank;
import 'package:motionfit_squat/features/pushup/records/domain/workout_session_details.dart'
    as pushup;
import 'package:motionfit_squat/features/records/domain/workout_session_details.dart'
    as squat;

class GrowthWorkoutRecord {
  const GrowthWorkoutRecord({
    required this.exerciseType,
    required this.sessionId,
    required this.startedAt,
    required this.totalReps,
    required this.completedSetCount,
    required this.activeDurationSeconds,
    required this.averageFormScore,
    required this.completed,
    required this.interrupted,
  });

  factory GrowthWorkoutRecord.fromSquat(squat.WorkoutSessionDetails details) {
    final session = details.session;
    return GrowthWorkoutRecord(
      exerciseType: ExerciseType.squat,
      sessionId: session.id,
      startedAt: session.startedAt.toLocal(),
      totalReps: session.totalReps,
      completedSetCount: session.completedSetCount,
      activeDurationSeconds: session.activeDurationSeconds,
      averageFormScore: details.averageFormScore,
      completed: session.completed,
      interrupted: session.interrupted,
    );
  }

  factory GrowthWorkoutRecord.fromPushup(pushup.WorkoutSessionDetails details) {
    final session = details.session;
    return GrowthWorkoutRecord(
      exerciseType: ExerciseType.pushup,
      sessionId: session.id,
      startedAt: session.startedAt.toLocal(),
      totalReps: session.totalReps,
      completedSetCount: session.completedSetCount,
      activeDurationSeconds: session.activeDurationSeconds,
      averageFormScore: details.averageFormScore,
      completed: session.completed,
      interrupted: session.interrupted,
    );
  }

  factory GrowthWorkoutRecord.fromPlank(plank.WorkoutSessionDetails details) {
    final session = details.session;
    return GrowthWorkoutRecord(
      exerciseType: ExerciseType.plank,
      sessionId: session.id,
      startedAt: session.startedAt.toLocal(),
      totalReps: session.totalReps,
      completedSetCount: session.completedSetCount,
      activeDurationSeconds: session.activeDurationSeconds,
      averageFormScore: details.averageFormScore,
      completed: session.completed,
      interrupted: session.interrupted,
    );
  }

  final ExerciseType exerciseType;
  final String sessionId;
  final DateTime startedAt;
  final int totalReps;
  final int completedSetCount;
  final int activeDurationSeconds;
  final double? averageFormScore;
  final bool completed;
  final bool interrupted;

  bool get isValid => completed && !interrupted && totalReps > 0;

  String get detailRoute => switch (exerciseType) {
    ExerciseType.squat => '/records/session/$sessionId',
    ExerciseType.pushup => '/records/pushup/session/$sessionId',
    ExerciseType.plank => '/records/plank/session/$sessionId',
  };
}
