# Feature / architecture — open follow-ups

Running backlog of still-open feature / architecture points. Remove an entry the same change it is resolved; append new ones as `### ` blocks (context, affected files, suggested fix).

### ScannerScreenView diverges from the target MVVM-C + DI posture
`ScannerScreenView` owns navigation through a local `NavigationPath` (no Coordinator layer) and reads `InjectionManager.shared.networkActivity` directly instead of receiving it injected.
- Affected: `FoodScanner/View/Scanner/ScannerScreenView.swift`
- Fix: when the Coordinator layer lands, route navigation through it and inject `networkActivity` (protocol + `nil`-defaulted param) like the other services. Not urgent — no Coordinator layer exists yet.
- Owner: mvvmc-architecture-orchestrator

### View models still on ObservableObject, not @Observable
The iOS 17 floor makes the Observation framework available, but every `<Screen>ViewModel` is still `ObservableObject` + `@Published`.
- Affected: `FoodScanner/View/**/*ViewModel.swift`, their `@StateObject`/`@ObservedObject` call sites
- Fix: migrate each view model to `@Observable` and swap the property wrappers at the call sites. Do it per-screen when touching one, not as a mass rewrite.
- Owner: mvvmc-architecture-orchestrator

### RootTabBarController is a removable UIKit bridge
`RootTabBarController` (`UITabBarController` + three `UIHostingController`) was only kept for the old iOS 16 floor. On iOS 17 a pure SwiftUI `TabView` root is viable.
- Affected: `FoodScanner/View/RootTabBarController.swift`, the app entry point, `AppAccessibilitySettings` application points, `OnboardingView` `.fullScreenCover` host
- Fix: replace with a SwiftUI `TabView`; move the `.fullScreenCover` onboarding and `appWideAccessibilitySettings()` to the SwiftUI root. Verify tab-bar appearance and the per-tab `NavigationStack` titles still match.
- Owner: mvvmc-architecture-orchestrator
