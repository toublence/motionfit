import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

enum DebugManualLabel { good, borderline, bad }

enum DebugComparisonResult {
  truePositive,
  trueNegative,
  falsePositive,
  falseNegative,
  borderline,
  unlabeled,
}

/// Development-only, append-only trace for one workout session.
///
/// Callers pass plain maps so this recorder stays independent from the three
/// exercise-specific domain model trees. In release/profile builds every
/// method is a no-op and no file is created.
class MotionFitDebugSession {
  MotionFitDebugSession({
    required this.exercise,
    required this.sessionId,
    DateTime? startedAt,
  }) : startTime = startedAt ?? DateTime.now();

  static const enabled =
      kDebugMode &&
      bool.fromEnvironment('MOTIONFIT_DEBUG_LOGGING', defaultValue: true);

  final String exercise;
  final String sessionId;
  final DateTime startTime;
  DateTime? _endTime;
  bool _saved = false;
  String? _appVersion;
  String? _lastSavedPath;

  final List<Map<String, Object?>> _frames = [];
  final List<Map<String, Object?>> _detectorTransitions = [];
  final List<Map<String, Object?>> _repResults = [];
  final List<Map<String, Object?>> _analyzerResults = [];
  final List<Map<String, Object?>> _coachDecisions = [];
  final List<Map<String, Object?>> _ttsEvents = [];

  String? get lastSavedPath => _lastSavedPath;

  void recordFrame({
    required Map<String, Object?> poseFrame,
    required String phase,
    required String trackingState,
    required double landmarkConfidence,
    required Map<String, Object?> features,
  }) {
    if (!enabled || _saved) return;
    _frames.add({
      'timestamp': poseFrame['timestampUs'],
      'exercise': exercise,
      'phase': phase,
      'trackingState': trackingState,
      'landmarkConfidence': landmarkConfidence,
      'kneeAngle': features['kneeAngle'],
      'hipAngle': features['hipAngle'],
      'elbowAngle': features['elbowAngle'],
      'torsoAngle': features['torsoAngle'],
      'bodyLineAngle': features['bodyLineAngle'],
      'hipDrop': features['hipDrop'],
      'shoulderDrop': features['shoulderDrop'],
      'velocity': features['velocity'],
      'derivedFeatures': features,
      // Raw landmarks are stored for deterministic feature extraction replay,
      // but are deliberately never printed frame-by-frame.
      'poseFrame': poseFrame,
    });
  }

  void recordDetectorTransition({
    required int timestampUs,
    required String from,
    required String to,
    required String reason,
    required Map<String, Object?> values,
    bool? isGoodPlank,
    String? resetReason,
  }) {
    if (!enabled || _saved) return;
    final event = <String, Object?>{
      'timestamp': timestampUs,
      'from': from,
      'to': to,
      'reason': reason,
      'values': values,
      'isGoodPlank': ?isGoodPlank,
      'resetReason': ?resetReason,
    };
    _detectorTransitions.add(event);
    debugPrint(
      '[${exercise.toUpperCase()}][Detector] $from -> $to reason=$reason values=${jsonEncode(values)}',
    );
  }

  void recordRep({
    required int repSequence,
    required int startedAtUs,
    required int completedAtUs,
    required double confidence,
  }) {
    if (!enabled || _saved) return;
    _repResults.add({
      'repSequence': repSequence,
      'startedAt': startedAtUs,
      'completedAt': completedAtUs,
      'confidence': confidence,
      'manualLabel': null,
      'manualIssue': null,
    });
  }

  void recordAnalyzer({
    required int repSequence,
    required List<Map<String, Object?>> metrics,
    required List<String> detectedIssues,
    required String? primaryIssue,
    required double confidence,
  }) {
    if (!enabled || _saved) return;
    _analyzerResults.add({
      'repSequence': repSequence,
      'metrics': metrics,
      'detectedIssues': detectedIssues,
      'primaryIssue': primaryIssue,
      'confidence': confidence,
    });
    debugPrint(
      '[${exercise.toUpperCase()}][REP $repSequence][Analyzer] '
      'issues=$detectedIssues primary=${primaryIssue ?? 'none'}',
    );
  }

  void recordCoachDecision({
    required int repSequence,
    required String? issue,
    String? selectedIssue,
    required bool coachCandidate,
    required bool spoken,
    required String? rejectReason,
  }) {
    if (!enabled || _saved) return;
    _coachDecisions.add({
      'repSequence': repSequence,
      'issue': issue,
      'candidateIssue': issue,
      'selectedIssue': selectedIssue,
      'coachCandidate': coachCandidate,
      'spoken': spoken,
      'rejectReason': rejectReason,
    });
    debugPrint(
      '[${exercise.toUpperCase()}][REP $repSequence][CoachPolicy] '
      '${issue == null
          ? 'NO_CANDIDATE'
          : rejectReason == null
          ? 'ACCEPTED'
          : 'REJECTED'} '
      'issue=${issue ?? 'none'} reason=${rejectReason ?? 'none'}',
    );
  }

  void recordTtsEvent({
    required String coachMessageId,
    required String event,
    required String type,
    required String message,
    required String deduplicationKey,
    int? repSequence,
    String? reason,
  }) {
    if (!enabled || _saved) return;
    if (type == 'form' && repSequence != null) {
      for (var index = _coachDecisions.length - 1; index >= 0; index--) {
        final decision = _coachDecisions[index];
        if (decision['repSequence'] != repSequence) continue;
        if (event == 'spoken') decision['spoken'] = true;
        if ((event == 'cancelled' || event == 'failed') &&
            decision['rejectReason'] == null) {
          decision['rejectReason'] = reason ?? event;
        }
        break;
      }
    }
    _ttsEvents.add({
      'timestamp': DateTime.now().toIso8601String(),
      'coachMessageId': coachMessageId,
      'event': event,
      'type': type,
      'issue': deduplicationKey.startsWith('form_')
          ? deduplicationKey.substring(5)
          : null,
      'message': message,
      'deduplicationKey': deduplicationKey,
      'repSequence': repSequence,
      'reason': reason,
    });
    debugPrint(
      '[${exercise.toUpperCase()}][TTS][$coachMessageId] $event'
      '${reason == null ? '' : ' reason=$reason'}',
    );
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'session': {
      'id': sessionId,
      'exercise': exercise,
      'startTime': startTime.toIso8601String(),
      'endTime': _endTime?.toIso8601String(),
      'appVersion': _appVersion,
      'device': {
        'operatingSystem': Platform.operatingSystem,
        'operatingSystemVersion': Platform.operatingSystemVersion,
        'locale': Platform.localeName,
      },
      'manualLabel': null,
      'manualIssue': null,
    },
    'frames': _frames,
    'detectorTransitions': _detectorTransitions,
    'repResults': _repResults,
    'analyzerResults': _analyzerResults,
    'coachDecisions': _coachDecisions,
    'ttsEvents': _ttsEvents,
  };

  Future<String?> finishAndSave({DateTime? endedAt}) async {
    if (!enabled || _saved) return _lastSavedPath;
    _endTime = endedAt ?? DateTime.now();
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = '${info.version}+${info.buildNumber}';
      final documents = Directory(await getDatabasesPath());
      final directory = Directory(
        path.join(documents.path, 'motionfit_debug_sessions'),
      );
      await directory.create(recursive: true);
      final safeTime = startTime
          .toUtc()
          .toIso8601String()
          .replaceAll(RegExp(r'[^0-9]'), '')
          .substring(0, 14);
      final file = File(
        path.join(directory.path, 'session_${safeTime}_$sessionId.json'),
      );
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(toJson()),
        flush: true,
      );
      _saved = true;
      _lastSavedPath = file.path;
      debugPrint('[MotionFitDebug] saved ${file.path}');
      return file.path;
    } on Object catch (error) {
      debugPrint('[MotionFitDebug] save failed: $error');
      return null;
    }
  }
}

DebugComparisonResult compareManualAndMotionFit({
  required String? manualLabel,
  required String? manualIssue,
  required List<String> detectedIssues,
}) {
  if (manualLabel == null) return DebugComparisonResult.unlabeled;
  if (manualLabel.toUpperCase() ==
      DebugManualLabel.borderline.name.toUpperCase()) {
    return DebugComparisonResult.borderline;
  }
  final motionFitBad = detectedIssues.isNotEmpty;
  final manualBad =
      manualLabel.toUpperCase() == DebugManualLabel.bad.name.toUpperCase();
  if (manualBad && !motionFitBad) return DebugComparisonResult.falseNegative;
  if (!manualBad && motionFitBad) return DebugComparisonResult.falsePositive;
  if (!manualBad) return DebugComparisonResult.trueNegative;
  if (manualIssue == null || manualIssue == 'none') {
    return DebugComparisonResult.truePositive;
  }
  return detectedIssues.contains(manualIssue)
      ? DebugComparisonResult.truePositive
      : DebugComparisonResult.falseNegative;
}
