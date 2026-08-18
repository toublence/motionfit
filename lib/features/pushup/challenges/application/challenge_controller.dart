import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/features/pushup/providers.dart';
import 'package:motionfit_squat/core/notifications/notification_service.dart';
import 'package:motionfit_squat/features/pushup/challenges/domain/challenge.dart';
import 'package:motionfit_squat/features/pushup/records/application/records_providers.dart';
import 'package:motionfit_squat/features/pushup/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/pushup/domain/services/workout_session_policy.dart';
import 'package:uuid/uuid.dart';

class ChallengeDashboard {
  const ChallengeDashboard({
    required this.active,
    required this.history,
    required this.hasWorkoutHistory,
    required this.referenceWorkoutReps,
    required this.recommendedType,
    required this.recommendedLevel,
    required this.daysSinceInstall,
    required this.recommendationDismissed,
  });

  final ChallengeProgress? active;
  final List<ChallengeProgress> history;
  final bool hasWorkoutHistory;
  final int referenceWorkoutReps;
  final ChallengeType recommendedType;
  final String recommendedLevel;
  final int daysSinceInstall;
  final bool recommendationDismissed;
}

final challengeDashboardProvider =
    AsyncNotifierProvider<ChallengeController, ChallengeDashboard>(
      ChallengeController.new,
    );

final challengeBadgeProvider = FutureProvider<bool>((ref) async {
  final sessions = await ref.watch(allSessionsProvider.future);
  final hasCompleted = sessions.any(
    (details) => details.session.completed && !details.session.interrupted,
  );
  if (!hasCompleted) return false;
  return !await ref.watch(challengeRepositoryProvider).isBadgeSeen();
});

final challengeProgressProvider = Provider.family<ChallengeProgress?, String>((
  ref,
  id,
) {
  final dashboard = ref.watch(challengeDashboardProvider).value;
  if (dashboard == null) return null;
  if (dashboard.active?.challenge.id == id) return dashboard.active;
  for (final progress in dashboard.history) {
    if (progress.challenge.id == id) return progress;
  }
  return null;
});

class ChallengeController extends AsyncNotifier<ChallengeDashboard> {
  static const _uuid = Uuid();

  @override
  Future<ChallengeDashboard> build() async {
    unawaited(
      ref
          .read(crashReportingServiceProvider)
          .setCustomKey('challenge_state', 'loading'),
    );
    final repository = ref.watch(challengeRepositoryProvider);
    final sessions = await ref.watch(allSessionsProvider.future);
    final installDate = await repository.installReferenceDate();
    final completedSessions = sessions
        .where(
          (details) =>
              details.session.completed && !details.session.interrupted,
        )
        .toList(growable: false);
    final challengeSessions = sessions
        .where(
          (details) => WorkoutSessionPolicy.canUpdateChallenge(details.session),
        )
        .toList(growable: false);
    final firstSession = completedSessions.isEmpty
        ? null
        : completedSessions.last;
    final referenceReps = firstSession?.session.totalReps ?? 0;
    final recommendation = _recommend(referenceReps, firstSession != null);
    final recommendationDismissed = await repository
        .isRecommendationDismissed();
    await repository.deleteByType(ChallengeType.weekly);
    var challenges = await repository.loadAll();
    final hasActiveReminder = challenges.any(
      (challenge) =>
          challenge.status == ChallengeStatus.active &&
          challenge.notificationEnabled,
    );
    if (!hasActiveReminder) {
      await ref
          .read(notificationServiceProvider)
          .cancelChallengeReminder(
            namespace: ChallengeNotificationNamespace.pushup,
          );
    }
    final progressValues = <ChallengeProgress>[];
    for (var challenge in challenges) {
      if (challenge.type == ChallengeType.sevenDay &&
          challenge.dailyGoals.contains(0)) {
        challenge = challenge.copyWith(
          dailyGoals: _continuousSevenDayGoals(challenge.dailyGoals),
        );
        await repository.update(challenge);
      }
      var progress = calculateProgress(challenge, challengeSessions);
      if (challenge.status == ChallengeStatus.active) {
        final today = _day(DateTime.now());
        final finalStatus = progress.progress >= 1
            ? ChallengeStatus.completed
            : today.isAfter(_day(challenge.endsAt))
            ? ChallengeStatus.ended
            : ChallengeStatus.active;
        if (finalStatus != ChallengeStatus.active) {
          if (challenge.notificationEnabled) {
            await ref
                .read(notificationServiceProvider)
                .cancelChallengeReminder(
                  namespace: ChallengeNotificationNamespace.pushup,
                );
          }
          challenge = challenge.copyWith(status: finalStatus);
          await repository.update(challenge);
          if (finalStatus == ChallengeStatus.completed) {
            ref
                .read(analyticsServiceProvider)
                .challengeCompleted(challengeType: challenge.type.name);
          }
          progress = calculateProgress(challenge, challengeSessions);
        }
      }
      progressValues.add(progress);
    }
    final dashboard = ChallengeDashboard(
      active: progressValues
          .where((value) => value.challenge.status == ChallengeStatus.active)
          .firstOrNull,
      history: progressValues
          .where((value) => value.challenge.status != ChallengeStatus.active)
          .toList(growable: false),
      hasWorkoutHistory: firstSession != null,
      referenceWorkoutReps: referenceReps,
      recommendedType: recommendation.$1,
      recommendedLevel: recommendation.$2,
      daysSinceInstall: math.max(
        0,
        DateTime.now().difference(installDate).inDays,
      ),
      recommendationDismissed: recommendationDismissed,
    );
    unawaited(
      ref
          .read(crashReportingServiceProvider)
          .setCustomKey(
            'challenge_state',
            dashboard.active == null ? 'idle' : 'active',
          ),
    );
    return dashboard;
  }

  Future<void> dismissRecommendation() async {
    await ref.read(challengeRepositoryProvider).dismissRecommendation();
    ref.invalidateSelf();
    await future;
  }

  Future<void> startSevenDay({required int firstDayGoal}) => _start(
    type: ChallengeType.sevenDay,
    durationDays: 7,
    targetReps: 0,
    dailyGoals: _sevenDayGoals(firstDayGoal),
  );

  Future<void> startCumulative({
    required int durationDays,
    required int targetReps,
  }) => _start(
    type: ChallengeType.cumulative,
    durationDays: durationDays,
    targetReps: targetReps,
  );

  Future<void> restart(Challenge source) => _start(
    type: source.type,
    durationDays:
        _day(source.endsAt).difference(_day(source.startedAt)).inDays + 1,
    targetReps: source.targetReps,
    dailyGoals: source.dailyGoals,
    weekdays: source.weekdays,
  );

  Future<void> _start({
    required ChallengeType type,
    required int durationDays,
    required int targetReps,
    List<int> dailyGoals = const [],
    List<int> weekdays = const [],
  }) async {
    if (state.value?.active != null) {
      throw StateError('Only one challenge can be active.');
    }
    final now = DateTime.now();
    final start = _day(now);
    await ref
        .read(challengeRepositoryProvider)
        .start(
          Challenge(
            id: _uuid.v4(),
            type: type,
            status: ChallengeStatus.active,
            startedAt: now,
            endsAt: start.add(Duration(days: durationDays - 1)),
            targetReps: targetReps,
            dailyGoals: List.unmodifiable(dailyGoals),
            weekdays: List.unmodifiable(weekdays),
            notificationEnabled: false,
            createdAt: now,
          ),
        );
    unawaited(
      ref
          .read(crashReportingServiceProvider)
          .setCustomKey('challenge_state', 'active'),
    );
    ref.invalidateSelf();
    await future;
    ref
        .read(analyticsServiceProvider)
        .challengeStarted(challengeType: type.name);
  }

  Future<void> cancel(String id) async {
    final progress = _find(id);
    if (progress == null ||
        progress.challenge.status != ChallengeStatus.active) {
      return;
    }
    if (progress.challenge.notificationEnabled) {
      await ref
          .read(notificationServiceProvider)
          .cancelChallengeReminder(
            namespace: ChallengeNotificationNamespace.pushup,
          );
    }
    await ref
        .read(challengeRepositoryProvider)
        .update(progress.challenge.copyWith(status: ChallengeStatus.cancelled));
    unawaited(
      ref
          .read(crashReportingServiceProvider)
          .setCustomKey('challenge_state', 'cancelled'),
    );
    ref.invalidateSelf();
    await future;
    ref
        .read(analyticsServiceProvider)
        .challengeCancelled(challengeType: progress.challenge.type.name);
  }

  Future<NotificationPermissionResult> setNotification(
    String id,
    bool enabled, {
    required String title,
    required String body,
  }) async {
    final progress = _find(id);
    if (progress == null) return NotificationPermissionResult.unavailable;
    final notifications = ref.read(notificationServiceProvider);
    if (enabled) {
      const source = 'challenge';
      final preferences = ref.read(preferencesControllerProvider);
      NotificationPermissionResult permission;
      if (preferences.postWorkoutReminderPermissionDenied) {
        permission = await notifications.permissionStatus();
      } else {
        ref
            .read(analyticsServiceProvider)
            .reminderPermissionRequested(source: source);
        permission = await notifications.requestPermission();
      }
      ref
          .read(analyticsServiceProvider)
          .reminderPermissionResult(result: permission.name, source: source);
      if (permission == NotificationPermissionResult.granted ||
          permission == NotificationPermissionResult.denied ||
          permission == NotificationPermissionResult.permanentlyDenied) {
        try {
          await ref
              .read(preferencesControllerProvider.notifier)
              .setReminderPermissionDenied(
                permission != NotificationPermissionResult.granted,
              );
        } on Object {
          // Challenge scheduling must not depend on prompt eligibility storage.
        }
      }
      if (permission != NotificationPermissionResult.granted) {
        return permission;
      }
      try {
        await notifications.scheduleChallengeReminder(
          title: title,
          body: body,
          weekdays: progress.challenge.type == ChallengeType.weekly
              ? progress.challenge.weekdays
              : const [],
          namespace: ChallengeNotificationNamespace.pushup,
        );
      } on Object {
        ref
            .read(analyticsServiceProvider)
            .reminderScheduleFailed(source: source);
        rethrow;
      }
      ref.read(analyticsServiceProvider).reminderScheduled(source: source);
    } else {
      await notifications.cancelChallengeReminder(
        namespace: ChallengeNotificationNamespace.pushup,
      );
      ref.read(analyticsServiceProvider).reminderDisabled(source: 'challenge');
    }
    await ref
        .read(challengeRepositoryProvider)
        .update(progress.challenge.copyWith(notificationEnabled: enabled));
    ref.invalidateSelf();
    await future;
    return NotificationPermissionResult.granted;
  }

  Future<void> delete(String id) async {
    final progress = _find(id);
    if (progress == null ||
        progress.challenge.status == ChallengeStatus.active) {
      return;
    }
    await ref.read(challengeRepositoryProvider).delete(id);
    ref.invalidateSelf();
    await future;
  }

  Future<bool> markBadgeSeen() async {
    final visible = await ref.read(challengeBadgeProvider.future);
    if (!visible) return false;
    await ref.read(challengeRepositoryProvider).markBadgeSeen();
    ref.invalidate(challengeBadgeProvider);
    return true;
  }

  ChallengeProgress? _find(String id) {
    final dashboard = state.value;
    if (dashboard?.active?.challenge.id == id) return dashboard!.active;
    return dashboard?.history
        .where((value) => value.challenge.id == id)
        .firstOrNull;
  }

  static (ChallengeType, String) _recommend(int reps, bool hasHistory) {
    if (!hasHistory || reps <= 15) {
      return (ChallengeType.sevenDay, 'light');
    }
    if (reps <= 30) return (ChallengeType.sevenDay, 'steady');
    return (ChallengeType.cumulative, 'familiar');
  }

  static List<int> _sevenDayGoals(int firstDayGoal) {
    final first = firstDayGoal.clamp(1, 70);
    return List.generate(7, (index) => first + index * 5, growable: false);
  }

  static List<int> _continuousSevenDayGoals(List<int> current) {
    final firstGoal = current.firstOrNull ?? 10;
    return _sevenDayGoals(firstGoal);
  }

  static ChallengeProgress calculateProgress(
    Challenge challenge,
    List<WorkoutSessionDetails> sessions,
  ) {
    final start = _day(challenge.startedAt);
    final countingStartedAt = challenge.createdAt.toLocal();
    final endExclusive = _day(challenge.endsAt).add(const Duration(days: 1));
    final matching = sessions
        .where((details) {
          final sessionStartedAt = details.session.startedAt.toLocal();
          final date = _day(sessionStartedAt);
          return !sessionStartedAt.isBefore(countingStartedAt) &&
              !date.isBefore(start) &&
              date.isBefore(endExclusive);
        })
        .toList(growable: false);
    final daily = <DateTime, int>{};
    var totalReps = 0;
    var activeSeconds = 0;
    for (final details in matching) {
      final date = _day(details.session.startedAt.toLocal());
      final reps = details.session.totalReps;
      daily[date] = (daily[date] ?? 0) + reps;
      totalReps += reps;
      activeSeconds += details.session.activeDurationSeconds;
    }
    final today = _day(DateTime.now());
    final currentDay =
        today
            .difference(start)
            .inDays
            .clamp(0, endExclusive.difference(start).inDays - 1) +
        1;
    final currentWeek = ((currentDay - 1) ~/ 7) + 1;
    final weekStart = start.add(Duration(days: (currentWeek - 1) * 7));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final weekDays = daily.keys
        .where((date) => !date.isBefore(weekStart) && date.isBefore(weekEnd))
        .length;
    var countedDays = daily.length;
    double progress;
    if (challenge.type == ChallengeType.sevenDay) {
      var achieved = 0;
      var target = 0;
      for (var i = 0; i < challenge.dailyGoals.length; i++) {
        final goal = challenge.dailyGoals[i];
        target += goal;
        achieved += math.min(goal, daily[start.add(Duration(days: i))] ?? 0);
      }
      progress = target == 0 ? 0 : achieved / target;
    } else if (challenge.type == ChallengeType.weekly) {
      countedDays = 0;
      for (var week = 0; week < 4; week++) {
        final from = start.add(Duration(days: week * 7));
        final to = from.add(const Duration(days: 7));
        countedDays += math.min(
          3,
          daily.keys
              .where((date) => !date.isBefore(from) && date.isBefore(to))
              .length,
        );
      }
      progress = countedDays / 12;
    } else {
      progress = challenge.targetReps == 0
          ? 0
          : totalReps / challenge.targetReps;
    }
    return ChallengeProgress(
      challenge: challenge,
      totalReps: totalReps,
      workoutDays: daily.length,
      totalActiveSeconds: activeSeconds,
      progress: progress.clamp(0, 1),
      todayReps: daily[today] ?? 0,
      currentDay: currentDay,
      currentWeek: currentWeek,
      thisWeekWorkoutDays: math.min(3, weekDays),
      countedWorkoutDays: countedDays,
      remainingDays: math.max(0, endExclusive.difference(today).inDays),
      dailyReps: Map.unmodifiable(daily),
    );
  }

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
