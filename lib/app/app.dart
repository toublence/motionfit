import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/router.dart';
import 'package:motionfit_squat/app/theme/motionfit_theme.dart';
import 'package:motionfit_squat/core/notifications/notification_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/exercise/application/combined_workout_metrics.dart';
import 'package:motionfit_squat/features/plank/localization/generated/plank_localizations.dart';
import 'package:motionfit_squat/features/plank/records/application/records_providers.dart'
    as plank_records;
import 'package:motionfit_squat/features/plank/workout/application/workout_session_controller.dart'
    as plank_workout;
import 'package:motionfit_squat/features/pushup/application/workout_session_controller.dart'
    as pushup_workout;
import 'package:motionfit_squat/features/pushup/localization/generated/pushup_localizations.dart';
import 'package:motionfit_squat/features/pushup/records/application/records_providers.dart'
    as pushup_records;
import 'package:motionfit_squat/features/records/application/records_providers.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/settings/domain/theme_preferences.dart';
import 'package:motionfit_squat/features/settings/application/reminder_controller.dart';
import 'package:motionfit_squat/features/squat/application/workout_session_controller.dart';

class MotionFitApp extends ConsumerStatefulWidget {
  const MotionFitApp({super.key});

  @override
  ConsumerState<MotionFitApp> createState() => _MotionFitAppState();
}

class _MotionFitAppState extends ConsumerState<MotionFitApp>
    with WidgetsBindingObserver {
  late final GoRouter _router;
  int? _lastAdPolicyCount;
  String? _lastCrashScreen;
  bool? _usingPushupWorkoutOrientation;

  @override
  void initState() {
    super.initState();
    final onboardingCompleted = ref
        .read(preferencesControllerProvider)
        .onboardingCompleted;
    _router = createAppRouter(onboardingCompleted: onboardingCompleted);
    _router.routeInformationProvider.addListener(_syncCrashScreen);
    _router.routeInformationProvider.addListener(_syncOrientation);
    _syncCrashScreen();
    _syncOrientation();
    WidgetsBinding.instance.addObserver(this);
    _refreshReminderEnvironment(force: true);
    if (onboardingCompleted) _refreshPrivacyConsent();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.routeInformationProvider.removeListener(_syncCrashScreen);
    _router.routeInformationProvider.removeListener(_syncOrientation);
    _router.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(
      ref
          .read(crashReportingServiceProvider)
          .setCustomKey('app_lifecycle', state.name),
    );
    if (state == AppLifecycleState.resumed) {
      _refreshDeniedNotificationPermission();
      _refreshReminderEnvironment();
    }
  }

  void _syncCrashScreen() {
    final path = _router.routeInformationProvider.value.uri.path;
    if (path == _lastCrashScreen) return;
    _lastCrashScreen = path;
    unawaited(
      ref
          .read(crashReportingServiceProvider)
          .setCustomKey('current_screen', path),
    );
  }

  void _syncOrientation() {
    final path = _router.routeInformationProvider.value.uri.path;
    if (path.startsWith('/plank/')) return;
    final useLandscape =
        path == '/pushup/prepare/countdown' || path == '/pushup/workout';
    if (_usingPushupWorkoutOrientation == useLandscape) return;
    _usingPushupWorkoutOrientation = useLandscape;
    unawaited(_setOrientation(useLandscape));
  }

  Future<void> _setOrientation(bool useLandscape) async {
    try {
      await SystemChrome.setPreferredOrientations(
        useLandscape
            ? const [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]
            : const [DeviceOrientation.portraitUp],
      );
    } on Object catch (error, stackTrace) {
      await ref
          .read(crashReportingServiceProvider)
          .recordNonFatal(
            error,
            stackTrace,
            reason: 'workout_orientation_change',
          );
    }
  }

  void _refreshDeniedNotificationPermission() {
    if (!ref
        .read(preferencesControllerProvider)
        .postWorkoutReminderPermissionDenied) {
      return;
    }
    unawaited(_clearDeniedNotificationPermissionIfGranted());
  }

  Future<void> _clearDeniedNotificationPermissionIfGranted() async {
    final crashReporting = ref.read(crashReportingServiceProvider);
    try {
      final status = await ref
          .read(notificationServiceProvider)
          .permissionStatus();
      if (!mounted || status != NotificationPermissionResult.granted) return;
      await ref
          .read(preferencesControllerProvider.notifier)
          .setReminderPermissionDenied(false);
    } on Object catch (error, stackTrace) {
      await crashReporting.recordNonFatal(
        error,
        stackTrace,
        reason: 'notification_permission_reconciliation',
      );
    }
  }

  void _refreshReminderEnvironment({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = rootNavigatorKey.currentContext;
      if (!mounted || context == null) return;
      final l10n = AppLocalizations.of(context);
      ref
        ..invalidate(allSessionsProvider)
        ..invalidate(retentionMetricsProvider)
        ..invalidate(pushup_records.allSessionsProvider)
        ..invalidate(pushup_records.retentionMetricsProvider)
        ..invalidate(plank_records.allSessionsProvider)
        ..invalidate(plank_records.retentionMetricsProvider)
        ..invalidate(combinedWorkoutMetricsProvider);
      unawaited(_runReminderEnvironmentRefresh(l10n, force: force));
    });
  }

  Future<void> _runReminderEnvironmentRefresh(
    AppLocalizations l10n, {
    required bool force,
  }) async {
    try {
      final retention = await ref.read(combinedWorkoutMetricsProvider.future);
      if (!mounted) return;
      await ref.read(reminderControllerProvider.future);
      if (!mounted) return;
      await ref
          .read(reminderControllerProvider.notifier)
          .refreshForEnvironment(
            title: l10n.notificationReminderTitle,
            body: l10n.notificationReminderBody,
            force: force,
            currentStreak: retention.currentStreak,
            streakAtRisk: retention.streakAtRisk,
            streakRiskBody: l10n.notificationStreakReminderBody(
              retention.currentStreak,
            ),
          );
    } on Object catch (error, stackTrace) {
      if (!mounted) return;
      await ref
          .read(crashReportingServiceProvider)
          .recordNonFatal(
            error,
            stackTrace,
            reason: 'reminder_environment_refresh',
          );
    }
  }

  void _refreshPrivacyConsent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final crashReporting = ref.read(crashReportingServiceProvider);
      unawaited(
        _runPrivacyConsentRefresh().catchError((
          Object error,
          StackTrace stackTrace,
        ) {
          return crashReporting.recordNonFatal(
            error,
            stackTrace,
            reason: 'privacy_consent_refresh',
          );
        }),
      );
    });
  }

  Future<void> _runPrivacyConsentRefresh() async {
    final metrics = await ref.read(combinedWorkoutMetricsProvider.future);
    if (!mounted) return;
    final completedWorkoutCount = metrics.completedWorkoutCount;
    final preferences = ref.read(preferencesControllerProvider);
    ref
        .read(adServiceProvider)
        .updatePolicyContext(
          onboardingCompleted: preferences.onboardingCompleted,
          completedWorkoutCount: completedWorkoutCount,
        );
    final privacyConsent = ref.read(privacyConsentServiceProvider);
    if (completedWorkoutCount < 1 &&
        _lastAdPolicyCount != completedWorkoutCount) {
      _lastAdPolicyCount = completedWorkoutCount;
      ref
          .read(analyticsServiceProvider)
          .adSkippedByPolicy(
            format: 'all',
            placement: 'app_initialization',
            skipReason: 'before_first_workout',
            workoutCompletionCount: completedWorkoutCount,
            onboardingCompleted: preferences.onboardingCompleted,
          );
    }
    await privacyConsent.requestTrackingAndConsent();
    if (!mounted) return;
    await ref.read(adServiceProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesControllerProvider);
    ref.listen(
      preferencesControllerProvider.select((value) => value.locale),
      (_, _) => _refreshReminderEnvironment(force: true),
    );
    ref.listen(
      preferencesControllerProvider.select(
        (value) => value.onboardingCompleted,
      ),
      (previous, next) {
        if (previous != true && next) _refreshPrivacyConsent();
      },
    );
    ref.listen(
      workoutSessionControllerProvider.select((value) => value.session),
      (previous, next) {
        if (next == null ||
            !next.completed ||
            next.interrupted ||
            (previous?.id == next.id && previous?.completed == true)) {
          return;
        }
        _refreshReminderEnvironment(force: true);
        _refreshPrivacyConsent();
      },
    );
    ref.listen(
      pushup_workout.workoutSessionControllerProvider.select(
        (value) => value.session,
      ),
      (previous, next) {
        if (next == null ||
            !next.completed ||
            next.interrupted ||
            (previous?.id == next.id && previous?.completed == true)) {
          return;
        }
        _refreshReminderEnvironment(force: true);
        _refreshPrivacyConsent();
      },
    );
    ref.listen(
      plank_workout.workoutSessionControllerProvider.select(
        (value) => value.session,
      ),
      (previous, next) {
        if (next == null ||
            !next.completed ||
            next.interrupted ||
            (previous?.id == next.id && previous?.completed == true)) {
          return;
        }
        _refreshReminderEnvironment(force: true);
        _refreshPrivacyConsent();
      },
    );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: MotionFitTheme.light(preferences.colorTheme),
      darkTheme: MotionFitTheme.dark(preferences.colorTheme),
      themeMode: switch (preferences.displayTheme) {
        MotionFitDisplayTheme.light => ThemeMode.light,
        MotionFitDisplayTheme.dark => ThemeMode.dark,
        MotionFitDisplayTheme.system => ThemeMode.system,
      },
      locale: switch (preferences.locale) {
        'zh' => const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hans',
        ),
        'zh_Hant' => const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
        ),
        null => null,
        final locale => Locale(locale),
      },
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        PushupLocalizations.delegate,
        PlankLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
      builder: (context, child) {
        ref
            .read(analyticsServiceProvider)
            .updateDeviceCategory(MediaQuery.sizeOf(context).shortestSide);
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
