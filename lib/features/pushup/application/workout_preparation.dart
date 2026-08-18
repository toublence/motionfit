import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/features/pushup/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_plan.dart';

enum WorkoutLaunchSource { workoutTab, challengeTab }

class ChallengeWorkoutContext {
  const ChallengeWorkoutContext({
    required this.challengeId,
    required this.challengeType,
    required this.currentProgress,
    this.currentDay,
    this.targetReps,
    this.completedRepsAtStart = 0,
    this.totalGoalReps,
  });

  final String challengeId;
  final String challengeType;
  final double currentProgress;
  final int? currentDay;
  final int? targetReps;
  final int completedRepsAtStart;
  final int? totalGoalReps;
}

class WorkoutPreparation {
  const WorkoutPreparation({
    required this.plan,
    this.recovery,
    this.launchSource = WorkoutLaunchSource.workoutTab,
    this.challenge,
  });

  factory WorkoutPreparation.newWorkout(WorkoutPlan plan) =>
      WorkoutPreparation(plan: plan);

  factory WorkoutPreparation.recovery(WorkoutSessionDetails details) {
    final session = details.session;
    return WorkoutPreparation(
      plan: WorkoutPlan(
        id: 'recovery:${session.id}',
        setCount: session.plannedSetCount,
        targetRepsPerSet: session.plannedRepsPerSet,
        restDurationSeconds: session.plannedRestSeconds,
        createdAt: session.createdAt,
        updatedAt: DateTime.now(),
      ),
      recovery: details,
    );
  }

  final WorkoutPlan plan;
  final WorkoutSessionDetails? recovery;
  final WorkoutLaunchSource launchSource;
  final ChallengeWorkoutContext? challenge;
  bool get isRecovery => recovery != null;
}

final workoutLaunchContextProvider =
    NotifierProvider<WorkoutLaunchContextController, WorkoutPreparation?>(
      WorkoutLaunchContextController.new,
    );

class WorkoutLaunchContextController extends Notifier<WorkoutPreparation?> {
  @override
  WorkoutPreparation? build() => null;

  void set(WorkoutPreparation preparation) => state = preparation;

  void clear() => state = null;
}
