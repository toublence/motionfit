import 'package:motionfit_squat/features/plank/workout/domain/models/calibration_profile.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/squat_metrics.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/plank/workout/domain/services/calibration_accumulator.dart';
import 'package:motionfit_squat/features/plank/workout/domain/services/squat_detection_config.dart';
import 'package:motionfit_squat/features/plank/workout/domain/services/squat_feature_extractor.dart';

enum RepEventType {
  calibrated,
  started,
  bottom,
  completed,
  shallowAttempt,
  trackingLost,
  ready,
}

class RepEvent {
  const RepEvent({
    required this.type,
    required this.timestampUs,
    this.trace,
    this.calibration,
    this.calibrationDurationUs,
    this.calibrationRetries,
    this.trackingLostDurationUs,
  });

  final RepEventType type;
  final int timestampUs;
  final RepMotionTrace? trace;
  final CalibrationProfile? calibration;
  final int? calibrationDurationUs;
  final int? calibrationRetries;
  final int? trackingLostDurationUs;
}

class RepDetectorSnapshot {
  const RepDetectorSnapshot({
    required this.phase,
    required this.count,
    required this.calibrationProgress,
    required this.calibrationElapsedUs,
    required this.calibrationRetries,
    required this.trackingState,
    required this.lastMetrics,
  });

  final SquatPhase phase;
  final int count;
  final double calibrationProgress;
  final int calibrationElapsedUs;
  final int calibrationRetries;
  final TrackingState trackingState;
  final SquatMetrics? lastMetrics;
}

abstract interface class RepDetector {
  RepDetectorSnapshot get snapshot;
  List<RepEvent> addFrame(PoseFrame frame);
  List<RepEvent> tick(int timestampUs);
  void pause(int timestampUs);
  void resume(int timestampUs);
  void reset();
}

class SquatRepDetector implements RepDetector {
  SquatRepDetector({
    this.config = const SquatDetectionConfig(),
    CalibrationProfile? initialCalibration,
  }) : _profile = initialCalibration {
    _extractor = SquatFeatureExtractor(config);
    _calibration = CalibrationAccumulator(config);
    _phase = initialCalibration == null
        ? SquatPhase.calibrating
        : SquatPhase.ready;
  }

  final SquatDetectionConfig config;
  late final SquatFeatureExtractor _extractor;
  late final CalibrationAccumulator _calibration;
  CalibrationProfile? _profile;
  late SquatPhase _phase;
  TrackingState _trackingState = TrackingState.lost;
  int _count = 0;
  int _lastTimestampUs = -1;
  int _lastSequenceId = -1;
  int? _lastValidAtUs;
  int? _trackingGapStartedAtUs;
  int? _candidateSinceUs;
  int? _candidateVideoElapsedUs;
  int? _checkpointStartedAtUs;
  int? _checkpointVideoStartedAtUs;
  int? _nextCheckpointAtUs;
  int? _poorFormSinceUs;
  int? _lastFormWarningAtUs;
  bool _trackingLossReported = false;
  final List<SquatMetrics> _checkpointSamples = [];
  SquatMetrics? _lastMetrics;

  @override
  RepDetectorSnapshot get snapshot => RepDetectorSnapshot(
    phase: _phase,
    count: _count,
    calibrationProgress: _profile == null ? _calibration.progress : 1,
    calibrationElapsedUs: _calibration.totalElapsedUs,
    calibrationRetries: _calibration.retryCount,
    trackingState: _trackingState,
    lastMetrics: _lastMetrics,
  );

  void prepareForWorkout() {
    _count = 0;
    _lastValidAtUs = null;
    _trackingGapStartedAtUs = null;
    _trackingLossReported = false;
    _clearHold();
    _extractor.resetDerivatives();
    if (_profile != null) {
      _phase = SquatPhase.ready;
    }
  }

  @override
  List<RepEvent> addFrame(PoseFrame frame) {
    if (frame.timestampUs <= _lastTimestampUs ||
        frame.sequenceId <= _lastSequenceId) {
      return const [];
    }
    _lastTimestampUs = frame.timestampUs;
    _lastSequenceId = frame.sequenceId;
    if (_phase == SquatPhase.paused) return const [];

    if (!frame.hasCompletePose || frame.peopleCount != 1) {
      _trackingState = frame.trackingState;
      if (_profile == null) _calibration.interrupt();
      return _handleTrackingGap(frame.timestampUs, startIfNeeded: true);
    }

    final metrics = _extractor.extract(frame, _profile);
    if (metrics == null ||
        metrics.confidence < config.aggregateConfidenceFloor) {
      _trackingState = TrackingState.lost;
      if (_profile == null) _calibration.interrupt();
      return _handleTrackingGap(frame.timestampUs, startIfNeeded: true);
    }
    _lastValidAtUs = frame.timestampUs;
    _trackingGapStartedAtUs = null;
    _lastMetrics = metrics;
    _trackingState = TrackingState.tracking;
    _trackingLossReported = false;

    if (_profile == null) {
      final profile = _calibration.add(metrics);
      if (profile == null) return const [];
      _profile = profile;
      _phase = SquatPhase.ready;
      _extractor.resetDerivatives();
      return [
        RepEvent(
          type: RepEventType.calibrated,
          timestampUs: frame.timestampUs,
          calibration: profile,
          calibrationDurationUs: _calibration.totalElapsedUs,
          calibrationRetries: _calibration.retryCount,
        ),
      ];
    }

    return _advance(metrics);
  }

  List<RepEvent> _advance(SquatMetrics metrics) {
    final timestampUs = metrics.timestampUs;
    final events = <RepEvent>[];
    if (!_isGoodPlank(metrics)) {
      _candidateSinceUs = null;
      _candidateVideoElapsedUs = null;
      if (_checkpointStartedAtUs != null) {
        _clearHold();
        _phase = SquatPhase.ready;
      }
      _poorFormSinceUs ??= timestampUs;
      final warningDue =
          timestampUs - _poorFormSinceUs! >= config.formWarningDwellUs &&
          (_lastFormWarningAtUs == null ||
              timestampUs - _lastFormWarningAtUs! >= 4000000);
      if (warningDue) {
        _lastFormWarningAtUs = timestampUs;
        events.add(
          RepEvent(type: RepEventType.shallowAttempt, timestampUs: timestampUs),
        );
      }
      return events;
    }

    _poorFormSinceUs = null;
    if (_checkpointStartedAtUs == null) {
      _candidateSinceUs ??= timestampUs;
      _candidateVideoElapsedUs ??= metrics.videoElapsedUs;
      _phase = SquatPhase.descending;
      if (timestampUs - _candidateSinceUs! < config.plankEntryDwellUs) {
        return events;
      }
      _checkpointStartedAtUs = timestampUs;
      _checkpointVideoStartedAtUs = metrics.videoElapsedUs;
      _nextCheckpointAtUs = timestampUs + config.plankCheckpointUs;
      _checkpointSamples
        ..clear()
        ..add(metrics);
      _candidateSinceUs = null;
      _candidateVideoElapsedUs = null;
      _phase = SquatPhase.bottom;
      events.add(
        RepEvent(type: RepEventType.started, timestampUs: timestampUs),
      );
      return events;
    }

    _phase = SquatPhase.bottom;
    _checkpointSamples.add(metrics);
    final checkpointAtUs = _nextCheckpointAtUs!;
    if (timestampUs < checkpointAtUs) return events;

    final trace = RepMotionTrace(
      repSequence: _count + 1,
      startedAtUs: _checkpointStartedAtUs!,
      bottomAtUs: null,
      completedAtUs: checkpointAtUs,
      videoStartedAtUs: _checkpointVideoStartedAtUs,
      videoBottomAtUs: null,
      videoCompletedAtUs: metrics.videoElapsedUs,
      samples: List.unmodifiable(_checkpointSamples),
      detectionConfidence: _averageConfidence(_checkpointSamples),
    );
    _count++;
    _checkpointStartedAtUs = checkpointAtUs;
    _checkpointVideoStartedAtUs = metrics.videoElapsedUs;
    _nextCheckpointAtUs = checkpointAtUs + config.plankCheckpointUs;
    _checkpointSamples
      ..clear()
      ..add(metrics);
    events.add(
      RepEvent(
        type: RepEventType.completed,
        timestampUs: timestampUs,
        trace: trace,
      ),
    );
    return events;
  }

  bool _isGoodPlank(SquatMetrics metrics) {
    final kneeObservable =
        metrics.leftKneeAngle != null || metrics.rightKneeAngle != null;
    return metrics.hipAngle >= config.minimumPlankHipAngle &&
        (!kneeObservable ||
            metrics.kneeAngle >= config.minimumPlankKneeAngle) &&
        metrics.torsoLeanDegrees >= config.minimumPlankTorsoAngle &&
        metrics.torsoLeanDegrees <= config.maximumPlankTorsoAngle;
  }

  double _averageConfidence(List<SquatMetrics> samples) => samples.isEmpty
      ? 0
      : samples.fold<double>(0, (sum, sample) => sum + sample.confidence) /
            samples.length;

  List<RepEvent> _handleTrackingGap(
    int timestampUs, {
    bool startIfNeeded = false,
  }) {
    if (_trackingGapStartedAtUs == null && startIfNeeded) {
      _trackingGapStartedAtUs = _lastValidAtUs ?? timestampUs;
    }
    final gapStartedAtUs = _trackingGapStartedAtUs;
    if (gapStartedAtUs == null ||
        timestampUs - gapStartedAtUs < config.trackingLostUs) {
      return const [];
    }
    _trackingState = TrackingState.lost;
    _phase = SquatPhase.trackingLost;
    _clearHold(keepPhase: true);
    _extractor.resetDerivatives();
    if (_trackingLossReported) return const [];
    _trackingLossReported = true;
    return [
      RepEvent(
        type: RepEventType.trackingLost,
        timestampUs: timestampUs,
        trackingLostDurationUs: timestampUs - gapStartedAtUs,
      ),
    ];
  }

  @override
  List<RepEvent> tick(int timestampUs) => _handleTrackingGap(timestampUs);

  @override
  void pause(int timestampUs) {
    if (_phase == SquatPhase.paused) return;
    _phase = SquatPhase.paused;
    _clearHold(keepPhase: true);
    _extractor.resetDerivatives();
  }

  @override
  void resume(int timestampUs) {
    if (_phase != SquatPhase.paused) return;
    _phase = SquatPhase.trackingLost;
    _candidateSinceUs = null;
    _lastValidAtUs = null;
    _trackingGapStartedAtUs = null;
    _trackingLossReported = false;
  }

  void _clearHold({bool keepPhase = false}) {
    _candidateVideoElapsedUs = null;
    _checkpointStartedAtUs = null;
    _checkpointVideoStartedAtUs = null;
    _nextCheckpointAtUs = null;
    _poorFormSinceUs = null;
    _candidateSinceUs = null;
    _checkpointSamples.clear();
    if (!keepPhase) _phase = SquatPhase.ready;
  }

  @override
  void reset() {
    _phase = SquatPhase.calibrating;
    _trackingState = TrackingState.lost;
    _profile = null;
    _count = 0;
    _lastTimestampUs = -1;
    _lastSequenceId = -1;
    _lastValidAtUs = null;
    _trackingGapStartedAtUs = null;
    _lastMetrics = null;
    _trackingLossReported = false;
    _lastFormWarningAtUs = null;
    _clearHold(keepPhase: true);
    _calibration.reset();
    _extractor.reset();
  }
}
