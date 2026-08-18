import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/core/permissions/permission_service.dart';
import 'package:motionfit_squat/features/pushup/providers.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/pushup/application/workout_preparation.dart';

Future<void> openWorkoutPreparation(
  BuildContext context,
  WidgetRef ref,
  WorkoutPreparation preparation,
) async {
  ref
      .read(analyticsServiceProvider)
      .workoutStartTapped(
        plannedSets: preparation.plan.setCount,
        plannedRepsPerSet: preparation.plan.targetRepsPerSet,
        launchSource: preparation.launchSource.name,
        isRecovery: preparation.isRecovery,
        challengeActive: preparation.challenge != null,
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
    final guideSeen = ref.read(preferencesControllerProvider).pushupCameraGuideSeen;
    await context.push(
      guideSeen ? '/pushup/prepare/countdown' : '/pushup/prepare/guide',
      extra: preparation,
    );
    return;
  }
  ref.read(workoutLaunchContextProvider.notifier).set(preparation);
  await context.push('/pushup/prepare/permission', extra: preparation);
}
