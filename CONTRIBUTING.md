# Contributing to BubblePop

Thanks for helping improve BubblePop. This is a small Swift/UIKit game, and clear, focused changes are the most useful.

## Before you start

- Open an issue for anything that is not a tiny fix, so we can agree on the approach.
- Check existing issues and pull requests so work is not duplicated.
- Read the [Code of Conduct](CODE_OF_CONDUCT.md).

## Development setup

1. Install Xcode 15 or newer.
2. Clone the repository and open `BubblePop.xcodeproj`.
3. Select the BubblePop scheme and an iOS Simulator.
4. Set your own Signing Team if you run on a device. The project does not require a specific Apple Developer team.
5. Build and run.

There is no package manager. The app uses only system frameworks (`UIKit` and `GameKit`).

## Testing

Run `bash scripts/test.sh` from the repository root, or press **⌘U** with the BubblePop scheme and an iOS Simulator selected. The script requires full Xcode, an iOS Simulator runtime, and Python 3 (provided with Xcode's developer tools). See the [README](README.md#tests) for simulator selection and output paths.

- Add regression tests for fixes and tests for new model behavior in `BubblePopTests`.
- Storage tests must use a temporary directory through `DataStorage(directory:)`, never the app's Documents directory.
- Play a round and verify the score, combo bonus, and game-over scoreboard transition.
- Check settings survive relaunch and clearing scores requires confirmation.
- For lifecycle changes, background/foreground the app and leave the game while the timer is running.
- For UI changes, check iPhone and iPad layouts, rotation, and VoiceOver labels.

The local test script saves an `.xcresult` bundle that opens in Xcode. A passing suite does not replace these manual UI checks.

## Making a change

- Keep the MVC split: models in `BubblePop/Model`, views in `BubblePop/View`, controllers in `BubblePop/View Controller`.
- Match the existing Swift style: small types, explicit names, and no new dependencies unless an issue asks for one.
- Do not change gameplay numbers (points, spawn weights, combo multiplier, slider ranges) without calling that out in the pull request.
- Prefer fixing a crash or a confusing flow over adding a large new feature in the same change.
- Update `README.md` if you change how to play, build, or configure the game.
- Update the appropriate section of `CHANGELOG.md` under **Unreleased** for user-visible changes.
- Do not commit build output, Xcode user settings, credentials, or personal signing teams.

## Pull requests

- Use a descriptive title and explain what changed and why.
- Run the test suite and fix failures before requesting review.
- Describe how you tested the change (simulator device and iOS version).
- Keep the diff limited to the issue you are solving.
- Screenshots or a short screen recording help for UI changes.

## Reporting bugs

Include:

- iOS version and device or simulator
- steps to reproduce
- what you expected and what happened
- a screenshot if the problem is visual

Scores and settings are stored as JSON in the app Documents directory (`GameSettings.json` and `ScoreBoard.json`). Mention whether you can still reproduce the bug after deleting the app.

Report vulnerabilities using the [security policy](SECURITY.md), not a public bug report.

## Maintainer release checklist

1. Run the local test suite and complete the manual checks above.
2. Move the relevant Unreleased entries into a dated version section in `CHANGELOG.md`.
3. Update the app version and build number in `BubblePop/Info.plist` when shipping an app build.
4. Tag the reviewed commit and publish GitHub release notes describing changes and any saved-data compatibility impact.

Consider requiring pull-request review on the default branch before merging. Enable GitHub private vulnerability reporting so the security policy has a private reporting channel.
