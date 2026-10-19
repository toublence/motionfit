import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import 'onboarding_copy.dart';

const onboardingBackground = Color(0xFF050607);
const onboardingText = Color(0xFFF5F7F8);
const onboardingMuted = Color(0xB3F5F7F8);
const onboardingGood = Color(0xFF52D69F);
const _attention = Color(0xFFE5AE58);
const _body = Color(0xFF444E51);

// Timings and joint trajectories match Android's OnboardingMotion/Visuals.
const _measureResult = 6700;
const _improveResult = 7700;
const _durations = [9000, 10200, 9600];
const _snapshots = [7400.0, 8500.0, 8250.0];
double _stage(double t, num start, num end) =>
    ((t - start) / (end - start)).clamp(0.0, 1.0);
double _smooth(double v) => (1 - math.cos(v.clamp(0.0, 1.0) * math.pi)) / 2;
({double depth, int reps}) _squat(double t, int reps) {
  if (t < 0) return (depth: 0, reps: 0);
  if (t >= reps * 1800 + (reps - 1) * 200) {
    return (depth: 0, reps: reps);
  }
  final index = (t / 2000).floor().clamp(0, reps - 1);
  final within = t - index * 2000;
  final depth = within < 800
      ? _smooth(within / 800)
      : within < 1000
      ? 1.0
      : within < 1800
      ? 1 - _smooth((within - 1000) / 800)
      : 0.0;
  return (depth: depth, reps: index + (within >= 1800 ? 1 : 0));
}

class OnboardingDemo extends StatefulWidget {
  const OnboardingDemo({super.key, required this.step, required this.copy});
  final int step;
  final OnboardingCopy copy;
  @override
  State<OnboardingDemo> createState() => _OnboardingDemoState();
}

class _OnboardingDemoState extends State<OnboardingDemo>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final _clock = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _durations[widget.step]),
  );
  bool _foreground = true;
  bool _still = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    _syncClock();
  }

  void _syncClock() {
    if (!_still && _foreground && TickerMode.of(context)) {
      if (!_clock.isAnimating) _clock.repeat();
    } else {
      _clock.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncClock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final description =
        widget.copy[[
          'onboarding_measure_description',
          'onboarding_improve_description',
          'onboarding_try_description',
        ][widget.step]];
    return Semantics(
      label: description,
      image: true,
      child: ExcludeSemantics(
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: AnimatedBuilder(
            animation: _clock,
            builder: (context, _) => _buildDemo(
              _still
                  ? _snapshots[widget.step]
                  : _clock.value * _durations[widget.step],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemo(double time) {
    final copy = widget.copy;
    final number = MaterialLocalizations.of(context).formatDecimal;
    final fade =
        1 -
        _stage(time, _durations[widget.step] - 250, _durations[widget.step]);
    if (widget.step == 2) {
      final back =
          _smooth(_stage(time, 1000, 2200)) *
          (1 - _smooth(_stage(time, 9000, 9600)));
      final motion = _squat(time - 6000, 1);
      final countdown = time >= 3000 && time < 6000
          ? 3 - ((time - 3000) / 1000).floor()
          : null;
      final guidance = time < 2200
          ? copy['instruction_move_back']
          : countdown != null
          ? number(countdown)
          : time < 6000
          ? copy['speak_ready']
          : '${copy['onboarding_rep_label']} ${number(motion.reps)}';
      return Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _PersonPainter(
                depth: motion.depth,
                correction: 1,
                preparation: true,
                back: back,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: fade,
            child: Text(
              guidance,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: countdown != null ? 36 : 16,
                fontWeight: FontWeight.w600,
                color: time < 2200 ? _attention : onboardingGood,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }
    final improve = widget.step == 1;
    final retrying = improve && time >= 3400;
    final motion = improve
        ? _squat(time - (retrying ? 3400 : 400), retrying ? 2 : 1)
        : _squat(time - 400, 3);
    final result = time >= (improve ? _improveResult : _measureResult);
    final feedback = improve && time >= 2200;
    final corrected = retrying ? 1.0 : 0.0;
    final arrow = Directionality.of(context) == TextDirection.rtl ? '←' : '→';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: _PersonPainter(
                    depth: motion.depth,
                    correction: corrected,
                    highlight: improve ? _stage(time, 1100, 1350) * fade : 0,
                    highlightCorrection: _stage(time, 3400, 4200),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              Expanded(
                child: Opacity(
                  opacity: fade,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _readout(
                          result || (feedback && !retrying)
                              ? copy['form_score_label']
                              : copy['onboarding_rep_label'],
                          number(
                            result
                                ? (improve ? 69 : 61)
                                : feedback && !retrying
                                ? 61
                                : motion.reps,
                          ),
                          color: result && improve
                              ? onboardingGood
                              : onboardingText,
                        ),
                        if (!improve && result) ...[
                          _metric(copy['metric_depth'], 72),
                          _metric(copy['metric_knee_stability'], 54),
                          _metric(copy['metric_tempo'], 58),
                        ],
                        if (feedback)
                          _metric(
                            copy['metric_knee_stability'],
                            result ? 66 : 54,
                            before: result ? 54 : null,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (improve) ...[
          Opacity(
            opacity: feedback ? fade : 0,
            child: Text(
              copy['onboarding_correction'],
              style: TextStyle(
                fontSize: 16,
                color: Color.lerp(
                  _attention,
                  onboardingGood,
                  _stage(time, 3400, 4200),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: result ? fade : 0,
            child: Text(
              '${number(61)}  $arrow  ${number(69)}',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: onboardingGood,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          copy['onboarding_demo'],
          style: TextStyle(
            fontSize: 12,
            color: onboardingMuted.withValues(alpha: .42),
          ),
        ),
      ],
    );
  }

  Widget _readout(String label, String value, {required Color color}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: onboardingMuted)),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          style: TextStyle(
            fontSize: 64,
            height: 1.15,
            fontWeight: FontWeight.bold,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    ],
  );

  Widget _metric(String label, int score, {int? before}) {
    final number = MaterialLocalizations.of(context).formatDecimal;
    final arrow = Directionality.of(context) == TextDirection.rtl ? '←' : '→';
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: onboardingMuted),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                before == null
                    ? number(score)
                    : '${number(before)} $arrow ${number(score)}',
                style: TextStyle(
                  fontSize: 14,
                  color: before == null ? onboardingText : onboardingGood,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score / 100,
            minHeight: 3,
            borderRadius: BorderRadius.circular(3),
            backgroundColor: onboardingText.withValues(alpha: .1),
            color: score < 60 ? _attention : onboardingGood,
          ),
        ],
      ),
    );
  }
}

class _PersonPainter extends CustomPainter {
  const _PersonPainter({
    required this.depth,
    required this.correction,
    this.highlight = 0,
    this.highlightCorrection = 0,
    this.preparation = false,
    this.back = 0,
  });
  final double depth, correction, highlight, highlightCorrection, back;
  final bool preparation;

  @override
  void paint(Canvas canvas, Size size) {
    if (preparation) {
      final frame = Rect.fromLTRB(
        size.width * .30,
        size.height * .08,
        size.width * .97,
        size.height * .93,
      );
      final personHeight = math.min(frame.height * .93, size.width * 1.15);
      final ground = frame.bottom - personHeight * .035;
      final apparentHeight = personHeight * (1.38 - .38 * back);
      final center = Offset(
        size.width * (.63 + .015 * back),
        ground - apparentHeight * .42,
      );
      final phone = Offset(size.width * .08, ground - personHeight * .4);
      final phoneSize = Size(size.width * .13, size.width * .25);
      final phoneRect = RRect.fromRectAndRadius(
        phone & phoneSize,
        const Radius.circular(8),
      );
      final phoneCenter = phone + Offset(phoneSize.width, phoneSize.height / 2);
      _line(
        canvas,
        phoneCenter,
        frame.topLeft,
        onboardingMuted.withValues(alpha: .15),
        1,
      );
      _line(
        canvas,
        phoneCenter,
        frame.bottomLeft,
        onboardingMuted.withValues(alpha: .15),
        1,
      );
      canvas.drawRRect(phoneRect, Paint()..color = _body);
      canvas.drawRRect(
        phoneRect,
        Paint()
          ..color = onboardingMuted
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(
        phone + Offset(phoneSize.width / 2, 7),
        2,
        Paint()..color = onboardingGood,
      );
      _line(
        canvas,
        phone + Offset(phoneSize.width / 2, phoneSize.height),
        Offset(phone.dx + phoneSize.width / 2, ground),
        _body,
        3,
      );
      _line(
        canvas,
        Offset(phone.dx, ground),
        Offset(phone.dx + phoneSize.width, ground),
        _body,
        3,
      );
      canvas.save();
      canvas.clipRect(frame);
      _person(canvas, size, center, apparentHeight, back);
      canvas.restore();
      final guide = Color.lerp(
        _attention,
        onboardingGood,
        back,
      )!.withValues(alpha: .65);
      final corners = [
        frame.topLeft,
        frame.topRight,
        frame.bottomLeft,
        frame.bottomRight,
      ];
      for (var i = 0; i < 4; i++) {
        final point = corners[i];
        _line(
          canvas,
          point,
          point + Offset(i.isEven ? 14 : -14, 0),
          guide,
          1.5,
        );
        _line(canvas, point, point + Offset(0, i < 2 ? 14 : -14), guide, 1.5);
      }
      _line(
        canvas,
        Offset(0, ground),
        Offset(size.width, ground),
        onboardingMuted.withValues(alpha: .12),
        1,
      );
    } else {
      _person(
        canvas,
        size,
        Offset(size.width / 2, size.height / 2),
        size.height * .85,
        0,
      );
    }
  }

  void _person(
    Canvas canvas,
    Size size,
    Offset center,
    double height,
    double stepBack,
  ) {
    final h = math.min(height, size.width * 1.85);
    final w = h * .64;
    Offset p(double x, double y) =>
        Offset(center.dx + (x - .5) * w, center.dy + (y - .5) * h);
    final thigh = depth * 72 * math.pi / 180;
    final shin = depth * 28 * math.pi / 180;
    final torsoAngle = depth * 14 * math.pi / 180;
    final leftLift = math.sin((stepBack * 2).clamp(0, 1) * math.pi) * .045;
    final rightLift =
        math.sin(((stepBack - .5) * 2).clamp(0, 1) * math.pi) * .045;
    final hipY =
        .92 -
        .21 * math.cos(shin) -
        .21 * math.cos(thigh) -
        (leftLift + rightLift) * .15;
    final shoulderY = hipY - .26 * math.cos(torsoAngle);
    final kneeY = .92 - .21 * math.cos(shin);
    final knee = .35 - .06 * depth + (1 - correction) * .135 * depth;
    final elbowY = shoulderY + .18 - .085 * depth;
    final wristY = elbowY + .16 - .25 * depth;
    final joints = [
      p(.5, shoulderY - .12 * math.cos(torsoAngle)),
      p(.37 - depth * .014, shoulderY),
      p(.63 + depth * .014, shoulderY),
      p(.32 - depth * .03, elbowY),
      p(.68 + depth * .03, elbowY),
      p(.30 + depth * .17, wristY),
      p(.70 - depth * .17, wristY),
      p(.43 - depth * .025, hipY),
      p(.57 + depth * .025, hipY),
      p(knee, kneeY - leftLift * .7),
      p(1 - knee, kneeY - rightLift * .7),
      p(.27, .92 - leftLift),
      p(.73, .92 - rightLift),
    ];
    const bones = [
      (1, 2),
      (1, 7),
      (2, 8),
      (7, 8),
      (1, 3),
      (3, 5),
      (2, 4),
      (4, 6),
      (7, 9),
      (9, 11),
      (8, 10),
      (10, 12),
    ];
    final torso = Path()
      ..moveTo(joints[1].dx, joints[1].dy)
      ..lineTo(joints[2].dx, joints[2].dy)
      ..lineTo(joints[8].dx + w * .04, joints[8].dy)
      ..lineTo(joints[7].dx - w * .04, joints[7].dy)
      ..close();
    canvas.drawPath(torso, Paint()..color = _body);
    for (final (a, b) in bones) {
      _line(canvas, joints[a], joints[b], _body, w * .095);
    }
    canvas.drawCircle(joints[0], w * .08, Paint()..color = _body);
    _line(canvas, joints[0], p(.5, shoulderY + .025), _body, w * .06);
    _line(canvas, joints[11], joints[11] + Offset(-w * .07, 0), _body, w * .07);
    _line(canvas, joints[12], joints[12] + Offset(w * .07, 0), _body, w * .07);
    final alpha = preparation ? .45 + .55 * back : 1.0;
    for (final (a, b) in bones) {
      _line(
        canvas,
        joints[a],
        joints[b],
        onboardingText.withValues(alpha: alpha * .8),
        1.8,
      );
    }
    final attention = Color.lerp(
      _attention,
      onboardingGood,
      highlightCorrection,
    )!;
    for (var i = 0; i < joints.length; i++) {
      final kneeJoint = i == 9 || i == 10;
      if (kneeJoint) {
        canvas.drawCircle(
          joints[i],
          w * .07,
          Paint()..color = attention.withValues(alpha: alpha * highlight * .12),
        );
      }
      canvas.drawCircle(
        joints[i],
        3,
        Paint()
          ..color = kneeJoint && highlight > 0
              ? attention.withValues(alpha: alpha * highlight)
              : onboardingGood.withValues(alpha: alpha),
      );
    }
  }

  void _line(Canvas c, Offset a, Offset b, Color color, double width) =>
      c.drawLine(
        a,
        b,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );

  @override
  bool shouldRepaint(_PersonPainter old) =>
      depth != old.depth ||
      correction != old.correction ||
      highlight != old.highlight ||
      highlightCorrection != old.highlightCorrection ||
      preparation != old.preparation ||
      back != old.back;
}
