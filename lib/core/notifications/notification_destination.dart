import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';

class NotificationDestination {
  const NotificationDestination(this.exercise, this.challenge);
  final ExerciseType exercise;
  final bool challenge;
  String get route => challenge ? '/challenge' : '/squat';

  static NotificationDestination? parse(
    String payload, {
    required String fallbackExercise,
  }) {
    final uri = Uri.tryParse(payload);
    if (uri == null ||
        uri.scheme != 'motionfit' ||
        !const ['workout', 'challenge'].contains(uri.host) ||
        uri.pathSegments.length > 1)
      return null;
    final exercise =
        uri.pathSegments.firstOrNull ??
        uri.queryParameters['exercise'] ??
        fallbackExercise;
    final resolved = ExerciseType.values
        .where((value) => value.name == exercise)
        .firstOrNull;
    if (resolved == null) return null;
    return NotificationDestination(resolved, uri.host == 'challenge');
  }
}

final notificationEntryProvider = NotifierProvider<NotificationEntry, String?>(
  NotificationEntry.new,
);

class NotificationEntry extends Notifier<String?> {
  DateTime? _openedAt;
  @override
  String? build() => null;
  void opened(String exercise) {
    state = exercise;
    _openedAt = DateTime.now();
  }

  String? consume(String exercise) {
    final matches =
        state == exercise &&
        _openedAt != null &&
        DateTime.now().difference(_openedAt!) < const Duration(minutes: 5);
    state = null;
    _openedAt = null;
    return matches ? 'notification' : null;
  }
}
