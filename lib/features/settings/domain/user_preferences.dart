import 'dart:convert';

import 'package:motionfit_squat/features/settings/domain/theme_preferences.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_plan.dart'
    as plank;
import 'package:motionfit_squat/features/pushup/domain/models/workout_plan.dart'
    as pushup;
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_plan.dart';

class UserPreferences {
  UserPreferences({
    required this.locale,
    required this.preferredRecordView,
    this.displayTheme = MotionFitDisplayTheme.system,
    this.colorTheme = MotionFitColorTheme.byeokcheong,
    required this.voiceCoachingEnabled,
    required this.repCountVoiceEnabled,
    required this.formVoiceEnabled,
    required this.encouragementVoiceEnabled,
    required this.ttsRate,
    required this.hapticsEnabled,
    required this.selectedCamera,
    this.repVideoReviewEnabled = true,
    this.onboardingCompleted = false,
    this.onboardingStartedAt,
    this.onboardingLastStep = 0,
    this.cameraGuideSeen = false,
    this.reviewRequested = false,
    this.lastReviewRequestAttemptAt,
    this.lastReviewRequestAppVersion,
    required this.installedAt,
    this.lastInterstitialShownAt,
    this.postWorkoutReminderPromptedAtWorkoutCount = 0,
    this.postWorkoutReminderDeferred = false,
    this.postWorkoutReminderPermissionDenied = false,
    required this.lastWorkoutPlan,
    pushup.WorkoutPlan? pushupLastWorkoutPlan,
    plank.WorkoutPlan? plankLastWorkoutPlan,
    this.pushupCameraGuideSeen = false,
    this.plankCameraGuideSeen = false,
  }) : pushupLastWorkoutPlan =
           pushupLastWorkoutPlan ?? pushup.WorkoutPlan.defaults(),
       plankLastWorkoutPlan =
           plankLastWorkoutPlan ?? plank.WorkoutPlan.defaults();

  static const supportedLocales = <String>[
    'en',
    'ko',
    'de',
    'es',
    'fr',
    'ja',
    'ar',
    'zh',
    'zh_Hant',
  ];

  factory UserPreferences.defaults() => UserPreferences(
    locale: null,
    preferredRecordView: RecordViewMode.calendar,
    displayTheme: MotionFitDisplayTheme.system,
    colorTheme: MotionFitColorTheme.byeokcheong,
    voiceCoachingEnabled: true,
    repCountVoiceEnabled: true,
    formVoiceEnabled: true,
    encouragementVoiceEnabled: true,
    ttsRate: 0.48,
    hapticsEnabled: true,
    selectedCamera: CameraSelection.front,
    repVideoReviewEnabled: true,
    onboardingCompleted: false,
    cameraGuideSeen: false,
    installedAt: DateTime.now(),
    lastWorkoutPlan: WorkoutPlan.defaults(),
    pushupLastWorkoutPlan: pushup.WorkoutPlan.defaults(),
    plankLastWorkoutPlan: plank.WorkoutPlan.defaults(),
  );

  final String? locale;
  final RecordViewMode preferredRecordView;
  final MotionFitDisplayTheme displayTheme;
  final MotionFitColorTheme colorTheme;
  final bool voiceCoachingEnabled;
  final bool repCountVoiceEnabled;
  final bool formVoiceEnabled;
  final bool encouragementVoiceEnabled;
  final double ttsRate;
  final bool hapticsEnabled;
  final CameraSelection selectedCamera;
  final bool repVideoReviewEnabled;
  final bool onboardingCompleted;
  final DateTime? onboardingStartedAt;
  final int onboardingLastStep;
  final bool cameraGuideSeen;
  // reviewRequested is retained only to migrate the legacy one-shot flag.
  final bool reviewRequested;
  final DateTime? lastReviewRequestAttemptAt;
  final String? lastReviewRequestAppVersion;
  final DateTime installedAt;
  final DateTime? lastInterstitialShownAt;
  final int postWorkoutReminderPromptedAtWorkoutCount;
  final bool postWorkoutReminderDeferred;
  final bool postWorkoutReminderPermissionDenied;
  final WorkoutPlan lastWorkoutPlan;
  final pushup.WorkoutPlan pushupLastWorkoutPlan;
  final plank.WorkoutPlan plankLastWorkoutPlan;
  final bool pushupCameraGuideSeen;
  final bool plankCameraGuideSeen;

  bool get cameraSetupSeen =>
      cameraGuideSeen || pushupCameraGuideSeen || plankCameraGuideSeen;

  UserPreferences copyWith({
    String? locale,
    bool useSystemLocale = false,
    RecordViewMode? preferredRecordView,
    MotionFitDisplayTheme? displayTheme,
    MotionFitColorTheme? colorTheme,
    bool? voiceCoachingEnabled,
    bool? repCountVoiceEnabled,
    bool? formVoiceEnabled,
    bool? encouragementVoiceEnabled,
    double? ttsRate,
    bool? hapticsEnabled,
    CameraSelection? selectedCamera,
    bool? repVideoReviewEnabled,
    bool? onboardingCompleted,
    DateTime? onboardingStartedAt,
    bool clearOnboardingStartedAt = false,
    int? onboardingLastStep,
    bool? cameraGuideSeen,
    bool? reviewRequested,
    DateTime? lastReviewRequestAttemptAt,
    String? lastReviewRequestAppVersion,
    DateTime? installedAt,
    DateTime? lastInterstitialShownAt,
    int? postWorkoutReminderPromptedAtWorkoutCount,
    bool? postWorkoutReminderDeferred,
    bool? postWorkoutReminderPermissionDenied,
    WorkoutPlan? lastWorkoutPlan,
    pushup.WorkoutPlan? pushupLastWorkoutPlan,
    plank.WorkoutPlan? plankLastWorkoutPlan,
    bool? pushupCameraGuideSeen,
    bool? plankCameraGuideSeen,
  }) {
    return UserPreferences(
      locale: useSystemLocale ? null : locale ?? this.locale,
      preferredRecordView: preferredRecordView ?? this.preferredRecordView,
      displayTheme: displayTheme ?? this.displayTheme,
      colorTheme: colorTheme ?? this.colorTheme,
      voiceCoachingEnabled: voiceCoachingEnabled ?? this.voiceCoachingEnabled,
      repCountVoiceEnabled: repCountVoiceEnabled ?? this.repCountVoiceEnabled,
      formVoiceEnabled: formVoiceEnabled ?? this.formVoiceEnabled,
      encouragementVoiceEnabled:
          encouragementVoiceEnabled ?? this.encouragementVoiceEnabled,
      ttsRate: (ttsRate ?? this.ttsRate).clamp(0.2, 0.8).toDouble(),
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      selectedCamera: selectedCamera ?? this.selectedCamera,
      repVideoReviewEnabled:
          repVideoReviewEnabled ?? this.repVideoReviewEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingStartedAt: clearOnboardingStartedAt
          ? null
          : onboardingStartedAt ?? this.onboardingStartedAt,
      onboardingLastStep: (onboardingLastStep ?? this.onboardingLastStep)
          .clamp(0, 2)
          .toInt(),
      cameraGuideSeen: cameraGuideSeen ?? this.cameraGuideSeen,
      reviewRequested: reviewRequested ?? this.reviewRequested,
      lastReviewRequestAttemptAt:
          lastReviewRequestAttemptAt ?? this.lastReviewRequestAttemptAt,
      lastReviewRequestAppVersion:
          lastReviewRequestAppVersion ?? this.lastReviewRequestAppVersion,
      installedAt: installedAt ?? this.installedAt,
      lastInterstitialShownAt:
          lastInterstitialShownAt ?? this.lastInterstitialShownAt,
      postWorkoutReminderPromptedAtWorkoutCount:
          (postWorkoutReminderPromptedAtWorkoutCount ??
                  this.postWorkoutReminderPromptedAtWorkoutCount)
              .clamp(0, 1 << 31)
              .toInt(),
      postWorkoutReminderDeferred:
          postWorkoutReminderDeferred ?? this.postWorkoutReminderDeferred,
      postWorkoutReminderPermissionDenied:
          postWorkoutReminderPermissionDenied ??
          this.postWorkoutReminderPermissionDenied,
      lastWorkoutPlan: (lastWorkoutPlan ?? this.lastWorkoutPlan).normalized(),
      pushupLastWorkoutPlan:
          (pushupLastWorkoutPlan ?? this.pushupLastWorkoutPlan).normalized(),
      plankLastWorkoutPlan: (plankLastWorkoutPlan ?? this.plankLastWorkoutPlan)
          .normalized(),
      pushupCameraGuideSeen:
          pushupCameraGuideSeen ?? this.pushupCameraGuideSeen,
      plankCameraGuideSeen: plankCameraGuideSeen ?? this.plankCameraGuideSeen,
    );
  }

  Map<String, Object?> toJson() => {
    'locale': locale,
    'preferredRecordView': preferredRecordView.name,
    'displayTheme': displayTheme.name,
    'colorTheme': colorTheme.name,
    'voiceCoachingEnabled': voiceCoachingEnabled,
    'repCountVoiceEnabled': repCountVoiceEnabled,
    'formVoiceEnabled': formVoiceEnabled,
    'encouragementVoiceEnabled': encouragementVoiceEnabled,
    'ttsRate': ttsRate,
    'hapticsEnabled': hapticsEnabled,
    'selectedCamera': selectedCamera.name,
    'repVideoReviewEnabled': repVideoReviewEnabled,
    'onboardingCompleted': onboardingCompleted,
    'onboardingStartedAt': onboardingStartedAt?.millisecondsSinceEpoch,
    'onboardingLastStep': onboardingLastStep,
    'cameraGuideSeen': cameraGuideSeen,
    'reviewRequested': reviewRequested,
    'lastReviewRequestAttemptAt':
        lastReviewRequestAttemptAt?.millisecondsSinceEpoch,
    'lastReviewRequestAppVersion': lastReviewRequestAppVersion,
    'installedAt': installedAt.millisecondsSinceEpoch,
    'lastInterstitialShownAt': lastInterstitialShownAt?.millisecondsSinceEpoch,
    'postWorkoutReminderPromptedAtWorkoutCount':
        postWorkoutReminderPromptedAtWorkoutCount,
    'postWorkoutReminderDeferred': postWorkoutReminderDeferred,
    'postWorkoutReminderPermissionDenied': postWorkoutReminderPermissionDenied,
    'lastWorkoutPlan': lastWorkoutPlan.toMap(),
    'pushupLastWorkoutPlan': pushupLastWorkoutPlan.toMap(),
    'plankLastWorkoutPlan': plankLastWorkoutPlan.toMap(),
    'pushupCameraGuideSeen': pushupCameraGuideSeen,
    'plankCameraGuideSeen': plankCameraGuideSeen,
  };

  String encode() => jsonEncode(toJson());

  factory UserPreferences.decode(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    final localeValue = map['locale'] as String?;
    return UserPreferences(
      locale: supportedLocales.contains(localeValue) ? localeValue : null,
      preferredRecordView: enumByName(
        RecordViewMode.values,
        map['preferredRecordView'] as String?,
        RecordViewMode.calendar,
      ),
      displayTheme: themePreferenceByName(
        MotionFitDisplayTheme.values,
        map['displayTheme'] as String?,
        MotionFitDisplayTheme.system,
      ),
      colorTheme: themePreferenceByName(
        MotionFitColorTheme.values,
        map['colorTheme'] as String?,
        MotionFitColorTheme.byeokcheong,
      ),
      voiceCoachingEnabled: map['voiceCoachingEnabled'] as bool? ?? true,
      repCountVoiceEnabled: map['repCountVoiceEnabled'] as bool? ?? true,
      formVoiceEnabled: map['formVoiceEnabled'] as bool? ?? true,
      encouragementVoiceEnabled:
          map['encouragementVoiceEnabled'] as bool? ?? true,
      ttsRate: ((map['ttsRate'] as num?)?.toDouble() ?? 0.48)
          .clamp(0.2, 0.8)
          .toDouble(),
      hapticsEnabled: map['hapticsEnabled'] as bool? ?? true,
      selectedCamera: enumByName(
        CameraSelection.values,
        map['selectedCamera'] as String?,
        CameraSelection.front,
      ),
      repVideoReviewEnabled: map['repVideoReviewEnabled'] as bool? ?? true,
      // Existing installations already have a preferences payload and should
      // not be treated as a brand-new install after this field is introduced.
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? true,
      onboardingStartedAt: switch (map['onboardingStartedAt']) {
        final num value => DateTime.fromMillisecondsSinceEpoch(value.toInt()),
        _ => null,
      },
      onboardingLastStep: ((map['onboardingLastStep'] as num?)?.toInt() ?? 0)
          .clamp(0, 2)
          .toInt(),
      cameraGuideSeen: map['cameraGuideSeen'] as bool? ?? false,
      reviewRequested: map['reviewRequested'] as bool? ?? false,
      lastReviewRequestAttemptAt: switch (map['lastReviewRequestAttemptAt']) {
        final num value => DateTime.fromMillisecondsSinceEpoch(value.toInt()),
        _ => null,
      },
      lastReviewRequestAppVersion:
          map['lastReviewRequestAppVersion'] as String?,
      installedAt: switch (map['installedAt']) {
        final num value => DateTime.fromMillisecondsSinceEpoch(value.toInt()),
        _ => DateTime.fromMillisecondsSinceEpoch(0),
      },
      lastInterstitialShownAt: switch (map['lastInterstitialShownAt']) {
        final num value => DateTime.fromMillisecondsSinceEpoch(value.toInt()),
        _ => null,
      },
      postWorkoutReminderPromptedAtWorkoutCount:
          switch (map['postWorkoutReminderPromptedAtWorkoutCount']) {
            final num value => value.toInt().clamp(0, 1 << 31).toInt(),
            _ => 0,
          },
      postWorkoutReminderDeferred:
          map['postWorkoutReminderDeferred'] as bool? ?? false,
      postWorkoutReminderPermissionDenied:
          map['postWorkoutReminderPermissionDenied'] as bool? ?? false,
      lastWorkoutPlan: WorkoutPlan.fromMap(
        Map<String, Object?>.from(map['lastWorkoutPlan'] as Map),
      ).normalized(),
      pushupLastWorkoutPlan: switch (map['pushupLastWorkoutPlan']) {
        final Map value => pushup.WorkoutPlan.fromMap(
          Map<String, Object?>.from(value),
        ).normalized(),
        _ => pushup.WorkoutPlan.defaults(),
      },
      plankLastWorkoutPlan: switch (map['plankLastWorkoutPlan']) {
        final Map value => plank.WorkoutPlan.fromMap(
          Map<String, Object?>.from(value),
        ).normalized(),
        _ => plank.WorkoutPlan.defaults(),
      },
      pushupCameraGuideSeen: map['pushupCameraGuideSeen'] as bool? ?? false,
      plankCameraGuideSeen: map['plankCameraGuideSeen'] as bool? ?? false,
    );
  }
}
