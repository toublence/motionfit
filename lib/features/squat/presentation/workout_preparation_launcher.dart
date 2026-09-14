import 'dart:async';
import 'package:motionfit_squat/features/exercise/application/combined_workout_metrics.dart';
import 'package:motionfit_squat/core/notifications/notification_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/core/permissions/permission_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/squat/application/workout_preparation.dart';

Future<void> openWorkoutPreparation(
  BuildContext context,
  WidgetRef ref,
  WorkoutPreparation preparation,
) async {
  ref
      .read(analyticsServiceProvider)
      .workoutStartTapped(
        exerciseType: 'squat',
        entryPointOverride: ref
            .read(notificationEntryProvider.notifier)
            .consume('squat'),
        isFirstWorkout: ref.read(combinedWorkoutMetricsProvider).value == null
            ? null
            : ref
                      .read(combinedWorkoutMetricsProvider)
                      .value!
                      .completedWorkoutCount ==
                  0,
        hadPriorCount:
            preparation.recovery?.session.totalReps != null &&
            preparation.recovery!.session.totalReps > 0,
        plannedSets: preparation.plan.setCount,
        plannedRepsPerSet: preparation.plan.targetRepsPerSet,
        launchSource: preparation.launchSource.name,
        isRecovery: preparation.isRecovery,
        challengeActive: preparation.challenge != null,
      );
  final analytics = ref.read(analyticsServiceProvider);
  final attemptId = analytics.currentWorkoutSessionId!;
  unawaited(
    ref
        .read(combinedWorkoutMetricsProvider.future)
        .then((metrics) {
          analytics.resolveFirstWorkout(
            attemptId,
            metrics.completedWorkoutCount == 0,
          );
        })
        .catchError((Object _) {}),
  );
  final challenge = preparation.challenge;
  if (challenge != null) {
    ref
        .read(analyticsServiceProvider)
        .challengeWorkoutStarted(
          challengeType: challenge.challengeType,
          currentProgress: challenge.currentProgress,
        );
  }
  final permissions = ref.read(permissionServiceProvider);
  final status = await permissions.cameraStatus();
  if (!context.mounted) return;

  if (status == AppPermissionState.granted) {
    ref
        .read(analyticsServiceProvider)
        .cameraPermissionResult(result: status.name, requested: false);
    ref.read(workoutLaunchContextProvider.notifier).set(preparation);
    final guideSeen = ref.read(preferencesControllerProvider).cameraGuideSeen;
    await context.push(
      guideSeen ? '/prepare/countdown' : '/prepare/guide',
      extra: preparation,
    );
    return;
  }
  ref.read(workoutLaunchContextProvider.notifier).set(preparation);
  await context.push('/prepare/permission', extra: preparation);
}
