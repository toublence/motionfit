import 'dart:convert';

import 'package:motionfit_squat/features/pushup/domain/models/workout_enums.dart';

class RepRecord {
  const RepRecord({
    required this.id,
    required this.sessionId,
    required this.setId,
    required this.repIndex,
    required this.startedAt,
    required this.bottomAt,
    required this.completedAt,
    required this.durationMilliseconds,
    required this.depthScore,
    required this.controlScore,
    required this.balanceScore,
    required this.overallFormScore,
    required this.detectedIssues,
    required this.cameraAngle,
    required this.confidence,
    this.sequenceNumber,
    this.videoStartMilliseconds,
    this.videoBottomMilliseconds,
    this.videoEndMilliseconds,
    this.primaryIssue,
    this.depthQuality = RepQuality.unavailable,
    this.upperBodyQuality = RepQuality.unavailable,
    this.kneeAlignmentQuality = RepQuality.unavailable,
  });

  final String id;
  final String sessionId;
  final String setId;
  final int repIndex;
  final DateTime startedAt;
  final DateTime? bottomAt;
  final DateTime completedAt;
  final int durationMilliseconds;
  final double? depthScore;
  final double? controlScore;
  final double? balanceScore;
  final double? overallFormScore;
  final List<FormIssue> detectedIssues;
  final CameraAngle cameraAngle;
  final double confidence;
  final int? sequenceNumber;
  final int? videoStartMilliseconds;
  final int? videoBottomMilliseconds;
  final int? videoEndMilliseconds;
  final FormIssue? primaryIssue;
  final RepQuality depthQuality;
  final RepQuality upperBodyQuality;
  final RepQuality kneeAlignmentQuality;

  Duration get duration => Duration(milliseconds: durationMilliseconds);

  Map<String, Object?> toMap() => {
    'id': id,
    'session_id': sessionId,
    'set_id': setId,
    'rep_index': repIndex,
    'started_at': startedAt.millisecondsSinceEpoch,
    'bottom_at': bottomAt?.millisecondsSinceEpoch,
    'completed_at': completedAt.millisecondsSinceEpoch,
    'duration_milliseconds': durationMilliseconds,
    'depth_score': depthScore,
    'control_score': controlScore,
    'balance_score': balanceScore,
    'overall_form_score': overallFormScore,
    'detected_issues': jsonEncode(
      detectedIssues.map((issue) => issue.name).toList(),
    ),
    'camera_angle': cameraAngle.name,
    'confidence': confidence,
    'sequence_number': sequenceNumber,
    'video_start_milliseconds': videoStartMilliseconds,
    'video_bottom_milliseconds': videoBottomMilliseconds,
    'video_end_milliseconds': videoEndMilliseconds,
    'primary_issue': primaryIssue?.name,
    'depth_quality': depthQuality.name,
    'upper_body_quality': upperBodyQuality.name,
    'knee_alignment_quality': kneeAlignmentQuality.name,
  };

  factory RepRecord.fromMap(Map<String, Object?> map) {
    final issueNames = (jsonDecode(map['detected_issues']! as String) as List)
        .cast<String>();
    return RepRecord(
      id: map['id']! as String,
      sessionId: map['session_id']! as String,
      setId: map['set_id']! as String,
      repIndex: map['rep_index']! as int,
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at']! as int),
      bottomAt: map['bottom_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['bottom_at']! as int),
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        map['completed_at']! as int,
      ),
      durationMilliseconds: map['duration_milliseconds']! as int,
      depthScore: (map['depth_score'] as num?)?.toDouble(),
      controlScore: (map['control_score'] as num?)?.toDouble(),
      balanceScore: (map['balance_score'] as num?)?.toDouble(),
      overallFormScore: (map['overall_form_score'] as num?)?.toDouble(),
      detectedIssues: issueNames
          .map((name) => _optionalEnumByName(FormIssue.values, name))
          .whereType<FormIssue>()
          .toList(growable: false),
      cameraAngle: enumByName(
        CameraAngle.values,
        map['camera_angle'] as String?,
        CameraAngle.uncertain,
      ),
      confidence: (map['confidence']! as num).toDouble(),
      sequenceNumber: (map['sequence_number'] as num?)?.toInt(),
      videoStartMilliseconds: (map['video_start_milliseconds'] as num?)
          ?.toInt(),
      videoBottomMilliseconds: (map['video_bottom_milliseconds'] as num?)
          ?.toInt(),
      videoEndMilliseconds: (map['video_end_milliseconds'] as num?)?.toInt(),
      primaryIssue: _optionalEnumByName(
        FormIssue.values,
        map['primary_issue'] as String?,
      ),
      depthQuality: enumByName(
        RepQuality.values,
        map['depth_quality'] as String?,
        RepQuality.unavailable,
      ),
      upperBodyQuality: enumByName(
        RepQuality.values,
        map['upper_body_quality'] as String?,
        RepQuality.unavailable,
      ),
      kneeAlignmentQuality: enumByName(
        RepQuality.values,
        map['knee_alignment_quality'] as String?,
        RepQuality.unavailable,
      ),
    );
  }
}

T? _optionalEnumByName<T extends Enum>(Iterable<T> values, String? name) {
  if (name == null) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}
