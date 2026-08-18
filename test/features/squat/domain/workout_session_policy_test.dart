import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_session.dart';
import 'package:motionfit_squat/features/squat/domain/services/workout_session_policy.dart';

void main() {
  test('camera failure does not create a valid or paused workout', () {
    expect(
      WorkoutSessionPolicy.isValidRecord(
        workoutStarted: false,
        detectedReps: 0,
      ),
      isFalse,
    );
    expect(
      WorkoutSessionPolicy.canCreatePausedWorkout(
        workoutStarted: false,
        detectedReps: 0,
      ),
      isFalse,
    );
  });

  test('zero rep session is not completed', () {
    expect(
      WorkoutSessionPolicy.canSendWorkoutCompleted(_session(reps: 0)),
      isFalse,
    );
  });

  test('valid early end can be persisted after a detected rep', () {
    expect(
      WorkoutSessionPolicy.isValidRecord(workoutStarted: true, detectedReps: 1),
      isTrue,
    );
  });

  test('only completed valid workout updates challenge', () {
    expect(WorkoutSessionPolicy.canUpdateChallenge(_session(reps: 1)), isTrue);
    expect(
      WorkoutSessionPolicy.canUpdateChallenge(
        _session(reps: 1, interrupted: true),
      ),
      isFalse,
    );
  });
}

WorkoutSession _session({int reps = 1, bool interrupted = false}) {
  final now = DateTime.utc(2026, 8, 4);
  return WorkoutSession(
    id: 'session',
    startedAt: now,
    endedAt: now.add(const Duration(minutes: 1)),
    plannedSetCount: 1,
    plannedRepsPerSet: 5,
    plannedRestSeconds: 15,
    completedSetCount: reps > 0 ? 1 : 0,
    totalReps: reps,
    activeDurationSeconds: reps > 0 ? 30 : 0,
    restDurationSeconds: 0,
    totalDurationSeconds: reps > 0 ? 30 : 0,
    averageRepDurationMilliseconds: reps > 0 ? 2000 : 0,
    completed: true,
    interrupted: interrupted,
    createdAt: now,
  );
}
