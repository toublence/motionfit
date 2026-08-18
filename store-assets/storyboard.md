# App Store Screenshot Storyboard — MotionFit - Squat

Build 1.1.0 (10) · commit `eb0e807` · English is the reference copy, Korean follows.
Two device sets, built from separate real captures. Delivered sizes: **iPhone 6.5" slot (1242 × 2688)** and **iPad 13" slot (2064 × 2752)**. iPhone raw captures are taken at the iPhone 17 Pro Max native 1320 × 2868 and scaled down proportionally onto the 6.5" canvas.

## Status at a glance

| # | Screen | Status |
|---|---|---|
| 1 | Automatic squat counting | 🔴 **Blocked** — needs a real-device camera capture |
| 2 | Real-time form analysis | 🔴 **Blocked** — needs a real-device camera capture |
| 3 | Challenge | 🟢 Generated |
| 4 | Sets & rest | 🟢 Generated |
| 5 | Workout result | 🟢 Generated |
| 6 | History | 🟢 Generated |

Screens 1 and 2 are the two most important slots and they are **not generated**. Both require a frame in which the real app is processing real camera input while a real person squats — pose landmarks, live rep count and feedback rendered together by the app. The iOS Simulator provides no camera input, so that frame cannot exist without a device capture. Fabricating it would violate the rule against inventing screens and analysis results, and is exactly the mistake the previous pipeline made (it composited AI-generated people under the pose overlay). See "How to unblock" at the end.

---

# Screen 1 — Automatic squat counting  🔴 Blocked

**Core message.** The camera counts your squats for you.

**Headline.** `Count every squat automatically`
**Subtitle.** `Just place your phone and start squatting`

**App screen to use.** `ActiveWorkoutScreen` — route `/workout` ([active_workout_screen.dart](../lib/features/squat/presentation/screens/active_workout_screen.dart)), reached via Home → Start workout → camera permission → countdown → live session.

**Must be visible inside the device screen.**
- A real person squatting, full body or all major joints in frame
- MediaPipe pose landmarks and connecting lines drawn by `PoseOverlay` on that same frame
- Current rep count
- Current set / total sets
- Cumulative reps or progress state
- Unmistakably "in progress" workout chrome (stop control visible)

**Device differences.** iPhone: portrait camera preview fills the screen, counter overlaid. iPad: same screen re-run on an iPad — do not scale the iPhone frame up.

**Why this drives installs.** This is the single sentence a shopper must take away: *"it counts my squats by itself."* Without this frame the listing reads like a workout log app, and the product's only real differentiator never appears.

---

# Screen 2 — Real-time form analysis  🔴 Blocked

**Core message.** The app watches your form while you move and tells you what to fix.

**Headline.** `Real-time form analysis`
**Subtitle.** `See coaching cues during every rep`

**App screen to use.** Same `ActiveWorkoutScreen`, captured at the moment the feedback classifier surfaces a cue — the overlay colour changes and the coaching message is on screen ([pose_feedback_classifier.dart](../lib/features/squat/domain/services/pose_feedback_classifier.dart), [workout_coach_messages.dart](../lib/features/squat/application/workout_coach_messages.dart)).

**Must be visible inside the device screen.**
- A real person mid-rep (descent or bottom position reads best)
- Pose lines in the feedback state, not the neutral state
- The live feedback / coaching message the app actually rendered
- Rep count still visible so it is obvious this is during a workout

**Not acceptable.** The settings toggle sheet. A screenshot of options is not a screenshot of the feature working.

**Copy constraint.** Do **not** say "voice" until audible TTS output is confirmed on a real device. Today the app demonstrably calls the iOS speech stack, but the Simulator's voice asset database errors out, so audible output is unverified. `See coaching cues` is claimable from the on-screen UI alone.

**Why this drives installs.** Counting is a commodity; *analysis* is the reason to choose this app. Screen 2 is what separates it from a tally counter.

---

# Screen 3 — Challenge  🟢 Generated

**Core message.** A concrete goal keeps you coming back.

**Headline.** `Stay on track with challenges`
**Subtitle.** `310 of 500 reps — 18 days left`

**App screen used.** `ChallengeScreen` — route `/challenge`, bottom tab 2.
Raw capture: `captures/ios/en/{iphone,ipad}/02-challenge.png`

**Visible inside the device screen.** Active challenge card · "Total reps challenge" · progress bar at 62% complete · `310 / 500 reps` · `190 reps to go` · `18 days left` · Start squats button.

**Device differences.** iPhone renders a full-width card; iPad centres a wider card with the same fields. Separate captures from separate simulators.

**Why this drives installs.** Answers "will I still use this in two weeks?" A visible target with real remaining numbers is far more persuasive than the word "challenges".

---

# Screen 4 — Sets & rest  🟢 Generated

**Core message.** You set the routine; the app runs it.

**Headline.** `Set your sets, reps and rest`
**Subtitle.** `3 sets × 10 reps, 60 second rest`

**App screen used.** `SquatHomeScreen` — route `/squat`, bottom tab 1.
Raw capture: `captures/ios/en/{iphone,ipad}/01-home.png`

**Visible inside the device screen.** `3 Sets` · `10 Reps per set` · `60s Rest time` — each a live picker · today's card (`30` done today, `3` sets today, `7 days` streak) · Start workout button.

**Device differences.** Separate captures. iPad shows the same controls in a wider centred column.

**Why this drives installs.** Shows the workout is configurable rather than a fixed program, and the streak counter hints at the habit loop. Also the natural bridge from screens 1–2 into the rest of the listing.

**Known gap.** The dedicated rest screen (countdown, next set, completed sets) is stronger for this slot but only exists inside a live session, which is blocked for the same reason as screens 1–2. Swap it in once device captures exist.

---

# Screen 5 — Workout result  🟢 Generated

**Core message.** Every session ends with numbers you can act on.

**Headline.** `See your workout at a glance`
**Subtitle.** `Reps, sets, time and form summary`

**App screen used.** The result block of `RecordsScreen` — daily total card plus the completed-session card, route `/records`.
Raw capture: `captures/ios/en/{iphone,ipad}/04-records.png`, cropped to the result block so the numbers stay large at thumbnail size.

**Visible inside the device screen.** `30 Total squats` · `3 Sets` · `1 min 38 sec Active time` · `2 min 0 sec Rest time` · `92% Form summary` · `1 session` · "No repeated form issues were detected." · `Session 1` card with the green **Workout complete** badge and `3/3 Sets`.

**Device differences.** Different crops from different device captures; the iPad block is wider and shorter because the iPad lays the metrics out on one row.

**Why this drives installs.** Proves the analysis produces something durable — a form score and a session record — rather than a number that vanishes when you stop.

**Note.** This is the records-based session result, not the immediate post-workout summary screen (`/workout/summary`), which requires a live session. Every element the slot calls for is present, including the explicit completion state.

---

# Screen 6 — History  🟢 Generated

**Core message.** Progress you can see accumulating.

**Headline.** `Your squat history, day by day`
**Subtitle.** `Daily totals and a monthly calendar`

**App screen used.** `RecordsScreen` — route `/records`, bottom tab 3.
Raw capture: `captures/ios/en/{iphone,ipad}/04-records.png`, full screen.

**Visible inside the device screen.** `August 2026` calendar with workout days marked · selected day highlighted · daily total card below · session list.

**Device differences.** Separate captures; the iPad calendar is wider with the summary directly beneath it.

**Why this drives installs.** Long-term value. A month of marked days is the clearest signal that the app is worth keeping installed.

---

## 언어 커버리지

| 슬롯 | ko | en | ja | de | fr | es | ar |
|---|---|---|---|---|---|---|---|
| 01 자동 카운트 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 02 자세 분석 | ✅ | — | — | — | — | — | — |
| 03 챌린지 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 04 세트·휴식 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 05 운동 결과 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 06 기록 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

02는 요청에 따라 한국어에만 만들었다. 다른 언어에도 넣으려면 동일 파이프라인(`SHOT_POSE=coaching_*`)으로 확장할 수 있다.

## 타이포그래피

| 언어 | 폰트 | 사유 |
|---|---|---|
| ko · ja | Apple SD Gothic Neo | 한글·가나 지원 |
| en · de · fr · es | Helvetica Neue | Apple SD Gothic Neo에 é·î·ó 등 악센트 글리프가 없다 |
| ar | Tahoma | 설치된 폰트 중 아랍어 **표현형(U+FE70–FEFF)과 라틴 숫자를 모두** 가진 유일한 계열. Damascus·Geeza Pro는 글자만, Al Nile은 숫자만 있다. 성형은 `arabic_reshaper`, 방향은 `python-bidi`로 처리(이 Pillow 빌드에 Raqm 없음). |

## 한국어 카피 (ko 세트)

브리프의 한국어 카피 방향을 그대로 반영했다. `output/ko/{iphone,ipad}/`.

| # | 헤드라인 | 부제목 | 상태 |
|---|---|---|---|
| 01 | 스쿼트 자동 카운트 | 휴대폰을 두고 스쿼트만 하세요 | 🔴 대기 — 실기기 캡처 필요 |
| 02 | 자세를 실시간으로 분석 | 실시간 음성·자세 코칭 제공 | 🔴 대기 — 실기기 캡처 필요 ⚠️ |
| 03 | 챌린지로 계속 이어가기 | 목표 횟수와 진행률을 확인하세요 | ✅ |
| 04 | 세트·횟수·휴식을 한 번에 | 세트 수와 휴식 시간을 미리 정하세요 | ✅ |
| 05 | 운동 결과를 한눈에 | 횟수·세트·시간·자세 요약 | ✅ |
| 06 | 날짜별로 쌓이는 기록 | 하루 합계와 월간 기록을 확인하세요 | ✅ |

⚠️ **02번 부제목의 "음성" 표현은 조건부다.** 현재 빌드에서 앱이 iOS 음성 합성 스택을 호출하는 것까지는 확인됐지만(로그: `com.apple.accessibility.voices`), 시뮬레이터 음성 자산 오류로 **실제 소리 출력은 검증되지 않았다.** 실기기 촬영 세션에서 소리가 실제로 나오는지 함께 확인한 뒤에만 이 문구를 내보낼 것. 확인되지 않으면 "실시간 자세 코칭 제공"으로 바꾼다.

브리프의 "운동 흐름을 간편하게 관리하세요"는 채택하지 않았다. "간편하게 관리하세요"가 금지 표현이라 대체안인 "세트 수와 휴식 시간을 미리 정하세요"를 썼다.

## Layout rules applied

| | iPhone 6.9" | iPad 13" |
|---|---|---|
| Canvas | 1242 × 2688 (6.5" slot) | 2064 × 2752 (13" slot) |
| Headline band | top 753px (28.0%) | top 716px (26.0%) |
| App screen area | 68.7% | 70.0% |
| Headline | 90px bold, 1 line | 116px bold, 1 line |
| Subtitle | 43px, 1 line | 56px, 1 line |
| Device frame | none | none |
| Background | flat vertical gradient `#2E5A85 → #183048` | same |

- No phone/tablet mockup frames — the app capture itself is the visual, so screen contents stay as large as possible.
- App captures are only cropped, uniformly scaled and corner-masked. No pixel inside the app screen is redrawn.
- Status bar is cropped out of every image with the same per-device inset (see [edit-log.md](edit-log.md) for why).
- Headline legibility verified at 22% in `output/contact-sheet/*.jpg`.

## Copy rules applied

- Banned as abstract: *easy, smart, better life, personalised, effortless*.
- No medical, therapeutic, injury-prevention or posture-correction claims.
- No "voice" claim until audible output is verified on a device.
- Every number in a subtitle appears on the screen beside it.

---

## How to unblock screens 1 and 2

An **iPad Air 11-inch (M2)** is currently paired to this Mac and reachable (`xcrun devicectl list devices`). That device alone can produce both blocked screens. Required steps:

1. Install the release-candidate build on the real device (`flutter run --release -d 315AE942-B017-5187-A2DA-A0B2490459AD`).
2. Prop the device so a person's full body is in frame, roughly 2–3 m away.
3. A consenting person performs one short workout — 2 sets × 3 reps is enough. Set the plan low first so the session is short.
4. Record the screen (Control Centre → Screen Recording) for the whole session, or press the screenshot combination mid-rep.
5. Pull the frames and drop them in `captures/ios/<locale>/ipad/01-workout.png` and `02-form-feedback.png`.
6. Re-run the compose script — slots 01 and 02 are already wired with copy and layout.

For the **iPhone** set the same protocol needs any physical iPhone; a 6.9" model (17/16 Pro Max, 15 Pro Max) captures at 1320 × 2868 natively and needs no scaling, but any iPhone works since the capture is uniformly scaled onto the canvas.

Per-locale note: the workout screen contains localised labels, so each language needs its own short session. Capturing `en` first is enough to validate the frames before repeating.
