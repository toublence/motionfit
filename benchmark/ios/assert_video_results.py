"""Check the six recorded iOS cases; exit 2 when exercise behavior is not valid."""
import json
from pathlib import Path
import sys

base = Path(sys.argv[1] if len(sys.argv) > 1 else 'reports/ios_video_validation_2026_10_17')
data = json.loads((base / 'detector_results.json').read_text())
checks = []
for case in data['cases']:
    name = case['id']
    integrity = (case['frames'] > 0 and case['nonIncreasingTimestamps'] == 0
                 and case['nonFiniteLandmarkValues'] == 0)
    details = []
    if name in ('squat_depth_after_5', 'squat_fast_10', 'pushup_good_repeat_10'):
        expected = {'squat_depth_after_5': 5, 'squat_fast_10': 10,
                    'pushup_good_repeat_10': 10}[name]
        passed = case['calibrated'] and case['count'] == expected
        details.append({'expected_repetitions': expected, 'actual': case['count']})
        if not case['calibrated']:
            details.append({'failure': 'automatic_calibration_not_completed'})
    elif name == 'pushup_shallow_10':
        # Twelve movement attempts are visible; the filename's "10" is not truth.
        # Do not call a zero-count uncalibrated detector a successful form filter.
        passed = case['calibrated']
        details.append({'criterion': 'ready_to_assess_shallow_movements',
                        'observed_attempts': 12, 'calibrated': case['calibrated']})
    elif name == 'plank_near_20s':
        # Conservative visual boundary: both knees are down by 15.0 seconds.
        late = [event['timestampSeconds'] for event in case['events']
                if event['type'] == 'completed' and event['timestampSeconds'] > 15.0]
        passed = case['calibrated'] and case['count'] > 0 and not late
        details.append({'latest_possible_hold_end_seconds': 15.0,
                        'checkpoints_after_hold_end': late})
    elif name == 'plank_hip_high_20s':
        passed = case['count'] == 0 and not case['calibrated']
        details.append({'criterion': 'invalid_start_posture_rejected_only'})
    else:
        raise ValueError(name)
    checks.append({'id': name, 'native_data_integrity': 'PASS' if integrity else 'FAIL',
                   'exercise_behavior': 'PASS' if passed and integrity else 'FAIL',
                   'details': details})

failed = sum(item['exercise_behavior'] != 'PASS' for item in checks)
report = {'native_videos_processed': len(checks),
          'native_integrity_passed': sum(c['native_data_integrity'] == 'PASS' for c in checks),
          'exercise_behavior_passed': len(checks) - failed,
          'exercise_behavior_failed': failed,
          'overall': 'FAIL' if failed else 'PASS',
          'scope': 'iPad native video inference + unchanged Dart detector replay; not full app UI',
          'checks': checks}
(base / 'checks.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
print(json.dumps(report, ensure_ascii=False, indent=2))
sys.exit(2 if failed else 0)
