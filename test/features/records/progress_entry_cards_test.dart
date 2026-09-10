import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/records/presentation/models/growth_workout_record.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/calendar_records_view.dart';

/// The Progress tab renders this view inside a `ListView`, which hands its
/// children an unbounded height. A row that stretches on its cross axis cannot
/// resolve against that and blanks the whole tab, so these tests pump the real
/// widget rather than a stand-in.
Widget host(List<GrowthWorkoutRecord> records) => ProviderScope(
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
    home: Scaffold(
      body: CalendarRecordsView(
        records: records,
        onRefresh: () async {},
        onStartWorkout: () {},
      ),
    ),
  ),
);

GrowthWorkoutRecord record(DateTime startedAt) => GrowthWorkoutRecord(
  exerciseType: ExerciseType.squat,
  sessionId: startedAt.toIso8601String(),
  startedAt: startedAt,
  totalReps: 30,
  completedSetCount: 3,
  activeDurationSeconds: 300,
  averageFormScore: 72,
  completed: true,
  interrupted: false,
);

void main() {
  testWidgets('the Progress tab lays out with no workout history', (
    tester,
  ) async {
    await tester.pumpWidget(host(const []));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('변화 추적'), findsOneWidget);
  });

  testWidgets('both progress entry cards are shown', (tester) async {
    await tester.pumpWidget(host([record(DateTime.now())]));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('바디 프로그레스'), findsOneWidget);
    expect(find.text('폼 프로그레스'), findsOneWidget);
  });

  testWidgets('the entry cards share one height', (tester) async {
    await tester.pumpWidget(host([record(DateTime.now())]));
    await tester.pump();

    final body = tester.getRect(find.text('바디 프로그레스'));
    final form = tester.getRect(find.text('폼 프로그레스'));
    expect(body.top, closeTo(form.top, 0.5));
  });

  testWidgets('the tab still lays out on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host([record(DateTime.now())]));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('바디 프로그레스'), findsOneWidget);
  });
}
