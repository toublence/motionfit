import 'package:motionfit_squat/features/pushup/localization/generated/pushup_localizations.dart';
import 'package:motionfit_squat/features/pushup/application/workout_coach_messages.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_enums.dart';

WorkoutCoachMessages localizedCoachMessages(PushupLocalizations l10n) {
  return WorkoutCoachMessages(
    locale: l10n.localeName,
    calibration: '${l10n.calibrationBody} ${l10n.calibrationStayStill}',
    ready: (variant) => variant.isEven ? l10n.coachReady1 : l10n.coachReady2,
    tracking: (state, variant) => switch (state) {
      TrackingState.partialBody =>
        variant.isEven ? l10n.coachWholeBody1 : l10n.coachWholeBody2,
      TrackingState.multiplePeople => l10n.coachMultiplePeople1,
      _ => variant.isEven ? l10n.coachTrackingLost1 : l10n.coachTrackingLost2,
    },
    repCount: (count) => l10n.localeName.toLowerCase().startsWith('ko')
        ? _koreanRepCount(count)
        : l10n.coachRepCount(count),
    formIssue: (issue, variant) => switch (issue) {
      FormIssue.insufficientDepth =>
        variant.isEven ? l10n.coachDepth1 : l10n.coachDepth2,
      FormIssue.excessiveTorsoLean =>
        variant.isEven ? l10n.coachTorso1 : l10n.coachTorso2,
      FormIssue.heelLift => variant.isEven ? l10n.coachHeel1 : l10n.coachHeel2,
      FormIssue.kneeAlignment =>
        variant.isEven ? l10n.coachKnees1 : l10n.coachKnees2,
      FormIssue.leftRightImbalance =>
        variant.isEven ? l10n.coachBalance1 : l10n.coachBalance2,
      FormIssue.descentTooFast =>
        variant.isEven ? l10n.coachDescendSlow1 : l10n.coachDescendSlow2,
      FormIssue.descentTooSlow =>
        variant.isEven ? l10n.coachDescendFaster1 : l10n.coachDescendFaster2,
      FormIssue.ascentTooFast =>
        variant.isEven
            ? l10n.coachAscendControlled1
            : l10n.coachAscendControlled2,
      FormIssue.ascentTooSlow =>
        variant.isEven ? l10n.coachAscendFaster1 : l10n.coachAscendFaster2,
      FormIssue.unstableControl =>
        variant.isEven ? l10n.coachControl1 : l10n.coachControl2,
      FormIssue.incompleteLockout =>
        variant.isEven ? l10n.coachStandTall1 : l10n.coachStandTall2,
    },
    goodRep: (variant) => switch (variant % 3) {
      0 => l10n.coachGood1,
      1 => l10n.coachGood2,
      _ => l10n.coachGood3,
    },
    goalNear: (remaining) =>
        remaining == 1 ? l10n.coachLastOne : l10n.coachLastTwo,
    setStart: l10n.coachStartSet,
    sevenDayChallengeStart: l10n.coachSevenDayChallengeStart,
    cumulativeChallengeStart: l10n.coachCumulativeChallengeStart,
    setComplete: l10n.coachSetComplete,
    restStart: l10n.coachRestStart,
    restTenSeconds: l10n.coachRestTenSeconds,
    restComplete: l10n.coachRestComplete,
    workoutComplete: l10n.coachWorkoutComplete,
  );
}

String _koreanRepCount(int count) {
  const nativeCounts = <String>[
    '',
    '하나!',
    '둘!',
    '셋!',
    '넷!',
    '다섯!',
    '여섯!',
    '일곱!',
    '여덟!',
    '아홉!',
    '열!',
    '열하나!',
    '열둘!',
    '열셋!',
    '열넷!',
    '열다섯!',
    '열여섯!',
    '열일곱!',
    '열여덟!',
    '열아홉!',
    '스물!',
  ];
  return count > 0 && count < nativeCounts.length
      ? nativeCounts[count]
      : '$count!';
}
