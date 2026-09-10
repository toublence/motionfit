import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_photo.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_summary.dart';
import 'package:motionfit_squat/features/body_progress/presentation/widgets/body_progress_widgets.dart';

/// The photo history is a grid, and a grid cell has a fixed height. If the card
/// inside is taller than that cell the tab renders a bottom overflow stripe, so
/// these tests pump the real card at the sizes and text scales it has to
/// survive.
BodyProgressPhoto photo(DateTime at) => BodyProgressPhoto(
  id: at.toIso8601String(),
  capturedAt: at,
  capturedOn: BodyProgressPhoto.dayKey(at),
  bodyView: BodyView.front,
  imageFile: 'missing.jpg',
  imageWidth: 640,
  imageHeight: 480,
  createdAt: at,
);

/// Sizes the test viewport like a real phone.
///
/// The default 800x600 test surface is wide enough to hide the overflow this
/// file exists to catch, so each test sets the device size explicitly.
void useDevice(WidgetTester tester, Size size) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget host({
  required Widget child,
  double textScale = 1,
}) => ProviderScope(
  child: MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ko'),
    theme: ThemeData(extensions: const [MotionFitTokens.standard()]),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: Scaffold(body: child),
  ),
);

/// Mirrors the history grid on the Body Progress screen.
Widget historyGrid(BodyProgressSummary summary) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: BodyProgressHistoryGrid(
    summary: summary,
    captionOf: (photo) => '2026년 9월 10일',
  ),
);

void main() {
  final summary = BodyProgressSummary(
    bodyView: BodyView.front,
    photos: [
      photo(DateTime(2026, 9, 10, 8)),
      photo(DateTime(2026, 9, 11, 8)),
      photo(DateTime(2026, 9, 12, 8)),
      photo(DateTime(2026, 9, 13, 8)),
    ],
  );

  testWidgets('the history grid lays out at the default text scale', (
    tester,
  ) async {
    useDevice(tester, const Size(393, 851));
    await tester.pumpWidget(host(child: historyGrid(summary)));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the history grid survives a narrow screen', (tester) async {
    useDevice(tester, const Size(320, 640));
    await tester.pumpWidget(host(child: historyGrid(summary)));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the history grid survives enlarged text', (tester) async {
    useDevice(tester, const Size(393, 851));
    await tester.pumpWidget(host(child: historyGrid(summary), textScale: 1.4));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('a single photo still renders its caption', (tester) async {
    useDevice(tester, const Size(393, 851));
    final one = BodyProgressSummary(
      bodyView: BodyView.front,
      photos: [photo(DateTime(2026, 9, 10, 8))],
    );
    await tester.pumpWidget(host(child: historyGrid(one)));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('1일차'), findsOneWidget);
  });
}
