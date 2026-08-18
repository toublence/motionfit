import 'package:motionfit_squat/features/pushup/domain/models/calibration_profile.dart';
import 'package:motionfit_squat/features/pushup/domain/models/pushup_metrics.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/pushup/domain/services/pushup_detection_config.dart';

class CalibrationAccumulator {
  CalibrationAccumulator(this.config);

  final PushupDetectionConfig config;
  final List<PushupMetrics> _samples = [];
  int? _startedAtUs;
  int? _firstObservedAtUs;
  int? _lastObservedAtUs;
  int _retryCount = 0;

  int get retryCount => _retryCount;

  int get elapsedUs => _samples.isEmpty || _startedAtUs == null
      ? 0
      : _samples.last.timestampUs - _startedAtUs!;

  int get totalElapsedUs =>
      _firstObservedAtUs == null || _lastObservedAtUs == null
      ? 0
      : _lastObservedAtUs! - _firstObservedAtUs!;

  double get progress {
    if (_samples.isEmpty || _startedAtUs == null) return 0;
    final timeProgress =
        (_samples.last.timestampUs - _startedAtUs!) /
        config.calibrationDurationUs;
    final frameProgress = _samples.length / config.minimumCalibrationFrames;
    return (timeProgress < frameProgress ? timeProgress : frameProgress)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  CalibrationProfile? add(PushupMetrics metrics) {
    _firstObservedAtUs ??= metrics.timestampUs;
    _lastObservedAtUs = metrics.timestampUs;
    final kneeObservable =
        metrics.leftKneeAngle != null || metrics.rightKneeAngle != null;
    final standingLike =
        (!kneeObservable || metrics.kneeAngle >= 145) &&
        metrics.hipAngle >= 145;
    if (!standingLike || metrics.confidence < config.aggregateConfidenceFloor) {
      _restart();
      return null;
    }
    _startedAtUs ??= metrics.timestampUs;
    _samples.add(metrics);
    final duration = metrics.timestampUs - _startedAtUs!;
    if (duration < config.calibrationDurationUs ||
        _samples.length < config.minimumCalibrationFrames) {
      return null;
    }
    if (!_isStable()) {
      _restart(withInitialSample: metrics);
      return null;
    }
    final hipYs = _samples.map((sample) => sample.hipY).toList();
    final hipMedian = _median(hipYs);
    final deviations = hipYs.map((value) => (value - hipMedian).abs()).toList();
    return CalibrationProfile(
      baselineKneeAngle: _median(
        _samples.map((sample) => sample.kneeAngle).toList(),
      ),
      baselineHipAngle: _median(
        _samples.map((sample) => sample.hipAngle).toList(),
      ),
      baselineHipY: hipMedian,
      baselineShoulderY: _median(
        _samples.map((sample) => sample.shoulderY).toList(),
      ),
      bodyScale: _median(_samples.map((sample) => sample.bodyScale).toList()),
      motionNoiseMad: _median(deviations),
      cameraAngle: _dominantAngle(_samples.map((sample) => sample.cameraAngle)),
      calibratedAtUs: metrics.timestampUs,
      baselineLeftHeelLift: _optionalMedian(
        _samples.map((sample) => sample.leftHeelLift),
      ),
      baselineRightHeelLift: _optionalMedian(
        _samples.map((sample) => sample.rightHeelLift),
      ),
      baselineKneeAlignment: _optionalMedian(
        _samples.map((sample) => sample.kneeAlignmentDeviation),
      ),
      baselineBalanceOffset: _optionalMedian(
        _samples.map((sample) => sample.balanceDeviation),
      ),
    );
  }

  void interrupt() {
    _restart();
  }

  bool _isStable() {
    final hipYs = _samples.map((sample) => sample.hipY);
    final kneeAngles = _samples.map((sample) => sample.kneeAngle);
    final hipAngles = _samples.map((sample) => sample.hipAngle);
    return _range(hipYs) <= config.maximumCalibrationHipRange &&
        _range(kneeAngles) <= config.maximumCalibrationAngleRange &&
        _range(hipAngles) <= config.maximumCalibrationAngleRange;
  }

  double _range(Iterable<double> values) {
    final iterator = values.iterator;
    if (!iterator.moveNext()) return 0;
    var minimum = iterator.current;
    var maximum = iterator.current;
    while (iterator.moveNext()) {
      final value = iterator.current;
      if (value < minimum) minimum = value;
      if (value > maximum) maximum = value;
    }
    return maximum - minimum;
  }

  void _restart({PushupMetrics? withInitialSample}) {
    if (_samples.isNotEmpty) _retryCount++;
    _samples.clear();
    _startedAtUs = null;
    if (withInitialSample != null) {
      _startedAtUs = withInitialSample.timestampUs;
      _samples.add(withInitialSample);
    }
  }

  double? _optionalMedian(Iterable<double?> values) {
    final observed = values.whereType<double>().toList();
    return observed.isEmpty ? null : _median(observed);
  }

  double _median(List<double> values) {
    values.sort();
    final middle = values.length ~/ 2;
    if (values.length.isOdd) return values[middle];
    return (values[middle - 1] + values[middle]) / 2;
  }

  CameraAngle _dominantAngle(Iterable<CameraAngle> angles) {
    final counts = <CameraAngle, int>{};
    for (final angle in angles) {
      counts[angle] = (counts[angle] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  void reset() {
    _samples.clear();
    _startedAtUs = null;
    _firstObservedAtUs = null;
    _lastObservedAtUs = null;
    _retryCount = 0;
  }
}
