import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:motionfit_squat/core/permissions/permission_service.dart';

import '../test/support/preparation_lifecycle_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('camera guide and countdown lifecycle flows stay error-free', (
    tester,
  ) async {
    final errors = LifecycleErrorCollector()..install();
    final harness = await PreparationLifecycleHarness.pump(tester);
    try {
      expect(harness.currentPath, '/setup');

      harness.permissions.delayNextStatus();
      await harness.openPermission(tester);
      await harness.goToSetup(tester);
      harness.permissions.completeDelayedStatus(AppPermissionState.denied);
      await tester.pump();

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

      for (var iteration = 0; iteration < 20; iteration++) {
        await harness.openCountdown(tester);
        if (iteration.isEven) {
          await tester.pump(const Duration(seconds: 5));
          await harness.pumpNavigation(tester);
          expect(harness.currentPath, '/workout');
          await harness.goToSetup(tester);
        } else {
          await tester.tap(find.byIcon(Icons.close_rounded));
          await tester.tap(find.byIcon(Icons.close_rounded));
          await harness.pumpNavigation(tester);
          expect(harness.currentPath, '/setup');
        }
      }

      await tester.pump(const Duration(seconds: 8));
      expect(harness.preferences.saveCount, 10);
      expect(harness.workoutController.startCount, 10);
      expect(harness.workoutController.cancelPreparationCount, 10);
      expect(harness.analytics.cancellationCount, 20);
      expect(harness.launchContext.clearCount, 20);
      errors.expectNoErrors();
    } finally {
      await harness.dispose(tester);
      errors.expectNoErrors();
      errors.restore();
    }
  });
}
