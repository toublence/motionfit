import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';

class WorkoutCoachMessages {
  const WorkoutCoachMessages({
    required this.locale,
    required this.calibration,
    required this.ready,
    required this.tracking,
    required this.repCount,
    required this.formIssue,
    required this.goodRep,
    required this.goalNear,
    required this.setStart,
    required this.sevenDayChallengeStart,
    required this.cumulativeChallengeStart,
    required this.setComplete,
    required this.restStart,
    required this.restTenSeconds,
    required this.restComplete,
    required this.workoutComplete,
  });

  final String locale;
  final String calibration;
  final String Function(int variant) ready;
  final String Function(TrackingState state, int variant) tracking;
  final String Function(int count) repCount;
  final String Function(FormIssue issue, int variant) formIssue;
  final String Function(int variant) goodRep;
  final String Function(int remaining) goalNear;
  final String Function(int set) setStart;
  final String Function(int day) sevenDayChallengeStart;
  final String Function(int completed, int remaining) cumulativeChallengeStart;
  final String Function(int set) setComplete;
  final String Function(int seconds) restStart;
  final String restTenSeconds;
  final String restComplete;
  final String Function(int reps) workoutComplete;
}
