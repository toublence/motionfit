import 'dart:convert';
import 'dart:io';

import 'package:motionfit_squat/features/squat/domain/models/pose_frame.dart'
    as squat;
import 'package:motionfit_squat/features/squat/domain/services/rep_detector.dart'
    as sd;
import 'package:motionfit_squat/features/squat/domain/services/form_analyzer.dart'
    as sa;
import 'package:motionfit_squat/features/pushup/domain/models/pose_frame.dart'
    as pushup;
import 'package:motionfit_squat/features/pushup/domain/services/rep_detector.dart'
    as pd;
import 'package:motionfit_squat/features/pushup/domain/services/form_analyzer.dart'
    as pa;
import 'package:motionfit_squat/features/plank/workout/domain/models/pose_frame.dart'
    as plank;
import 'package:motionfit_squat/features/plank/workout/domain/services/rep_detector.dart'
    as hd;
import 'package:motionfit_squat/features/plank/workout/domain/services/form_analyzer.dart'
    as ha;

// Replays every real iOS inference frame through unchanged production detectors.
// No injected calibration, invented frames, end padding or threshold overrides.
void main(List<String> arguments) {
  if (arguments.length != 2) {
    throw ArgumentError(
      'Usage: evaluate_replays.dart <native outputs> <output.json>',
    );
  }
  final directory = Directory(arguments[0]);
  final result = <Map<String, Object?>>[];
  for (final file in directory.listSync().whereType<File>()) {
    if ((!file.path.endsWith('.json') && !file.path.endsWith('.json.gz')) ||
        file.path.endsWith('summary.json')) {
      continue;
    }
    final source = file.path.endsWith('.gz')
        ? utf8.decode(gzip.decode(file.readAsBytesSync()))
        : file.readAsStringSync();
    final root = jsonDecode(source) as Map;
    if (root['frames'] is! List) continue;
    final metadata = Map<String, Object?>.from(root['metadata'] as Map);
    final exercise = metadata['exercise'] as String;
    final dynamic detector = switch (exercise) {
      'squat' => sd.SquatRepDetector(),
      'pushup' => pd.PushupRepDetector(),
      'plank' => hd.SquatRepDetector(),
      _ => throw StateError('Unsupported exercise: $exercise'),
    };
    final dynamic analyzer = switch (exercise) {
      'squat' => sa.SquatFormAnalyzer(),
      'pushup' => pa.PushupFormAnalyzer(),
      'plank' => ha.SquatFormAnalyzer(),
      _ => throw StateError(exercise),
    };
    final events = <Map<String, Object?>>[];
    final states = <String, int>{};
    final phases = <String, int>{};
    final feedback = <String, int>{};
    final metrics = <Map<String, Object?>>[];
    final latencies = <int>[];
    var lastTimestamp = -1;
    var invalid = 0;
    var finiteFailures = 0;
    var maxCalibrationProgress = 0.0;
    for (final raw in root['frames'] as List) {
      final map = Map<String, Object?>.from(raw as Map);
      final timestamp = map['timestampUs'] as int;
      if (timestamp <= lastTimestamp) invalid++;
      lastTimestamp = timestamp;
      List<Map<String, double>> unpack(String key) {
        final flat = (map[key] as List).cast<num>();
        if (flat.length != 165) throw StateError('Expected 33 x 5 $key');
        return List.generate(33, (i) {
          final values = flat.sublist(i * 5, i * 5 + 5);
          finiteFailures += values.where((n) => !n.isFinite).length;
          return Map.fromIterables([
            'x',
            'y',
            'z',
            'visibility',
            'presence',
          ], values.map((n) => n.toDouble()));
        });
      }

      final converted = <Object?, Object?>{
        ...map,
        'sequenceId': map['frameId'],
        'peopleCount': map['personCount'],
        'landmarks': unpack('normalizedLandmarks'),
        'worldLandmarks': unpack('worldLandmarks'),
      };
      final dynamic frame = switch (exercise) {
        'squat' => squat.PoseFrame.fromMap(converted),
        'pushup' => pushup.PoseFrame.fromMap(converted),
        'plank' => plank.PoseFrame.fromMap(converted),
        _ => throw StateError(exercise),
      };
      states.update(
        map['trackingState'] as String,
        (n) => n + 1,
        ifAbsent: () => 1,
      );
      latencies.add(map['inferenceLatencyMilliseconds'] as int);
      for (final dynamic event in detector.addFrame(frame) as List) {
        final entry = <String, Object?>{
          'type': (event.type as Enum).name,
          'timestampSeconds': event.timestampUs / 1000000,
        };
        if (event.calibration != null) {
          entry['calibration'] = event.calibration.toMap();
        }
        if (event.trace != null) {
          final dynamic analysis = analyzer.analyze(event.trace);
          entry.addAll({
            'repSequence': analysis.repSequence,
            'startedSeconds': event.trace.startedAtUs / 1000000,
            'completedSeconds': event.trace.completedAtUs / 1000000,
            'score': analysis.overallScore,
            'coverage': analysis.coverage,
            'confidence': analysis.confidence,
            'issues': [
              for (final dynamic issue in analysis.detectedIssues)
                (issue as Enum).name,
            ],
            'primaryIssue': (analysis.primaryIssue as Enum?)?.name,
          });
        }
        events.add(entry);
      }
      final dynamic snapshot = detector.snapshot;
      if (snapshot.calibration == null &&
          snapshot.calibrationProgress > maxCalibrationProgress) {
        maxCalibrationProgress = snapshot.calibrationProgress as double;
      }
      phases.update(
        (snapshot.phase as Enum).name,
        (n) => n + 1,
        ifAbsent: () => 1,
      );
      feedback.update(
        (snapshot.calibrationFeedback as Enum).name,
        (n) => n + 1,
        ifAbsent: () => 1,
      );
      final dynamic value = snapshot.lastMetrics;
      if (value != null) {
        metrics.add({
          'timestampSeconds': timestamp / 1000000,
          'measurementTimestampSeconds': value.timestampUs / 1000000,
          'calibrationProgress': snapshot.calibrationProgress,
          'calibrationFeedback': (snapshot.calibrationFeedback as Enum).name,
          'phase': (snapshot.phase as Enum).name,
          'count': snapshot.count,
          'hipAngle': value.hipAngle,
          'kneeAngle': value.kneeAngle,
          'torsoLeanDegrees': value.torsoLeanDegrees,
          'confidence': value.confidence,
          'cameraAngle': (value.cameraAngle as Enum).name,
        });
      }
    }
    latencies.sort();
    final dynamic snapshot = detector.snapshot;
    result.add({
      ...metadata,
      'count': snapshot.count,
      'countUnit': exercise == 'plank'
          ? 'one_second_checkpoints'
          : 'repetitions',
      'calibrated': snapshot.calibration != null,
      'calibrationRetries': snapshot.calibrationRetries,
      'maxUnfinishedCalibrationProgress': maxCalibrationProgress,
      'finalPhase': (snapshot.phase as Enum).name,
      'trackingFrames': states,
      'phaseFrames': phases,
      'calibrationFeedbackFrames': feedback,
      'nonIncreasingTimestamps': invalid,
      'nonFiniteLandmarkValues': finiteFailures,
      'latencyMedianMs': latencies.isEmpty
          ? null
          : latencies[latencies.length ~/ 2],
      'latencyP95Ms': latencies.isEmpty
          ? null
          : latencies[((latencies.length - 1) * .95).round()],
      'events': events,
      'metrics': metrics,
    });
  }
  result.sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
  File(arguments[1]).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'source':
          'real iOS MediaPipe video inference; production Dart detectors on host',
      'thresholds': 'production defaults',
      'calibration': 'production automatic calibration only',
      'cases': result,
    }),
  );
  for (final item in result) {
    stdout.writeln(
      '${item['id']}: calibrated=${item['calibrated']}, count=${item['count']}, '
      'tracking=${item['trackingFrames']}, latencyP95=${item['latencyP95Ms']}ms',
    );
  }
}
