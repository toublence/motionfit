class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.plannedSetCount,
    required this.plannedRepsPerSet,
    required this.plannedRestSeconds,
    required this.completedSetCount,
    required this.totalReps,
    required this.activeDurationSeconds,
    required this.restDurationSeconds,
    required this.totalDurationSeconds,
    required this.averageRepDurationMilliseconds,
    required this.completed,
    required this.interrupted,
    required this.createdAt,
    this.analyticsSessionId,
    this.videoPath,
    this.videoDurationMilliseconds,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int plannedSetCount;
  final int plannedRepsPerSet;
  final int plannedRestSeconds;
  final int completedSetCount;
  final int totalReps;
  final int activeDurationSeconds;
  final int restDurationSeconds;
  final int totalDurationSeconds;
  final int averageRepDurationMilliseconds;
  final bool completed;
  final bool interrupted;
  final DateTime createdAt;
  final String? analyticsSessionId;
  final String? videoPath;
  final int? videoDurationMilliseconds;

  WorkoutSession copyWith({
    DateTime? endedAt,
    bool clearEndedAt = false,
    int? completedSetCount,
    int? totalReps,
    int? activeDurationSeconds,
    int? restDurationSeconds,
    int? totalDurationSeconds,
    int? averageRepDurationMilliseconds,
    bool? completed,
    bool? interrupted,
    String? videoPath,
    bool clearVideoPath = false,
    int? videoDurationMilliseconds,
    bool clearVideoDuration = false,
  }) {
    return WorkoutSession(
      id: id,
      startedAt: startedAt,
      endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
      plannedSetCount: plannedSetCount,
      plannedRepsPerSet: plannedRepsPerSet,
      plannedRestSeconds: plannedRestSeconds,
      completedSetCount: completedSetCount ?? this.completedSetCount,
      totalReps: totalReps ?? this.totalReps,
      activeDurationSeconds:
          activeDurationSeconds ?? this.activeDurationSeconds,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      averageRepDurationMilliseconds:
          averageRepDurationMilliseconds ?? this.averageRepDurationMilliseconds,
      completed: completed ?? this.completed,
      interrupted: interrupted ?? this.interrupted,
      createdAt: createdAt,
      analyticsSessionId: analyticsSessionId,
      videoPath: clearVideoPath ? null : videoPath ?? this.videoPath,
      videoDurationMilliseconds: clearVideoDuration
          ? null
          : videoDurationMilliseconds ?? this.videoDurationMilliseconds,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'started_at': startedAt.millisecondsSinceEpoch,
    'ended_at': endedAt?.millisecondsSinceEpoch,
    'planned_set_count': plannedSetCount,
    'planned_reps_per_set': plannedRepsPerSet,
    'planned_rest_seconds': plannedRestSeconds,
    'completed_set_count': completedSetCount,
    'total_reps': totalReps,
    'active_duration_seconds': activeDurationSeconds,
    'rest_duration_seconds': restDurationSeconds,
    'total_duration_seconds': totalDurationSeconds,
    'average_rep_duration_milliseconds': averageRepDurationMilliseconds,
    'completed': completed ? 1 : 0,
    'interrupted': interrupted ? 1 : 0,
    'created_at': createdAt.millisecondsSinceEpoch,
    'analytics_session_id': analyticsSessionId,
    'video_path': videoPath,
    'video_duration_milliseconds': videoDurationMilliseconds,
  };

  factory WorkoutSession.fromMap(Map<String, Object?> map) => WorkoutSession(
    id: map['id']! as String,
    startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at']! as int),
    endedAt: map['ended_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(map['ended_at']! as int),
    plannedSetCount: map['planned_set_count']! as int,
    plannedRepsPerSet: map['planned_reps_per_set']! as int,
    plannedRestSeconds: map['planned_rest_seconds']! as int,
    completedSetCount: map['completed_set_count']! as int,
    totalReps: map['total_reps']! as int,
    activeDurationSeconds: map['active_duration_seconds']! as int,
    restDurationSeconds: map['rest_duration_seconds']! as int,
    totalDurationSeconds: map['total_duration_seconds']! as int,
    averageRepDurationMilliseconds:
        map['average_rep_duration_milliseconds']! as int,
    completed: map['completed'] == 1,
    interrupted: map['interrupted'] == 1,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
    analyticsSessionId: map['analytics_session_id'] as String?,
    videoPath: map['video_path'] as String?,
    videoDurationMilliseconds: (map['video_duration_milliseconds'] as num?)
        ?.toInt(),
  );
}
