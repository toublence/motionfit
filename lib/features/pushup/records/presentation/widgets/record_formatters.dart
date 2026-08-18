import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/features/pushup/localization/generated/pushup_localizations.dart';
import 'package:motionfit_squat/features/pushup/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_enums.dart';

String recordLocaleName(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

String formatRecordDate(BuildContext context, DateTime value) =>
    DateFormat.yMMMd(recordLocaleName(context)).format(value.toLocal());

String formatRecordMonth(BuildContext context, DateTime value) =>
    DateFormat.yMMMM(recordLocaleName(context)).format(value.toLocal());

String formatRecordTime(BuildContext context, DateTime value) =>
    DateFormat.jm(recordLocaleName(context)).format(value.toLocal());

String formatRecordDuration(PushupLocalizations l10n, int totalSeconds) {
  final safeSeconds = totalSeconds.clamp(0, 864000).toInt();
  const secondsPerHour = Duration.secondsPerMinute * Duration.minutesPerHour;
  if (safeSeconds >= secondsPerHour) {
    return l10n.durationHoursMinutes(
      safeSeconds ~/ secondsPerHour,
      (safeSeconds % secondsPerHour) ~/ Duration.secondsPerMinute,
    );
  }
  return l10n.durationMinutesSeconds(
    safeSeconds ~/ Duration.secondsPerMinute,
    safeSeconds % Duration.secondsPerMinute,
  );
}

String formatAverageRepDuration(PushupLocalizations l10n, int milliseconds) {
  if (milliseconds <= 0) return l10n.commonNotAvailable;
  return formatRecordDuration(l10n, (milliseconds / 1000).round());
}

String formatFormScore(BuildContext context, double? score) {
  final l10n = PushupLocalizations.of(context);
  if (score == null) return l10n.commonNotAvailable;
  return NumberFormat.percentPattern(
    recordLocaleName(context),
  ).format(score.clamp(0, 100) / 100);
}

String formatDecimal(BuildContext context, double value) =>
    NumberFormat.decimalPatternDigits(
      locale: recordLocaleName(context),
      decimalDigits: 1,
    ).format(value);

String formIssueLabel(PushupLocalizations l10n, FormIssue issue) =>
    switch (issue) {
      FormIssue.insufficientDepth => l10n.formIssueDepth,
      FormIssue.excessiveTorsoLean => l10n.formIssueTorsoLean,
      FormIssue.heelLift => l10n.formIssueHeelLift,
      FormIssue.kneeAlignment => l10n.formIssueKneeAlignment,
      FormIssue.leftRightImbalance => l10n.formIssueBalance,
      FormIssue.descentTooFast ||
      FormIssue.descentTooSlow => l10n.formIssueDescentSpeed,
      FormIssue.ascentTooFast ||
      FormIssue.ascentTooSlow => l10n.formIssueAscentSpeed,
      FormIssue.unstableControl => l10n.formIssueControl,
      FormIssue.incompleteLockout => l10n.formIssueStandingCompletion,
    };

List<MapEntry<FormIssue, int>> frequentSessionIssues(
  WorkoutSessionDetails details,
) {
  final counts = <FormIssue, int>{};
  for (final rep in details.reps) {
    for (final issue in rep.detectedIssues) {
      counts[issue] = (counts[issue] ?? 0) + 1;
    }
  }
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final countOrder = b.value.compareTo(a.value);
      return countOrder != 0 ? countOrder : a.key.index.compareTo(b.key.index);
    });
  return entries;
}

List<String> sessionStrengthLabels(
  PushupLocalizations l10n,
  WorkoutSessionDetails details,
) {
  final issues = details.reps.expand((rep) => rep.detectedIssues).toSet();
  final strengths = <String>[];

  final depthScores = details.reps
      .map((rep) => rep.depthScore)
      .whereType<double>();
  final depthAverage = _average(depthScores);
  if (depthAverage != null &&
      depthAverage >= 75 &&
      !issues.contains(FormIssue.insufficientDepth)) {
    strengths.add(l10n.formStrengthDepth);
  }

  final controlScores = details.reps
      .map((rep) => rep.controlScore)
      .whereType<double>();
  final controlAverage = _average(controlScores);
  if (controlAverage != null &&
      controlAverage >= 75 &&
      !issues.contains(FormIssue.unstableControl)) {
    strengths.add(l10n.formStrengthControl);
  }

  final balanceScores = details.reps
      .map((rep) => rep.balanceScore)
      .whereType<double>();
  final balanceAverage = _average(balanceScores);
  if (balanceAverage != null &&
      balanceAverage >= 75 &&
      !issues.contains(FormIssue.leftRightImbalance)) {
    strengths.add(l10n.formStrengthBalance);
  }

  return strengths;
}

double? _average(Iterable<double> values) {
  final list = values.toList(growable: false);
  if (list.isEmpty) return null;
  return list.reduce((a, b) => a + b) / list.length;
}
