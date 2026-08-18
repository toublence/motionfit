# Edit log

Everything applied to the raw captures. Only the permitted operations were used: **crop, uniform proportional scale, corner mask, and placement on a flat background with headline text.**

No pixel inside an app screenshot was redrawn, recoloured, retouched, in-painted, generated, or otherwise altered. No number was edited.

## Per-scene operations

All images go through the same pipeline ([`scripts/compose_store_assets.py`](scripts/compose_store_assets.py)).

### iPhone 6.5" slot — canvas 1242 × 2688, message band 753px (28.0%)

Raw captures are the iPhone 17 Pro Max native 1320 × 2868, scaled down proportionally onto the smaller canvas.

| Scene | Source | Crop | Uniform scale | Placed | Corner mask |
|---|---|---|---|---|---|
| `01-auto-count` | `00-auto-count.png` | status bar, top 186px → 1320 × 2682 | 0.6879 → 908 × 1845 | centred | r = 45px |
| `02-form-analysis` | `00-form-analysis.png` | status bar, top 186px → 1320 × 2682 | 0.6879 → 908 × 1845 | centred | r = 45px |
| `03-challenge` | `02-challenge.png` | status bar, top 186px → 1320 × 2682 | 0.6879 → 908 × 1845 | centred | r = 45px |
| `04-sets-rest` | `01-home.png` | status bar, top 186px → 1320 × 2682 | 0.6879 → 908 × 1845 | centred | r = 45px |
| `05-workout-result` | `04-records.png` | scene crop `(32, 1390, 1288, 2680)` → 1256 × 1290 | 0.8455 → 1062 × 1091 | centred | r = 53px |
| `06-history` | `04-records.png` | status bar, top 186px → 1320 × 2682 | 0.6879 → 908 × 1845 | centred | r = 45px |

### iPad 13" — canvas 2064 × 2752, message band 716px (26.0%)

| Scene | Source | Crop | Uniform scale | Placed | Corner mask |
|---|---|---|---|---|---|
| `03-challenge` | `02-challenge.png` | status bar, top 48px → 2064 × 2704 | 0.7123 → 1470 × 1926 | centred | r = 74px |
| `04-sets-rest` | `01-home.png` | status bar, top 48px → 2064 × 2704 | 0.7123 → 1470 × 1926 | centred | r = 74px |
| `05-workout-result` | `04-records.png` | scene crop `(330, 855, 1734, 1760)` → 1404 × 905 | **1.2564 (enlarge)** → 1764 × 1137 | centred | r = 88px |
| `06-history` | `04-records.png` | status bar, top 48px → 2064 × 2704 | 0.7123 → 1470 × 1926 | centred | r = 74px |

Scale is identical horizontally and vertically in every row — no stretching, no aspect change. The one enlargement (iPad `05`) is a proportional upscale of a 2×-density capture, done so the metrics stay legible at thumbnail size; it is still an untouched app image.

### Why `05` and `06` share a source

The Records screen shows both the month calendar and the result block. On iPad the whole screen fits without scrolling, so the two slots would otherwise be identical images. `05` is cropped to the result block — which is also what makes the numbers large — and `06` shows the full screen. Two different framings of the same real screen, no synthesis.

## Slots 01 / 02 — how the workout screens were made

The two camera screens are a real iOS render of the real workout screen. Nothing
about the app's output was drawn by hand.

**1. The app was driven, not faked.** `poseEngineFactoryProvider` was temporarily
pointed at the app's own `ReplayPoseEngine`, fed a landmark-only squat sequence.
Everything downstream ran unmodified production code:

| On screen | Produced by |
|---|---|
| `1 / 3세트`, `3 / 10회`, `누적 3회` | `RepDetector` counting the replayed reps |
| Pose skeleton geometry, line weights, joint dots | `PoseOverlay` / `_PosePainter` |
| Green skeleton (slot 01) | `PoseFeedbackClassifier` → `PoseFeedbackLevel.good` |
| Amber skeleton (slot 02) | `PoseFeedbackClassifier` → `PoseFeedbackLevel.caution` on that pose |
| Counter card, stop button, status bar | iOS render, untouched |

**2. The skeleton was aimed at the photo.** The replayed landmarks are the joint
positions of the reference photograph, read off the image, converted to
screen-normalised coordinates and pre-mirrored to match the preview flip. So the
app drew its own overlay exactly onto the subject's joints.

**3. The photo was substituted for the camera feed, not painted over the app.**
Two captures of the same frame were taken, identical except for the flat colour
where the camera preview would be — one on black, one on white. Comparing them
recovers, per pixel, how much of that flat colour is still visible through every
app layer, including the semi-transparent counter card:

```
capture_black = a·O
capture_white = a·O + (1-a)·255      =>  1-a = (white - black)/255
result        = a·O + (1-a)·photo    =   black + (1-a)·photo
```

Every pixel the app rendered keeps its own colour **and its own translucency**.
No app pixel is repainted, recoloured, redrawn or erased.
[`scripts/add_figure.py`](scripts/add_figure.py)

**4. What is not real.** The person is a synthetic image
(`_deprecated-2026-08-05/source/people/squat_deep.png`, `squat_coaching.png`),
used at the owner's explicit direction. The app screen around it is a genuine
capture, and the app contains no on-screen coaching-text widget, so none was
invented — unlike the previously rejected version, which added a "Voice
coaching" banner and a "Knee detected" chip that do not exist in the app, and
placed the whole thing in a drawn phone mockup.

**Temporary app changes, all reverted** — see [RESTORE-ME.md](RESTORE-ME.md).

## Status-bar handling

The raw captures' status bar glyphs are pure white (255, 255, 255) on a (246, 247, 249) background — a contrast ratio of about **1.03 : 1**, effectively invisible. Cause: [motionfit_theme.dart:103](../lib/app/theme/motionfit_theme.dart:103) sets `AppBarTheme(backgroundColor: Colors.transparent)` without `systemOverlayStyle`, so a light-content status bar is requested over a light background.

The second option of the status-bar gate was taken:

- ✅ The app screen is **cropped consistently so no status bar is visible at all** — the same per-device inset on every image, and the scene crops for `05` sit well below it.
- ❌ No status bar was drawn or generated.
- ❌ No clock / Wi-Fi / cellular / battery glyphs were taken from another image.
- ❌ No partial erase with generative fill.
- ❌ No iPhone status bar placed on an iPad screen, or the reverse.

Verified that the inset never clips app content: the first content row below the inset is at y ≥ 237 on iPhone and y ≥ 98 on iPad across all captures.

## Device frames

No third-party or mockup device frames. The app capture itself is the visual, with only a corner mask — this also keeps the on-screen information as large as possible, which a frame would shrink.

## Background and decoration

- Flat vertical gradient only: `#2E5A85 → #183048`, fully opaque.
- No generated people, workout scenes, devices, OS UI, notifications or status bars used as decoration.
- No logo, no watermark.
- Type: Apple SD Gothic Neo Bold / Medium (system font), renders both Latin and Hangul.

## Quarantined legacy assets

Moved to [`_deprecated-2026-08-05/`](_deprecated-2026-08-05/), not deleted.

| Item | Why it was discarded |
|---|---|
| `source/people/*.png` | AI-generated human figures. `squat_deep.png` and `squat_coaching.png` are now reused as the camera subject in slots 01/02 at the owner's direction; the rest are unused. |
| `source/real/**` | Harness renders that composited pose lines over those generated figures — not real camera input. |
| `output/**` (old) | Built from the above, and sized 1242 × 2688, which is not a current 6.9" size. |
| `scripts/generate_*.py`, `capture_real.py`, `validate_*.py` | Belonged to that pipeline; depend on a deleted `lib/store_screenshot_main.dart` harness. |
| `contact-sheets/`, `translations/`, `feature-graphics/` | Outputs of the same pipeline. `feature-graphics` is Google Play material and needs separate verification. |
