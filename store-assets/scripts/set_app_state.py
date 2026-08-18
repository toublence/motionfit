#!/usr/bin/env python3
"""Set app preferences inside an iOS Simulator container before capture.

Writes the same `user_preferences_v1` JSON blob the app's own
`PreferencesService` writes, so the app loads it through its normal
`UserPreferences.decode` path. Used to pin the locale (the app's in-app
language setting) and the workout plan so every locale renders the same
plan, instead of hand-driving pickers 45 times per device.

No app source is modified; simulator container state is disposable.

Usage:
    python3 store-assets/scripts/set_app_state.py <udid> --locale ko
"""
from __future__ import annotations

import argparse
import json
import plistlib
import subprocess
from pathlib import Path

BUNDLE_ID = "com.namslab.motionfit.squat"
KEY = "user_preferences_v1"

SET_COUNT = 3
REPS_PER_SET = 10
REST_SECONDS = 60


def plist_path(udid: str) -> Path:
    """Resolve the app's preferences plist.

    `simctl get_app_container` only answers on a booted device, but the plist
    has to be written while the device is shut down - otherwise cfprefsd holds
    the old values in memory and flushes them back over the file.
    """
    try:
        container = subprocess.run(
            ["xcrun", "simctl", "get_app_container", udid, BUNDLE_ID, "data"],
            check=True, capture_output=True, text=True,
        ).stdout.strip()
        return Path(container) / "Library" / "Preferences" / f"{BUNDLE_ID}.plist"
    except subprocess.CalledProcessError:
        root = (Path.home() / "Library/Developer/CoreSimulator/Devices" / udid
                / "data/Containers/Data/Application")
        matches = sorted(root.glob(f"*/Library/Preferences/{BUNDLE_ID}.plist"))
        if not matches:
            raise SystemExit(f"no preferences plist for {BUNDLE_ID} on {udid}")
        return matches[-1]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("udid")
    parser.add_argument("--locale", required=True,
                        choices=[
                            "ko", "en", "ja", "de", "fr", "es", "ar",
                            "zh", "zh_Hant",
                        ])
    args = parser.parse_args()

    path = plist_path(args.udid)
    with path.open("rb") as handle:
        root = plistlib.load(handle)

    preferences = json.loads(root.get(KEY, "{}"))
    preferences.setdefault("lastWorkoutPlan", {
        "id": "store-shot",
        "set_count": SET_COUNT,
        "target_reps_per_set": REPS_PER_SET,
        "rest_duration_seconds": REST_SECONDS,
        "created_at": 0,
        "updated_at": 0,
    })
    preferences["locale"] = args.locale
    preferences["onboardingCompleted"] = True
    preferences["cameraGuideSeen"] = True
    plan = preferences["lastWorkoutPlan"]
    plan["set_count"] = SET_COUNT
    plan["target_reps_per_set"] = REPS_PER_SET
    plan["rest_duration_seconds"] = REST_SECONDS
    root[KEY] = json.dumps(preferences, separators=(",", ":"))

    with path.open("wb") as handle:
        plistlib.dump(root, handle)
    print(f"{args.udid}: locale={args.locale} "
          f"plan={SET_COUNT}x{REPS_PER_SET} rest={REST_SECONDS}s")


if __name__ == "__main__":
    main()
