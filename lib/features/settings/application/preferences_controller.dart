import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';
import 'package:motionfit_squat/features/settings/domain/theme_preferences.dart';
import 'package:motionfit_squat/features/plank/providers.dart'
    as plank_providers;
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_plan.dart'
    as plank;
import 'package:motionfit_squat/features/pushup/domain/models/workout_plan.dart'
    as pushup;
import 'package:motionfit_squat/features/pushup/providers.dart'
    as pushup_providers;
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_plan.dart';

final preferencesControllerProvider =
    NotifierProvider<PreferencesController, UserPreferences>(
      PreferencesController.new,
    );

class PreferencesController extends Notifier<UserPreferences> {
  Future<void> _pendingOperation = Future.value();

  @override
  UserPreferences build() => ref.watch(initialPreferencesProvider);

  Future<void> _commit(UserPreferences next) async {
    final previous = state;
    state = next;
    try {
      await ref.read(preferencesServiceProvider).save(next);
    } on Object {
      state = previous;
      rethrow;
    }
  }

  Future<void> setLocale(String? locale) => _serialize(
    () => _commit(
      locale == null
          ? state.copyWith(useSystemLocale: true)
          : state.copyWith(locale: locale),
    ),
  );

  Future<void> setRecordView(RecordViewMode view) =>
      _serialize(() => _commit(state.copyWith(preferredRecordView: view)));

  Future<void> setDisplayTheme(MotionFitDisplayTheme value) =>
      _serialize(() => _commit(state.copyWith(displayTheme: value)));

  Future<void> setColorTheme(MotionFitColorTheme value) =>
      _serialize(() => _commit(state.copyWith(colorTheme: value)));

  Future<void> setVoiceCoaching(bool value) =>
      _serialize(() => _commit(state.copyWith(voiceCoachingEnabled: value)));

  Future<void> setRepCountVoice(bool value) =>
      _serialize(() => _commit(state.copyWith(repCountVoiceEnabled: value)));

  Future<void> setFormVoice(bool value) =>
      _serialize(() => _commit(state.copyWith(formVoiceEnabled: value)));

  Future<void> setEncouragementVoice(bool value) => _serialize(
    () => _commit(state.copyWith(encouragementVoiceEnabled: value)),
  );

  Future<void> setTtsRate(double value) =>
      _serialize(() => _commit(state.copyWith(ttsRate: value)));

  Future<void> setHaptics(bool value) =>
      _serialize(() => _commit(state.copyWith(hapticsEnabled: value)));

  Future<void> setCamera(CameraSelection value) =>
      _serialize(() => _commit(state.copyWith(selectedCamera: value)));

  Future<void> setRepVideoReview(bool value) =>
      _serialize(() => _commit(state.copyWith(repVideoReviewEnabled: value)));

  Future<void> markCameraGuideSeen() =>
      _serialize(() => _commit(state.copyWith(cameraGuideSeen: true)));

  Future<void> markCameraSetupSeen() => _serialize(
    () => _commit(
      state.copyWith(
        cameraGuideSeen: true,
        pushupCameraGuideSeen: true,
        plankCameraGuideSeen: true,
      ),
    ),
  );

  Future<void> markPushupCameraGuideSeen() =>
      _serialize(() => _commit(state.copyWith(pushupCameraGuideSeen: true)));

  Future<void> markPlankCameraGuideSeen() =>
      _serialize(() => _commit(state.copyWith(plankCameraGuideSeen: true)));

  Future<void> markReviewRequestAttempted(
    String appVersion,
    DateTime attemptedAt,
  ) => _serialize(
    () => _commit(
      state.copyWith(
        reviewRequested: true,
        lastReviewRequestAppVersion: appVersion,
        lastReviewRequestAttemptAt: attemptedAt,
      ),
    ),
  );

  Future<void> markInterstitialShown() => _serialize(
    () => _commit(state.copyWith(lastInterstitialShownAt: DateTime.now())),
  );

  Future<void> markReminderPromptShown(int completedWorkoutCount) => _serialize(
    () => _commit(
      state.copyWith(
        postWorkoutReminderPromptedAtWorkoutCount: completedWorkoutCount,
      ),
    ),
  );

  Future<void> setReminderPromptDeferred(bool deferred) => _serialize(
    () => _commit(state.copyWith(postWorkoutReminderDeferred: deferred)),
  );

  Future<void> setReminderPermissionDenied(bool denied) => _serialize(
    () => _commit(state.copyWith(postWorkoutReminderPermissionDenied: denied)),
  );

  Future<void> completeOnboarding() => _serialize(
    () => _commit(
      state.copyWith(onboardingCompleted: true, clearOnboardingStartedAt: true),
    ),
  );

  Future<void> markOnboardingStarted(DateTime startedAt) => _serialize(
    () => _commit(
      state.copyWith(onboardingStartedAt: startedAt, onboardingLastStep: 0),
    ),
  );

  Future<void> markOnboardingStep(int step) =>
      _serialize(() => _commit(state.copyWith(onboardingLastStep: step)));

  Future<void> setWorkoutPlan(WorkoutPlan plan) => _serialize(() async {
    final normalized = plan.normalized().copyWith(updatedAt: DateTime.now());
    await ref.read(workoutRepositoryProvider).savePlan(normalized);
    await _commit(state.copyWith(lastWorkoutPlan: normalized));
  });

  Future<void> setPushupWorkoutPlan(pushup.WorkoutPlan plan) => _serialize(
    () async {
      final normalized = plan.normalized().copyWith(updatedAt: DateTime.now());
      await ref
          .read(pushup_providers.workoutRepositoryProvider)
          .savePlan(normalized);
      await _commit(state.copyWith(pushupLastWorkoutPlan: normalized));
    },
  );

  Future<void> setPlankWorkoutPlan(plank.WorkoutPlan plan) => _serialize(
    () async {
      final normalized = plan.normalized().copyWith(updatedAt: DateTime.now());
      await ref
          .read(plank_providers.workoutRepositoryProvider)
          .savePlan(normalized);
      await _commit(state.copyWith(plankLastWorkoutPlan: normalized));
    },
  );

  Future<void> _serialize(Future<void> Function() operation) {
    final run = _pendingOperation.then((_) => operation());
    _pendingOperation = run.catchError((Object _) {});
    return run;
  }
}
