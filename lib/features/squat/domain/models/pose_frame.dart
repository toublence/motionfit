import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

class PoseLandmark {
  const PoseLandmark({
    required this.x,
    required this.y,
    required this.z,
    required this.visibility,
    required this.presence,
  });

  final double x;
  final double y;
  final double z;
  final double visibility;
  final double presence;

  double get confidence => visibility < presence ? visibility : presence;

  factory PoseLandmark.fromMap(Map<Object?, Object?> map) => PoseLandmark(
    x: (map['x']! as num).toDouble(),
    y: (map['y']! as num).toDouble(),
    z: (map['z']! as num).toDouble(),
    visibility: (map['visibility'] as num? ?? 0).toDouble(),
    presence: (map['presence'] as num? ?? 0).toDouble(),
  );

  Map<String, double> toMap() => {
    'x': x,
    'y': y,
    'z': z,
    'visibility': visibility,
    'presence': presence,
  };
}

abstract final class PoseLandmarkIndex {
  static const leftShoulder = 11;
  static const rightShoulder = 12;
  static const leftHip = 23;
  static const rightHip = 24;
  static const leftKnee = 25;
  static const rightKnee = 26;
  static const leftAnkle = 27;
  static const rightAnkle = 28;
  static const leftHeel = 29;
  static const rightHeel = 30;
  static const leftFootIndex = 31;
  static const rightFootIndex = 32;
}

class PoseFrame {
  const PoseFrame({
    required this.sequenceId,
    required this.timestampUs,
    required this.landmarks,
    required this.worldLandmarks,
    required this.trackingState,
    required this.peopleCount,
    required this.mirrored,
    required this.rotationDegrees,
    required this.inputWidth,
    required this.inputHeight,
    required this.inferenceLatencyMilliseconds,
    this.videoElapsedUs,
    this.previewTransform = const <double>[1, 0, 0, 0, 1, 0, 0, 0, 1],
    this.previewHandlesCropAndRotation = true,
  });

  final int sequenceId;
  final int timestampUs;
  final List<PoseLandmark> landmarks;
  final List<PoseLandmark> worldLandmarks;
  final TrackingState trackingState;
  final int peopleCount;
  final bool mirrored;
  final int rotationDegrees;
  final int inputWidth;
  final int inputHeight;
  final int inferenceLatencyMilliseconds;
  final int? videoElapsedUs;
  final List<double> previewTransform;
  final bool previewHandlesCropAndRotation;

  bool get hasCompletePose =>
      (trackingState == TrackingState.tracking ||
          trackingState == TrackingState.partialBody) &&
      peopleCount == 1 &&
      landmarks.length >= 33;

  PoseLandmark? landmark(int index) =>
      index >= 0 && index < landmarks.length ? landmarks[index] : null;

  PoseLandmark? worldLandmark(int index) =>
      index >= 0 && index < worldLandmarks.length
      ? worldLandmarks[index]
      : null;

  double get meanKeyConfidence {
    const sides = [
      [
        PoseLandmarkIndex.leftShoulder,
        PoseLandmarkIndex.leftHip,
        PoseLandmarkIndex.leftKnee,
      ],
      [
        PoseLandmarkIndex.rightShoulder,
        PoseLandmarkIndex.rightHip,
        PoseLandmarkIndex.rightKnee,
      ],
    ];
    var bestSide = 0.0;
    for (final side in sides) {
      var sideConfidence = 1.0;
      for (final index in side) {
        final point = landmark(index);
        if (point == null) {
          sideConfidence = 0;
          break;
        }
        if (point.confidence < sideConfidence) {
          sideConfidence = point.confidence;
        }
      }
      if (sideConfidence > bestSide) bestSide = sideConfidence;
    }
    return bestSide;
  }

  factory PoseFrame.fromMap(Map<Object?, Object?> map) {
    List<PoseLandmark> parseLandmarks(Object? value) => value is List
        ? value
              .whereType<Map>()
              .map(
                (item) => PoseLandmark.fromMap(item.cast<Object?, Object?>()),
              )
              .toList(growable: false)
        : const [];

    final stateName = map['trackingState'] as String?;
    return PoseFrame(
      sequenceId: (map['sequenceId'] as num? ?? 0).toInt(),
      timestampUs: (map['timestampUs'] as num? ?? 0).toInt(),
      landmarks: parseLandmarks(map['landmarks']),
      worldLandmarks: parseLandmarks(map['worldLandmarks']),
      trackingState: enumByName(
        TrackingState.values,
        stateName,
        TrackingState.lost,
      ),
      peopleCount: (map['peopleCount'] as num? ?? 0).toInt(),
      mirrored: map['mirrored'] as bool? ?? false,
      rotationDegrees: (map['rotationDegrees'] as num? ?? 0).toInt(),
      inputWidth: (map['inputWidth'] as num? ?? 0).toInt(),
      inputHeight: (map['inputHeight'] as num? ?? 0).toInt(),
      inferenceLatencyMilliseconds:
          (map['inferenceLatencyMilliseconds'] as num? ?? 0).toInt(),
      videoElapsedUs: (map['videoElapsedUs'] as num?)?.toInt(),
      previewTransform:
          (map['previewTransform'] as List?)
              ?.map((value) => (value as num).toDouble())
              .toList(growable: false) ??
          const <double>[1, 0, 0, 0, 1, 0, 0, 0, 1],
      previewHandlesCropAndRotation:
          map['previewHandlesCropAndRotation'] as bool? ?? true,
    );
  }

  Map<String, Object?> toMap() => {
    'sequenceId': sequenceId,
    'timestampUs': timestampUs,
    'landmarks': landmarks.map((point) => point.toMap()).toList(),
    'worldLandmarks': worldLandmarks.map((point) => point.toMap()).toList(),
    'trackingState': trackingState.name,
    'peopleCount': peopleCount,
    'mirrored': mirrored,
    'rotationDegrees': rotationDegrees,
    'inputWidth': inputWidth,
    'inputHeight': inputHeight,
    'inferenceLatencyMilliseconds': inferenceLatencyMilliseconds,
    'videoElapsedUs': videoElapsedUs,
    'previewTransform': previewTransform,
    'previewHandlesCropAndRotation': previewHandlesCropAndRotation,
  };
}
