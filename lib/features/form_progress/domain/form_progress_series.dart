import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_pose_snapshot.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_progress_point.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

class FormIssueTally {
  const FormIssueTally({required this.issue, required this.count});

  final FormIssue issue;
  final int count;
}

/// Read model for one exercise's form history.
///
/// Points arrive oldest first so `first` is the day-one reference and `latest`
/// is today's result.
class FormProgressSeries {
  FormProgressSeries({
    required this.exerciseType,
    required List<FormProgressPoint> points,
    Map<String, FormPoseSnapshot> poses = const {},
  }) : points = List.unmodifiable(
         [...points]..sort((a, b) => a.workoutDate.compareTo(b.workoutDate)),
       ),
       poses = Map.unmodifiable(poses);

  final ExerciseType exerciseType;
  final List<FormProgressPoint> points;

  /// Representative pose per session id, when one was captured.
  final Map<String, FormPoseSnapshot> poses;

  bool get isEmpty => points.isEmpty && poseSnapshots.isEmpty;

  int get sessionCount => points.length;

  List<FormProgressPoint> get scoredPoints =>
      points.where((point) => point.isScored).toList(growable: false);

  FormProgressPoint? get first =>
      scoredPoints.isEmpty ? null : scoredPoints.first;

  FormProgressPoint? get latest =>
      scoredPoints.isEmpty ? null : scoredPoints.last;

  double? get firstScore =>
      first?.formScore ??
      (poseSnapshots.isEmpty ? null : poseSnapshots.first.formScore);

  double? get latestScore =>
      latest?.formScore ??
      (poseSnapshots.isEmpty ? null : poseSnapshots.last.formScore);

  double? get scoreDelta {
    final start = firstScore;
    final end = latestScore;
    if (start == null || end == null || scoredPoints.length < 2) return null;
    return end - start;
  }

  double? get firstAccuracy =>
      first?.accuracy ??
      (poseSnapshots.isEmpty ? null : poseSnapshots.first.accuracy);

  double? get latestAccuracy =>
      latest?.accuracy ??
      (poseSnapshots.isEmpty ? null : poseSnapshots.last.accuracy);

  double? get accuracyDelta {
    final start = firstAccuracy;
    final end = latestAccuracy;
    if (start == null || end == null || scoredPoints.length < 2) return null;
    return end - start;
  }

  /// Best single-session score, used to celebrate a personal best.
  double? get bestScore {
    final scores = scoredPoints
        .map((point) => point.formScore!)
        .toList(growable: false);
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a > b ? a : b);
  }

  DateTime? get firstDate => points.isEmpty ? null : points.first.workoutDate;

  DateTime? get latestDate => points.isEmpty ? null : points.last.workoutDate;

  /// `Day N` of a point, counting the first workout as day 1.
  int dayNumberOf(FormProgressPoint point) {
    final start = firstDate;
    if (start == null) return 1;
    return _dayOnly(point.workoutDate).difference(_dayOnly(start)).inDays + 1;
  }

  /// Issues ordered by how often they were detected, most frequent first.
  List<FormIssueTally> get topIssues {
    final counts = <FormIssue, int>{};
    for (final point in points) {
      for (final issue in point.issues) {
        counts[issue] = (counts[issue] ?? 0) + 1;
      }
    }
    final tallies =
        counts.entries
            .map(
              (entry) => FormIssueTally(issue: entry.key, count: entry.value),
            )
            .toList()
          ..sort((a, b) => b.count.compareTo(a.count));
    return List.unmodifiable(tallies);
  }

  /// Issues that showed up in the earlier half of the history and no longer
  /// appear in the most recent sessions.
  List<FormIssue> get resolvedIssues {
    if (points.length < 4) return const [];
    final split = points.length ~/ 2;
    final early = points.take(split).expand((point) => point.issues).toSet();
    final recent = points.skip(split).expand((point) => point.issues).toSet();
    return List.unmodifiable(early.difference(recent));
  }

  FormPoseSnapshot? poseFor(FormProgressPoint point) => poses[point.sessionId];

  /// Stored representative poses are the visual timeline's source of truth.
  ///
  /// They are intentionally independent from completed-session points: the
  /// first valid rep is saved while a workout is still active, so waiting for
  /// session completion made a freshly captured pose disappear from Progress.
  List<FormPoseSnapshot> get poseSnapshots {
    final snapshots = poses.values.where((pose) => pose.isRenderable).toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    return List.unmodifiable(snapshots);
  }

  int dayNumberOfSnapshot(FormPoseSnapshot snapshot) {
    final snapshots = poseSnapshots;
    if (snapshots.isEmpty) return 1;
    return _dayOnly(
          snapshot.capturedAt,
        ).difference(_dayOnly(snapshots.first.capturedAt)).inDays +
        1;
  }

  /// Points that carry a representative pose, oldest first. These drive the
  /// form timelapse and the before/after comparison.
  List<FormProgressPoint> get posedPoints => points
      .where((point) => poses.containsKey(point.sessionId))
      .toList(growable: false);

  static DateTime _dayOnly(DateTime moment) {
    final local = moment.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
