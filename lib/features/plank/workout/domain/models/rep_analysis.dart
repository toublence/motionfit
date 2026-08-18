import 'package:motionfit_squat/features/plank/workout/domain/models/rep_record.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';

/// Compact, persisted-data-backed summary used by rep review surfaces.
///
/// Raw landmarks are intentionally excluded. Times are offsets from the
/// workout video's monotonic timeline, never wall-clock timestamps.
class RepAnalysis {
  const RepAnalysis({
    required this.repNumber,
    required this.setNumber,
    required this.startTime,
    required this.bottomTime,
    required this.endTime,
    required this.duration,
    required this.result,
    required this.primaryIssue,
    required this.issues,
    required this.depthQuality,
    required this.upperBodyQuality,
    required this.kneeAlignmentQuality,
    required this.improvedFromPreviousRep,
  });

  final int repNumber;
  final int setNumber;
  final Duration startTime;
  final Duration? bottomTime;
  final Duration endTime;
  final Duration duration;
  final RepAnalysisResult result;
  final FormIssue? primaryIssue;
  final List<FormIssue> issues;
  final RepQuality depthQuality;
  final RepQuality upperBodyQuality;
  final RepQuality kneeAlignmentQuality;
  final bool improvedFromPreviousRep;

  bool get needsImprovement => result == RepAnalysisResult.needsImprovement;

  static List<RepAnalysis> fromRecords({
    required List<RepRecord> records,
    required Map<String, int> setNumbers,
    required DateTime workoutStartedAt,
  }) {
    final analyses = <RepAnalysis>[];
    for (var index = 0; index < records.length; index++) {
      final record = records[index];
      final previous = analyses.isEmpty ? null : analyses.last;
      final previousRecord = index == 0 ? null : records[index - 1];
      final start = _elapsed(
        storedMilliseconds: record.videoStartMilliseconds,
        wallClock: record.startedAt,
        workoutStartedAt: workoutStartedAt,
      );
      final bottom =
          record.bottomAt == null && record.videoBottomMilliseconds == null
          ? null
          : _elapsed(
              storedMilliseconds: record.videoBottomMilliseconds,
              wallClock: record.bottomAt ?? record.startedAt,
              workoutStartedAt: workoutStartedAt,
            );
      final end = _elapsed(
        storedMilliseconds: record.videoEndMilliseconds,
        wallClock: record.completedAt,
        workoutStartedAt: workoutStartedAt,
      );
      final primaryIssue =
          record.primaryIssue ??
          (record.detectedIssues.isEmpty ? null : record.detectedIssues.first);
      final assessed =
          record.overallFormScore != null ||
          record.depthQuality != RepQuality.unavailable ||
          record.upperBodyQuality != RepQuality.unavailable ||
          record.kneeAlignmentQuality != RepQuality.unavailable;
      final resolvedPreviousIssue =
          previous != null &&
          previousRecord != null &&
          previousRecord.setId == record.setId &&
          previousRecord.cameraAngle == record.cameraAngle &&
          previousRecord.confidence >= 0.7 &&
          record.confidence >= 0.7 &&
          record.detectedIssues.isEmpty &&
          _resolved(previous.primaryIssue, record);
      final result = record.detectedIssues.isNotEmpty
          ? RepAnalysisResult.needsImprovement
          : resolvedPreviousIssue
          ? RepAnalysisResult.improved
          : assessed
          ? RepAnalysisResult.good
          : RepAnalysisResult.notAssessed;
      analyses.add(
        RepAnalysis(
          repNumber: record.sequenceNumber ?? index + 1,
          setNumber: setNumbers[record.setId] ?? 1,
          startTime: start,
          bottomTime: bottom,
          endTime: end < start ? start + record.duration : end,
          duration: record.duration,
          result: result,
          primaryIssue: primaryIssue,
          issues: List.unmodifiable(record.detectedIssues),
          depthQuality: record.depthQuality,
          upperBodyQuality: record.upperBodyQuality,
          kneeAlignmentQuality: record.kneeAlignmentQuality,
          improvedFromPreviousRep: resolvedPreviousIssue,
        ),
      );
    }
    return List.unmodifiable(analyses);
  }

  static Duration _elapsed({
    required int? storedMilliseconds,
    required DateTime wallClock,
    required DateTime workoutStartedAt,
  }) {
    if (storedMilliseconds != null) {
      return Duration(milliseconds: storedMilliseconds.clamp(0, 86400000));
    }
    final fallback = wallClock.difference(workoutStartedAt);
    return fallback.isNegative ? Duration.zero : fallback;
  }

  static bool _resolved(
    FormIssue? previousIssue,
    RepRecord current,
  ) => switch (previousIssue) {
    FormIssue.insufficientDepth => current.depthQuality == RepQuality.good,
    FormIssue.excessiveTorsoLean => current.upperBodyQuality == RepQuality.good,
    FormIssue.kneeAlignment => current.kneeAlignmentQuality == RepQuality.good,
    _ => false,
  };
}
