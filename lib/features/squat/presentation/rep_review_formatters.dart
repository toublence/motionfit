import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_analysis.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

String repResultLabel(AppLocalizations l10n, RepAnalysis analysis) =>
    switch (analysis.result) {
      RepAnalysisResult.good => l10n.repResultGood,
      RepAnalysisResult.needsImprovement => repIssueLabel(
        l10n,
        analysis.primaryIssue,
      ),
      RepAnalysisResult.improved => l10n.repResultImproved,
      RepAnalysisResult.notAssessed => l10n.repResultNotAssessed,
    };

String repIssueLabel(AppLocalizations l10n, FormIssue? issue) =>
    switch (issue) {
      FormIssue.insufficientDepth => l10n.repIssueShallowDepth,
      FormIssue.excessiveTorsoLean => l10n.repIssueForwardLean,
      FormIssue.kneeAlignment => l10n.repIssueKneesInward,
      FormIssue.heelLift => l10n.formIssueHeelLift,
      FormIssue.leftRightImbalance => l10n.formIssueBalance,
      FormIssue.descentTooFast ||
      FormIssue.descentTooSlow => l10n.formIssueDescentSpeed,
      FormIssue.ascentTooFast ||
      FormIssue.ascentTooSlow => l10n.formIssueAscentSpeed,
      FormIssue.unstableControl => l10n.formIssueControl,
      FormIssue.incompleteLockout => l10n.formIssueStandingCompletion,
      null => l10n.repResultNeedsAttention,
    };

String repIssueCategory(AppLocalizations l10n, FormIssue? issue) =>
    switch (issue) {
      FormIssue.insufficientDepth => l10n.formIssueDepth,
      FormIssue.excessiveTorsoLean => l10n.formIssueTorsoLean,
      FormIssue.kneeAlignment => l10n.formIssueKneeAlignment,
      _ => repIssueLabel(l10n, issue),
    };

String repFeedback(AppLocalizations l10n, RepAnalysis analysis) {
  if (analysis.result == RepAnalysisResult.notAssessed) {
    return l10n.commonNotAvailable;
  }
  if (analysis.result == RepAnalysisResult.good ||
      analysis.result == RepAnalysisResult.improved) {
    return l10n.repFeedbackGood;
  }
  return switch (analysis.primaryIssue) {
    FormIssue.insufficientDepth => l10n.repFeedbackDepth,
    FormIssue.excessiveTorsoLean => l10n.repFeedbackTorso,
    FormIssue.kneeAlignment => l10n.repFeedbackKnees,
    final issue => l10n.repFeedbackGeneric(repIssueCategory(l10n, issue)),
  };
}

String formatRepTimestamp(Duration value) {
  final minutes = value.inMinutes;
  final seconds = value.inSeconds.remainder(60);
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}
