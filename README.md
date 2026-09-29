# BubblePop

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

BubblePop is a small iOS game written in Swift. Tap colored bubbles before they disappear, chain the same color for a bonus, and beat the local high score before the timer runs out.

![Game running](GameRunningExample.gif)

## How to play

1. Open the app and tap **New Game**.
2. Enter a name. A blank name is saved as **Player**.
3. Tap bubbles to score. Each bubble can also vanish on its own.
4. When time runs out, open the scoreboard to see where you placed.

| Bubble | Points | Chance to appear |
| --- | ---: | ---: |
| Red | 1 | 40% |
| Pink | 2 | 30% |
| Green | 5 | 15% |
| Blue | 8 | 10% |
| Black | 10 | 5% |

Popping the same color twice in a row multiplies that bubble's points by 1.5. The bonus is rounded down, so a 1-point combo is still worth 1.

About 30% of the bubbles on screen are removed each second, and each empty slot has a 50% chance to spawn a new bubble, up to the maximum you set. Bubbles that would overlap an existing one are skipped.

## Settings

**Settings** saves two values on this device:

| Setting | Default | Range |
| --- | ---: | --- |
| Game time | 60 seconds | 15–120 seconds |
| Max bubbles | 15 | 5–20 |

Settings and scores are JSON files in the app Documents directory (`GameSettings.json` and `ScoreBoard.json`). Nothing is uploaded. Delete the app to reset them, or use **Clear** on the scoreboard.

## Requirements

- Xcode 15 or newer
- iOS 15.0 or newer
- iPhone or iPad

For development, use macOS with the full Xcode app and an installed iOS Simulator runtime. Standalone Command Line Tools are not enough. No CocoaPods, Carthage, or third-party Swift packages are needed.

## Build and run

```bash
git clone https://github.com/CroffZ/BubblePop.git
cd BubblePop
open BubblePop.xcodeproj
```

Select the shared **BubblePop** scheme, pick a simulator, and run. For a device, choose your own Signing Team under Signing & Capabilities. This repository does not depend on a particular Apple Developer account.

Simulator builds do not need an Apple Developer account. For a physical device, you may also need to change the bundle identifier to a unique value; keep personal signing changes out of pull requests.

Command-line build:

```bash
xcodebuild \
  -project BubblePop.xcodeproj \
  -scheme BubblePop \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

### Tests

In Xcode, select the **BubblePop** scheme and an iOS Simulator, then press **⌘U**. From the repository root:

```bash
bash scripts/test.sh
```

The script selects an available iPhone simulator and builds and runs the XCTest suite without signing. Tests cover spawn weights, combo scoring, repeated taps, overlap detection, accessibility labels, and JSON persistence. Storage tests use temporary directories, not the player's saved files.

To choose a specific simulator, set `SIMULATOR_UDID` (find it with `xcrun simctl list devices available`). `DERIVED_DATA_PATH` and `RESULT_BUNDLE_PATH` can override the output locations. By default, test results are saved under `build/` as an `.xcresult` bundle that opens in Xcode.

These are local unit/regression tests, not full UI automation; play a round and check settings and the scoreboard before submitting UI changes.

### Troubleshooting

- **`xcodebuild` requires Xcode:** select full Xcode under **Xcode → Settings → Locations → Command Line Tools**. The test script automatically uses `/Applications/Xcode.app` when standalone tools are selected.
- **No simulator available:** install an iOS runtime in Xcode Settings (under **Platforms** or **Components**, depending on the Xcode version).
- **Simulator window missing:** verify the full Xcode app is installed; command-line build tools alone cannot display the game.
- **Signing fails on a device:** select your team and a unique bundle identifier. Use a simulator if you do not want to configure signing.

## Project layout

The app uses a straightforward MVC split and storyboards. There are no third-party dependencies.

| Path | Role |
| --- | --- |
| `BubblePop/Model` | Bubble types, settings, score records, and JSON storage |
| `BubblePop/View` | Bubble button and scoreboard cell |
| `BubblePop/View Controller` | Menu, game loop, settings, and scoreboard |
| `BubblePop/Base.lproj` | Main interface and launch screen |
| `BubblePopTests` | XCTest model, storage, and gameplay regression tests |
| `scripts/test.sh` | Local test entry point |

`GameViewController` owns the one-second timer: it counts down, removes some bubbles, and spawns replacements inside the play area. `DataStorage` reads and writes the two JSON files.

## Contributing

Issues and pull requests are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) and the [Code of Conduct](CODE_OF_CONDUCT.md) first.

For vulnerabilities, follow [SECURITY.md](SECURITY.md) rather than posting sensitive details in a public issue.

Ideas that would help:

- UI tests for the full game flow and timer lifecycle
- a pause button
- sound and haptics
- a way to replay without returning to the menu

## License

Released under the [MIT License](LICENSE). Copyright (c) 2019 Croff Zhong.