# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

FoodScanner is an iOS app (Swift, SwiftUI) that scans a product barcode (or accepts a typed barcode), fetches nutrition data from the Open Food Facts API (`https://world.openfoodfacts.org/api/v0/product/<barcode>.json`), caches it in Realm, and displays nutrient breakdowns (Nutri-Score badge + proportion bars).

- Deployment target: iOS 16.0
- Dependencies are managed via **Swift Package Manager**, including a local package, **FoodScannerUI**, which supplies the design system (tokens, atoms, molecules) consumed throughout the app.
- UI is SwiftUI; the app root is a `UITabBarController` (`RootTabBarController`) hosting three `UIHostingController` tabs, since `UITabBarController`/`UIHostingController` bridging is still needed at the root for `iOS 16` (pre-`TabView`-parity concerns) — everything below that root is pure SwiftUI. Each tab's `UIHostingController` hosts its screen directly (no wrapping `UINavigationController`) — every screen already owns its own `NavigationStack`, and wrapping it a second time in UIKit produced a duplicated navigation title bar.
- Concurrency is Swift Concurrency (`async`/`await`, actors) — there is no GCD/completion-handler code left in the Managers layer.

## Build, run, and test

Open `FoodScanner.xcworkspace` (or the `.xcodeproj`) in Xcode, or use the command line. The scheme is `FoodScanner`.

```bash
# Build for simulator (use `xcodebuild -list` to confirm available simulator names in this environment)
xcodebuild -scheme FoodScanner -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run the full test suite (unit + UI)
xcodebuild -scheme FoodScanner -destination 'platform=iOS Simulator,name=iPhone 17' test

# Run a single test class or method
xcodebuild -scheme FoodScanner -destination 'platform=iOS Simulator,name=iPhone 17' \
  test -only-testing:FoodScannerTests/FoodScannerTests/testExample
```

Note: the existing `FoodScannerTests`/`FoodScannerUITests` are Xcode-template stubs with no real assertions.

## SPM dependencies

Declared as remote/local package references in `FoodScanner.xcodeproj/project.pbxproj`:
- `realm-swift` (Realm community branch) — local persistence, imported as `RealmSwift`
- `FoodScannerUI` — local package, the design system (tokens, atoms, molecules); every screen imports it

`Charts`/`DGCharts` and `FTLinearActivityIndicator` were removed — the pie chart was replaced by `FSScoreBadge` + `FSNutrientRow` bars, and network activity is now surfaced via a SwiftUI `ProgressView` driven by `NetworkActivityManager`.

## Architecture

SwiftUI screens, each with its own `ObservableObject` screen model (`@Published` state, `async` methods) — no shared MVVM base class, and no `@Observable` (deployment target iOS 16 predates the `Observation` framework's iOS 17 minimum). Layers live under `FoodScanner/`:

- **View** (`View/`) — one folder per screen/tab:
  - `View/Scanner/` — `ScannerScreenView` (camera + AVFoundation barcode capture via `CameraPreviewView`, `FSBarcodeField`/`FSKeypad` manual entry) + `ScannerScreenModel`.
  - `View/FoodDetail/` — `ProductSheetView` (product header, `FSProductCard`) and `NutrientsScreenView` (`FSScoreBadge` + `FSNutrientRow` bars) + `FoodDetailModel`, shared by the Scanner and History tabs.
  - `View/History/` — `HistoryScreenView` (`FSHistoryRow`, `FSOfflineBanner`, `FSSceneFooter`) + `HistoryScreenModel`. `FSHistoryRow` owns its own `Button` (it takes an `action` closure, not passive content), so navigation is driven by a `NavigationStack(path:)` bound to a local `NavigationPath` — the row's action appends the barcode to the path — rather than wrapping the row in a `NavigationLink`, which would nest a `Button` inside a `NavigationLink` and swallow the tap.
  - `View/Settings/` — `SettingsScreenView` (`FSToggleRow`, `FSTextSizeSlider`, `@AppStorage`-backed), owns its own `NavigationStack` like the other tabs, + `SettingsScreenModel`.
  - `View/Onboarding/OnboardingView.swift` — first-launch welcome/permissions screen, presented as a `.fullScreenCover` from the root.
  - `View/RootTabBarController.swift` — the only UIKit view controller left; hosts the three tabs, each owning its own `NavigationStack` (no UIKit `UINavigationController` wrapper — see Overview).
- **Model** (`Model/`) — `Food`/`Nutrient` are Realm `Object` subclasses (persisted, keyed by `barcode`, includes `nutriscoreGrade`). `FoodStruct`/`NutrientStruct`/`ProductRoot` are `Codable` + `Sendable` structs used to decode the API JSON and to cross async/actor boundaries. `FoodSummary` is a lightweight `Sendable` struct for the history list. `FoodBridge.swift` maps app model structs to design-system types (`FSNutrient`, `FSNutriScore`) — this mapping lives in the app, not in the `FoodScannerUI` package, which knows nothing about `Food`/`Nutrient`.

### Data flow (barcode → screen)

`ScannerScreenView` → `ScannerScreenModel` (`async` methods) → `WebServiceManager.getFoodDescription(barcode:) async throws -> FoodStruct` → `ParserManager.parseFood(from:) throws -> FoodStruct` (Codable decode) → `RealmManager.updateFood(_:) async` (persist) → `RealmManager.food(barcode:) async -> FoodStruct?` (read back) → navigation to `ProductSheetView` → `NutrientsScreenView` via `NavigationStack`. On network/parse failure, `WebServiceManager` falls back to the Realm cache for that barcode.

### Managers (`Managers/`, mostly `sharedInstance` singletons)

- `WebServiceManager` — Open Food Facts HTTP calls via `URLSession.shared.data(from:)`, `async throws`.
- `ParserManager` — JSON → model decoding; `static func parseFood(from data: Data) throws -> FoodStruct`.
- `RealmManager` — **`actor`**. All Realm reads/writes happen actor-isolated; its public API never returns Realm objects (`Food`/`Nutrient`), only Sendable structs (`FoodStruct`, `NutrientStruct`, `FoodSummary`). Uses a per-user Realm file and disables file protection on the Realm directory.
- `ReachabilityManager` — `ObservableObject` with `@Published private(set) var onlineMode`, wraps the vendored `Reachability` callback; `sharedInstance` singleton, observed directly by screen models via Combine or SwiftUI's `@Published`.
- `NetworkActivityManager` — `@MainActor final class ... ObservableObject` with `@Published private(set) var isActive`; drives a SwiftUI `ProgressView` indicator (no more `FTLinearActivityIndicator`).
- `ErrorManager` — kept only for blocking errors (e.g. camera permission denied) via `UIAlertController`; non-blocking cases (product not found, offline) use `FSScanStatusBanner`/`FSOfflineBanner` instead.

`NavigationManager` was removed — each tab manages its own navigation via `NavigationStack`.

### Tools and Open Source Code

- `Tools/` — utilities: `CameraTool`, `MutexCounter`, `Tool` (e.g. `getBestPicture` resolution picking). `MulticastDelegate` was removed after `ReachabilityManager` moved off the delegate pattern.
- `Open Source Code/` — vendored third-party sources: `Reachability` and `CwlMutex` (`PThreadMutex`). Edit with care; these track upstream projects.
- `Extensions/` — `DispatchQueue+Events`, `String+Regex`, `UIImageView+ImageCache` (async/await on top of `ImageCacheManager`, kept for UIKit call sites), `AppAccessibilitySettings` (propagates the Settings screen's text-size and reduce-animations choices app-wide via `View.appWideAccessibilitySettings()`, applied at each tab's root and to `OnboardingView`; see Conventions).
- `ImageCacheManager` (`Managers/`) — `actor`, `NSCache`-backed, dedupes concurrent downloads of the same URL. Shared image cache for both SwiftUI (`FoodDetailModel.loadThumbnail()` → `Image`) and UIKit (`UIImageView+ImageCache`) call sites.

## FoodScannerUI (design system)

Local SPM package under `FoodScannerUI/`, consumed via `import FoodScannerUI` throughout the app. Provides tokens (`FSColor`, `FSFont`, `FSMetrics`, `FSSeason`), atoms (`FSButton`, `FSScoreBadge`, `FSBarcodeField`, `FSKeypad`, `FSToggleRow`, `FSTextSizeSlider`, `FSPattern`, `FSMascot`), and molecules (`FSNutrientRow`, `FSProductCard`, `FSScanStatusBanner`, `FSHistoryRow`, `FSOfflineBanner`, `FSSceneFooter`). `FSNutrientRing` exists in the package but is intentionally unused (nutrient visualization uses score + bars instead). `FSNutrient` covers only 5 cases: carbs/fat/protein/salt/fiber (no "sugars" case — sugars is shown as plain text, not a bar).

Design rules enforced by the package and audited on every screen change: Nutri-Score colors never re-themed by light/dark mode, never color alone without a pattern (`FSPattern`), text ≥19pt, tap targets ≥44pt, Dynamic Type up to AX5, **no component performs its own async work** (no `AsyncImage(url:)`/`.task`-driven network fetch inside FoodScannerUI — a component only ever receives an already-resolved value, e.g. `FSProductCard(thumbnail: Image?)`; loading/caching is the app's job via `ImageCacheManager`). See `FoodScannerUI/MIGRATION.md` for the original screen-by-screen mapping this refactor was based on.

## Conventions

- Singletons are accessed via `Type.sharedInstance` (not `.shared`).
- Code documentation (comments, `///` doc comments) is always written in **English**, like the code itself — never French — regardless of what language surrounding prose (commit messages, PR descriptions, chat) happens to be in. This does not apply to user-facing strings (UI text, `accessibilityLabel`, error messages shown to the user), which stay French to match the app's locale. Existing French comments predating this rule are tracked as technical debt and migrated via `technical-debt-migration-orchestrator` phase 2, not rewritten ad hoc outside that governed process.
- Every Swift file carries a copyright header: `Copyright © MULLOT Romain EI. All rights reserved.` followed by `Created on MM/DD/YYYY.` (creation date, month/day/year). Any agent that creates a new file adds this header; any agent that touches an existing file missing it adds it too, using the file's actual creation date (`git log --follow --diff-filter=A --format=%ad --date=format:%m/%d/%Y -- <file>`, never a guessed date) — never rewrite a header already present in a different format (e.g. the older `Copyright © 2018 Romain Mullot`). `Generated/Assets.swift` (SwiftGen-generated) is exempt.
- `RealmManager`'s default Realm file is encrypted at rest (`Realm.Configuration.encryptionKey`, AES-256 via `RealmEncryptionKeyStore`); the key lives in the Keychain (`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`), generated on first launch, never stored alongside the `.realm` file itself.
- Async APIs use `async`/`await`; `RealmManager` is an actor. Do not let a Realm `Object`/`List` cross an async boundary — convert to a `Sendable` struct first.
- Each screen has its own `ObservableObject` screen model (`@Published` state); there is no shared closure/delegate binding pattern anymore.
- Realm model objects (`Food`, `Nutrient`) must only be created/mutated through `RealmManager`; pass `Codable`/`Sendable` structs (`FoodStruct`, `NutrientStruct`) across layer and concurrency boundaries and let `RealmManager` produce the persisted objects.
- Any UIKit↔SwiftUI or Realm↔design-system bridging code belongs in the app target (e.g. `FoodBridge.swift`), never inside the `FoodScannerUI` package, which must stay unaware of `Food`/`Nutrient`/Realm.
- For any non-trivial new feature or refactor, prefer delegating to `mvvmc-architecture-orchestrator` as the entry point: it is the referent for MVVM-C + service injection, testability, TDD/SOLID/Clean Architecture, and design-system compliance, and it plans + delegates the work (implementation to `swiftui-uikit-engineer`, cross-cutting audits to `design-system-reviewer`/`rgaa-accessibility-reviewer`/`rgpd-privacy-reviewer`, and test authoring to `test-suite-engineer`) rather than doing everything itself. Note it targets MVVM-C + DI going forward; the codebase as currently documented below still has no Coordinator layer and uses `.sharedInstance` singletons directly — the orchestrator converges new/touched code toward the target rather than mass-migrating unprompted.
- `test-suite-engineer` writes tests only after implementation is done and the build is green: unit tests always, UI tests only if views were created/modified, performance tests only if explicitly requested. It never touches production code.
- For a small, self-contained visual/screen change where the full orchestrator pipeline is overkill, delegating directly to `swiftui-uikit-engineer` is fine — it still self-audits against `design-system-reviewer`, `rgaa-accessibility-reviewer`, and (when data collection/storage/transmission is touched) `rgpd-privacy-reviewer` before concluding.
- Three distinct roles around FoodScannerUI, do not conflate them: `design-system-engineer` builds/extends the **package itself** (tokens/atoms/molecules), deciding SwiftUI vs. UIKit vs. Metal per component against pixel-perfect/stability/performance/theming and always consulting `rgaa-accessibility-reviewer`; `swiftui-uikit-engineer` **consumes** the package inside app screens; `design-system-reviewer` **audits** consumer code against the package + Apple HIG + supported iOS/device range after the fact, read-only. `design-system-engineer`'s scope also covers the app's brand identity outside the package itself: the app icon (`FoodScanner/Assets.xcassets/AppIcon.appiconset/`, generated in every size Apple requires — no alpha channel, no baked-in rounded corners) and flagging when a visual change makes existing App Store listing screenshots/description stale.
- Technical-debt work (legacy Objective-C, misspelled/undocumented symbols, leftover storyboards/zips, pre-MVVM code, non-injected singletons) goes through `technical-debt-migration-orchestrator`, never ad hoc. It runs 5 strictly sequential phases (Obj-C→Swift verbatim → spelling/docs/deprecation → storyboard/zip fragmentation into the design system → MVVM/SOLID/Clean Architecture → service injection/mockability then tests), one dedicated `techdebt/phase-<n>-*` branch per phase, and never merges/pushes/opens a PR itself — each phase requires explicit human validation and a merge to `develop` before the next phase starts.
- `rgaa-accessibility-reviewer` is the project's accessibility referent for iOS, pinned to **RGAA version 4.1.2**: consult it (not just after the fact, but before/during implementation for any non-obvious accessibility question) rather than guessing at RGAA-derived requirements. It transposes RGAA (a web standard) to native iOS equivalents — VoiceOver, Dynamic Type, Reduce Motion, Switch/Voice Control — never applies web criteria verbatim. A monthly cloud routine ("RGAA version watch (FoodScanner)") checks for a newer officially-published RGAA version; do not bump the pinned version without an explicit human decision.
- `rgpd-privacy-reviewer` is the project's GDPR/data-protection referent for iOS: consult it for any question touching data collection, local Realm storage, network transmission to Open Food Facts or any third party, data retention, or user rights (access/erasure). It is a technical referent, not a substitute for legal/DPO advice on contractual or regulatory matters.
- Accessibility settings from `SettingsScreenView` (text size, reduce animations) are app-scoped, not screen-local: propagate them from `AppAccessibilitySettings.swift` (`View.appWideAccessibilitySettings()`) applied at each tab's `UIHostingController` root, not just inside `SettingsScreenView`. "Reduce animations" uses an app-only `EnvironmentKey` (`appReduceAnimations`), consulted via `View.appAnimation(_:value:)`, because `\.accessibilityReduceMotion` is read-only in `EnvironmentValues` and FoodScannerUI components (`FSButton`, `FSMascot`) only honor the system value — extending that to app-only overrides needs a FoodScannerUI change. High-contrast is intentionally NOT wired up yet: FoodScannerUI exposes no contrast token/environment key, and no hard-coded value was added to fake it.
