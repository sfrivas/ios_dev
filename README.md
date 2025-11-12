# gradientShort
[![CI](https://img.shields.io/badge/CI-pending-lightgrey.svg)](#) [![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](#) [![Platform](https://img.shields.io/badge/iOS-26.1%2B-blue.svg)](#)

gradientShort is a SwiftUI-driven interval timer that layers each phase (initial/warm-up, work, rest) over a full-screen gradient so you can see—and hear—where you are in the session at a glance. Wheel pickers let you dial in per-phase durations and up to 50 rounds without ever leaving the main screen.

## Screenshots
🚧 This section is under construction—we'll add screenshots here once they're ready.

## Features
- **Multi-phase control:** Configure initial, work, and rest segments independently right from the main view—no separate settings sheet.
- **Round sequencing:** Choose 1–50 rounds; the UI keeps the “Round N of M” label in sync as you edit values or progress through the workout.
- **Contextual gradients:** Each phase gets its own color pair (blue for initial, green for work, red for rest) rendered edge-to-edge via `ignoresSafeArea()`.
- **Audible cues:** Single and double beeps (AudioToolbox) confirm phase changes and per-second ticks so you can look away from the screen.
- **Inline controls:** Start/stop and reset buttons live above the configuration wheels, keeping interaction in one column for fast adjustments.
- **SwiftUI-first:** Uses the SwiftUI App lifecycle, `@State` for view state, and wheel pickers for an iOS-native feel.

## Requirements
- iOS 26.1 or later (based on `IPHONEOS_DEPLOYMENT_TARGET` in `gradientShort.xcodeproj`).
- Xcode 16.x or newer with the iOS 18 SDK (recommended to match the deployment target).
- Swift 5.0 toolchain or newer (per project build settings).

## Installation
```bash
git clone https://github.com/your-org/gradientShort.git
cd gradientShort
open gradientShort.xcodeproj
```
1. Select the `gradientShort` scheme.
2. Choose an iOS Simulator (e.g., iPhone 16 Pro) or a connected device running iOS 26.1+.
3. Press `Cmd+R` to build and run.

### Swift Package Manager
No third-party Swift packages are referenced (`Swift Package Dependencies` is empty), so there is nothing additional to resolve.

### CocoaPods
This project does not use CocoaPods; the workspace stays lightweight.

## Configuration
- No API keys, entitlement files, or background modes are configured. Xcode generates the Info.plist (`GENERATE_INFOPLIST_FILE = YES`).
- Default durations start at zero minutes/seconds to encourage manual setup; tweak the defaults inside `ContentView` if you want preset workouts.
- Gradients live in `ContentView`'s `gradientColors` computed property—update the `switch` to brand the phases differently.
- Provide screenshots by saving images under `Docs/Images/` (paths referenced in the Screenshots section once assets exist).

## Usage
- **Set your session:** Use the “Rounds” wheel plus the Initial/Work/Rest minute and second wheels to define the workout. Values update even while previews are running, but timers only sync when idle.
- **Run from Xcode:** Launch the `gradientShort` scheme (`Cmd+R`). Tap “Start” to begin the sequence; tap “Stop” to pause or “Reset” (when idle) to jump back to the initial phase.
- **Understand the cues:** The timer beeps every second, triggers a double beep on phase changes, and updates the background gradient + “Round N of M” label so the screen state always matches the audio.
- **Command line:**  
  ```bash
  xcodebuild \
    -scheme gradientShort \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    clean run
  ```
- **Previews:** Open `ContentView.swift` and use SwiftUI previews for layout tweaks without running the full simulator loop.

## Timer Flow
1. Initial phase counts down once per session and primes the “Round 1 of N” label.
2. Work and rest phases alternate until the chosen round count is met.
3. If you edit picker values while the timer is stopped, the next phase syncs immediately; edits are ignored mid-countdown to avoid surprise jumps.
4. Completing the final rest phase marks the sequence as finished and reloads the initial duration so you can restart.

## Architecture
gradientShort follows the pure SwiftUI App lifecycle. `gradientShortApp` bootstraps a single `WindowGroup` hosting `ContentView`, which owns all state via `@State` properties: `remainingSeconds`, timer bookkeeping, current phase, and round tracking. Timers are scheduled on the main run loop with `Timer.scheduledTimer`, and AudioToolbox serves lightweight beeps—no background services or Combine pipelines are involved.

```
gradientShort/
├─ gradientShortApp.swift   # @main entry point
├─ ContentView.swift        # Interval logic, gradient rendering, controls, pickers
└─ Assets.xcassets/         # AppIcon and AccentColor catalogs
```

## Dependencies
| Name | Version | Usage |
| --- | --- | --- |
| Apple SwiftUI (built-in) | Swift 5 / iOS SDK | Declarative UI, gradients, pickers, scene lifecycle |
| AudioToolbox (system) | iOS SDK | Phase-change beeps and per-second cues |

No external frameworks, Swift packages, or CocoaPods are included.

## Testing
- Unit/UI test targets are not present yet. Running `Cmd+U` or:
  ```bash
  xcodebuild test -scheme gradientShort -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
  ```
  finishes immediately and reports “no tests” until suites are added.
- fastlane is not configured.

## Roadmap / Known Issues
- Persist last-used timer settings so repeat sessions do not start from zero.
- Add background execution support or Live Activities for hands-free workouts.
- Provide export/share actions for template workouts or captured gradients.
- Build snapshot/UI tests as additional states emerge.

## Contributing
1. Fork the repository and create a feature branch (`git checkout -b feature/my-idea`).
2. Make changes, keep SwiftLint/formatting consistent (if configured later), and update documentation or screenshots when relevant.
3. Test on both simulator and device targets when possible.
4. Open a Pull Request describing the change, test coverage, and screenshots/gifs if UI-related.

## License
MIT License (placeholder). Replace with your preferred license text when ready.
