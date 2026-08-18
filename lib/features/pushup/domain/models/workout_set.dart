class WorkoutSet {
  const WorkoutSet({
    required this.id,
    required this.sessionId,
    required this.setIndex,
    required this.startedAt,
    this.endedAt,
    required this.targetReps,
    required this.completedReps,
    required this.activeDurationSeconds,
    required this.restDurationAfterSeconds,
  });

  final String id;
  final String sessionId;
  final int setIndex;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int targetReps;
  final int completedReps;
  final int activeDurationSeconds;
  final int restDurationAfterSeconds;

  WorkoutSet copyWith({
    DateTime? endedAt,
    int? completedReps,
    int? activeDurationSeconds,
    int? restDurationAfterSeconds,
  }) => WorkoutSet(
    id: id,
    sessionId: sessionId,
    setIndex: setIndex,
    startedAt: startedAt,
    endedAt: endedAt ?? this.endedAt,
    targetReps: targetReps,
    completedReps: completedReps ?? this.completedReps,
    activeDurationSeconds: activeDurationSeconds ?? this.activeDurationSeconds,
    restDurationAfterSeconds:
        restDurationAfterSeconds ?? this.restDurationAfterSeconds,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'session_id': sessionId,
    'set_index': setIndex,
    'started_at': startedAt.millisecondsSinceEpoch,
    'ended_at': endedAt?.millisecondsSinceEpoch,
    'target_reps': targetReps,
    'completed_reps': completedReps,
    'active_duration_seconds': activeDurationSeconds,
    'rest_duration_after_seconds': restDurationAfterSeconds,
  };

  factory WorkoutSet.fromMap(Map<String, Object?> map) => WorkoutSet(
    id: map['id']! as String,
    sessionId: map['session_id']! as String,
    setIndex: map['set_index']! as int,
    startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at']! as int),
    endedAt: map['ended_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(map['ended_at']! as int),
    targetReps: map['target_reps']! as int,
    completedReps: map['completed_reps']! as int,
    activeDurationSeconds: map['active_duration_seconds']! as int,
    restDurationAfterSeconds: map['rest_duration_after_seconds']! as int,
  );
}
