# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- MIT license, contribution guide, code of conduct, and GitHub issue and pull request templates.
- Shared Xcode scheme and a simulator build workflow.
- Accessibility names for bubbles.
- A confirmation before clearing the local scoreboard.
- XCTest coverage for spawn weights, combo scoring, repeated taps, overlap detection, accessibility, and isolated JSON persistence.
- A shared local/CI test script with automatic iPhone simulator selection.
- A security policy, test instructions, setup troubleshooting, and a maintainer release checklist.

### Changed

- README now explains how to play, build, and contribute.
- The project no longer pins a personal development team, so other people can sign their own builds.
- Settings are saved when the settings screen disappears, not only when Back is tapped.
- An empty player name is stored as "Player".
- Game over waits for the player to open the scoreboard instead of dismissing itself after two seconds.
- CI now runs tests with read-only permissions and pinned actions, and uploads test results and build logs.
- JSON files are written atomically, and storage errors retain their underlying read/write/decoding details.
- Source license notices consistently refer to MIT.

### Fixed

- The game timer no longer starts a second early or keeps running after leaving the game.
- The timer pauses while the app is inactive and resumes when the game is still on screen.
- Settings and scores are loaded independently, so a missing settings file does not hide saved scores.
- The scoreboard no longer crashes if a cell cannot be cast, and the unused restart button no longer sends an unrecognized action.
- Repeated taps cannot score a bubble more than once; disappearing bubbles and taps after game over no longer score.
- The documented minimum iOS version now matches the iOS 15.0 deployment target, and the obsolete armv7 capability requirement was removed.

## [1.0.0] - 2019-06-05

### Added

- Initial Bubble Pop game: timed play, colored bubbles, combo scoring, settings, and a local scoreboard.
