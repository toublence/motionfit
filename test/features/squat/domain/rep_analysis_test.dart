import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_analysis.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_record.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

void main() {
  final workoutStartedAt = DateTime(2026, 8, 11, 9);

  group('RepAnalysis.fromRecords', () {
    test('creates a good analysis from stored rep summary data', () {
      final analyses = RepAnalysis.fromRecords(
        records: [
          _record(
            startedAt: workoutStartedAt.add(const Duration(seconds: 30)),
            bottomAt: workoutStartedAt.add(
              const Duration(seconds: 31, milliseconds: 100),
            ),
            completedAt: workoutStartedAt.add(const Duration(seconds: 32)),
            sequenceNumber: 3,
            videoStartMilliseconds: 9200,
            videoBottomMilliseconds: 10300,
            videoEndMilliseconds: 11200,
            depthQuality: RepQuality.good,
            upperBodyQuality: RepQuality.good,
            kneeAlignmentQuality: RepQuality.good,
          ),
        ],
        setNumbers: const {'set-1': 2},
        workoutStartedAt: workoutStartedAt,
      );

      final analysis = analyses.single;
      expect(analysis.repNumber, 3);
      expect(analysis.setNumber, 2);
      expect(analysis.startTime, const Duration(milliseconds: 9200));
      expect(analysis.bottomTime, const Duration(milliseconds: 10300));
      expect(analysis.endTime, const Duration(milliseconds: 11200));
      expect(analysis.duration, const Duration(seconds: 2));
      expect(analysis.result, RepAnalysisResult.good);
      expect(analysis.primaryIssue, isNull);
      expect(analysis.issues, isEmpty);
      expect(analysis.improvedFromPreviousRep, isFalse);
    });

    test('classifies persisted depth, upper-body, and knee issues', () {
      final cases =
          <
            ({
              FormIssue issue,
              RepQuality depth,
              RepQuality upperBody,
              RepQuality knee,
            })
          >[
            (
              issue: FormIssue.insufficientDepth,
              depth: RepQuality.needsImprovement,
              upperBody: RepQuality.good,
              knee: RepQuality.unavailable,
            ),
            (
              issue: FormIssue.excessiveTorsoLean,
              depth: RepQuality.good,
              upperBody: RepQuality.needsImprovement,
              knee: RepQuality.unavailable,
            ),
            (
              issue: FormIssue.kneeAlignment,
              depth: RepQuality.good,
              upperBody: RepQuality.unavailable,
              knee: RepQuality.needsImprovement,
            ),
          ];

      for (final value in cases) {
        final analysis = RepAnalysis.fromRecords(
          records: [
            _record(
              detectedIssues: [value.issue],
              primaryIssue: value.issue,
              depthQuality: value.depth,
              upperBodyQuality: value.upperBody,
              kneeAlignmentQuality: value.knee,
            ),
          ],
          setNumbers: const {'set-1': 1},
          workoutStartedAt: workoutStartedAt,
        ).single;

        expect(analysis.result, RepAnalysisResult.needsImprovement);
        expect(analysis.primaryIssue, value.issue);
        expect(analysis.issues, [value.issue]);
        expect(analysis.depthQuality, value.depth);
        expect(analysis.upperBodyQuality, value.upperBody);
        expect(analysis.kneeAlignmentQuality, value.knee);
      }
    });

    test('marks a clearly resolved issue as improved', () {
      final analyses = RepAnalysis.fromRecords(
        records: [
          _record(
            id: 'rep-1',
            detectedIssues: const [FormIssue.insufficientDepth],
            primaryIssue: FormIssue.insufficientDepth,
            depthQuality: RepQuality.needsImprovement,
          ),
          _record(
            id: 'rep-2',
            repIndex: 2,
            sequenceNumber: 2,
            depthQuality: RepQuality.good,
          ),
        ],
        setNumbers: const {'set-1': 1},
        workoutStartedAt: workoutStartedAt,
      );

      expect(analyses.first.result, RepAnalysisResult.needsImprovement);
      expect(analyses.last.result, RepAnalysisResult.improved);
      expect(analyses.last.improvedFromPreviousRep, isTrue);
    });

    test(
      'requires same set, angle, confidence, and a passed metric to improve',
      () {
        final scenarios =
            <({String name, RepRecord previous, RepRecord current})>[
              (
                name: 'different set',
                previous: _problemRep(),
                current: _resolvedRep(setId: 'set-2'),
              ),
              (
                name: 'different angle',
                previous: _problemRep(),
                current: _resolvedRep(cameraAngle: CameraAngle.front),
              ),
              (
                name: 'low previous confidence',
                previous: _problemRep(confidence: 0.69),
                current: _resolvedRep(),
              ),
              (
                name: 'low current confidence',
                previous: _problemRep(),
                current: _resolvedRep(confidence: 0.69),
              ),
              (
                name: 'metric not passed',
                previous: _problemRep(),
                current: _resolvedRep(depthQuality: RepQuality.unavailable),
              ),
              (
                name: 'another issue remains',
                previous: _problemRep(),
                current: _resolvedRep(
                  detectedIssues: const [FormIssue.excessiveTorsoLean],
                  primaryIssue: FormIssue.excessiveTorsoLean,
                ),
              ),
            ];

        for (final scenario in scenarios) {
          final analysis = RepAnalysis.fromRecords(
            records: [scenario.previous, scenario.current],
            setNumbers: const {'set-1': 1, 'set-2': 2},
            workoutStartedAt: workoutStartedAt,
          ).last;

          expect(
            analysis.improvedFromPreviousRep,
            isFalse,
            reason: scenario.name,
          );
          expect(
            analysis.result,
            scenario.current.detectedIssues.isEmpty
                ? RepAnalysisResult.good
                : RepAnalysisResult.needsImprovement,
            reason: scenario.name,
          );
        }
      },
    );

    test('falls back to wall-clock offsets for a legacy rep', () {
      final analysis = RepAnalysis.fromRecords(
        records: [
          _record(
            sequenceNumber: null,
            startedAt: workoutStartedAt.add(const Duration(seconds: 4)),
            bottomAt: workoutStartedAt.add(
              const Duration(seconds: 5, milliseconds: 250),
            ),
            completedAt: workoutStartedAt.add(const Duration(seconds: 6)),
            videoStartMilliseconds: null,
            videoBottomMilliseconds: null,
            videoEndMilliseconds: null,
            depthQuality: RepQuality.unavailable,
            overallFormScore: null,
          ),
        ],
        setNumbers: const {'set-1': 1},
        workoutStartedAt: workoutStartedAt,
      ).single;

      expect(analysis.repNumber, 1);
      expect(analysis.startTime, const Duration(seconds: 4));
      expect(
        analysis.bottomTime,
        const Duration(seconds: 5, milliseconds: 250),
      );
      expect(analysis.endTime, const Duration(seconds: 6));
      expect(analysis.result, RepAnalysisResult.notAssessed);
    });
  });
}

RepRecord _problemRep({double confidence = 0.9}) => _record(
  id: 'rep-1',
  detectedIssues: const [FormIssue.insufficientDepth],
  primaryIssue: FormIssue.insufficientDepth,
  depthQuality: RepQuality.needsImprovement,
  confidence: confidence,
);

RepRecord _resolvedRep({
  String setId = 'set-1',
  CameraAngle cameraAngle = CameraAngle.side,
  double confidence = 0.9,
  RepQuality depthQuality = RepQuality.good,
  List<FormIssue> detectedIssues = const [],
  FormIssue? primaryIssue,
}) => _record(
  id: 'rep-2',
  setId: setId,
  repIndex: 2,
  sequenceNumber: 2,
  cameraAngle: cameraAngle,
  confidence: confidence,
  detectedIssues: detectedIssues,
  primaryIssue: primaryIssue,
  depthQuality: depthQuality,
);

RepRecord _record({
  String id = 'rep-1',
  String setId = 'set-1',
  int repIndex = 1,
  DateTime? startedAt,
  DateTime? bottomAt,
  DateTime? completedAt,
  double? overallFormScore = 92,
  List<FormIssue> detectedIssues = const [],
  CameraAngle cameraAngle = CameraAngle.side,
  double confidence = 0.9,
  int? sequenceNumber = 1,
  int? videoStartMilliseconds = 1000,
  int? videoBottomMilliseconds = 2000,
  int? videoEndMilliseconds = 3000,
  FormIssue? primaryIssue,
  RepQuality depthQuality = RepQuality.good,
  RepQuality upperBodyQuality = RepQuality.unavailable,
  RepQuality kneeAlignmentQuality = RepQuality.unavailable,
}) {
  final base = DateTime(2026, 8, 11, 9);
  return RepRecord(
    id: id,
    sessionId: 'session-1',
    setId: setId,
    repIndex: repIndex,
    startedAt: startedAt ?? base.add(const Duration(seconds: 1)),
    bottomAt: bottomAt ?? base.add(const Duration(seconds: 2)),
    completedAt: completedAt ?? base.add(const Duration(seconds: 3)),
    durationMilliseconds: 2000,
    depthScore: depthQuality == RepQuality.unavailable ? null : 92,
    controlScore: null,
    balanceScore: null,
    overallFormScore: overallFormScore,
    detectedIssues: detectedIssues,
    cameraAngle: cameraAngle,
    confidence: confidence,
    sequenceNumber: sequenceNumber,
    videoStartMilliseconds: videoStartMilliseconds,
    videoBottomMilliseconds: videoBottomMilliseconds,
    videoEndMilliseconds: videoEndMilliseconds,
    primaryIssue: primaryIssue,
    depthQuality: depthQuality,
    upperBodyQuality: upperBodyQuality,
    kneeAlignmentQuality: kneeAlignmentQuality,
  );
}
