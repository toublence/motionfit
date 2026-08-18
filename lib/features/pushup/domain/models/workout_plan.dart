class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.setCount,
    required this.targetRepsPerSet,
    required this.restDurationSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  static const int minSets = 1;
  static const int maxSets = 20;
  static const int minReps = 1;
  static const int maxReps = 100;
  static const int minRestSeconds = 0;
  static const int maxRestSeconds = 600;

  factory WorkoutPlan.defaults({String id = 'default'}) {
    final now = DateTime.now();
    return WorkoutPlan(
      id: id,
      setCount: 1,
      targetRepsPerSet: 5,
      restDurationSeconds: 15,
      createdAt: now,
      updatedAt: now,
    );
  }

  final String id;
  final int setCount;
  final int targetRepsPerSet;
  final int restDurationSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get plannedTotalReps => setCount * targetRepsPerSet;

  WorkoutPlan normalized({int maxRepsPerSet = maxReps}) => copyWith(
    setCount: setCount.clamp(minSets, maxSets).toInt(),
    targetRepsPerSet: targetRepsPerSet.clamp(minReps, maxRepsPerSet).toInt(),
    restDurationSeconds: restDurationSeconds
        .clamp(minRestSeconds, maxRestSeconds)
        .toInt(),
  );

  WorkoutPlan copyWith({
    String? id,
    int? setCount,
    int? targetRepsPerSet,
    int? restDurationSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      setCount: setCount ?? this.setCount,
      targetRepsPerSet: targetRepsPerSet ?? this.targetRepsPerSet,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'set_count': setCount,
    'target_reps_per_set': targetRepsPerSet,
    'rest_duration_seconds': restDurationSeconds,
    'created_at': createdAt.millisecondsSinceEpoch,
    'updated_at': updatedAt.millisecondsSinceEpoch,
  };

  factory WorkoutPlan.fromMap(Map<String, Object?> map) => WorkoutPlan(
    id: map['id']! as String,
    setCount: map['set_count']! as int,
    targetRepsPerSet: map['target_reps_per_set']! as int,
    restDurationSeconds: map['rest_duration_seconds']! as int,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']! as int),
  );
}
