import 'dart:convert';

import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';

enum ChallengeType { sevenDay, weekly, cumulative }

enum ChallengeStatus { active, completed, ended, cancelled }

class Challenge {
  const Challenge({
    required this.id,
    required this.type,
    required this.status,
    required this.startedAt,
    required this.endsAt,
    required this.targetReps,
    required this.dailyGoals,
    required this.weekdays,
    required this.notificationEnabled,
    required this.createdAt,
  });

  final String id;
  final ChallengeType type;
  final ChallengeStatus status;
  final DateTime startedAt;
  final DateTime endsAt;
  final int targetReps;
  final List<int> dailyGoals;
  final List<int> weekdays;
  final bool notificationEnabled;
  final DateTime createdAt;
  ExerciseType get exerciseType => ExerciseType.squat;

  Challenge copyWith({
    ChallengeStatus? status,
    bool? notificationEnabled,
    List<int>? dailyGoals,
  }) => Challenge(
    id: id,
    type: type,
    status: status ?? this.status,
    startedAt: startedAt,
    endsAt: endsAt,
    targetReps: targetReps,
    dailyGoals: dailyGoals ?? this.dailyGoals,
    weekdays: weekdays,
    notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    createdAt: createdAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'type': type.name,
    'status': status.name,
    'started_at': startedAt.millisecondsSinceEpoch,
    'ends_at': endsAt.millisecondsSinceEpoch,
    'target_reps': targetReps,
    'daily_goals': jsonEncode(dailyGoals),
    'weekdays': jsonEncode(weekdays),
    'notification_enabled': notificationEnabled ? 1 : 0,
    'created_at': createdAt.millisecondsSinceEpoch,
  };

  factory Challenge.fromMap(Map<String, Object?> map) => Challenge(
    id: map['id']! as String,
    type: ChallengeType.values.byName(map['type']! as String),
    status: ChallengeStatus.values.byName(map['status']! as String),
    startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at']! as int),
    endsAt: DateTime.fromMillisecondsSinceEpoch(map['ends_at']! as int),
    targetReps: map['target_reps']! as int,
    dailyGoals: (jsonDecode(map['daily_goals']! as String) as List).cast<int>(),
    weekdays: (jsonDecode(map['weekdays']! as String) as List).cast<int>(),
    notificationEnabled: map['notification_enabled'] == 1,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
  );
}

class ChallengeProgress {
  const ChallengeProgress({
    required this.challenge,
    required this.totalReps,
    required this.workoutDays,
    required this.totalActiveSeconds,
    required this.progress,
    required this.todayReps,
    required this.currentDay,
    required this.currentWeek,
    required this.thisWeekWorkoutDays,
    required this.countedWorkoutDays,
    required this.remainingDays,
    required this.dailyReps,
  });

  final Challenge challenge;
  final int totalReps;
  final int workoutDays;
  final int totalActiveSeconds;
  final double progress;
  final int todayReps;
  final int currentDay;
  final int currentWeek;
  final int thisWeekWorkoutDays;
  final int countedWorkoutDays;
  final int remainingDays;
  final Map<DateTime, int> dailyReps;

  int get todayGoal =>
      challenge.type == ChallengeType.sevenDay &&
          challenge.dailyGoals.isNotEmpty
      ? challenge.dailyGoals[(currentDay - 1).clamp(
          0,
          challenge.dailyGoals.length - 1,
        )]
      : 0;

  bool get isRecoveryDay =>
      challenge.type == ChallengeType.sevenDay && todayGoal == 0;

  bool get isTodayGoalCompleted =>
      challenge.type == ChallengeType.sevenDay &&
      todayGoal > 0 &&
      remainingReps == 0;

  int get remainingReps => switch (challenge.type) {
    ChallengeType.sevenDay => (todayGoal - todayReps).clamp(0, todayGoal),
    ChallengeType.cumulative => (challenge.targetReps - totalReps).clamp(
      0,
      challenge.targetReps,
    ),
    ChallengeType.weekly => 0,
  };

  int get remainingWeeklyWorkouts => (3 - thisWeekWorkoutDays).clamp(0, 3);

  int get suggestedCumulativeRepsToday {
    if (challenge.type != ChallengeType.cumulative || remainingReps == 0) {
      return 0;
    }
    final days = remainingDays.clamp(1, 365);
    return (remainingReps / days).ceil();
  }
}
