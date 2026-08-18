import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/diagnostics/crash_reporting_service.dart';
import 'package:motionfit_squat/core/permissions/permission_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';
import 'package:motionfit_squat/features/squat/application/workout_coach_messages.dart';
import 'package:motionfit_squat/features/squat/application/workout_preparation.dart';
import 'package:motionfit_squat/features/squat/application/workout_session_controller.dart';
import 'package:motionfit_squat/features/squat/application/workout_session_state.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_plan.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/camera_guide_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/camera_permission_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/workout_countdown_screen.dart';

class LifecycleErrorCollector {
  FlutterExceptionHandler? _previousFlutterHandler;
  ErrorCallback? _previousPlatformHandler;
  final List<FlutterErrorDetails> flutterErrors = [];
  final List<(Object, StackTrace)> platformErrors = [];

  void install() {
    _previousFlutterHandler = FlutterError.onError;
    _previousPlatformHandler = PlatformDispatcher.instance.onError;
    FlutterError.onError = (details) {
      flutterErrors.add(details);
      _previousFlutterHandler?.call(details);
    };
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      platformErrors.add((error, stackTrace));
      return _previousPlatformHandler?.call(error, stackTrace) ?? false;
    };
  }

  void restore() {
    FlutterError.onError = _previousFlutterHandler;
    PlatformDispatcher.instance.onError = _previousPlatformHandler;
  }

  void expectNoErrors() {
    expect(
      flutterErrors,
      isEmpty,
      reason: flutterErrors
          .map((error) => error.exceptionAsString())
          .join('\n'),
    );
    expect(
      platformErrors,
      isEmpty,
      reason: platformErrors.map((error) => error.$1).join('\n'),
    );
  }
}

class TrackingAnalyticsService extends AnalyticsService {
  int cancellationCount = 0;
  int countdownInitializationCount = 0;
  int permissionRequestCount = 0;
  int permissionResultCount = 0;
  final List<String> cancellationStages = [];

  @override
  void screenView(String screenName) {}

  @override
  void workoutInitializationStarted() {
    countdownInitializationCount++;
  }

  @override
  void cameraPermissionRequested() {
    permissionRequestCount++;
  }

  @override
  void cameraPermissionResult({
    required String result,
    required bool requested,
  }) {
    permissionResultCount++;
  }

  @override
  void workoutCancelled({
    required String cancelStage,
    required String cancelReason,
    required Duration elapsed,
    required int detectedReps,
    required Duration trackingLoss,
  }) {
    cancellationCount++;
    cancellationStages.add(cancelStage);
  }
}

class ControlledPreferencesController extends PreferencesController {
  int saveCount = 0;
  Completer<void>? _nextSave;

  void delayNextSave() {
    _nextSave = Completer<void>();
  }

  void completeDelayedSave() {
    final save = _nextSave;
    if (save != null && !save.isCompleted) save.complete();
    _nextSave = null;
  }

  @override
  UserPreferences build() => UserPreferences.defaults().copyWith(
    onboardingCompleted: true,
    cameraGuideSeen: false,
  );

  @override
  Future<void> markCameraGuideSeen() {
    saveCount++;
    state = state.copyWith(cameraGuideSeen: true);
    return _nextSave?.future ?? Future<void>.value();
  }
}

class TrackingLaunchContextController extends WorkoutLaunchContextController {
  int clearCount = 0;
  int setCount = 0;

  @override
  void set(WorkoutPreparation preparation) {
    setCount++;
    super.set(preparation);
  }

  @override
  void clear() {
    clearCount++;
    super.clear();
  }
}

class ControlledPermissionService extends PermissionService {
  ControlledPermissionService()
    : super(CrashReportingService(supported: false));

  AppPermissionState status = AppPermissionState.denied;
  int statusCount = 0;
  int requestCount = 0;
  Completer<AppPermissionState>? _nextStatus;
  Completer<AppPermissionState>? _nextRequest;

  void delayNextStatus() {
    _nextStatus = Completer<AppPermissionState>();
  }

  void completeDelayedStatus(AppPermissionState result) {
    final pending = _nextStatus;
    if (pending != null && !pending.isCompleted) pending.complete(result);
    _nextStatus = null;
  }

  void delayNextRequest() {
    _nextRequest = Completer<AppPermissionState>();
  }

  void completeDelayedRequest(AppPermissionState result) {
    final pending = _nextRequest;
    if (pending != null && !pending.isCompleted) pending.complete(result);
    _nextRequest = null;
  }

  @override
  Future<AppPermissionState> cameraStatus() {
    statusCount++;
    return _nextStatus?.future ?? Future<AppPermissionState>.value(status);
  }

  @override
  Future<AppPermissionState> requestCamera() {
    requestCount++;
    return _nextRequest?.future ?? Future<AppPermissionState>.value(status);
  }

  @override
  Future<bool> openSettings() async => true;
}

class ControlledWorkoutSessionController extends WorkoutSessionController {
  int prewarmCount = 0;
  int startCount = 0;
  int recoverCount = 0;
  int cancelPreparationCount = 0;
  Completer<void>? _nextPrewarm;

  void delayNextPrewarm() {
    _nextPrewarm = Completer<void>();
  }

  void completeDelayedPrewarm() {
    final prewarm = _nextPrewarm;
    if (prewarm != null && !prewarm.isCompleted) prewarm.complete();
    _nextPrewarm = null;
  }

  void resetCounts() {
    prewarmCount = 0;
    startCount = 0;
    recoverCount = 0;
    cancelPreparationCount = 0;
  }

  @override
  WorkoutSessionState build() => WorkoutSessionState.idle();

  @override
  Future<void> prewarm(WorkoutCoachMessages messages) {
    prewarmCount++;
    return _nextPrewarm?.future ?? Future<void>.value();
  }

  @override
  Future<void> start(
    WorkoutPlan plan,
    WorkoutCoachMessages messages, {
    int maxRepsPerSet = WorkoutPlan.maxReps,
    int spokenRepOffset = 0,
    bool cumulativeChallenge = false,
    int? sevenDayChallengeDay,
  }) async {
    startCount++;
    state = state.copyWith(status: WorkoutSessionStatus.active, plan: plan);
  }

  @override
  Future<void> recover(
    WorkoutSessionDetails details,
    WorkoutCoachMessages messages,
  ) async {
    recoverCount++;
    state = state.copyWith(status: WorkoutSessionStatus.active);
  }

  @override
  Future<void> cancelPreparation() async {
    cancelPreparationCount++;
  }
}

class PreparationLifecycleHarness {
  PreparationLifecycleHarness._({
    required this.container,
    required this.router,
    required this.analytics,
    required this.permissions,
    required this.preferences,
    required this.launchContext,
    required this.workoutController,
    required this.preparation,
  });

  final ProviderContainer container;
  final GoRouter router;
  final TrackingAnalyticsService analytics;
  final ControlledPermissionService permissions;
  final ControlledPreferencesController preferences;
  final TrackingLaunchContextController launchContext;
  final ControlledWorkoutSessionController workoutController;
  final WorkoutPreparation preparation;
  final List<String> visitedPaths = [];
  late final VoidCallback _routerListener;

  static Future<PreparationLifecycleHarness> pump(WidgetTester tester) async {
    final analytics = TrackingAnalyticsService();
    final permissions = ControlledPermissionService();
    final preferences = ControlledPreferencesController();
    final launchContext = TrackingLaunchContextController();
    final workoutController = ControlledWorkoutSessionController();
    final preparation = WorkoutPreparation.newWorkout(
      WorkoutPlan.defaults(id: 'lifecycle-test'),
    );
    final container = ProviderContainer(
      overrides: [
        analyticsServiceProvider.overrideWithValue(analytics),
        permissionServiceProvider.overrideWithValue(permissions),
        preferencesControllerProvider.overrideWith(() => preferences),
        workoutLaunchContextProvider.overrideWith(() => launchContext),
        workoutSessionControllerProvider.overrideWith(() => workoutController),
      ],
    );
    late final GoRouter router;
    router = GoRouter(
      initialLocation: '/setup',
      routes: [
        GoRoute(
          path: '/setup',
          pageBuilder: (_, _) => const NoTransitionPage(
            child: Scaffold(body: Center(child: Text('setup-screen'))),
          ),
        ),
        GoRoute(
          path: '/prepare/permission',
          pageBuilder: (_, _) => NoTransitionPage(
            child: CameraPermissionScreen(preparation: preparation),
          ),
        ),
        GoRoute(
          path: '/prepare/guide',
          pageBuilder: (_, _) => NoTransitionPage(
            child: CameraGuideScreen(preparation: preparation),
          ),
        ),
        GoRoute(
          path: '/prepare/countdown',
          pageBuilder: (_, _) => NoTransitionPage(
            child: WorkoutCountdownScreen(preparation: preparation),
          ),
        ),
        GoRoute(
          path: '/workout',
          pageBuilder: (_, _) => const NoTransitionPage(
            child: Scaffold(body: Center(child: Text('active-workout-screen'))),
          ),
          routes: [
            GoRoute(
              path: 'rest',
              pageBuilder: (_, _) => const NoTransitionPage(
                child: Scaffold(body: Center(child: Text('rest-screen'))),
              ),
            ),
          ],
        ),
      ],
    );
    final harness = PreparationLifecycleHarness._(
      container: container,
      router: router,
      analytics: analytics,
      permissions: permissions,
      preferences: preferences,
      launchContext: launchContext,
      workoutController: workoutController,
      preparation: preparation,
    );
    harness._routerListener = () {
      harness.visitedPaths.add(harness.currentPath);
    };
    router.routerDelegate.addListener(harness._routerListener);
    harness.visitedPaths.add('/setup');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    return harness;
  }

  String get currentPath =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;

  int visitsTo(String path) =>
      visitedPaths.where((visited) => visited == path).length;

  Future<void> openGuide(WidgetTester tester) async {
    unawaited(router.push('/prepare/guide', extra: preparation));
    await pumpNavigation(tester);
  }

  Future<void> openPermission(WidgetTester tester) async {
    unawaited(router.push('/prepare/permission', extra: preparation));
    await pumpNavigation(tester);
  }

  Future<void> openCountdown(WidgetTester tester) async {
    unawaited(router.push('/prepare/countdown', extra: preparation));
    await pumpNavigation(tester);
  }

  Future<void> goToSetup(WidgetTester tester) async {
    router.go('/setup');
    await pumpNavigation(tester);
  }

  Future<void> tapGuideContinue(
    WidgetTester tester, {
    bool rapidDoubleTap = false,
  }) async {
    final button = find.byType(FilledButton);
    await tester.scrollUntilVisible(
      button,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(button);
    if (rapidDoubleTap) await tester.tap(button);
  }

  Future<void> pumpNavigation(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    router.routerDelegate.removeListener(_routerListener);
    router.dispose();
    container.dispose();
  }
}
