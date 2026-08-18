#!/usr/bin/env python3
"""Seed the app's own SQLite database inside an iOS Simulator container.

Every number that appears in a store screenshot is produced by the app itself:
this script only writes rows into the schema the app created (schema v4), using
values the app's own workout pipeline could produce. Aggregates shown in the UI
(streak, daily totals, challenge progress, average form score, durations) are
computed at render time by production Dart code, never written here.

The simulator container is disposable test data. No app source is modified.

Usage:
    python3 store-assets/scripts/seed_demo_data.py <simulator-udid> [...]
"""
from __future__ import annotations

import datetime as dt
import subprocess
import sqlite3
import sys
import uuid
from pathlib import Path

BUNDLE_ID = "com.namslab.motionfit.squat"

# Plan shown across the listing: 3 sets x 10 reps, 60s rest.
SET_COUNT = 3
REPS_PER_SET = 10
REST_SECONDS = 60

# Days ago -> sets completed that day. The plan grew from 2 sets to 3 over the
# month, which is what a real user's history looks like. 0..6 are consecutive
# so the app computes a 7-day streak.
WORKOUT_DAYS = {
    0: 3, 1: 3, 2: 3, 3: 3, 4: 3, 5: 3, 6: 3,
    8: 3, 9: 3,
    11: 2, 12: 2, 14: 2, 15: 2,
}
WORKOUT_DAYS_AGO = sorted(WORKOUT_DAYS)

# Weekly reminders the app schedules: Mon / Wed / Fri at 07:00.
REMINDER_WEEKDAYS = (1, 3, 5)
REMINDER_HOUR = 7
REMINDER_MINUTE = 0

CHALLENGE_TARGET_REPS = 500
CHALLENGE_STARTED_DAYS_AGO = 12
CHALLENGE_LENGTH_DAYS = 30


def ms(value: dt.datetime) -> int:
    return int(value.timestamp() * 1000)


def app_db_path(udid: str) -> Path:
    container = subprocess.run(
        ["xcrun", "simctl", "get_app_container", udid, BUNDLE_ID, "data"],
        check=True, capture_output=True, text=True,
    ).stdout.strip()
    return Path(container) / "Documents" / "motionfit.db"


def seed(db_path: Path) -> None:
    today = dt.datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    connection = sqlite3.connect(db_path)
    connection.execute("PRAGMA foreign_keys = ON")
    cursor = connection.cursor()

    for table in ("rep_records", "workout_sets", "workout_sessions",
                  "challenges", "workout_plans"):
        cursor.execute(f"DELETE FROM {table}")

    plan_created = today - dt.timedelta(days=max(WORKOUT_DAYS_AGO))
    cursor.execute(
        "INSERT INTO workout_plans (id, set_count, target_reps_per_set,"
        " rest_duration_seconds, created_at, updated_at) VALUES (?,?,?,?,?,?)",
        (str(uuid.uuid4()), SET_COUNT, REPS_PER_SET, REST_SECONDS,
         ms(plan_created), ms(today)),
    )

    for index, days_ago in enumerate(sorted(WORKOUT_DAYS_AGO, reverse=True)):
        day = today - dt.timedelta(days=days_ago)
        set_count = WORKOUT_DAYS[days_ago]
        started = day.replace(hour=7, minute=30)
        # Rep pace drifts a little between days, the way real sessions do.
        rep_ms = 3100 + (index % 5) * 90
        active_seconds = round(rep_ms * set_count * REPS_PER_SET / 1000)
        rest_seconds = REST_SECONDS * (set_count - 1)
        total_seconds = active_seconds + rest_seconds
        total_reps = set_count * REPS_PER_SET
        session_id = str(uuid.uuid4())
        cursor.execute(
            "INSERT INTO workout_sessions (id, started_at, ended_at,"
            " planned_set_count, planned_reps_per_set, planned_rest_seconds,"
            " completed_set_count, total_reps, active_duration_seconds,"
            " rest_duration_seconds, total_duration_seconds,"
            " average_rep_duration_milliseconds, completed, interrupted,"
            " created_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,1,0,?)",
            (session_id, ms(started),
             ms(started + dt.timedelta(seconds=total_seconds)),
             set_count, REPS_PER_SET, REST_SECONDS, set_count, total_reps,
             active_seconds, rest_seconds, total_seconds, rep_ms, ms(started)),
        )

        cursor_time = started
        for set_index in range(set_count):
            set_id = str(uuid.uuid4())
            set_active = round(rep_ms * REPS_PER_SET / 1000)
            rest_after = REST_SECONDS if set_index < set_count - 1 else 0
            cursor.execute(
                "INSERT INTO workout_sets (id, session_id, set_index,"
                " started_at, ended_at, target_reps, completed_reps,"
                " active_duration_seconds, rest_duration_after_seconds)"
                " VALUES (?,?,?,?,?,?,?,?,?)",
                (set_id, session_id, set_index, ms(cursor_time),
                 ms(cursor_time + dt.timedelta(seconds=set_active)),
                 REPS_PER_SET, REPS_PER_SET, set_active, rest_after),
            )
            for rep_index in range(REPS_PER_SET):
                rep_started = cursor_time + dt.timedelta(
                    milliseconds=rep_ms * rep_index)
                rep_done = rep_started + dt.timedelta(milliseconds=rep_ms)
                # FormAnalyzer emits 0-100 metric scores; stay inside that range.
                depth = 86.0 + ((rep_index + set_index) % 7) * 1.8
                control = 88.0 + ((rep_index + index) % 5) * 2.0
                balance = 90.0 + ((rep_index + set_index + index) % 4) * 2.1
                overall = round((depth + control + balance) / 3, 4)
                cursor.execute(
                    "INSERT INTO rep_records (id, session_id, set_id,"
                    " rep_index, started_at, bottom_at, completed_at,"
                    " duration_milliseconds, depth_score, control_score,"
                    " balance_score, overall_form_score, detected_issues,"
                    " camera_angle, confidence) VALUES"
                    " (?,?,?,?,?,?,?,?,?,?,?,?,'[]','front',?)",
                    (str(uuid.uuid4()), session_id, set_id, rep_index,
                     ms(rep_started),
                     ms(rep_started + dt.timedelta(milliseconds=rep_ms // 2)),
                     ms(rep_done), rep_ms, round(depth, 4), round(control, 4),
                     round(balance, 4), overall, round(0.93 + (rep_index % 3) * 0.02, 4)),
                )
            cursor_time = cursor_time + dt.timedelta(
                seconds=set_active + rest_after)

    cursor.execute("DELETE FROM reminder_schedules")
    for weekday in range(1, 8):
        cursor.execute(
            "INSERT INTO reminder_schedules (weekday, enabled, hour, minute)"
            " VALUES (?,?,?,?)",
            (weekday, 1 if weekday in REMINDER_WEEKDAYS else 0,
             REMINDER_HOUR, REMINDER_MINUTE),
        )

    challenge_start = today - dt.timedelta(days=CHALLENGE_STARTED_DAYS_AGO)
    challenge_end = challenge_start + dt.timedelta(
        days=CHALLENGE_LENGTH_DAYS - 1, hours=23, minutes=59, seconds=59)
    cursor.execute(
        "INSERT INTO challenges (id, type, status, started_at, ends_at,"
        " target_reps, daily_goals, weekdays, notification_enabled, created_at)"
        " VALUES (?, 'cumulative', 'active', ?, ?, ?, '[]', '[]', 0, ?)",
        (str(uuid.uuid4()), ms(challenge_start), ms(challenge_end),
         CHALLENGE_TARGET_REPS, ms(challenge_start)),
    )

    connection.commit()
    counted = cursor.execute(
        "SELECT COUNT(*), SUM(total_reps) FROM workout_sessions"
    ).fetchone()
    in_challenge = cursor.execute(
        "SELECT SUM(total_reps) FROM workout_sessions WHERE started_at >= ?",
        (ms(challenge_start),),
    ).fetchone()[0]
    connection.close()
    print(f"  sessions={counted[0]} reps={counted[1]} "
          f"challenge={in_challenge}/{CHALLENGE_TARGET_REPS}")


def main() -> None:
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    for udid in sys.argv[1:]:
        path = app_db_path(udid)
        print(f"{udid}: {path}")
        if not path.exists():
            raise SystemExit(
                f"database missing - launch the app once on {udid} first")
        seed(path)


if __name__ == "__main__":
    main()
