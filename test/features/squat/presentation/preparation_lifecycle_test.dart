import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/permissions/permission_service.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/camera_guide_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/camera_permission_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/workout_countdown_screen.dart';

import '../../../support/preparation_lifecycle_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LifecycleErrorCollector errors;

  setUp(() {
    errors = LifecycleErrorCollector()..install();
  });

  tearDown(() {
    errors.restore();
  });

  Future<PreparationLifecycleHarness> createHarness(WidgetTester tester) async {
    final harness = await PreparationLifecycleHarness.pump(tester);
    addTearDown(() async {
      await harness.dispose(tester);
      errors.expectNoErrors();
    });
    return harness;
  }

  group('CameraGuideScreen lifecycle', () {
    testWidgets('continue navigates once and is not recorded as cancellation', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openGuide(tester);
      final visitsBefore = harness.visitsTo('/prepare/countdown');

      await harness.tapGuideContinue(tester);
      await harness.pumpNavigation(tester);

      expect(harness.currentPath, '/prepare/countdown');
      expect(harness.visitsTo('/prepare/countdown') - visitsBefore, 1);
      expect(harness.preferences.saveCount, 1);
      expect(harness.analytics.cancellationCount, 0);
      expect(harness.launchContext.clearCount, 0);
    });

    testWidgets('system back records one explicit cancellation', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openGuide(tester);

      await tester.binding.handlePopRoute();
      await harness.pumpNavigation(tester);

      expect(harness.currentPath, '/setup');
      expect(harness.analytics.cancellationCount, 1);
      expect(harness.analytics.cancellationStages, ['before_first_rep']);
      expect(harness.launchContext.clearCount, 1);
      expect(harness.preferences.saveCount, 0);
    });

    testWidgets('app bar Back to setup uses the explicit cancellation path', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openGuide(tester);

      await tester.tap(find.byType(BackButton));
      await harness.pumpNavigation(tester);

      expect(harness.currentPath, '/setup');
      expect(harness.analytics.cancellationCount, 1);
      expect(harness.launchContext.clearCount, 1);
    });

    testWidgets('rapid double continue performs one save and one navigation', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openGuide(tester);
      final visitsBefore = harness.visitsTo('/prepare/countdown');
      await harness.tapGuideContinue(tester, rapidDoubleTap: true);
      await harness.pumpNavigation(tester);

      expect(harness.preferences.saveCount, 1);
      expect(harness.visitsTo('/prepare/countdown') - visitsBefore, 1);
      expect(harness.analytics.cancellationCount, 0);
    });

    testWidgets('pushReplacement disposal does not run cancellation cleanup', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openGuide(tester);

      await harness.tapGuideContinue(tester);
      await harness.pumpNavigation(tester);
      await harness.goToSetup(tester);

      expect(find.byType(CameraGuideScreen), findsNothing);
      expect(harness.analytics.cancellationCount, 0);
      expect(harness.launchContext.clearCount, 0);
    });

    testWidgets('provider save completion after removal does not access ref', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      harness.preferences.delayNextSave();
      await harness.openGuide(tester);

      await harness.tapGuideContinue(tester);
      await tester.pump();
      await harness.goToSetup(tester);
      harness.preferences.completeDelayedSave();
      await tester.pump();

      expect(find.byType(CameraGuideScreen), findsNothing);
      expect(harness.currentPath, '/setup');
      expect(harness.preferences.saveCount, 1);
      expect(harness.analytics.cancellationCount, 0);
    });

    testWidgets('late timer-backed provider callback after removal is safe', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      harness.preferences.delayNextSave();
      await harness.openGuide(tester);

      await harness.tapGuideContinue(tester);
      await tester.pump();
      await harness.goToSetup(tester);
      Timer.run(harness.preferences.completeDelayedSave);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(harness.currentPath, '/setup');
      expect(harness.visitsTo('/prepare/countdown'), 0);
      expect(harness.preferences.saveCount, 1);
    });

    testWidgets('20 alternating exits tolerate rapid repeated taps', (
      tester,
    ) async {
      final harness = await createHarness(tester);

      for (var iteration = 0; iteration < 20; iteration++) {
        await harness.openGuide(tester);
        if (iteration.isEven) {
          await harness.tapGuideContinue(tester, rapidDoubleTap: true);
          await harness.pumpNavigation(tester);
          expect(harness.currentPath, '/prepare/countdown');
          await harness.goToSetup(tester);
        } else {
          final back = tester.binding.handlePopRoute();
          await tester.binding.handlePopRoute();
          await back;
          await harness.pumpNavigation(tester);
          expect(harness.currentPath, '/setup');
        }
      }

      expect(harness.preferences.saveCount, 10);
      expect(harness.analytics.cancellationCount, 10);
      expect(harness.launchContext.clearCount, 10);
      expect(harness.visitsTo('/prepare/countdown'), 10);
    });
  });

  group('CameraPermissionScreen lifecycle', () {
    testWidgets('system back records one explicit cancellation', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openPermission(tester);

      await tester.binding.handlePopRoute();
      await harness.pumpNavigation(tester);

      expect(harness.currentPath, '/setup');
      expect(harness.analytics.cancellationCount, 1);
      expect(harness.analytics.cancellationStages, ['before_permission']);
      expect(harness.launchContext.clearCount, 1);
    });

    testWidgets('status completion after removal does not access ref', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      harness.permissions.delayNextStatus();
      await harness.openPermission(tester);

      await harness.goToSetup(tester);
      harness.permissions.completeDelayedStatus(AppPermissionState.denied);
      await tester.pump();

      expect(find.byType(CameraPermissionScreen), findsNothing);
      expect(harness.currentPath, '/setup');
      expect(harness.analytics.permissionResultCount, 0);
    });

    testWidgets('request status completion after removal does not access ref', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openPermission(tester);
      harness.permissions.delayNextStatus();

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await harness.goToSetup(tester);
      harness.permissions.completeDelayedStatus(AppPermissionState.denied);
      await tester.pump();

      expect(find.byType(CameraPermissionScreen), findsNothing);
      expect(harness.permissions.requestCount, 0);
      expect(harness.analytics.permissionRequestCount, 0);
    });

    testWidgets('permission callback after removal does not navigate', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openPermission(tester);
      harness.permissions.delayNextRequest();

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await harness.goToSetup(tester);
      harness.permissions.completeDelayedRequest(AppPermissionState.granted);
      await tester.pump();

      expect(find.byType(CameraPermissionScreen), findsNothing);
      expect(harness.currentPath, '/setup');
      expect(harness.permissions.requestCount, 1);
      expect(harness.visitsTo('/prepare/countdown'), 0);
    });

    testWidgets('granted status navigates once without cancellation', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      harness.permissions.status = AppPermissionState.granted;

      await harness.openPermission(tester);
      await harness.pumpNavigation(tester);

      expect(harness.currentPath, '/prepare/countdown');
      expect(harness.preferences.saveCount, 1);
      expect(harness.analytics.cancellationCount, 0);
      expect(harness.visitsTo('/prepare/countdown'), 1);
    });
  });

  group('WorkoutCountdownScreen lifecycle', () {
    testWidgets('normal countdown completes once without cancellation', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openCountdown(tester);
      final visitsBefore = harness.visitsTo('/workout');

      await tester.pump(const Duration(seconds: 5));
      await harness.pumpNavigation(tester);

      expect(harness.currentPath, '/workout');
      expect(harness.workoutController.startCount, 1);
      expect(harness.workoutController.cancelPreparationCount, 0);
      expect(harness.analytics.cancellationCount, 0);
      expect(harness.visitsTo('/workout') - visitsBefore, 1);
    });

    testWidgets('system back during countdown cancels timer and preparation', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openCountdown(tester);

      await tester.binding.handlePopRoute();
      await harness.pumpNavigation(tester);
      await tester.pump(const Duration(seconds: 6));

      expect(harness.currentPath, '/setup');
      expect(harness.workoutController.startCount, 0);
      expect(harness.workoutController.cancelPreparationCount, 1);
      expect(harness.analytics.cancellationCount, 1);
      expect(harness.launchContext.clearCount, 1);
    });

    testWidgets('close button cancellation runs provider cleanup once', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openCountdown(tester);
      final close = find.byIcon(Icons.close_rounded);

      await tester.tap(close);
      await tester.tap(close);
      await harness.pumpNavigation(tester);
      await tester.pump(const Duration(seconds: 6));

      expect(harness.currentPath, '/setup');
      expect(harness.workoutController.cancelPreparationCount, 1);
      expect(harness.analytics.cancellationCount, 1);
      expect(harness.workoutController.startCount, 0);
    });

    testWidgets('zero-second tick racing system back cancels only once', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openCountdown(tester);
      await tester.pump(const Duration(seconds: 4));

      final back = tester.binding.handlePopRoute();
      await tester.pump(const Duration(seconds: 1));
      await back;
      await harness.pumpNavigation(tester);

      expect(harness.currentPath, '/setup');
      expect(harness.workoutController.cancelPreparationCount, 1);
      expect(harness.workoutController.startCount, 0);
      expect(harness.analytics.cancellationCount, 1);
    });

    testWidgets('removal while timer is active prevents late timer work', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openCountdown(tester);
      await tester.pump(const Duration(seconds: 1));

      await harness.goToSetup(tester);
      final startCount = harness.workoutController.startCount;
      final cancelCount = harness.workoutController.cancelPreparationCount;
      await tester.pump(const Duration(seconds: 8));

      expect(find.byType(WorkoutCountdownScreen), findsNothing);
      expect(harness.workoutController.startCount, startCount);
      expect(harness.workoutController.cancelPreparationCount, cancelCount);
      expect(harness.analytics.cancellationCount, 0);
    });

    testWidgets('rapid open and close leaves no late callback', (tester) async {
      final harness = await createHarness(tester);
      await harness.openCountdown(tester);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await harness.pumpNavigation(tester);
      await tester.pump(const Duration(seconds: 8));

      expect(harness.currentPath, '/setup');
      expect(harness.workoutController.startCount, 0);
      expect(harness.workoutController.cancelPreparationCount, 1);
    });

    testWidgets('guide pushReplacement is not recorded as cancellation', (
      tester,
    ) async {
      final harness = await createHarness(tester);
      await harness.openCountdown(tester);

      await tester.tap(find.byIcon(Icons.help_outline_rounded));
      await harness.pumpNavigation(tester);

      expect(harness.currentPath, '/prepare/guide');
      expect(harness.analytics.cancellationCount, 0);
      expect(harness.launchContext.clearCount, 0);
      expect(harness.workoutController.cancelPreparationCount, 0);
    });

    testWidgets('lifecycle change followed by removal is safe', (tester) async {
      final harness = await createHarness(tester);
      await harness.openCountdown(tester);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      await harness.goToSetup(tester);
      await tester.pump(const Duration(seconds: 6));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      expect(harness.currentPath, '/setup');
      expect(harness.workoutController.startCount, 0);
      expect(harness.analytics.cancellationCount, 0);
    });

    testWidgets(
      'delayed prewarm completion after removal does not access ref',
      (tester) async {
        final harness = await createHarness(tester);
        harness.workoutController.delayNextPrewarm();
        await harness.openCountdown(tester);
        await tester.pump(const Duration(seconds: 5));

        await harness.goToSetup(tester);
        harness.workoutController.completeDelayedPrewarm();
        await tester.pump();

        expect(harness.currentPath, '/setup');
        expect(harness.workoutController.startCount, 0);
        expect(harness.analytics.cancellationCount, 0);
      },
    );

    testWidgets(
      '20 alternating completions and cancellations stay single-shot',
      (tester) async {
        final harness = await createHarness(tester);

        for (var iteration = 0; iteration < 20; iteration++) {
          await harness.openCountdown(tester);
          if (iteration.isEven) {
            await tester.pump(const Duration(seconds: 5));
            await harness.pumpNavigation(tester);
            expect(harness.currentPath, '/workout');
            await harness.goToSetup(tester);
          } else {
            final close = find.byIcon(Icons.close_rounded);
            await tester.tap(close);
            await tester.tap(close);
            await harness.pumpNavigation(tester);
            expect(harness.currentPath, '/setup');
          }
        }
        await tester.pump(const Duration(seconds: 8));

        expect(harness.workoutController.startCount, 10);
        expect(harness.workoutController.cancelPreparationCount, 10);
        expect(harness.analytics.cancellationCount, 10);
        expect(harness.launchContext.clearCount, 10);
      },
    );
  });
}
