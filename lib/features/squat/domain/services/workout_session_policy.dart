import 'package:motionfit_squat/features/squat/domain/models/workout_session.dart';

abstract final class WorkoutSessionPolicy {
  static bool isValidRecord({
    required bool workoutStarted,
    required int detectedReps,
  }) => workoutStarted && detectedReps > 0;

  static bool canCreatePausedWorkout({
    required bool workoutStarted,
    required int detectedReps,
  }) =>
      isValidRecord(workoutStarted: workoutStarted, detectedReps: detectedReps);

  static bool canUpdateChallenge(WorkoutSession session) =>
      session.completed && !session.interrupted && session.totalReps > 0;

  static bool canSendWorkoutCompleted(WorkoutSession session) =>
      canUpdateChallenge(session);
}
