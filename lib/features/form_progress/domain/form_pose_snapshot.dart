import 'dart:convert';

import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

/// One normalized landmark of a representative pose.
///
/// Deliberately independent of each exercise's own `PoseLandmark` type so the
/// three workout pipelines can all feed the same snapshot without conversion
/// layers between them.
class FormPosePoint {
  const FormPosePoint({
    required this.x,
    required this.y,
    required this.confidence,
  });

  final double x;
  final double y;
  final double confidence;
}

/// Where the workout that produced a snapshot came from.
enum FormProgressSource { freeWorkout, challenge, routine }

/// Representative pose of one workout, stored as normalized landmark points.
///
/// Only the coordinates of a single rep are kept, never camera pixels. This is
/// what lets Form Progress show a real before/after posture without storing
/// photos and without re-analysing past workouts.
class FormPoseSnapshot {
  const FormPoseSnapshot({
    required this.sessionId,
    required this.repId,
    required this.capturedAt,
    required this.capturedOn,
    required this.formScore,
    required this.accuracy,
    required this.primaryIssue,
    required this.landmarks,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.mirrored,
    required this.createdAt,
    this.sourceType = FormProgressSource.freeWorkout,
  });

  final String sessionId;
  final String? repId;
  final DateTime capturedAt;

  /// Local day key in `yyyy-MM-dd` form. One snapshot is kept per day.
  final String capturedOn;
  final double? formScore;

  /// Mean detection confidence of the rep, on a 0-1 scale.
  final double? accuracy;
  final FormIssue? primaryIssue;

  /// MediaPipe's 33 normalized points, x and y only.
  final List<FormPosePoint> landmarks;
  final int sourceWidth;
  final int sourceHeight;
  final bool mirrored;
  final DateTime createdAt;
  final FormProgressSource sourceType;

  static String dayKey(DateTime moment) {
    final local = moment.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  bool get isRenderable => landmarks.length >= 33;

  double get aspectRatio =>
      sourceWidth > 0 && sourceHeight > 0 ? sourceWidth / sourceHeight : 3 / 4;

  /// Encodes x, y and confidence as one flat list so the row stays compact.
  static String encodeLandmarks(List<FormPosePoint> landmarks) {
    final flat = <double>[];
    for (final point in landmarks) {
      flat
        ..add(_round(point.x))
        ..add(_round(point.y))
        ..add(_round(point.confidence));
    }
    return jsonEncode(flat);
  }

  static List<FormPosePoint> decodeLandmarks(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! List) return const [];
    final flat = decoded
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList(growable: false);
    final points = <FormPosePoint>[];
    for (var index = 0; index + 2 < flat.length; index += 3) {
      points.add(
        FormPosePoint(
          x: flat[index],
          y: flat[index + 1],
          confidence: flat[index + 2],
        ),
      );
    }
    return List.unmodifiable(points);
  }

  static double _round(double value) => (value * 10000).roundToDouble() / 10000;

  Map<String, Object?> toMap() => {
    'session_id': sessionId,
    'rep_id': repId,
    'captured_at': capturedAt.millisecondsSinceEpoch,
    'captured_on': capturedOn,
    'form_score': formScore,
    'accuracy': accuracy,
    'primary_issue': primaryIssue?.name,
    'landmarks': encodeLandmarks(landmarks),
    'source_width': sourceWidth,
    'source_height': sourceHeight,
    'mirrored': mirrored ? 1 : 0,
    'source_type': sourceType.name,
    'created_at': createdAt.millisecondsSinceEpoch,
  };

  factory FormPoseSnapshot.fromMap(Map<String, Object?> map) =>
      FormPoseSnapshot(
        sessionId: map['session_id']! as String,
        repId: map['rep_id'] as String?,
        capturedAt: DateTime.fromMillisecondsSinceEpoch(
          map['captured_at']! as int,
        ),
        capturedOn: (map['captured_on'] as String?) ?? '',
        formScore: (map['form_score'] as num?)?.toDouble(),
        accuracy: (map['accuracy'] as num?)?.toDouble(),
        primaryIssue: _issueByName(map['primary_issue'] as String?),
        landmarks: decodeLandmarks(map['landmarks']! as String),
        sourceWidth: (map['source_width'] as num?)?.toInt() ?? 0,
        sourceHeight: (map['source_height'] as num?)?.toInt() ?? 0,
        mirrored: map['mirrored'] == 1,
        sourceType: enumByName(
          FormProgressSource.values,
          map['source_type'] as String?,
          FormProgressSource.freeWorkout,
        ),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at']! as int,
        ),
      );
}

FormIssue? _issueByName(String? name) {
  if (name == null) return null;
  for (final issue in FormIssue.values) {
    if (issue.name == name) return issue;
  }
  return null;
}
