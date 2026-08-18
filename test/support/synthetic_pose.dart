import 'dart:math' as math;

import 'package:motionfit_squat/features/squat/domain/models/calibration_profile.dart';
import 'package:motionfit_squat/features/squat/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

/// Deterministic landmark-only input for detector tests.
///
/// It intentionally contains no camera pixels or encoded image payloads.
class SyntheticPoseSequence {
  SyntheticPoseSequence({this.frameIntervalUs = 50000});

  final int frameIntervalUs;
  int _sequenceId = 0;
  int _timestampUs = 0;

  int get timestampUs => _timestampUs;

  CalibrationProfile get standingCalibration => CalibrationProfile(
    baselineKneeAngle: 180,
    baselineHipAngle: 180,
    baselineHipY: 0.45,
    baselineShoulderY: 0.20,
    bodyScale: math.sqrt(0.0001 + 0.5041),
    motionNoiseMad: 0,
    cameraAngle: CameraAngle.side,
    calibratedAtUs: 0,
    baselineLeftHeelLift: 0,
    baselineRightHeelLift: 0,
    baselineKneeAlignment: 1,
    baselineBalanceOffset: 0,
  );

  PoseFrame frame({
    double depth = 0,
    TrackingState trackingState = TrackingState.tracking,
    int peopleCount = 1,
    bool anklesVisible = true,
  }) {
    _sequenceId++;
    _timestampUs += frameIntervalUs;
    if ((trackingState != TrackingState.tracking &&
            trackingState != TrackingState.partialBody) ||
        peopleCount != 1) {
      return PoseFrame(
        sequenceId: _sequenceId,
        timestampUs: _timestampUs,
        landmarks: const [],
        worldLandmarks: const [],
        trackingState: trackingState,
        peopleCount: peopleCount,
        mirrored: false,
        rotationDegrees: 0,
        inputWidth: 720,
        inputHeight: 1280,
        inferenceLatencyMilliseconds: 12,
      );
    }

    final value = depth.clamp(0.0, 1.0);
    final landmarks = List<PoseLandmark>.generate(
      33,
      (_) => const PoseLandmark(
        x: 0.5,
        y: 0.5,
        z: 0,
        visibility: 0.99,
        presence: 0.99,
      ),
    );

    void set(
      int index,
      double startX,
      double startY,
      double endX,
      double endY,
    ) {
      landmarks[index] = PoseLandmark(
        x: _lerp(startX, endX, value),
        y: _lerp(startY, endY, value),
        z: 0,
        visibility: 0.99,
        presence: 0.99,
      );
    }

    set(PoseLandmarkIndex.leftShoulder, 0.49, 0.20, 0.35, 0.40);
    set(PoseLandmarkIndex.rightShoulder, 0.51, 0.20, 0.37, 0.40);
    set(PoseLandmarkIndex.leftHip, 0.50, 0.45, 0.43, 0.63);
    set(PoseLandmarkIndex.rightHip, 0.52, 0.45, 0.45, 0.63);
    set(PoseLandmarkIndex.leftKnee, 0.50, 0.68, 0.62, 0.73);
    set(PoseLandmarkIndex.rightKnee, 0.52, 0.68, 0.64, 0.73);
    set(PoseLandmarkIndex.leftAnkle, 0.50, 0.91, 0.50, 0.91);
    set(PoseLandmarkIndex.rightAnkle, 0.52, 0.91, 0.52, 0.91);
    set(PoseLandmarkIndex.leftHeel, 0.49, 0.93, 0.49, 0.93);
    set(PoseLandmarkIndex.rightHeel, 0.51, 0.93, 0.51, 0.93);
    set(PoseLandmarkIndex.leftFootIndex, 0.55, 0.93, 0.55, 0.93);
    set(PoseLandmarkIndex.rightFootIndex, 0.57, 0.93, 0.57, 0.93);
    if (!anklesVisible) {
      for (final index in const [27, 28, 29, 30, 31, 32]) {
        final point = landmarks[index];
        landmarks[index] = PoseLandmark(
          x: point.x,
          y: point.y,
          z: point.z,
          visibility: 0.05,
          presence: 0.05,
        );
      }
    }

    return PoseFrame(
      sequenceId: _sequenceId,
      timestampUs: _timestampUs,
      landmarks: List.unmodifiable(landmarks),
      worldLandmarks: List.unmodifiable(landmarks),
      trackingState: trackingState,
      peopleCount: peopleCount,
      mirrored: false,
      rotationDegrees: 0,
      inputWidth: 720,
      inputHeight: 1280,
      inferenceLatencyMilliseconds: 12,
    );
  }

  List<PoseFrame> hold(
    double depth,
    int frameCount, {
    bool anklesVisible = true,
  }) => List.generate(
    frameCount,
    (_) => frame(
      depth: depth,
      trackingState: anklesVisible
          ? TrackingState.tracking
          : TrackingState.partialBody,
      anklesVisible: anklesVisible,
    ),
    growable: false,
  );

  List<PoseFrame> ramp(
    double from,
    double to,
    int frameCount, {
    bool anklesVisible = true,
  }) => List.generate(
    frameCount,
    (index) => frame(
      depth: _lerp(from, to, (index + 1) / frameCount),
      trackingState: anklesVisible
          ? TrackingState.tracking
          : TrackingState.partialBody,
      anklesVisible: anklesVisible,
    ),
    growable: false,
  );

  List<PoseFrame> validRep({
    int recoveryFrames = 20,
    bool anklesVisible = true,
  }) => [
    ...hold(0, 6, anklesVisible: anklesVisible),
    ...ramp(0, 1, 24, anklesVisible: anklesVisible),
    ...hold(1, 12, anklesVisible: anklesVisible),
    ...ramp(1, 0, 24, anklesVisible: anklesVisible),
    ...hold(0, recoveryFrames, anklesVisible: anklesVisible),
  ];

  List<PoseFrame> trackingGap(int frameCount) => List.generate(
    frameCount,
    (_) => frame(trackingState: TrackingState.noPerson, peopleCount: 0),
    growable: false,
  );

  double _lerp(double start, double end, double t) => start + (end - start) * t;
}
