import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/privacy/privacy_consent_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/onboarding/presentation/onboarding_copy.dart';
import 'package:motionfit_squat/features/onboarding/presentation/onboarding_screen.dart';
import 'package:motionfit_squat/features/settings/data/preferences_service.dart';
import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('three pages and completion in $locale at large text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final preferences = _Preferences();
      final tracking = _Tracking();
      final events = _Events();
      final router = await _mount(
        tester,
        locale,
        preferences,
        tracking,
        events,
      );
      final copy = OnboardingCopy.forLocale(locale);
      for (var page = 0; page < 3; page++) {
        expect(
          find.text(
            copy[[
              'onboarding_measure_heading',
              'onboarding_improve_heading',
              'onboarding_try_heading',
            ][page]],
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(
          find.byKey(ValueKey(page == 2 ? 'welcome_try' : 'onboarding_next')),
        );
        await tester.pumpAndSettle();
      }
      expect(find.text('WORKOUT_HOME'), findsOneWidget);
      expect(preferences.saved!.onboardingCompleted, isTrue);
      expect(tracking.requests, 1);
      expect(
        events.names.where((e) => e == 'mf2_onboarding_completed').length,
        1,
      );
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    });
  }
  testWidgets('skip completes once without waiting for animation', (
    tester,
  ) async {
    final preferences = _Preferences();
    final tracking = _Tracking();
    final events = _Events();
    final router = await _mount(
      tester,
      const Locale('ko'),
      preferences,
      tracking,
      events,
      reducedMotion: false,
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const ValueKey('onboarding_skip')));
    await tester.pumpAndSettle();
    expect(find.text('WORKOUT_HOME'), findsOneWidget);
    expect(preferences.saved!.onboardingCompleted, isTrue);
    expect(tracking.requests, 1);
    expect(events.names, contains('mf2_onboarding_skipped'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
  });
  testWidgets('landscape animated pages pause and resume with the app', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = await _mount(
      tester,
      const Locale('ko'),
      _Preferences(),
      _Tracking(),
      _Events(),
      reducedMotion: false,
    );
    for (var page = 0; page < 3; page++) {
      await tester.pump(const Duration(seconds: 8));
      expect(tester.takeException(), isNull);
      if (page < 2) {
        await tester.tap(find.byKey(const ValueKey('onboarding_next')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }
    }
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(seconds: 1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
  });
}

Future<GoRouter> _mount(
  WidgetTester tester,
  Locale locale,
  _Preferences preferences,
  _Tracking tracking,
  _Events events, {
  bool reducedMotion = true,
}) async {
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/squat',
        builder: (_, _) => const Scaffold(body: Text('WORKOUT_HOME')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        initialPreferencesProvider.overrideWithValue(
          UserPreferences.defaults(),
        ),
        preferencesServiceProvider.overrideWithValue(preferences),
        privacyConsentServiceProvider.overrideWithValue(tracking),
        analyticsServiceProvider.overrideWithValue(
          AnalyticsService(sink: events),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reducedMotion,
            textScaler: TextScaler.linear(reducedMotion ? 2 : 1),
          ),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pump();
  return router;
}

class _Preferences implements PreferencesService {
  UserPreferences? saved;
  @override
  Future<void> save(UserPreferences preferences) async => saved = preferences;
  @override
  Future<UserPreferences> load() async => saved ?? UserPreferences.defaults();
  @override
  Future<bool> hasSavedPreferences() async => saved != null;
  @override
  Future<bool> claimRetentionEvent(String key) async => true;
}

class _Tracking extends PrivacyConsentService {
  int requests = 0;
  @override
  Future<void> requestTrackingAuthorization() async {
    requests++;
  }
}

class _Events implements AnalyticsSink {
  final names = <String>[];
  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    names.add(name);
  }

  @override
  Future<void> logScreenView(String screenName) async {}
}
