# Pose corpus evaluation

The evaluator replays landmark-only JSON through the production rep detector in
timestamp order. It reports exact-count accuracy, count precision/recall/F1,
and mean absolute count error. It rejects replay files containing image or pixel
payload fields.

Run a smoke evaluation:

```sh
dart run tool/evaluate_pose_corpus.dart \
  --manifest test/fixtures/corpus/synthetic_smoke_manifest.json \
  --format markdown
```

Exit code `0` means the target was validated on an eligible corpus. Exit code
`2` means the run completed but the corpus was ineligible or metrics were below
target. Input/schema failures use a nonzero error exit code.

## Manifest contract

```json
{
  "schemaVersion": 1,
  "corpus": {
    "id": "field-corpus-v1",
    "provenance": "real_recorded_landmarks",
    "humanLabeled": true,
    "subjectCount": 10
  },
  "cases": [
    {
      "id": "subject-01-clip-001",
      "replay": "replays/subject-01-clip-001.json",
      "expectedReps": 10,
      "calibration": {
        "baselineKneeAngle": 176.0,
        "baselineHipAngle": 171.0,
        "baselineHipY": 0.45,
        "baselineShoulderY": 0.2,
        "bodyScale": 0.7,
        "motionNoiseMad": 0.002,
        "cameraAngle": "side",
        "calibratedAtUs": 0
      }
    }
  ]
}
```

If `calibration` is omitted, the replay must include enough initial standing
frames for normal calibration.

## 97% qualification gate

Synthetic data can verify determinism and regressions, but it cannot validate a
production accuracy claim. The report marks the 97% target as validated only
when all three metrics (exact-count accuracy, count precision, and count recall)
reach 97% and the corpus is:

- human-labeled, with provenance `real_recorded_landmarks`;
- at least 100 clips across at least 10 subjects;
- at least 500 labeled repetitions; and
- at least 20 negative clips with zero expected repetitions.

The committed fixture is intentionally synthetic and its expected report is
`INELIGIBLE_CORPUS`, even though its one negative smoke case is counted exactly.
