#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Prefer full Xcode when only the standalone Command Line Tools are selected.
if [[ -z "${DEVELOPER_DIR:-}" && "$(xcode-select -p)" == "/Library/Developer/CommandLineTools" ]]; then
    if [[ -d /Applications/Xcode.app/Contents/Developer ]]; then
        export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    else
        echo "Install full Xcode and select it in Xcode > Settings > Locations." >&2
        exit 1
    fi
fi

xcodebuild -version

if [[ -z "${SIMULATOR_UDID:-}" ]]; then
    SIMULATOR_UDID="$(xcrun simctl list devices available --json | python3 -c '
import json, sys
devices = json.load(sys.stdin)["devices"]
def version(runtime):
    return tuple(int(part) for part in runtime.rsplit("iOS-", 1)[-1].split("-"))
for runtime in sorted((r for r in devices if ".iOS-" in r), key=version, reverse=True):
    iphones = [d for d in devices[runtime] if d.get("isAvailable") and d["name"].startswith("iPhone")]
    iphones.sort(key=lambda d: d["state"] != "Booted")
    if iphones:
        print(iphones[0]["udid"])
        break
else:
    sys.exit("No iPhone simulator is available. Install an iOS runtime in Xcode > Settings > Components.")
')"
fi

DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT/DerivedData}"
RESULT_BUNDLE_PATH="${RESULT_BUNDLE_PATH:-$ROOT/build/TestResults-$(date +%Y%m%d-%H%M%S).xcresult}"
mkdir -p "$(dirname "$RESULT_BUNDLE_PATH")"
echo "Testing on simulator $SIMULATOR_UDID"
echo "Results: $RESULT_BUNDLE_PATH"

xcodebuild \
    -project BubblePop.xcodeproj \
    -scheme BubblePop \
    -configuration Debug \
    -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -resultBundlePath "$RESULT_BUNDLE_PATH" \
    -parallel-testing-enabled NO \
    CODE_SIGNING_ALLOWED=NO \
    test