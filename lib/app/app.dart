import 'package:motionfit_squat/core/ads/ad_bootstrap.dart';
import 'package:motionfit_squat/core/ads/app_open_gate.dart';
import 'package:motionfit_squat/core/notifications/notification_destination.dart';
import 'package:motionfit_squat/features/exercise/application/exercise_selection.dart';
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
import 'package:motionfit_squat/core/privacy/tracking_explainer.dart';
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
  String? _pendingNotification;
  String? _lastNotification;
  DateTime? _lastNotificationAt;
  late final NotificationService _notifications;
  late final VoidCallback _detachTrackingExplainer;
  String? _lastCrashScreen;
  bool? _usingPushupWorkoutOrientation;

  @override
  void initState() {
    super.initState();
    final onboardingCompleted = ref
        .read(preferencesControllerProvider)
        .onboardingCompleted;
    _router = createAppRouter(onboardingCompleted: onboardingCompleted);
    final privacy = ref.read(privacyConsentServiceProvider);
    privacy.setTrackingExplainer(_explainTracking);
    _detachTrackingExplainer = () => privacy.setTrackingExplainer(null);
    _router.routeInformationProvider.addListener(_syncCrashScreen);
    _router.routeInformationProvider.addListener(_syncOrientation);
    _router.routeInformationProvider.addListener(_retryDeferredTracking);
    _syncCrashScreen();
    _syncOrientation();
    _notifications = ref.read(notificationServiceProvider);
    _notifications.setNotificationHandler(_receiveNotification);
    _router.routeInformationProvider.addListener(_drainNotification);
    unawaited(_notifications.initialize().catchError((Object _) {}));
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null) _syncAdLifecycle(lifecycle);
    _refreshReminderEnvironment(force: true);
    if (onboardingCompleted) _refreshPrivacyConsent();
  }

  void _retryDeferredTracking() {
    final path = _router.routeInformationProvider.value.uri.path;
    if (path.contains('/prepare') || path.contains('/workout')) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(adServiceProvider).retryDeferredTrackingAuthorization();
      }
    });
  }

  Future<bool> _explainTracking() async {
    if (!mounted) return false;
    final context = rootNavigatorKey.currentContext;
    final state = WidgetsBinding.instance.lifecycleState;
    final path = _router.routeInformationProvider.value.uri.path;
    if (context == null ||
        !context.mounted ||
        (state != null && state != AppLifecycleState.resumed) ||
        path.contains('/prepare') ||
        path.contains('/workout')) {
      return false;
    }
    final ads = ref.read(adServiceProvider);
    if (ads.fullScreenShowing) return false;
    ads.cancelAppOpenOpportunity('tracking_explainer');
    final acknowledged = await showTrackingExplainer(context);
    final currentState = WidgetsBinding.instance.lifecycleState;
    return mounted &&
        acknowledged &&
        (currentState == null || currentState == AppLifecycleState.resumed);
  }

  void _receiveNotification(String payload) {
    final now = DateTime.now();
    if (_lastNotification == payload &&
        _lastNotificationAt != null &&
        now.difference(_lastNotificationAt!) < const Duration(seconds: 2))
      return;
    _lastNotification = payload;
    _lastNotificationAt = now;
    _pendingNotification = payload;
    _drainNotification();
  }

  void _drainNotification() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pendingNotification == null) return;
      if (!ref.read(preferencesControllerProvider).onboardingCompleted) return;
      final path = _router.routeInformationProvider.value.uri.path;
      if (path.contains('/prepare') || path.contains('/workout')) return;
      final destination = NotificationDestination.parse(
        _pendingNotification!,
        fallbackExercise: ref.read(preferencesControllerProvider).lastExercise,
      );
      _pendingNotification = null;
      if (destination == null) return;
      ref.read(selectedExerciseProvider.notifier).select(destination.exercise);
      ref
          .read(notificationEntryProvider.notifier)
          .opened(destination.exercise.name);
      ref
          .read(analyticsServiceProvider)
          .retentionEvent('mf2_notification_opened', {
            'exercise_type': destination.exercise.name,
            'entry_point': 'notification',
            'destination': destination.challenge ? 'challenge' : 'workout',
          });
      _router.go(destination.route);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.routeInformationProvider.removeListener(_syncCrashScreen);
    _router.routeInformationProvider.removeListener(_syncOrientation);
    _router.routeInformationProvider.removeListener(_retryDeferredTracking);
    _notifications.setNotificationHandler(null);
    _router.routeInformationProvider.removeListener(_drainNotification);
    _detachTrackingExplainer();
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
    _syncAdLifecycle(state);
    if (state == AppLifecycleState.resumed) {
      _refreshDeniedNotificationPermission();
      _refreshReminderEnvironment();
      _refreshPrivacyConsent();
    }
  }

  // iOS reports inactive while the app stays on screen (system alerts,
  // Control Center, iPad split view); view ads must not vanish then.
  void _syncAdLifecycle(AppLifecycleState state) => ref
      .read(adServiceProvider)
      .setForeground(
        state == AppLifecycleState.resumed,
        visible:
            state == AppLifecycleState.resumed ||
            state == AppLifecycleState.inactive,
      );

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

  Future<void> _runPrivacyConsentRefresh() => prepareAds(
    ref.read(adServiceProvider),
    onboardingCompleted: ref
        .read(preferencesControllerProvider)
        .onboardingCompleted,
    readMetrics: () => ref.read(combinedWorkoutMetricsProvider.future),
    isMounted: () => mounted,
  );

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
        if (previous != true && next) {
          _refreshPrivacyConsent();
          _drainNotification();
        }
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
        if (next.totalReps > 0) {
          ref.read(adServiceProvider).workoutCompleted('squat:${next.id}');
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
        if (next.totalReps > 0) {
          ref.read(adServiceProvider).workoutCompleted('pushup:${next.id}');
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
        if (next.totalReps > 0) {
          ref.read(adServiceProvider).workoutCompleted('plank:${next.id}');
        }
        _refreshReminderEnvironment(force: true);
        _refreshPrivacyConsent();
      },
    );
    ref.listen(combinedWorkoutMetricsProvider, (_, next) {
      final metrics = next.value;
      if (metrics != null) {
        ref
            .read(adServiceProvider)
            .updatePolicyContext(
              onboardingCompleted: preferences.onboardingCompleted,
              completedWorkoutCount: metrics.completedWorkoutCount,
              completedSessionIds: metrics.completedSessionIds,
            );
      }
    });
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
        return AppOpenGate(
          router: _router,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
