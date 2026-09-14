import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/app/app.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/analytics/workout_retention.dart';
import 'package:motionfit_squat/core/notifications/notification_destination.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';

class _Sink implements AnalyticsSink {
  final events = <({String name, Map<String, Object> parameters})>[];
  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    events.add((name: name, parameters: parameters));
  }

  @override
  Future<void> logScreenView(String screenName) async {}
}

void main() {
  test('application and all exercise routes compile', () {
    expect(const MotionFitApp(), isNotNull);
  });

  test(
    'same-day second workout is distinct from next-day return across exercises',
    () {
      final workouts = [
        CompletedWorkout('a', 'squat', DateTime(2026, 9, 14, 9)),
        CompletedWorkout('b', 'pushup', DateTime(2026, 9, 14, 10)),
        CompletedWorkout('c', 'plank', DateTime(2026, 9, 15, 9)),
        CompletedWorkout('d', 'squat', DateTime(2026, 9, 15, 10)),
      ];
      final first = retentionMilestones(workouts, 'a', 'squat');
      expect(first, contains('mf2_first_workout_completed'));
      final second = retentionMilestones(workouts, 'b', 'pushup');
      expect(second, contains('mf2_app_second_workout_completed'));
      expect(second, isNot(contains('mf2_second_workout_day_completed')));
      final nextDay = retentionMilestones(workouts, 'c', 'plank');
      expect(
        nextDay['mf2_second_workout_day_completed']!['workout_day_count'],
        2,
      );
      expect(
        nextDay['mf2_second_workout_day_completed']!['is_next_calendar_day'],
        1,
      );
      expect(retentionMilestones(workouts, 'd', 'squat'), isEmpty);
      final later = retentionMilestones(
        [workouts.first, CompletedWorkout('e', 'plank', DateTime(2026, 9, 18))],
        'e',
        'plank',
      );
      expect(
        later['mf2_second_workout_day_completed']!['is_next_calendar_day'],
        0,
      );
    },
  );

  test('dismissed reminder gets one retry; permission denial never does', () {
    final initial = UserPreferences.defaults();
    expect(initial.shouldOfferWorkoutReminder(0), isFalse);
    expect(initial.shouldOfferWorkoutReminder(1), isTrue);
    final dismissed = initial.copyWith(
      reminderPromptCount: 1,
      postWorkoutReminderPromptedAtWorkoutCount: 1,
      reminderPromptResponse: ReminderPromptResponse.dismissed,
    );
    expect(dismissed.shouldOfferWorkoutReminder(1), isFalse);
    expect(dismissed.shouldOfferWorkoutReminder(2), isTrue);
    expect(
      dismissed.copyWith(reminderPromptCount: 2).shouldOfferWorkoutReminder(3),
      isFalse,
    );
    expect(
      dismissed
          .copyWith(postWorkoutReminderPermissionDenied: true)
          .shouldOfferWorkoutReminder(3),
      isFalse,
    );
    expect(
      dismissed
          .copyWith(reminderPromptResponse: ReminderPromptResponse.accepted)
          .shouldOfferWorkoutReminder(3),
      isFalse,
    );
    expect(
      initial
          .copyWith(
            reminderPromptCount: 1,
            postWorkoutReminderPromptedAtWorkoutCount: 1,
          )
          .shouldOfferWorkoutReminder(2),
      isTrue,
    );
  });

  test('notification destinations preserve explicit or last exercise', () {
    final challenge = NotificationDestination.parse(
      'motionfit://challenge/pushup',
      fallbackExercise: 'squat',
    )!;
    expect(challenge.exercise, ExerciseType.pushup);
    expect(challenge.route, '/challenge');
    expect(
      NotificationDestination.parse(
        'motionfit://workout',
        fallbackExercise: 'plank',
      )!.exercise,
      ExerciseType.plank,
    );
    expect(
      NotificationDestination.parse(
        'motionfit://workout?exercise=pushup',
        fallbackExercise: 'plank',
      )!.exercise,
      ExerciseType.pushup,
    );
    expect(
      NotificationDestination.parse(
        'https://challenge/pushup',
        fallbackExercise: 'squat',
      ),
      isNull,
    );
    expect(
      NotificationDestination.parse(
        'motionfit://challenge/unknown',
        fallbackExercise: 'squat',
      ),
      isNull,
    );
  });

  test(
    'count commits, preparation transitions and exits are deduplicated per attempt',
    () async {
      final sink = _Sink();
      final analytics = AnalyticsService(
        sink: sink,
        sessionIdFactory: () => 'attempt',
        appVersion: '1.6.13',
      );
      analytics.workoutStartTapped(
        plannedSets: 1,
        plannedRepsPerSet: 20,
        launchSource: 'workoutTab',
        exerciseType: 'plank',
        isFirstWorkout: true,
      );
      for (var i = 0; i < 10; i++) {
        analytics.preparationChanged(
          reason: 'low_confidence',
          hadValidPose: false,
          ready: false,
        );
      }
      analytics.firstCountCommitted(attemptId: 'stale');
      analytics.workoutExit(stage: 'calibration', reason: 'cancelled');
      analytics.workoutExit(stage: 'calibration', reason: 'cancelled');
      await analytics.flush();
      expect(
        sink.events
            .where((e) => e.name == 'mf2_preparation_state_changed')
            .length,
        1,
      );
      expect(
        sink.events.where((e) => e.name == 'mf2_first_count_committed'),
        isEmpty,
      );
      final exit = sink.events.singleWhere((e) => e.name == 'mf2_workout_exit');
      expect(exit.parameters['first_count_completed'], 0);
      expect(exit.parameters['had_valid_pose'], 0);
      expect(exit.parameters['attempt_id'], 'attempt');
      expect(exit.parameters['exercise_type'], 'plank');
      expect(exit.parameters['target_unit'], 'seconds');
      expect(exit.parameters['analytics_revision'], 3);
      analytics.workoutStartTapped(
        plannedSets: 1,
        plannedRepsPerSet: 20,
        launchSource: 'workoutTab',
        exerciseType: 'pushup',
      );
      analytics.firstCountCommitted(attemptId: 'attempt');
      analytics.firstCountCommitted(attemptId: 'attempt');
      await analytics.flush();
      expect(
        sink.events.where((e) => e.name == 'mf2_first_count_committed').length,
        1,
      );
    },
  );
}
