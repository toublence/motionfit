import 'package:motionfit_squat/features/squat/domain/models/calibration_profile.dart';
import 'package:motionfit_squat/features/squat/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/squat/domain/models/squat_metrics.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/services/calibration_accumulator.dart';
import 'package:motionfit_squat/features/squat/domain/services/squat_detection_config.dart';
import 'package:motionfit_squat/features/squat/domain/services/squat_feature_extractor.dart';

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
  int? _attemptStartedAtUs;
  int? _bottomAtUs;
  int? _completedAtUs;
  int? _candidateVideoElapsedUs;
  int? _attemptVideoStartedAtUs;
  int? _bottomVideoAtUs;
  bool _intentReached = false;
  bool _ascentObserved = false;
  bool _trackingLossReported = false;
  final List<SquatMetrics> _attemptSamples = [];
  SquatMetrics? _deepestSample;
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
    _clearAttempt();
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

    if (_phase == SquatPhase.trackingLost) {
      if (_isStanding(metrics)) {
        _candidateSinceUs ??= frame.timestampUs;
        if (frame.timestampUs - _candidateSinceUs! >=
            config.reacquireStandingUs) {
          _phase = SquatPhase.ready;
          _candidateSinceUs = null;
          _extractor.resetDerivatives();
          return [
            RepEvent(type: RepEventType.ready, timestampUs: frame.timestampUs),
          ];
        }
      } else {
        _candidateSinceUs = null;
      }
      return const [];
    }

    return _advance(metrics);
  }

  List<RepEvent> _advance(SquatMetrics metrics) {
    final timestampUs = metrics.timestampUs;
    final kneeFlex = _kneeFlex(metrics);
    final hipFlex = _profile!.baselineHipAngle - metrics.hipAngle;
    final events = <RepEvent>[];

    switch (_phase) {
      case SquatPhase.ready:
        final descentSignals = <bool>[
          kneeFlex >= _adaptive(config.descentKneeFlexDegrees, 180),
          hipFlex >= _adaptive(config.descentHipFlexDegrees, 180),
          metrics.hipDrop >= _adaptive(config.descentHipDrop, 1),
          metrics.hipVelocity >= config.descentVelocity,
        ].where((value) => value).length;
        if (descentSignals >= 2 && metrics.hipVelocity > 0) {
          _candidateSinceUs ??= timestampUs;
          _candidateVideoElapsedUs ??= metrics.videoElapsedUs;
          if (timestampUs - _candidateSinceUs! >= config.directionDwellUs) {
            _phase = SquatPhase.descending;
            _attemptStartedAtUs = _candidateSinceUs;
            _attemptVideoStartedAtUs = _candidateVideoElapsedUs;
            _attemptSamples
              ..clear()
              ..add(metrics);
            _deepestSample = metrics;
            _intentReached = false;
            _ascentObserved = false;
            _bottomAtUs = null;
            _bottomVideoAtUs = null;
            _candidateSinceUs = null;
            _candidateVideoElapsedUs = null;
            events.add(
              RepEvent(type: RepEventType.started, timestampUs: timestampUs),
            );
          }
        } else {
          _candidateSinceUs = null;
          _candidateVideoElapsedUs = null;
        }
      case SquatPhase.descending:
        _recordAttemptSample(metrics);
        _intentReached =
            _intentReached || _hasIntent(kneeFlex, hipFlex, metrics);
        if (_attemptStartedAtUs != null &&
            timestampUs - _attemptStartedAtUs! > config.maximumAttemptUs) {
          _cancelAttempt();
          break;
        }
        if (!_intentReached && _isStanding(metrics)) {
          events.add(
            RepEvent(
              type: RepEventType.shallowAttempt,
              timestampUs: timestampUs,
            ),
          );
          _cancelAttempt();
          break;
        }
        if (_intentReached && metrics.hipVelocity <= config.ascentVelocity) {
          _ascentObserved = true;
        }
        if (_intentReached &&
            _ascentObserved &&
            _hasRecoveredFromBottom(metrics)) {
          _confirmBottom(events, timestampUs);
          _phase = SquatPhase.ascending;
          _candidateSinceUs = timestampUs;
          _ascentObserved = false;
        } else if (_intentReached &&
            metrics.hipVelocity <= config.bottomVelocity) {
          _candidateSinceUs ??= timestampUs;
          _ascentObserved =
              _ascentObserved || metrics.hipVelocity <= config.ascentVelocity;
          if (timestampUs - _candidateSinceUs! >= config.directionDwellUs) {
            _confirmBottom(events, timestampUs);
            _phase = _ascentObserved ? SquatPhase.ascending : SquatPhase.bottom;
            _candidateSinceUs = null;
            _ascentObserved = false;
          }
        } else {
          _candidateSinceUs = null;
          _ascentObserved = false;
        }
      case SquatPhase.bottom:
        _recordAttemptSample(metrics);
        if (metrics.hipVelocity <= config.ascentVelocity) {
          _ascentObserved = true;
        }
        if (_ascentObserved && _hasRecoveredFromBottom(metrics)) {
          _phase = SquatPhase.ascending;
          _candidateSinceUs = timestampUs;
        } else if (metrics.hipVelocity <= config.ascentVelocity) {
          _candidateSinceUs ??= timestampUs;
          if (timestampUs - _candidateSinceUs! >= config.directionDwellUs) {
            _phase = SquatPhase.ascending;
            _candidateSinceUs = null;
          }
        } else if (metrics.hipVelocity > config.descentVelocity) {
          _phase = SquatPhase.descending;
          _candidateSinceUs = null;
          _ascentObserved = false;
        }
      case SquatPhase.ascending:
        _recordAttemptSample(metrics);
        // A clear recovery from a real bottom completes the repetition.
        // Full knee/hip lockout belongs to form coaching, not counting.
        if (_hasRecoveredFromBottom(metrics)) {
          _candidateSinceUs ??= timestampUs;
          if (timestampUs - _candidateSinceUs! >= config.completionDwellUs) {
            final trace = RepMotionTrace(
              repSequence: _count + 1,
              startedAtUs: _attemptStartedAtUs!,
              bottomAtUs: _bottomAtUs,
              completedAtUs: timestampUs,
              videoStartedAtUs: _attemptVideoStartedAtUs,
              videoBottomAtUs: _bottomVideoAtUs,
              videoCompletedAtUs: metrics.videoElapsedUs,
              samples: List.unmodifiable(_attemptSamples),
              detectionConfidence: _averageConfidence(_attemptSamples),
            );
            _count++;
            _completedAtUs = timestampUs;
            _phase = SquatPhase.completed;
            _candidateSinceUs = null;
            events.add(
              RepEvent(
                type: RepEventType.completed,
                timestampUs: timestampUs,
                trace: trace,
              ),
            );
          }
        } else if (metrics.hipVelocity > config.descentVelocity) {
          _phase = SquatPhase.bottom;
          _candidateSinceUs = null;
        } else {
          _candidateSinceUs = null;
        }
      case SquatPhase.completed:
        if (_completedAtUs != null &&
            timestampUs - _completedAtUs! >= config.refractoryUs) {
          _phase = SquatPhase.ready;
          _clearAttempt();
          events.add(
            RepEvent(type: RepEventType.ready, timestampUs: timestampUs),
          );
        }
      case SquatPhase.calibrating:
      case SquatPhase.trackingLost:
      case SquatPhase.paused:
        break;
    }
    return events;
  }

  bool _hasIntent(double kneeFlex, double hipFlex, SquatMetrics metrics) =>
      (kneeFlex >= config.minimumIntentKneeFlexDegrees &&
          metrics.hipDrop >=
              _adaptive(config.minimumIntentHipDropWithKnee, 1)) ||
      (hipFlex >= config.minimumIntentHipFlexDegrees &&
          metrics.hipDrop >= _adaptive(config.minimumIntentHipDropWithHip, 1));

  bool _isStanding(SquatMetrics metrics) {
    final kneeFlex = _kneeFlex(metrics);
    final hipFlex = _profile!.baselineHipAngle - metrics.hipAngle;
    return kneeFlex <= config.standingKneeFlexDegrees &&
        hipFlex <= config.standingHipFlexDegrees &&
        metrics.hipDrop <= _adaptive(config.standingHipDrop, 1);
  }

  bool _hasRecoveredFromBottom(SquatMetrics current) {
    final bottom = _deepestSample;
    if (bottom == null) return false;
    final bottomHasKnee =
        bottom.leftKneeAngle != null || bottom.rightKneeAngle != null;
    final currentHasKnee =
        current.leftKneeAngle != null || current.rightKneeAngle != null;
    final recoveredSignals = <bool>[
      bottom.hipDrop - current.hipDrop >= 0.025,
      current.hipAngle - bottom.hipAngle >= 8,
      bottomHasKnee &&
          currentHasKnee &&
          current.kneeAngle - bottom.kneeAngle >= 10,
    ].where((value) => value).length;
    return recoveredSignals >= 2;
  }

  void _recordAttemptSample(SquatMetrics metrics) {
    _attemptSamples.add(metrics);
    final deepest = _deepestSample;
    if (deepest == null || metrics.hipDrop > deepest.hipDrop) {
      _deepestSample = metrics;
    }
  }

  void _confirmBottom(List<RepEvent> events, int timestampUs) {
    _bottomAtUs = _deepestSample?.timestampUs ?? timestampUs;
    _bottomVideoAtUs = _deepestSample?.videoElapsedUs;
    events.add(RepEvent(type: RepEventType.bottom, timestampUs: timestampUs));
  }

  double _kneeFlex(SquatMetrics metrics) =>
      metrics.leftKneeAngle == null && metrics.rightKneeAngle == null
      ? 0
      : _profile!.baselineKneeAngle - metrics.kneeAngle;

  double _adaptive(double base, double unitScale) =>
      base > _profile!.motionNoiseMad * 4 * unitScale
      ? base
      : _profile!.motionNoiseMad * 4 * unitScale;

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
    // A crop or temporary landmark gap does not pause the workout or cancel
    // an in-progress repetition. The next usable frame continues this phase.
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
    _cancelAttempt(setReady: false);
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

  void _cancelAttempt({bool setReady = true}) {
    _clearAttempt();
    if (setReady) _phase = SquatPhase.ready;
  }

  void _clearAttempt() {
    _attemptStartedAtUs = null;
    _bottomAtUs = null;
    _completedAtUs = null;
    _candidateVideoElapsedUs = null;
    _attemptVideoStartedAtUs = null;
    _bottomVideoAtUs = null;
    _intentReached = false;
    _ascentObserved = false;
    _candidateSinceUs = null;
    _deepestSample = null;
    _attemptSamples.clear();
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
    _clearAttempt();
    _calibration.reset();
    _extractor.reset();
  }
}
