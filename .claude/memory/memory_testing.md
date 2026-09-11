# Testing — open follow-ups

Running backlog of still-open testing points. Remove an entry the same change it is resolved; append new ones as `### ` blocks (context, affected files, suggested fix).

### No small-device AX5 coverage
The AX5 keypad hittability test in `FoodScannerUITests/ScannerKeypadUITests.swift` runs on iPhone 17 only. The installed SE simulator is iOS 16, which can no longer run the app now the floor is iOS 17.
- Fix: install an SE-class iOS 17+ simulator and run the suite there in CI. The launch arg is device-independent — no code change needed.

### FoodScannerUI package unit tests can't run in this environment
The `FoodScannerUI` scheme is not configured for the test action, and `swift test` builds for macOS (fails on `scrollBounceBehavior`, iOS-only). `FSTokensTests` additions are therefore unverified locally — only the production code is checked, via the app build.
- Affected: `FoodScannerUI/Tests/**`, `FoodScannerUI` scheme
- Fix: enable the test action on the `FoodScannerUI` scheme (or add a shared test plan) so `xcodebuild -scheme FoodScannerUI test` runs against an iOS simulator.
