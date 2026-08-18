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
  });

  final String sessionId;
  final String entryPoint;
  final bool challengeActive;
  final int targetSets;
  final int targetReps;

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
    'entry_point': entryPoint,
    'challenge_active': challengeActive ? 1 : 0,
    'target_sets': targetSets,
    'target_reps': targetReps,
  };
}
