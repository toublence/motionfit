import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/settings/domain/theme_preferences.dart';
import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_plan.dart';

void main() {
  test('new installs enable rep video review by default', () {
    expect(UserPreferences.defaults().repVideoReviewEnabled, isTrue);
  });

  test('missing video preference defaults on and explicit false is kept', () {
    final missing = UserPreferences.defaults().toJson()
      ..remove('repVideoReviewEnabled');
    final explicitOff = UserPreferences.defaults().toJson()
      ..['repVideoReviewEnabled'] = false;

    expect(
      UserPreferences.decode(jsonEncode(missing)).repVideoReviewEnabled,
      isTrue,
    );
    expect(
      UserPreferences.decode(jsonEncode(explicitOff)).repVideoReviewEnabled,
      isFalse,
    );
  });

  test('all user preferences survive JSON serialization', () {
    final timestamp = DateTime.utc(2026, 7, 21, 10, 30);
    final preferences = UserPreferences(
      locale: 'ar',
      preferredRecordView: RecordViewMode.statistics,
      displayTheme: MotionFitDisplayTheme.dark,
      colorTheme: MotionFitColorTheme.chwiram,
      voiceCoachingEnabled: false,
      repCountVoiceEnabled: false,
      formVoiceEnabled: true,
      encouragementVoiceEnabled: false,
      ttsRate: 0.63,
      hapticsEnabled: false,
      selectedCamera: CameraSelection.back,
      onboardingStartedAt: timestamp.subtract(const Duration(minutes: 2)),
      onboardingLastStep: 2,
      reviewRequested: true,
      lastReviewRequestAttemptAt: timestamp,
      lastReviewRequestAppVersion: '1.0.7',
      installedAt: timestamp.subtract(const Duration(days: 10)),
      lastInterstitialShownAt: timestamp,
      postWorkoutReminderPromptedAtWorkoutCount: 3,
      postWorkoutReminderDeferred: true,
      postWorkoutReminderPermissionDenied: true,
      lastWorkoutPlan: WorkoutPlan(
        id: 'saved-plan',
        setCount: 5,
        targetRepsPerSet: 12,
        restDurationSeconds: 75,
        createdAt: timestamp,
        updatedAt: timestamp.add(const Duration(minutes: 1)),
      ),
    );

    final restored = UserPreferences.decode(preferences.encode());

    expect(restored.locale, 'ar');
    expect(restored.preferredRecordView, RecordViewMode.statistics);
    expect(restored.displayTheme, MotionFitDisplayTheme.dark);
    expect(restored.colorTheme, MotionFitColorTheme.chwiram);
    expect(restored.voiceCoachingEnabled, isFalse);
    expect(restored.repCountVoiceEnabled, isFalse);
    expect(restored.formVoiceEnabled, isTrue);
    expect(restored.encouragementVoiceEnabled, isFalse);
    expect(restored.ttsRate, 0.63);
    expect(restored.hapticsEnabled, isFalse);
    expect(restored.selectedCamera, CameraSelection.back);
    expect(
      restored.onboardingStartedAt?.millisecondsSinceEpoch,
      timestamp.subtract(const Duration(minutes: 2)).millisecondsSinceEpoch,
    );
    expect(restored.onboardingLastStep, 2);
    expect(restored.reviewRequested, isTrue);
    expect(
      restored.lastReviewRequestAttemptAt?.millisecondsSinceEpoch,
      timestamp.millisecondsSinceEpoch,
    );
    expect(restored.lastReviewRequestAppVersion, '1.0.7');
    expect(
      restored.installedAt.millisecondsSinceEpoch,
      timestamp.subtract(const Duration(days: 10)).millisecondsSinceEpoch,
    );
    expect(
      restored.lastInterstitialShownAt?.millisecondsSinceEpoch,
      timestamp.millisecondsSinceEpoch,
    );
    expect(restored.postWorkoutReminderPromptedAtWorkoutCount, 3);
    expect(restored.postWorkoutReminderDeferred, isTrue);
    expect(restored.postWorkoutReminderPermissionDenied, isTrue);
    expect(restored.lastWorkoutPlan.id, 'saved-plan');
    expect(restored.lastWorkoutPlan.setCount, 5);
    expect(restored.lastWorkoutPlan.targetRepsPerSet, 12);
    expect(restored.lastWorkoutPlan.restDurationSeconds, 75);
    expect(
      restored.lastWorkoutPlan.createdAt.millisecondsSinceEpoch,
      timestamp.millisecondsSinceEpoch,
    );
  });

  test('decode applies safe enum, locale, rate, and plan bounds', () {
    final raw = UserPreferences.defaults().toJson();
    raw['locale'] = 'unsupported';
    raw['preferredRecordView'] = 'unknown';
    raw['displayTheme'] = 'unknown';
    raw['colorTheme'] = 'unknown';
    raw['ttsRate'] = 4.0;
    raw['selectedCamera'] = 'unknown';
    final plan = Map<String, Object?>.from(raw['lastWorkoutPlan']! as Map);
    plan['set_count'] = 99;
    plan['target_reps_per_set'] = 0;
    plan['rest_duration_seconds'] = 999;
    raw['lastWorkoutPlan'] = plan;

    final restored = UserPreferences.decode(jsonEncode(raw));

    expect(restored.locale, isNull);
    expect(restored.preferredRecordView, RecordViewMode.calendar);
    expect(restored.displayTheme, MotionFitDisplayTheme.system);
    expect(restored.colorTheme, MotionFitColorTheme.byeokcheong);
    expect(restored.ttsRate, 0.8);
    expect(restored.selectedCamera, CameraSelection.front);
    expect(restored.lastWorkoutPlan.setCount, WorkoutPlan.maxSets);
    expect(restored.lastWorkoutPlan.targetRepsPerSet, WorkoutPlan.minReps);
    expect(
      restored.lastWorkoutPlan.restDurationSeconds,
      WorkoutPlan.maxRestSeconds,
    );
  });

  test('copyWith can return to system locale and clamps mutable values', () {
    final preferences = UserPreferences.defaults()
        .copyWith(locale: 'ko')
        .copyWith(
          useSystemLocale: true,
          ttsRate: 0.01,
          lastWorkoutPlan: WorkoutPlan.defaults().copyWith(
            setCount: -1,
            targetRepsPerSet: 1000,
          ),
        );

    expect(preferences.locale, isNull);
    expect(preferences.ttsRate, 0.2);
    expect(preferences.lastWorkoutPlan.setCount, WorkoutPlan.minSets);
    expect(preferences.lastWorkoutPlan.targetRepsPerSet, WorkoutPlan.maxReps);
  });

  test('legacy payload gets retention-safe persistence defaults', () {
    final raw = UserPreferences.defaults().toJson()
      ..remove('installedAt')
      ..remove('lastInterstitialShownAt')
      ..remove('postWorkoutReminderPromptedAtWorkoutCount')
      ..remove('postWorkoutReminderDeferred')
      ..remove('postWorkoutReminderPermissionDenied');
    raw
      ..remove('onboardingStartedAt')
      ..remove('onboardingLastStep');

    final restored = UserPreferences.decode(jsonEncode(raw));

    expect(restored.installedAt.millisecondsSinceEpoch, 0);
    expect(restored.lastInterstitialShownAt, isNull);
    expect(restored.postWorkoutReminderPromptedAtWorkoutCount, 0);
    expect(restored.postWorkoutReminderDeferred, isFalse);
    expect(restored.postWorkoutReminderPermissionDenied, isFalse);
    expect(restored.onboardingStartedAt, isNull);
    expect(restored.onboardingLastStep, 0);
  });
}
