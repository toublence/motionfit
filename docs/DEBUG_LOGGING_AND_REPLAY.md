# Debug Logging and Replay

This infrastructure is compiled on only in Flutter debug builds. It observes
the existing detector, analyzer, coaching policy, queue, and TTS paths without
changing their thresholds or state transitions.

## Capture

Run the app normally with `flutter run`. Debug logging defaults to enabled.
Disable it for a debug run with:

```sh
flutter run --dart-define=MOTIONFIT_DEBUG_LOGGING=false
```

Completed sessions are written inside the app sandbox's database directory at
`motionfit_debug_sessions/session_<UTC timestamp>_<session id>.json`.
Release/profile builds never allocate a recorder or write these files.

The JSON contains `session`, `frames`, `detectorTransitions`, `repResults`,
`analyzerResults`, `coachDecisions`, and `ttsEvents`. Each frame includes the
structured derived features plus a raw `poseFrame` used only for replay.

## Replay

```sh
flutter test \
  --dart-define=MOTIONFIT_REPLAY_SESSION=/absolute/path/session.json \
  test/debug_session_replay_test.dart
```

Replay sends the stored PoseFrame sequence through the exercise's existing
feature extractor/detector, FormAnalyzer, and CoachPolicy and prints every rep
or plank checkpoint.

## Manual labels

Session and rep objects reserve nullable `manualLabel` and `manualIssue` fields.
Label a rep without manually editing JSON:

```sh
dart run tool/label_debug_session.dart /absolute/path/session.json \
  --rep 2 --label BAD --issue excessiveTorsoLean
```

Allowed labels are `GOOD`, `BORDERLINE`, and `BAD`. Use `--issue none` for no
manual issue. Replay prints TRUE/FALSE POSITIVE/NEGATIVE comparisons.
