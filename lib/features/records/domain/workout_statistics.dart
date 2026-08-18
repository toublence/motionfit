import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

class DailyWorkoutTotal {
  const DailyWorkoutTotal({
    required this.date,
    required this.totalReps,
    required this.sessionCount,
    required this.activeDurationSeconds,
  });

  final DateTime date;
  final int totalReps;
  final int sessionCount;
  final int activeDurationSeconds;
}

class WorkoutStatistics {
  const WorkoutStatistics({
    required this.totalReps,
    required this.workoutDays,
    required this.totalActiveSeconds,
    required this.averageSetCount,
    required this.averageReps,
    required this.dailyTotals,
    required this.frequentIssues,
  });

  final int totalReps;
  final int workoutDays;
  final int totalActiveSeconds;
  final double averageSetCount;
  final double averageReps;
  final List<DailyWorkoutTotal> dailyTotals;
  final Map<FormIssue, int> frequentIssues;
}
