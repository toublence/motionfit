import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/features/records/application/records_providers.dart';
import 'package:motionfit_squat/features/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/records/presentation/workout_session_detail_screen.dart';
import 'package:motionfit_squat/features/settings/presentation/settings_screen.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_analysis.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_record.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_session.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_set.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/workout_summary_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/rep_review_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/widgets/rep_timeline_section.dart';

void main() {
  testWidgets('Workout Result shows five persisted reps in order', (
    tester,
  ) async {
    final details = _details();

    await _pump(
      tester,
      SingleChildScrollView(
        child: WorkoutResultRepTimeline(
          sessionId: details.session.id,
          details: AsyncData(details),
          onRetry: () {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('workout-result-rep-timeline')), findsOne);
    for (var rep = 1; rep <= 5; rep++) {
      expect(find.byKey(ValueKey('rep-timeline-row-$rep')), findsOneWidget);
    }
    final positions = List.generate(
      5,
      (index) => tester
          .getTopLeft(find.byKey(ValueKey('rep-timeline-row-${index + 1}')))
          .dy,
    );
    expect(positions, orderedEquals(positions.toList()..sort()));
  });

  testWidgets('video disabled keeps rows and hides play buttons', (
    tester,
  ) async {
    await _pump(
      tester,
      SingleChildScrollView(
        child: RepTimelineSection(
          sessionId: 'session-1',
          analyses: _analyses(),
          videoPath: null,
          onOpenRep: (_) {},
        ),
      ),
    );
    expect(find.byKey(const ValueKey('rep-timeline-row-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('rep-timeline-play-3')), findsNothing);
  });

  testWidgets('valid video shows play and opens Rep 3 timestamps', (
    tester,
  ) async {
    final directory = Directory.systemTemp.createTempSync('rep-video-ui-');
    addTearDown(() {
      if (directory.existsSync()) directory.deleteSync(recursive: true);
    });
    final video = File('${directory.path}/workout_session-1.mp4');
    video.writeAsBytesSync(const [0, 1, 2]);

    RepAnalysis? opened;
    await _pump(
      tester,
      SingleChildScrollView(
        child: RepTimelineSection(
          sessionId: 'session-1',
          analyses: _analyses(),
          videoPath: video.path,
          onOpenRep: (analysis) => opened = analysis,
        ),
      ),
    );
    final play = tester.widget<IconButton>(
      find.byKey(const ValueKey('rep-timeline-play-3')),
    );
    play.onPressed!();
    expect(opened?.repNumber, 3);
    expect(opened?.startTime, const Duration(seconds: 9));
  });

  testWidgets('deleted video keeps Timeline and hides play', (tester) async {
    final directory = Directory.systemTemp.createTempSync(
      'rep-deleted-video-ui-',
    );
    addTearDown(() {
      if (directory.existsSync()) directory.deleteSync(recursive: true);
    });
    final video = File('${directory.path}/workout_session-1.mp4');
    video.writeAsBytesSync(const [0, 1, 2]);

    video.deleteSync();
    await _pump(
      tester,
      SingleChildScrollView(
        child: RepTimelineSection(
          sessionId: 'session-1',
          analyses: _analyses(),
          videoPath: video.path,
          onOpenRep: (_) {},
        ),
      ),
    );
    expect(find.byKey(const ValueKey('rep-timeline-row-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('rep-timeline-play-3')), findsNothing);
  });

  testWidgets('row tap opens the matching rep detail', (tester) async {
    RepAnalysis? opened;
    await _pump(
      tester,
      SingleChildScrollView(
        child: RepTimelineSection(
          sessionId: 'session-1',
          analyses: _analyses(),
          videoPath: null,
          onOpenRep: (analysis) => opened = analysis,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('rep-timeline-row-4')));
    expect(opened?.repNumber, 4);
  });

  testWidgets('Improve filter keeps only reps needing attention', (
    tester,
  ) async {
    await _pump(
      tester,
      SingleChildScrollView(
        child: RepTimelineSection(
          sessionId: 'session-1',
          analyses: _analyses(),
          videoPath: null,
          onOpenRep: (_) {},
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('rep-timeline-filter-attention')),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('rep-timeline-row-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('rep-timeline-row-1')), findsNothing);
    expect(find.text('Knees moved inward'), findsOneWidget);
  });

  testWidgets('100 reps render without overflow at compact width', (
    tester,
  ) async {
    await _pump(
      tester,
      SingleChildScrollView(
        child: RepTimelineSection(
          sessionId: 'session-100',
          analyses: List.generate(100, (index) => _analysis(index + 1)),
          videoPath: null,
          onOpenRep: (_) {},
        ),
      ),
      size: const Size(360, 640),
    );

    expect(find.byKey(const ValueKey('rep-timeline-row-100')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('History detail renders the same persisted timeline', (
    tester,
  ) async {
    final details = _details();
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionDetailsProvider(
            'session-1',
          ).overrideWith((ref) async => details),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WorkoutSessionDetailScreen(sessionId: 'session-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('history-rep-timeline')), findsOneWidget);
    expect(find.byKey(const ValueKey('rep-timeline-row-5')), findsOneWidget);
  });

  testWidgets('Settings owns the Rep Video Review switch', (tester) async {
    bool? changed;
    await _pump(
      tester,
      RepVideoReviewSettingsTile(
        value: true,
        onChanged: (value) => changed = value,
      ),
    );

    expect(
      find.byKey(const ValueKey('settings-rep-video-review-toggle')),
      findsOneWidget,
    );
    final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    tile.onChanged!(false);
    expect(changed, isFalse);
  });

  testWidgets('Rep review exposes previous and next navigation states', (
    tester,
  ) async {
    final details = _details();
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionDetailsProvider(
            'session-1',
          ).overrideWith((ref) async => details),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepReviewScreen(sessionId: 'session-1', repNumber: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final previous = tester.widget<TextButton>(
      find.byKey(const ValueKey('rep-review-previous')),
    );
    final next = tester.widget<TextButton>(
      find.byKey(const ValueKey('rep-review-next')),
    );
    expect(previous.onPressed, isNull);
    expect(next.onPressed, isNotNull);
  });

  test('Workout Setup no longer contains the video review setting', () {
    final source = File(
      'lib/features/squat/presentation/screens/squat_home_screen.dart',
    ).readAsStringSync();
    expect(source, isNot(contains('repVideoReviewTitle')));
    expect(source, isNot(contains('setRepVideoReview')));
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(500, 1200),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

List<RepAnalysis> _analyses() =>
    List.generate(5, (index) => _analysis(index + 1));

RepAnalysis _analysis(int number) => RepAnalysis(
  repNumber: number,
  setNumber: 1,
  startTime: Duration(seconds: number * 3),
  bottomTime: Duration(seconds: number * 3 + 1),
  endTime: Duration(seconds: number * 3 + 2),
  duration: const Duration(seconds: 2),
  result: number == 2
      ? RepAnalysisResult.needsImprovement
      : RepAnalysisResult.good,
  primaryIssue: number == 2 ? FormIssue.kneeAlignment : null,
  issues: number == 2 ? const [FormIssue.kneeAlignment] : const [],
  depthQuality: RepQuality.good,
  upperBodyQuality: RepQuality.good,
  kneeAlignmentQuality: number == 2
      ? RepQuality.needsImprovement
      : RepQuality.good,
  improvedFromPreviousRep: false,
);

WorkoutSessionDetails _details() {
  final startedAt = DateTime.utc(2026, 8, 11, 9);
  final session = WorkoutSession(
    id: 'session-1',
    startedAt: startedAt,
    endedAt: startedAt.add(const Duration(minutes: 1)),
    plannedSetCount: 1,
    plannedRepsPerSet: 5,
    plannedRestSeconds: 15,
    completedSetCount: 1,
    totalReps: 5,
    activeDurationSeconds: 25,
    restDurationSeconds: 0,
    totalDurationSeconds: 30,
    averageRepDurationMilliseconds: 2000,
    completed: true,
    interrupted: false,
    createdAt: startedAt,
  );
  final set = WorkoutSet(
    id: 'set-1',
    sessionId: session.id,
    setIndex: 1,
    startedAt: startedAt,
    endedAt: startedAt.add(const Duration(seconds: 25)),
    targetReps: 5,
    completedReps: 5,
    activeDurationSeconds: 25,
    restDurationAfterSeconds: 0,
  );
  final reps = List.generate(5, (index) {
    final number = index + 1;
    return RepRecord(
      id: 'rep-$number',
      sessionId: session.id,
      setId: set.id,
      repIndex: number,
      startedAt: startedAt.add(Duration(seconds: number * 3)),
      bottomAt: startedAt.add(Duration(seconds: number * 3 + 1)),
      completedAt: startedAt.add(Duration(seconds: number * 3 + 2)),
      durationMilliseconds: 2000,
      depthScore: 88,
      controlScore: 86,
      balanceScore: 90,
      overallFormScore: 88,
      detectedIssues: const [],
      cameraAngle: CameraAngle.side,
      confidence: .95,
      sequenceNumber: number,
      videoStartMilliseconds: number * 3000,
      videoBottomMilliseconds: number * 3000 + 1000,
      videoEndMilliseconds: number * 3000 + 2000,
      depthQuality: RepQuality.good,
      upperBodyQuality: RepQuality.good,
      kneeAlignmentQuality: RepQuality.good,
    );
  });
  return WorkoutSessionDetails(session: session, sets: [set], reps: reps);
}
