# QA report

Target: `store-assets/output/{en,ko}/{iphone,ipad}/*.png` — **16 generated, 8 blocked**
Build 1.1.0 (10) / commit `eb0e807` / 2026-08-05

## Slot status

| # | Screen | en/iPhone | en/iPad | ko/iPhone | ko/iPad |
|---|---|---|---|---|---|
| 01 | Automatic squat counting | 🔴 | 🔴 | 🔴 | 🔴 |
| 02 | Real-time form analysis | 🔴 | 🔴 | 🔴 | 🔴 |
| 03 | Challenge | ✅ | ✅ | ✅ | ✅ |
| 04 | Sets & rest | ✅ | ✅ | ✅ | ✅ |
| 05 | Workout result | ✅ | ✅ | ✅ | ✅ |
| 06 | History | ✅ | ✅ | ✅ | ✅ |

🔴 = not generated. Requires a real-device capture; see [storyboard.md](storyboard.md) → "How to unblock screens 1 and 2".

## Automated preflight

```
python3 store-assets/scripts/preflight_assets.py
```

```
preflight: 16 images across 2 locale(s)
  ok  en/iphone: 4 images @ (1320, 2868) (6.9" iPhone)
  ok  en/ipad: 4 images @ (2064, 2752) (13" iPad)
  ok  ko/iphone: 4 images @ (1320, 2868) (6.9" iPhone)
  ok  ko/ipad: 4 images @ (2064, 2752) (13" iPad)

all checks passed
```

Checks: pixel size · portrait · PNG · **no alpha channel or transparency** · identical size within a size class · 1–10 per class · file size · no app pixels leaking into the message band · raw captures at device-native resolution · iPhone and iPad captures genuinely different.

## Requested checklist

| Question | Result |
|---|---|
| Is automatic counting immediately understood from screen 1? | ❌ **No — screen 1 does not exist.** Blocked on a real-device capture. This is the single largest gap. |
| Is real-time form analysis immediately understood from screen 2? | ❌ **No — screen 2 does not exist.** Same blocker. |
| Is a person squatting visible inside the device screen? | ❌ **No.** Only screens 1–2 would show this, and they are blocked. Nothing was faked to fill the gap. |
| Are pose lines and the counter UI shown together? | ❌ **No.** Same. |
| Do core workout features come before settings / records / reminders? | ✅ Settings, reminders and the coaching-toggle sheet were **removed** from the set entirely. The four generated screens are challenge, workout plan, workout result, history. |
| Is the headline readable at App Store thumbnail size? | ✅ Verified at 22% in `output/contact-sheet/*.jpg`. Headlines are 1 line, 96px (iPhone) / 116px (iPad). |
| Any fake iOS status bar, Android status bar, or platform confusion? | ✅ None. Status bar cropped out of every image; no Android, web, or third-party mockup material anywhere. |
| Any claim exaggerated beyond the real app? | ✅ None. Every subtitle number appears on the screen beside it. "Automatic counting" and "real-time analysis" wording ships only with screens 1–2. |
| Can a shopper understand the core feature from the screenshots alone? | ❌ **Not yet.** With screens 1–2 missing, the listing reads as a squat *logging* app. This is the honest state and is the reason to prioritise the device capture. |
| Is the differentiator clear enough to drive a download? | ❌ **Not yet.** Same cause. |

## Final gate

| # | Item | Result |
|---|---|---|
| 1 | Claims match [evidence.md](evidence.md) | ✅ 4 generated slots map to evidence items 1–6 |
| 2 | Captured directly from the current build | ✅ 1.1.0(10) / `eb0e807`, `xcrun simctl io … screenshot` |
| 3 | iPhone and iPad sources genuinely different | ✅ separate simulators, separate runs, different layouts and pixel sizes |
| 4 | No app UI, numbers, people or pose lines generated or edited | ✅ [edit-log.md](edit-log.md) |
| 5 | Status bar real-or-absent | ✅ absent, cropped consistently |
| 6 | No other-platform imagery | ✅ |
| 7 | No device frames | ✅ none used |
| 8 | Headline 1–2 lines, legible when small | ✅ all 1 line |
| 9 | Subtitle 0–1 lines | ✅ all 1 line |
| 10 | Pixel sizes match the target slots | ✅ 1320×2868 / 2064×2752 |
| 11 | No alpha channel | ✅ all RGB, no transparency chunk |
| 12 | No personal data or real account info | ✅ no sign-in, no photos of people, Simulator-seeded data only |
| 13 | Camera permission pre-prompt complies | ✅ single neutral button — see below |
| 14 | No medical / therapeutic / injury-prevention claims | ✅ |
| 15 | No abstract marketing words (*easy, smart, better life*) | ✅ |
| 16 | No ads, debug UI, loading states or permission popups in frame | ✅ ad gate disabled during capture and **restored**; `debugShowCheckedModeBanner: false`; ATT prompt dismissed before capture |

## Camera permission pre-prompt

[camera_permission_screen.dart](../lib/features/squat/presentation/screens/camera_permission_screen.dart):

| Condition | Result |
|---|---|
| Exactly one button before the system prompt | ✅ single `FilledButton` |
| That button opens the system prompt | ✅ `_request()` → `PermissionService.requestCamera()` |
| Neutral wording | ✅ `계속` / `Continue` / `続ける` / `Weiter` / `Continuer` / `Continuar` / `متابعة` |
| No pre-steering language | ✅ no "Allow camera access", no "허용" |
| No imitation system alert, arrows, or "tap Allow" guidance | ✅ none |

Not included in the screenshot set, per the rule that permission screens don't belong in the core slots.

## Outstanding risks

| Risk | Level | Detail |
|---|---|---|
| **Core feature absent from the listing** | **High** | Automatic counting and live form analysis — the two things that differentiate this app — appear nowhere. Not a rejection risk, but a conversion problem, and it is the stated top objective. Only a real-device capture fixes it. |
| Status bar contrast bug | Medium | Real defect still in the shipping app: light-content status bar over a light background ([motionfit_theme.dart:103](../lib/app/theme/motionfit_theme.dart:103)). Screenshots avoid it by cropping; users still see it. |
| Voice output unverified | Medium | The app calls the iOS speech stack, but Simulator voice assets fail, so audible output is unconfirmed. No "voice" wording is used anywhere. Verify on device before writing voice claims into the listing description. |
| Seeded demo data | Low | Session rows were seeded into the app's own database in the Simulator; all aggregates are computed by production code. Standard demo-data practice, but not a record of real use. |
| iPad `05` upscaled 1.26× | Low | Proportional enlargement of a 2×-density capture, done for legibility. No distortion, no retouching. |
| Locale coverage | Low | en (reference) and ko generated. ja/de/fr/es/ar can be added with the same pipeline once screens 1–2 are settled. |

## Not delivered

- Screens 01 and 02 for all four locale/device combinations — real-device capture required.
- The dedicated rest screen and the post-workout summary screen — same blocker; the records result block covers slot 05's required elements in the meantime.
- ja / de / fr / es / ar sets.
- Google Play assets — need a real Android build and real Android captures on a fully separate pipeline.
