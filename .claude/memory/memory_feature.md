# Feature / architecture — open follow-ups

Running backlog of still-open feature / architecture points. Remove an entry the same change it is resolved; append new ones as `### ` blocks (context, affected files, suggested fix).

### View models still on ObservableObject, not @Observable
The iOS 17 floor makes the Observation framework available, but every `<Screen>ViewModel` is still `ObservableObject` + `@Published`.
- Affected: `FoodScanner/View/**/*ViewModel.swift`, their `@StateObject`/`@ObservedObject` call sites
- Fix: migrate each view model to `@Observable` and swap the property wrappers at the call sites. Do it per-screen when touching one, not as a mass rewrite.
- Evaluated 09/2026 while landing the Coordinator layer: deferred. `ScannerCoordinator` forwards `Router.objectWillChange`, the unit suite drives the VMs through Combine `$`-publishers, and no screen is being reworked deeply enough to justify the swap. Revisit per-screen.
- Owner: mvvmc-architecture-orchestrator

### Only the Scanner tab is behind a Coordinator
The Coordinator + `Router` layer (`FoodScanner/View/Coordinator/`) currently drives the Scanner tab only. `HistoryScreenView` still owns a local `NavigationPath` the row appends to, and `SettingsScreenView` has no navigation of its own.
- Affected: `FoodScanner/View/History/HistoryScreenView.swift`, `FoodScanner/View/Settings/SettingsScreenView.swift`
- Fix: introduce `HistoryCoordinator` (+ `HistoryRoute`) and route History→ProductDetail through a `Router<HistoryRoute>`, hosted from `RootView` like `ScannerCoordinatorView`. Settings can get a coordinator when it grows a pushed screen.
- Owner: mvvmc-architecture-orchestrator

### ScannerCoordinatorView binds the stack through a manual closure Binding
`Router` is a nested `ObservableObject`; `\ScannerCoordinator.router.path` is not a `ReferenceWritableKeyPath`, so `ScannerCoordinatorView` builds the `NavigationStack` path binding with an explicit `Binding(get:set:)` and `ScannerCoordinator` re-publishes `router.objectWillChange`.
- Affected: `FoodScanner/View/Coordinator/Router.swift`, `FoodScanner/View/Coordinator/ScannerCoordinator.swift`
- Fix: when `Router` / coordinators move to `@Observable`, drop the manual Binding and the `objectWillChange` forwarding.
- Owner: mvvmc-architecture-orchestrator

### No deterministic onboarding reset hook for UI tests
`hasSeenOnboarding` is `@AppStorage`-backed with no launch-argument / launch-environment override, so a UI test cannot force the first-run `.fullScreenCover` on/off deterministically. Existing UI tests just run past it.
- Affected: `FoodScanner/RootView.swift`, `FoodScannerUITests/`
- Fix: honour a launch argument (e.g. `-resetOnboarding`) in `RootView`/`FoodScannerApp` to clear the flag, so `test-suite-engineer` can add an onboarding-dismiss journey.
- Workaround today (manual checks): `xcrun simctl spawn <udid> defaults write com.MULLOTRomainEI.FoodScanner hasSeenOnboarding -bool true`. `ScannerScreenView` now also reads `hasSeenOnboarding` to refresh the camera authorization state when onboarding finishes; revisit if a Coordinator/VM should own that signal.
- Owner: mvvmc-architecture-orchestrator

### App runs on the SwiftUI lifecycle with no App/Scene delegate
`AppDelegate`/`SceneDelegate` were removed with the UIKit root; `FoodScannerApp` is a pure SwiftUI `App`.
- Affected: `FoodScanner/FoodScannerApp.swift`, `FoodScanner/Info.plist`
- Fix: if push notifications, URL/universal-link handling or UIScene restoration is ever needed, reintroduce a delegate via `@UIApplicationDelegateAdaptor` rather than a standalone `SceneDelegate`.
- Owner: mvvmc-architecture-orchestrator
