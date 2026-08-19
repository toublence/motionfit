import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/diagnostics/motionfit_debug_session.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/pose_frame.dart'
    as plank_pose;
import 'package:motionfit_squat/features/plank/workout/domain/models/calibration_profile.dart'
    as plank_calibration;
import 'package:motionfit_squat/features/plank/workout/domain/services/coach_engine.dart'
    as plank_coach;
import 'package:motionfit_squat/features/plank/workout/domain/services/form_analyzer.dart'
    as plank_form;
import 'package:motionfit_squat/features/plank/workout/domain/services/rep_detector.dart'
    as plank_detector;
import 'package:motionfit_squat/features/pushup/domain/models/pose_frame.dart'
    as pushup_pose;
import 'package:motionfit_squat/features/pushup/domain/models/calibration_profile.dart'
    as pushup_calibration;
import 'package:motionfit_squat/features/pushup/domain/services/coach_engine.dart'
    as pushup_coach;
import 'package:motionfit_squat/features/pushup/domain/services/form_analyzer.dart'
    as pushup_form;
import 'package:motionfit_squat/features/pushup/domain/services/rep_detector.dart'
    as pushup_detector;
import 'package:motionfit_squat/features/squat/domain/models/pose_frame.dart'
    as squat_pose;
import 'package:motionfit_squat/features/squat/domain/models/calibration_profile.dart'
    as squat_calibration;
import 'package:motionfit_squat/features/squat/domain/services/coach_engine.dart'
    as squat_coach;
import 'package:motionfit_squat/features/squat/domain/services/form_analyzer.dart'
    as squat_form;
import 'package:motionfit_squat/features/squat/domain/services/rep_detector.dart'
    as squat_detector;

const replayPath = String.fromEnvironment('MOTIONFIT_REPLAY_SESSION');

void main() {
  test('replays a saved MotionFit debug session', () async {
    if (replayPath.isEmpty) {
      debugPrint(
        'Set --dart-define=MOTIONFIT_REPLAY_SESSION=/absolute/session.json',
      );
      return;
    }
    final root =
        jsonDecode(await File(replayPath).readAsString())
            as Map<String, Object?>;
    final session = (root['session'] as Map).cast<String, Object?>();
    final frames = (root['frames'] as List)
        .cast<Map>()
        .map((frame) => frame.cast<String, Object?>())
        .toList(growable: false);
    final labels = <int, Map<String, Object?>>{
      for (final rep in (root['repResults'] as List).cast<Map>())
        (rep['repSequence'] as num).toInt(): rep.cast<String, Object?>(),
    };
    final output = switch (session['exercise']) {
      'squat' => _replaySquat(frames, labels),
      'pushup' => _replayPushup(frames, labels),
      'plank' => _replayPlank(frames, labels),
      final exercise => throw StateError('Unsupported exercise: $exercise'),
    };
    debugPrint(output.join('\n'));
    expect(output, isNotEmpty);
  });
}

List<String> _replaySquat(
  List<Map<String, Object?>> frames,
  Map<int, Map<String, Object?>> labels,
) {
  final calibration = _calibrationMap(frames);
  final detector = squat_detector.SquatRepDetector(
    initialCalibration: calibration == null
        ? null
        : squat_calibration.CalibrationProfile.fromMap(calibration),
  );
  const analyzer = squat_form.SquatFormAnalyzer();
  final policy = squat_coach.CoachPolicy();
  final output = <String>[];
  for (final saved in frames) {
    final frame = squat_pose.PoseFrame.fromMap(
      (saved['poseFrame'] as Map).cast<Object?, Object?>(),
    );
    for (final event in detector.addFrame(frame)) {
      final trace = event.trace;
      if (trace == null) continue;
      final analysis = analyzer.analyze(trace);
      final decision = policy.evaluate(analysis);
      output.add(
        _format(
          trace.repSequence,
          analysis.detectedIssues.map((issue) => issue.name).toList(),
          analysis.primaryIssue?.name,
          decision.selectedIssue != null,
          decision.rejectReason?.name,
          labels[trace.repSequence],
        ),
      );
    }
  }
  return output;
}

List<String> _replayPushup(
  List<Map<String, Object?>> frames,
  Map<int, Map<String, Object?>> labels,
) {
  final calibration = _calibrationMap(frames);
  final detector = pushup_detector.PushupRepDetector(
    initialCalibration: calibration == null
        ? null
        : pushup_calibration.CalibrationProfile.fromMap(calibration),
  );
  const analyzer = pushup_form.PushupFormAnalyzer();
  final policy = pushup_coach.CoachPolicy();
  final output = <String>[];
  for (final saved in frames) {
    final frame = pushup_pose.PoseFrame.fromMap(
      (saved['poseFrame'] as Map).cast<Object?, Object?>(),
    );
    for (final event in detector.addFrame(frame)) {
      final trace = event.trace;
      if (trace == null) continue;
      final analysis = analyzer.analyze(trace);
      final decision = policy.evaluate(analysis);
      output.add(
        _format(
          trace.repSequence,
          analysis.detectedIssues.map((issue) => issue.name).toList(),
          analysis.primaryIssue?.name,
          decision.selectedIssue != null,
          decision.rejectReason?.name,
          labels[trace.repSequence],
        ),
      );
    }
  }
  return output;
}

List<String> _replayPlank(
  List<Map<String, Object?>> frames,
  Map<int, Map<String, Object?>> labels,
) {
  final calibration = _calibrationMap(frames);
  final detector = plank_detector.SquatRepDetector(
    initialCalibration: calibration == null
        ? null
        : plank_calibration.CalibrationProfile.fromMap(calibration),
  );
  const analyzer = plank_form.SquatFormAnalyzer();
  final policy = plank_coach.CoachPolicy();
  final output = <String>[];
  for (final saved in frames) {
    final frame = plank_pose.PoseFrame.fromMap(
      (saved['poseFrame'] as Map).cast<Object?, Object?>(),
    );
    for (final event in detector.addFrame(frame)) {
      final trace = event.trace;
      if (trace == null) continue;
      final analysis = analyzer.analyze(trace);
      final decision = policy.evaluate(analysis);
      output.add(
        _format(
          trace.repSequence,
          analysis.detectedIssues.map((issue) => issue.name).toList(),
          analysis.primaryIssue?.name,
          decision.selectedIssue != null,
          decision.rejectReason?.name,
          labels[trace.repSequence],
        ),
      );
    }
  }
  return output;
}

String _format(
  int rep,
  List<String> issues,
  String? primary,
  bool accepted,
  String? rejectReason,
  Map<String, Object?>? manual,
) {
  final comparison = compareManualAndMotionFit(
    manualLabel: manual?['manualLabel'] as String?,
    manualIssue: manual?['manualIssue'] as String?,
    detectedIssues: issues,
  );
  return 'Rep $rep\n'
      'detectedIssues: ${issues.isEmpty ? 'GOOD' : issues.join(', ')}\n'
      'primaryIssue: ${primary ?? 'none'}\n'
      'coachDecision: ${accepted ? 'accepted' : 'rejected'}\n'
      'reason: ${rejectReason ?? 'none'}\n'
      'manual: ${manual?['manualLabel'] ?? 'unlabeled'} / '
      '${manual?['manualIssue'] ?? 'none'}\n'
      'comparison: ${comparison.name.toUpperCase()}';
}

Map<Object?, Object?>? _calibrationMap(List<Map<String, Object?>> frames) {
  if (frames.isEmpty) return null;
  final derived = frames.first['derivedFeatures'];
  if (derived is! Map) return null;
  final calibration = derived['calibration'];
  if (calibration is Map) return calibration.cast<Object?, Object?>();
  return null;
}
