import 'dart:math' as math;

class OneEuroFilter {
  OneEuroFilter({
    this.minimumCutoff = 1.0,
    this.beta = 0.01,
    this.derivativeCutoff = 1.0,
  });

  final double minimumCutoff;
  final double beta;
  final double derivativeCutoff;
  double? _value;
  double? _derivative;
  int? _timestampUs;

  double filter(double value, int timestampUs, {double confidence = 1}) {
    if (!value.isFinite) return _value ?? 0;
    if (_value == null ||
        _timestampUs == null ||
        timestampUs <= _timestampUs!) {
      _value = value;
      _derivative = 0;
      _timestampUs = timestampUs;
      return value;
    }

    final dt = (timestampUs - _timestampUs!) / 1000000.0;
    if (dt > 0.5) {
      _value = value;
      _derivative = 0;
      _timestampUs = timestampUs;
      return value;
    }
    final rawDerivative = (value - _value!) / dt;
    final derivativeAlpha = _alpha(derivativeCutoff, dt);
    _derivative = _lowPass(
      rawDerivative,
      _derivative ?? rawDerivative,
      derivativeAlpha,
    );
    final cutoff = minimumCutoff + beta * (_derivative?.abs() ?? 0);
    final confidenceWeight = confidence.clamp(0.05, 1.0).toDouble();
    final alpha = (_alpha(cutoff, dt) * confidenceWeight)
        .clamp(0.01, 1.0)
        .toDouble();
    _value = _lowPass(value, _value!, alpha);
    _timestampUs = timestampUs;
    return _value!;
  }

  double _alpha(double cutoff, double dt) {
    final tau = 1 / (2 * math.pi * cutoff);
    return 1 / (1 + tau / dt);
  }

  double _lowPass(double value, double previous, double alpha) =>
      alpha * value + (1 - alpha) * previous;

  void reset() {
    _value = null;
    _derivative = null;
    _timestampUs = null;
  }
}
