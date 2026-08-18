import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:motionfit_squat/features/squat/domain/models/calibration_profile.dart';
import 'package:motionfit_squat/features/squat/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/services/rep_detector.dart';

abstract final class CorpusQualificationPolicy {
  static const targetAccuracy = 0.97;
  static const minimumClips = 100;
  static const minimumSubjects = 10;
  static const minimumExpectedReps = 500;
  static const minimumNegativeClips = 20;
}

class CorpusCaseResult {
  const CorpusCaseResult({
    required this.id,
    required this.expectedReps,
    required this.observedReps,
  });

  final String id;
  final int expectedReps;
  final int observedReps;

  int get matchedReps => math.min(expectedReps, observedReps);
  int get absoluteError => (expectedReps - observedReps).abs();
  bool get exact => expectedReps == observedReps;

  Map<String, Object?> toJson() => {
    'id': id,
    'expectedReps': expectedReps,
    'observedReps': observedReps,
    'absoluteError': absoluteError,
    'exact': exact,
  };
}

class CorpusReport {
  const CorpusReport({
    required this.corpusId,
    required this.provenance,
    required this.humanLabeled,
    required this.subjectCount,
    required this.caseResults,
    required this.failedEligibilityChecks,
  });

  final String corpusId;
  final String provenance;
  final bool humanLabeled;
  final int subjectCount;
  final List<CorpusCaseResult> caseResults;
  final List<String> failedEligibilityChecks;

  int get clipCount => caseResults.length;
  int get negativeClipCount =>
      caseResults.where((result) => result.expectedReps == 0).length;
  int get expectedReps =>
      caseResults.fold(0, (total, result) => total + result.expectedReps);
  int get observedReps =>
      caseResults.fold(0, (total, result) => total + result.observedReps);
  int get matchedReps =>
      caseResults.fold(0, (total, result) => total + result.matchedReps);
  int get exactCases => caseResults.where((result) => result.exact).length;
  int get totalAbsoluteError =>
      caseResults.fold(0, (total, result) => total + result.absoluteError);

  double get exactCountAccuracy => clipCount == 0 ? 0 : exactCases / clipCount;
  double get countPrecision => observedReps == 0
      ? expectedReps == 0
            ? 1
            : 0
      : matchedReps / observedReps;
  double get countRecall => expectedReps == 0
      ? observedReps == 0
            ? 1
            : 0
      : matchedReps / expectedReps;
  double get countF1 => countPrecision + countRecall == 0
      ? 0
      : 2 * countPrecision * countRecall / (countPrecision + countRecall);
  double get meanAbsoluteError =>
      clipCount == 0 ? 0 : totalAbsoluteError / clipCount;

  bool get corpusEligible => failedEligibilityChecks.isEmpty;
  bool get targetMetricsMet =>
      exactCountAccuracy >= CorpusQualificationPolicy.targetAccuracy &&
      countPrecision >= CorpusQualificationPolicy.targetAccuracy &&
      countRecall >= CorpusQualificationPolicy.targetAccuracy;

  /// This can only become true for a sufficiently large, human-labeled,
  /// real-recorded corpus. Synthetic smoke fixtures are always ineligible.
  bool get target97Validated => corpusEligible && targetMetricsMet;

  String get status => !corpusEligible
      ? 'INELIGIBLE_CORPUS'
      : target97Validated
      ? 'TARGET_VALIDATED'
      : 'BELOW_TARGET';

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'corpus': {
      'id': corpusId,
      'provenance': provenance,
      'humanLabeled': humanLabeled,
      'subjectCount': subjectCount,
      'clipCount': clipCount,
      'negativeClipCount': negativeClipCount,
      'expectedReps': expectedReps,
    },
    'metrics': {
      'observedReps': observedReps,
      'exactCountAccuracy': exactCountAccuracy,
      'countPrecision': countPrecision,
      'countRecall': countRecall,
      'countF1': countF1,
      'meanAbsoluteError': meanAbsoluteError,
    },
    'qualification': {
      'target': CorpusQualificationPolicy.targetAccuracy,
      'corpusEligible': corpusEligible,
      'targetMetricsMet': targetMetricsMet,
      'target97Validated': target97Validated,
      'status': status,
      'failedEligibilityChecks': failedEligibilityChecks,
    },
    'cases': caseResults.map((result) => result.toJson()).toList(),
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String toMarkdown() {
    final accuracyPercent = (exactCountAccuracy * 100).toStringAsFixed(2);
    final precisionPercent = (countPrecision * 100).toStringAsFixed(2);
    final recallPercent = (countRecall * 100).toStringAsFixed(2);
    final buffer = StringBuffer()
      ..writeln('# MotionFit corpus evaluation')
      ..writeln()
      ..writeln('- Corpus: `$corpusId`')
      ..writeln('- Provenance: `$provenance`')
      ..writeln('- Human labeled: ${humanLabeled ? 'yes' : 'no'}')
      ..writeln('- Clips / subjects: $clipCount / $subjectCount')
      ..writeln('- Expected / observed reps: $expectedReps / $observedReps')
      ..writeln('- Exact-count accuracy: $accuracyPercent%')
      ..writeln(
        '- Count precision / recall: $precisionPercent% / $recallPercent%',
      )
      ..writeln(
        '- Mean absolute error: ${meanAbsoluteError.toStringAsFixed(3)}',
      )
      ..writeln()
      ..writeln('## Qualification')
      ..writeln()
      ..writeln('- Status: `$status`')
      ..writeln('- 97% target validated: ${target97Validated ? 'YES' : 'NO'}');
    if (failedEligibilityChecks.isNotEmpty) {
      buffer
        ..writeln('- Failed eligibility checks:')
        ..writeln();
      for (final check in failedEligibilityChecks) {
        buffer.writeln('  - `$check`');
      }
    }
    buffer
      ..writeln()
      ..writeln(
        'Synthetic or unlabeled fixtures are smoke tests only and cannot '
        'validate the 97% production target.',
      );
    return buffer.toString();
  }
}

Future<CorpusReport> evaluateCorpusManifest(String manifestPath) async {
  final manifestFile = File(manifestPath).absolute;
  final decoded = jsonDecode(await manifestFile.readAsString());
  if (decoded is! Map) {
    throw const FormatException('Corpus manifest root must be an object.');
  }
  final manifest = decoded.cast<String, Object?>();
  final metadata = _requiredMap(manifest, 'corpus');
  final rawCases = manifest['cases'];
  if (rawCases is! List) {
    throw const FormatException('Corpus manifest cases must be an array.');
  }

  final results = <CorpusCaseResult>[];
  for (final rawCase in rawCases) {
    if (rawCase is! Map) {
      throw const FormatException('Every corpus case must be an object.');
    }
    final item = rawCase.cast<String, Object?>();
    final id = _requiredString(item, 'id');
    final replayPath = _requiredString(item, 'replay');
    final expectedReps = _requiredNonNegativeInt(item, 'expectedReps');
    final replayFile = File.fromUri(
      manifestFile.parent.uri.resolve(replayPath),
    );
    final replayRoot = jsonDecode(await replayFile.readAsString());
    _validateLandmarkOnlyReplay(replayRoot, id);
    final frames = _parseFrames(replayRoot);
    final detector = SquatRepDetector(
      initialCalibration: _parseCalibration(item['calibration']),
    );
    for (final frame in frames) {
      detector.addFrame(frame);
    }
    results.add(
      CorpusCaseResult(
        id: id,
        expectedReps: expectedReps,
        observedReps: detector.snapshot.count,
      ),
    );
  }

  final provenance = _requiredString(metadata, 'provenance');
  final humanLabeled = metadata['humanLabeled'] == true;
  final subjectCount = _requiredNonNegativeInt(metadata, 'subjectCount');
  final expectedRepCount = results.fold<int>(
    0,
    (total, result) => total + result.expectedReps,
  );
  final negativeClips = results
      .where((result) => result.expectedReps == 0)
      .length;
  final failed = <String>[
    if (!humanLabeled || provenance != 'real_recorded_landmarks')
      'human_labeled_real_corpus',
    if (results.length < CorpusQualificationPolicy.minimumClips)
      'minimum_${CorpusQualificationPolicy.minimumClips}_clips',
    if (subjectCount < CorpusQualificationPolicy.minimumSubjects)
      'minimum_${CorpusQualificationPolicy.minimumSubjects}_subjects',
    if (expectedRepCount < CorpusQualificationPolicy.minimumExpectedReps)
      'minimum_${CorpusQualificationPolicy.minimumExpectedReps}_expected_reps',
    if (negativeClips < CorpusQualificationPolicy.minimumNegativeClips)
      'minimum_${CorpusQualificationPolicy.minimumNegativeClips}_negative_clips',
  ];

  return CorpusReport(
    corpusId: _requiredString(metadata, 'id'),
    provenance: provenance,
    humanLabeled: humanLabeled,
    subjectCount: subjectCount,
    caseResults: List.unmodifiable(results),
    failedEligibilityChecks: List.unmodifiable(failed),
  );
}

List<PoseFrame> _parseFrames(Object? replayRoot) {
  final rawFrames = replayRoot is Map ? replayRoot['frames'] : replayRoot;
  if (rawFrames is! List) {
    throw const FormatException('Replay frames must be an array.');
  }
  return rawFrames
      .map((rawFrame) {
        if (rawFrame is! Map) {
          throw const FormatException('Every replay frame must be an object.');
        }
        return PoseFrame.fromMap(rawFrame.cast<Object?, Object?>());
      })
      .toList(growable: false);
}

CalibrationProfile? _parseCalibration(Object? raw) {
  if (raw == null) return null;
  if (raw is! Map) {
    throw const FormatException('Calibration must be an object.');
  }
  return CalibrationProfile(
    baselineKneeAngle: _requiredNumber(raw, 'baselineKneeAngle'),
    baselineHipAngle: _requiredNumber(raw, 'baselineHipAngle'),
    baselineHipY: _requiredNumber(raw, 'baselineHipY'),
    baselineShoulderY: _requiredNumber(raw, 'baselineShoulderY'),
    bodyScale: _requiredNumber(raw, 'bodyScale'),
    motionNoiseMad: _requiredNumber(raw, 'motionNoiseMad'),
    cameraAngle: enumByName(
      CameraAngle.values,
      raw['cameraAngle'] as String?,
      CameraAngle.uncertain,
    ),
    calibratedAtUs: (raw['calibratedAtUs'] as num? ?? 0).toInt(),
  );
}

void _validateLandmarkOnlyReplay(Object? value, String caseId) {
  if (_hasForbiddenImagePayload(value)) {
    throw FormatException(
      'Replay `$caseId` contains a forbidden image/pixel payload.',
    );
  }
  if (value is Map && value['privacy'] is Map) {
    final privacy = value['privacy'] as Map;
    if (privacy['containsImages'] == true) {
      throw FormatException('Replay `$caseId` declares image content.');
    }
  }
}

bool _hasForbiddenImagePayload(Object? value) {
  const forbiddenKeys = {
    'image',
    'imagebytes',
    'pixels',
    'jpeg',
    'jpg',
    'png',
    'base64',
    'camera_frame',
  };
  if (value is Map) {
    for (final entry in value.entries) {
      if (forbiddenKeys.contains(entry.key.toString().toLowerCase())) {
        return true;
      }
      if (_hasForbiddenImagePayload(entry.value)) return true;
    }
  } else if (value is Iterable) {
    return value.any(_hasForbiddenImagePayload);
  }
  return false;
}

Map<String, Object?> _requiredMap(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! Map) throw FormatException('`$key` must be an object.');
  return value.cast<String, Object?>();
}

String _requiredString(Map map, String key) {
  final value = map[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('`$key` must be a non-empty string.');
  }
  return value;
}

int _requiredNonNegativeInt(Map map, String key) {
  final value = map[key];
  if (value is! num || value.toInt() != value || value < 0) {
    throw FormatException('`$key` must be a non-negative integer.');
  }
  return value.toInt();
}

double _requiredNumber(Map map, String key) {
  final value = map[key];
  if (value is! num) throw FormatException('`$key` must be a number.');
  return value.toDouble();
}
