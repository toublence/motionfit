# Feature evidence

Build 1.1.0 (10) / commit `eb0e807`. A claim is usable only when it is confirmed **both** in source and in a running capture.

## Claims used in the generated screenshots

| # | Claim | Source | Run path | Real capture | Build/commit | Usable |
|---|---|---|---|---|---|---|
| 1 | Cumulative rep challenge with goal, progress, reps remaining and days left | [challenge_controller.dart:366-405](../lib/features/challenges/application/challenge_controller.dart:366) `calculateProgress`; [challenge.dart](../lib/features/challenges/domain/challenge.dart) `ChallengeType.cumulative` | Bottom tab → Challenge | `captures/ios/en/*/02-challenge.png` — 310/500 reps, 62%, 190 to go, 18 days left | 1.1.0(10) / eb0e807 | ✅ |
| 2 | User-set sets, reps per set and rest duration | [squat_home_screen.dart:121-170](../lib/features/squat/presentation/screens/squat_home_screen.dart:121); [workout_plan.dart](../lib/features/squat/domain/models/workout_plan.dart) | App launch → Home | `…/01-home.png` — 3 sets, 10 reps, 60s rest | 1.1.0(10) / eb0e807 | ✅ |
| 3 | Today's reps, sets and consecutive-day streak | [retention_metrics.dart:15-52](../lib/features/records/domain/retention_metrics.dart:15) | Home top card | `…/01-home.png` — 30 / 3 / 7 days | 1.1.0(10) / eb0e807 | ✅ |
| 4 | Session result: total reps, sets, active time, rest time, form summary, completion state | [calendar_records_view.dart:140-215](../lib/features/records/presentation/widgets/calendar_records_view.dart:140) `_DailyTotalCard`, `_SessionCard` | Bottom tab → Records | `…/04-records.png` — 30 / 3 / 1min38s / 2min0s / 92% / Workout complete / 3-3 | 1.1.0(10) / eb0e807 | ✅ |
| 5 | Monthly calendar with marked workout days | [monthly_workout_calendar.dart](../lib/features/records/presentation/widgets/monthly_workout_calendar.dart) | Bottom tab → Records | `…/04-records.png` | 1.1.0(10) / eb0e807 | ✅ |
| 6 | In-app language switching (ko/en/ja/de/fr/es/ar) | [user_preferences.dart:35](../lib/features/settings/domain/user_preferences.dart:35); [settings_screen.dart:392-432](../lib/features/settings/presentation/settings_screen.dart:392) | Settings → Language | ko and en sets render genuinely different UI strings | 1.1.0(10) / eb0e807 | ✅ |

## Claims planned for screens 1–2 — implemented but NOT captured

These are the app's headline features. The code exists and is wired into the live session; what is missing is a capture of it running.

| Claim | Source | Execution status | Blocker |
|---|---|---|---|
| Automatic squat counting from the camera | [rep_detector.dart](../lib/features/squat/domain/services/rep_detector.dart); [native_pose_engine.dart](../lib/features/squat/data/native_pose_engine.dart); [workout_session_controller.dart:609-620](../lib/features/squat/application/workout_session_controller.dart:609) — the production engine factory returns `NativePoseEngine` unconditionally | ❌ **Not run** | Requires real camera frames. `NativePoseEngine` drives `AVCaptureDevice` through the `motionfit_pose` plugin; the iOS Simulator exposes no capture device, so the session cannot start and no counting frame exists. |
| Real-time pose landmarks over the camera preview | [pose_overlay.dart](../lib/features/squat/presentation/widgets/pose_overlay.dart); [pose_landmark_smoother.dart](../lib/features/squat/domain/services/pose_landmark_smoother.dart) | ❌ **Not run** | Same. Landmarks are computed from live frames only. |
| Real-time form analysis and coaching cues | [form_analyzer.dart](../lib/features/squat/domain/services/form_analyzer.dart); [pose_feedback_classifier.dart](../lib/features/squat/domain/services/pose_feedback_classifier.dart); [workout_coach_messages.dart](../lib/features/squat/application/workout_coach_messages.dart) | ❌ **Not run** | Same. Feedback is emitted per detected rep. |
| Rest timer and next-set flow | [rest_screen.dart](../lib/features/squat/presentation/screens/rest_screen.dart) | ❌ **Not run** | `/workout/rest` is only reachable from an active session, which needs the camera. |
| Post-workout summary screen | [workout_summary_screen.dart](../lib/features/squat/presentation/screens/workout_summary_screen.dart) | ❌ **Not run** | Same. The equivalent numbers are shown by the records result block, which **is** captured (claim 4). |

**These screens were not generated.** No mockup, no generated person, no synthetic pose overlay was substituted. See [storyboard.md](storyboard.md) → "How to unblock screens 1 and 2".

## Claim deliberately withheld

| Claim | Status | Decision |
|---|---|---|
| Voice coaching (audible output) | ⚠️ **Partially confirmed.** Tapping *Voice test* makes the app call the iOS speech stack — the log shows a `com.apple.accessibility.voices` XPC session opening from `Runner`. But the Simulator's voice asset database fails (`Error fetching voices … Using fallback voices`), so audible output could not be verified. | The words "voice" / "음성" are not used in any headline or subtitle. Screen 2 says *"See coaching cues"*, which is claimable from the on-screen feedback UI alone. Verify on a real device before adding any voice wording to the listing or description. |

## Copy exclusions

- No medical, therapeutic, injury-prevention or posture-correction claims.
- No "real-time" or "automatic counting" wording on the generated screens 3–6, because those screens do not show it. The wording is reserved for screens 1–2 and ships only with their captures.
- Abstract marketing words excluded: *easy, smart, better life, personalised, effortless*.

## Where the on-screen numbers come from

| Shown | Produced by |
|---|---|
| 30 reps / 3 sets today | The app aggregating today's session (3 sets × 10 reps) |
| 7 days streak | `RetentionMetrics` counting consecutive dates |
| 310 / 500 reps, 62%, 190 to go, 18 days left | `ChallengeController.calculateProgress` over sessions and the challenge window |
| 1 min 38 sec / 2 min 0 sec | App formatter over `active_duration_seconds` 98 and `rest_duration_seconds` 120 |
| 92% form summary | App averaging `overall_form_score` across rep records and rounding |

Underlying session rows were seeded into the app's own SQLite database inside the Simulator container; every aggregate above is computed by production Dart code at render time. No number was edited in an image editor. Details in [capture-manifest.md](capture-manifest.md).
