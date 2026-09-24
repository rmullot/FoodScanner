# Testing — open follow-ups

Running backlog of still-open testing points. Remove an entry the same change it is resolved; append new ones as `### ` blocks (context, affected files, suggested fix).

### CI doesn't pin an SE-class destination
The AX5 keypad hittability test in `FoodScannerUITests/ScannerKeypadUITests.swift` previously only ran on iPhone 17 in CI. An SE-class iOS 17+ simulator can be created locally (no pre-built one ships) via `xcrun simctl create "iPhone SE (3rd generation) 17+" com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation com.apple.CoreSimulator.SimRuntime.iOS-26-5` and running the suite there surfaced a real bug (keypad "0"/delete/validate unhittable at large Dynamic Type on a 375×667pt screen — fixed in `ScannerScreenView.swift`/`FSMetrics.keypadMinRegionHeight`).
- Affected: `.github/workflows/ios.yml`, which picks whatever simulator `xcrun xctrace list devices` returns first — it doesn't pin an SE device, so this class of regression won't be caught automatically.
- Fix: wire the SE-class iOS 17+ simulator (create it in the CI runner the same way, or cache/provision it) into `.github/workflows/ios.yml` as a pinned destination for `FoodScannerUITests/ScannerKeypadUITests`, alongside the current default-device run.

### FoodScannerUI package unit tests can't run in this environment
The `FoodScannerUI` scheme is not configured for the test action, and `swift test` builds for macOS (fails on `scrollBounceBehavior`, iOS-only). `FSTokensTests` additions are therefore unverified locally — only the production code is checked, via the app build.
- Affected: `FoodScannerUI/Tests/**`, `FoodScannerUI` scheme
- Fix: enable the test action on the `FoodScannerUI` scheme (or add a shared test plan) so `xcodebuild -scheme FoodScannerUI test` runs against an iOS simulator.

### ScannerKeypadUITests fail on iPhone 17 / iOS 27 (keypad below the floating tab bar)
On the iOS 27.0 iPhone 17 simulator (402×874pt) 4 of the 5 `ScannerKeypadUITests` fail: with the keypad open, "Chercher ce produit" is at y≈793-853 (under the floating tab bar) or beyond the window, and "Masquer le pavé" is off-screen. They passed on iOS 26.5, so the CI default destination hides it. Root cause is the Scanner panel layout in portrait on iOS 27 (see `memory_design.md`).
- Affected: `FoodScannerUITests/ScannerKeypadUITests.swift`, `FoodScanner/View/Scanner/ScannerScreenView.swift`
- Fix: fix the layout, then re-run the whole suite on the iOS 27 iPhone 17 and pin an iOS 27 destination in `.github/workflows/ios.yml` next to the SE-class one.

### xcodebuild can reuse a stale UI-test bundle
Editing a `FoodScannerUITests` source (or adding a class) sometimes isn't recompiled: `Executed 0 tests` for the new class, assertion line numbers from the previous file version, debug output never written.
- Affected: local workflow and any script that runs `-only-testing:FoodScannerUITests/...`
- Fix: use a dedicated `-derivedDataPath` (worked reliably) or clean the UI-test target; find the actual cause before relying on incremental UI-test runs.
