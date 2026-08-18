import 'dart:convert';

import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

class WorkoutJournal {
  const WorkoutJournal({
    required this.sessionId,
    required this.currentSetId,
    required this.status,
    required this.activeDurationSeconds,
    required this.currentSetActiveDurationSeconds,
    required this.restDurationSeconds,
    required this.totalDurationSeconds,
    required this.restStartedAt,
    required this.restEndsAt,
    required this.updatedAt,
  });

  final String sessionId;
  final String currentSetId;
  final WorkoutSessionStatus status;
  final int activeDurationSeconds;
  final int currentSetActiveDurationSeconds;
  final int restDurationSeconds;
  final int totalDurationSeconds;
  final DateTime? restStartedAt;
  final DateTime? restEndsAt;
  final DateTime updatedAt;

  String encode() => jsonEncode({
    'sessionId': sessionId,
    'currentSetId': currentSetId,
    'status': status.name,
    'activeDurationSeconds': activeDurationSeconds,
    'currentSetActiveDurationSeconds': currentSetActiveDurationSeconds,
    'restDurationSeconds': restDurationSeconds,
    'totalDurationSeconds': totalDurationSeconds,
    'restStartedAt': restStartedAt?.millisecondsSinceEpoch,
    'restEndsAt': restEndsAt?.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  });

  factory WorkoutJournal.decode(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    DateTime? date(Object? value) => value is num
        ? DateTime.fromMillisecondsSinceEpoch(value.toInt())
        : null;

    return WorkoutJournal(
      sessionId: map['sessionId']! as String,
      currentSetId: map['currentSetId']! as String,
      status: enumByName(
        WorkoutSessionStatus.values,
        map['status'] as String?,
        WorkoutSessionStatus.paused,
      ),
      activeDurationSeconds: (map['activeDurationSeconds'] as num? ?? 0)
          .toInt(),
      currentSetActiveDurationSeconds:
          (map['currentSetActiveDurationSeconds'] as num? ?? 0).toInt(),
      restDurationSeconds: (map['restDurationSeconds'] as num? ?? 0).toInt(),
      totalDurationSeconds: (map['totalDurationSeconds'] as num? ?? 0).toInt(),
      restStartedAt: date(map['restStartedAt']),
      restEndsAt: date(map['restEndsAt']),
      updatedAt: date(map['updatedAt']) ?? DateTime.now(),
    );
  }
}
