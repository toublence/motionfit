import json
from pathlib import Path

root = Path(__file__).resolve().parent
trace = [json.loads(line) for line in (root / 'interstitial-complete-trace.jsonl').read_text().splitlines()]
def select(name, **fields):
    return [e for e in trace if e['event'] == name and all(e['parameters'].get(k) == v for k, v in fields.items())]

paused = select('qa_lifecycle', state='paused', full_screen_showing=True)[0]
resumed = next(e for e in select('qa_lifecycle', state='resumed') if e['at'] > paused['at'])
dismissed = select('mf2_ad_disposed', ad_format='interstitial', reason='dismissed')[0]
checks = {
    'real_sdk_interstitial_showed': bool(select('mf2_ad_show_result', ad_format='interstitial', result='showed')),
    'paused_still_allows_loads': paused['parameters']['loads_allowed'] is True and paused['parameters']['visible'] is False,
    'no_cancelled_events': not select('mf2_ad_load_result', result='cancelled'),
    'resumed_before_sdk_dismissal': resumed['at'] < dismissed['at'],
    'dismissal_completed_successfully': bool(select('qa_interstitial_complete', shown=True)),
    'real_background_stops_loads': bool(select('qa_lifecycle', state='paused', full_screen_showing=False, loads_allowed=False)),
}
loaded_requests = {}
for fmt in ['interstitial', 'banner']:
    requests = select('mf2_ad_request_attempted', ad_format=fmt)
    # Initial request + intentional banner replacement / next interstitial.
    checks[f'{fmt}_request_count_is_two'] = len(requests) == 2
    rid = requests[1]['parameters']['request_id']
    loads = select('mf2_ad_load_result', ad_format=fmt, request_id=rid, result='loaded')
    checks[f'{fmt}_same_request_loaded_while_covered'] = bool(loads and paused['at'] < loads[0]['at'] < resumed['at'])
    checks[f'{fmt}_no_new_request_after_dismissal'] = not [e for e in requests if e['at'] > dismissed['at']]
    loaded_requests[fmt] = {'request_id': rid, 'loaded_at': loads[0]['at'] if loads else None}
result = {'status': 'PASS' if all(checks.values()) else 'FAIL', 'checks': checks,
          'loads_completed_while_covered': loaded_requests,
          'paused_at': paused['at'], 'resumed_at': resumed['at'], 'sdk_dismissal_at': dismissed['at'],
          'evidence': 'interstitial-complete-trace.jsonl',
          'scope': 'Production AdService and AdSlot, actual iPad lifecycle and real Google demo ads; QA policy context is in memory, no workout DB writes.'}
(root / 'interstitial-checks.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
