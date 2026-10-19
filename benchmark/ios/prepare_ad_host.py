"""Disable Firebase uploads in the isolated built test artifact, then re-sign.

Does not modify the production Info.plist or any production source.
"""
from pathlib import Path
import plistlib
import re
import subprocess
import sys

app = Path(sys.argv[1])
build_log = Path(sys.argv[2]).read_text()
info = app / 'Info.plist'
values = plistlib.loads(info.read_bytes())
assert values['CFBundleIdentifier'] == 'fit.motionfit.app.adsvalidation'
entitlements = subprocess.check_output(
    ['codesign', '-d', '--entitlements', ':-', str(app)], stderr=subprocess.DEVNULL)
entitlement_file = app.parent / 'validation-entitlements.plist'
entitlement_file.write_bytes(entitlements)
values['FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED'] = True
values['FirebaseCrashlyticsCollectionEnabled'] = False
info.write_bytes(plistlib.dumps(values, fmt=plistlib.FMT_BINARY))
identities = re.findall(r'/usr/bin/codesign --force --sign ([A-Fa-f0-9]{40})', build_log)
assert identities, 'Signing identity was not found in successful Xcode build log'
# A command-line bundle ID override also reaches CocoaPods targets. Restore
# their exact original identifiers from this project's verified release output.
# Never invent identifiers or alter the original release frameworks.
baseline = Path(sys.argv[3]) / 'Frameworks'
restored = 0
for framework_info in (app / 'Frameworks').glob('*.framework/Info.plist'):
    framework_values = plistlib.loads(framework_info.read_bytes())
    if framework_values.get('CFBundleIdentifier') != values['CFBundleIdentifier']:
        continue
    original = plistlib.loads((baseline / framework_info.parent.name / 'Info.plist').read_bytes())
    identifier = original['CFBundleIdentifier']
    assert identifier != values['CFBundleIdentifier']
    framework_values['CFBundleIdentifier'] = identifier
    framework_info.write_bytes(plistlib.dumps(framework_values, fmt=plistlib.FMT_BINARY))
    subprocess.run(['codesign', '--force', '--sign', identities[-1],
                    str(framework_info.parent)], check=True, capture_output=True)
    restored += 1
subprocess.run(['codesign', '--force', '--sign', identities[-1], '--entitlements',
                str(entitlement_file), str(app)], check=True)
subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True)
print('Verified isolated bundle ID, Firebase disabled, original framework IDs restored:', restored)
