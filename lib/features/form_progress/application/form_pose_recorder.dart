import 'package:motionfit_squat/features/form_progress/domain/form_pose_snapshot.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

/// Keeps the first valid rep of the running workout as a representative pose.
///
/// The recorder is fed from the pose frame stream the workout already
/// consumes. It holds a short rolling window in memory and picks the frame
/// closest to the rep's bottom. Only the first scored rep of a session yields a
/// snapshot, so every day's entry is captured under the same condition: the
/// start of the workout. Nothing here influences rep detection, calibration, or
/// form analysis.
class FormPoseRecorder {
  FormPoseRecorder({this.windowLength = 150});

  /// Frames retained, about five seconds at 30fps. A rep is far shorter, so
  /// the bottom frame is always still inside the window when the rep is saved.
  final int windowLength;

  final List<_BufferedPose> _window = [];
  bool _captured = false;

  /// Records a frame. Frames without a full landmark set are ignored.
  void addFrame({
    required int timestampUs,
    required List<double> flatXyConfidence,
    required int sourceWidth,
    required int sourceHeight,
    required bool mirrored,
  }) {
    if (flatXyConfidence.length < 99) return;
    _window.add(
      _BufferedPose(
        timestampUs: timestampUs,
        values: flatXyConfidence,
        sourceWidth: sourceWidth,
        sourceHeight: sourceHeight,
        mirrored: mirrored,
      ),
    );
    if (_window.length > windowLength) {
      _window.removeRange(0, _window.length - windowLength);
    }
  }

  /// Returns a snapshot for the first scored rep of the session.
  ///
  /// Returns null when the rep was not scored, when a snapshot was already
  /// taken for this session, or when no usable frame is buffered.
  FormPoseSnapshot? snapshotForRep({
    required String sessionId,
    required String repId,
    required DateTime capturedAt,
    required double? score,
    required double? accuracy,
    required FormIssue? primaryIssue,
    required int? bottomAtUs,
    FormProgressSource sourceType = FormProgressSource.freeWorkout,
  }) {
    if (_captured || score == null) return null;
    final pose = _closestTo(bottomAtUs);
    if (pose == null) return null;
    _captured = true;
    return FormPoseSnapshot(
      sessionId: sessionId,
      repId: repId,
      capturedAt: capturedAt,
      capturedOn: FormPoseSnapshot.dayKey(capturedAt),
      formScore: score,
      accuracy: accuracy,
      primaryIssue: primaryIssue,
      landmarks: _toPoints(pose.values),
      sourceWidth: pose.sourceWidth,
      sourceHeight: pose.sourceHeight,
      mirrored: pose.mirrored,
      sourceType: sourceType,
      createdAt: DateTime.now(),
    );
  }

  void reset() {
    _window.clear();
    _captured = false;
  }

  _BufferedPose? _closestTo(int? timestampUs) {
    if (_window.isEmpty) return null;
    if (timestampUs == null) return _window.last;
    _BufferedPose? best;
    var bestDistance = -1;
    for (final pose in _window) {
      final distance = (pose.timestampUs - timestampUs).abs();
      if (best == null || distance < bestDistance) {
        best = pose;
        bestDistance = distance;
      }
    }
    return best;
  }

  static List<FormPosePoint> _toPoints(List<double> values) {
    final points = <FormPosePoint>[];
    for (var index = 0; index + 2 < values.length; index += 3) {
      points.add(
        FormPosePoint(
          x: values[index],
          y: values[index + 1],
          confidence: values[index + 2],
        ),
      );
    }
    return List.unmodifiable(points);
  }
}

class _BufferedPose {
  const _BufferedPose({
    required this.timestampUs,
    required this.values,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.mirrored,
  });

  final int timestampUs;
  final List<double> values;
  final int sourceWidth;
  final int sourceHeight;
  final bool mirrored;
}
