/// Anonymous analytics context for one workout attempt.
///
/// This ID is generated when the user taps Start. It is not a Firebase UID,
/// device identifier, or workout database identifier.
class WorkoutAnalyticsSession {
  WorkoutAnalyticsSession({
    required this.sessionId,
    required this.entryPoint,
    required this.challengeActive,
    required this.targetSets,
    required this.targetReps,
    this.exerciseType = 'squat',
    this.isFirstWorkout,
    this.hadPriorCount = false,
  });

  final String sessionId;
  final String entryPoint;
  final bool challengeActive;
  final int targetSets;
  final int targetReps;
  final String exerciseType;
  bool? isFirstWorkout;
  final bool hadPriorCount;
  final Stopwatch clock = Stopwatch()..start();
  bool hadValidPose = false;
  bool calibrationCompleted = false;
  bool firstCountCompleted = false;
  bool calibrationObserved = false;
  int calibrationAttemptIndex = 1;
  String? preparationReason;

  final Set<String> _loggedOnce = <String>{};
  String? _terminalEvent;

  bool markOnce(String eventName) => _loggedOnce.add(eventName);

  bool markTerminal(String eventName) {
    if (_terminalEvent != null) return false;
    _terminalEvent = eventName;
    return _loggedOnce.add(eventName);
  }

  Map<String, Object> get parameters => <String, Object>{
    'workout_session_id': sessionId,
    'attempt_id': sessionId,
    'exercise_type': exerciseType,
    'target_unit': exerciseType == 'plank' ? 'seconds' : 'reps',
    'is_first_workout': isFirstWorkout == null
        ? -1
        : isFirstWorkout!
        ? 1
        : 0,
    'entry_point': entryPoint,
    'challenge_active': challengeActive ? 1 : 0,
    'target_sets': targetSets,
    'target_reps': targetReps,
  };
}
