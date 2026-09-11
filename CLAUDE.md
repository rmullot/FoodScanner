# CLAUDE.md

Guidance for Claude Code working in this repository.

## Overview

FoodScanner is an iOS app (Swift, SwiftUI) that scans a product barcode (or accepts a typed one), fetches nutrition data from Open Food Facts (`https://world.openfoodfacts.org/api/v0/product/<barcode>.json`), caches it in Realm, and shows a nutrient breakdown (Nutri-Score badge + proportion bars).

- Deployment target: **iOS 17.0**. View models still use `ObservableObject` / `@Published`; migrating them to `@Observable` is deferred (`.claude/memory/memory_feature.md`).
- Dependencies via **Swift Package Manager**. Local package **FoodScannerUI** is the design system (tokens, atoms, molecules); every screen imports it.
- App uses the SwiftUI lifecycle: `FoodScannerApp` (`@main`, `App`) → `RootView`, a pure SwiftUI `TabView` with three tabs. No `AppDelegate`/`SceneDelegate`. `RootView` applies `appWideAccessibilitySettings()` and hosts the first-launch onboarding `.fullScreenCover`. Navigation is per-flow: the Scanner tab runs through a `Coordinator` + `Router` (`FoodScanner/View/Coordinator/`) that owns the `NavigationStack` path; History still owns a local `NavigationPath`. No `UINavigationController` anywhere.
- Concurrency is `async`/`await` + actors. No GCD / completion handlers in the Managers layer.

## Backlog memory files

Four running backlog files in `.claude/memory/` hold the still-open follow-up points per area: `memory_cybersecurity.md`, `memory_design.md`, `memory_testing.md`, `memory_feature.md`.

- **Before starting a task**, read the file(s) matching its area and fold any relevant open point into the plan.
- **When a point is resolved**, delete its entry from the file in the same change.
- **When you surface new follow-ups or deferred work**, append them to the matching file as a `### ` entry (context, affected files, suggested fix) — don't only mention them in chat.

## Build and test

Scheme is `FoodScanner`. Confirm simulator names with `xcodebuild -list`.

```bash
xcodebuild -scheme FoodScanner -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -scheme FoodScanner -destination 'platform=iOS Simulator,name=iPhone 17' test
xcodebuild -scheme FoodScanner -destination 'platform=iOS Simulator,name=iPhone 17' \
  test -only-testing:FoodScannerTests/CacheManagerTests
```

`FoodScannerTests/` holds a real unit suite (service-protocol test doubles in `TestDoubles.swift`); `FoodScannerUITests/` holds XCUITests.

## SPM dependencies

Declared in `FoodScanner.xcodeproj/project.pbxproj`:
- `realm-swift` — pinned to exact version **20.0.5**, imported as `RealmSwift`.
- `FoodScannerUI` — local design-system package.

## Architecture

Each screen has an `ObservableObject` view model `<Screen>ViewModel` (`@Published` state, `async` methods) — no shared base class. Services are injected as protocol parameters (`WebServiceProviding`, `CacheProviding`, `ReachabilityProviding`, `NetworkActivityTracking`, `ImageCaching`, `SystemAccessibilityProviding`) with a `nil` default resolving to `InjectionManager.shared.<service>`, so production call sites stay `ScannerViewModel()` and tests pass fakes.

### View (`FoodScanner/View/`, one folder per tab/screen)

- `Scanner/` — `ScannerScreenView` (AVFoundation capture via `CameraPreviewView`, `FSBarcodeField` / `FSKeypad` manual entry) + `ScannerViewModel`. Coordinator-agnostic: it takes its VM plus an `onProductFound` closure; the `NavigationStack` and destination live in `ScannerCoordinatorView`.
- `Coordinator/` — `Router<Route>` (owns a typed nav stack), `Coordinator` protocol, `ScannerCoordinator` + `ScannerCoordinatorView` (build the Scanner flow's screens/VMs, translate intents to `router.push`). Views never reference these types.
- `FoodDetail/` — `ProductDetailScreenView` (`FSProductCard`, `FSNutrientRow`) + `FoodDetailViewModel`, shared by the Scanner and History tabs.
- `History/` — `HistoryScreenView` (`FSHistoryRow`, `FSOfflineBanner`, `FSSceneFooter`) + `HistoryViewModel`. `FSHistoryRow` owns its `Button` (takes an `action` closure), so navigation is a `NavigationStack(path:)` bound to a local `NavigationPath` the row appends to — not a `NavigationLink`.
- `Settings/` — `SettingsScreenView` (`FSToggleRow`, `FSStatusRow`, `FSTextSizeSlider`, `@AppStorage`-backed) + `SettingsViewModel` (mirrors live system accessibility state via injected `SystemAccessibilityProviding`; system-imposed settings render as read-only `FSStatusRow`s).
- `Onboarding/OnboardingView.swift` — first-launch permissions screen, a `.fullScreenCover` from `RootView`.
- `RootView.swift` — the SwiftUI `TabView` root (lives in `FoodScanner/`, next to `FoodScannerApp.swift`).

### Model (`FoodScanner/Model/`)

- `Food` / `Nutrient` — Realm `Object` subclasses, keyed by `barcode`, persisted only.
- `FoodStruct` / `NutrientStruct` / `ProductRoot` — `Codable` + `Sendable`, used to decode the API and cross async/actor boundaries. `FoodSummary` — lightweight `Sendable` struct for the history list.
- `FoodBridge.swift` — maps app structs to design-system types (`FSNutrient`, `FSNutriScore`). Lives in the app; the package knows nothing of `Food`/`Nutrient`/Realm.

### Data flow

`ScannerScreenView` → `ScannerViewModel` → `WebServiceManager.getFoodDescription(barcode:) async throws -> FoodStruct` → `ParserManager.parseFood(from:) throws` → `CacheManager.updateFood(_:) async` → `CacheManager.food(barcode:) async -> FoodStruct?` → navigation to `ProductDetailScreenView`. On network/parse failure `WebServiceManager` falls back to the Realm cache.

### Managers (`FoodScanner/Managers/`, wired by `InjectionManager`)

`InjectionManager` (`@MainActor final class`, `.shared`) is the single composition root: owns one instance of each service, exposes them behind protocols. No `sharedInstance` anywhere; cross-service deps are constructor-injected.

- `WebServiceManager` — `WebServiceProviding`; Open Food Facts HTTP via `URLSession.shared`; holds injected `CacheProviding` + `NetworkActivityTracking`.
- `ParserManager` — stateless `static func parseFood(from: Data) throws -> FoodStruct`.
- `CacheManager` — **actor**, `CacheProviding`. All Realm access is actor-isolated; public API returns only Sendable structs. `init(configuration: Realm.Configuration? = nil)`: `nil` builds the encrypted on-disk config (see SECURITY note below); a passed config (in-memory in tests) is used as-is.
- `ReachabilityManager` — `@MainActor ObservableObject`, `ReachabilityProviding`. Wraps a `ReachabilitySource` seam (`SystemReachabilitySource` in prod owns the vendored `Reachability` + `CTTelephonyNetworkInfo`; fake in tests). `.offline` transition debounced (default 2s) via a cancellable `Task`.
- `NetworkActivityManager` — `@MainActor ObservableObject`, `@Published private(set) var isActive`; drives a `ProgressView`. Auto-off is a cancellable `Task`.
- `ErrorManager` — blocking errors only (e.g. camera denied) via `UIAlertController` through an injected `AlertPresenting` seam (`KeyWindowAlertPresenter` in prod). Non-blocking cases use `FSScanStatusBanner` / `FSOfflineBanner`.
- `ImageCacheManager` — **actor**, `NSCache`-backed, dedupes concurrent downloads. Shared by SwiftUI (`FoodDetailViewModel.loadThumbnail()`) and UIKit (`UIImageView+ImageCache`).
- `SystemAccessibilityManager` — `@MainActor`, `SystemAccessibilityProviding`. Read-only mirror of the live iOS accessibility state (Reduce Motion, Increase Contrast / darker colors, preferred content size category); subscribes to the matching `UIAccessibility` / `UIContentSizeCategory` change notifications and republishes them via `changesPublisher`. Consumed by `SettingsViewModel` so Réglages reflects and live-updates the system settings the app cannot mutate.

### Other

- `Tools/` — `CameraTool`, `MutexCounter`, `Tool` (`getBestPicture` resolution picking).
- `Open Source Code/` — vendored `Reachability` and `CwlMutex`; track upstream, edit with care. `Reachability`'s callback fires off-main — `SystemReachabilitySource` is the only place it's bridged to `@MainActor`.
- `Extensions/` — `String+Regex`, `UIApplication+KeyWindow`, `UIImageView+ImageCache`, `AppAccessibilitySettings` (see Conventions).

## Localization (French base, English)

French is the source/UI locale. Two independent SwiftGen layers, matching the app/package boundary — never merge them:

- **App** (`FoodScanner/`) — `fr.lproj`/`en.lproj` `Localizable.strings` → `Generated/Strings.swift` (`L10n.*`), via the root `swiftgen.yml` Run Script phase. Info.plist usage strings localized via `InfoPlist.strings`.
- **Package** (`FoodScannerUI/`) — its own `Sources/FoodScannerUI/Resources/{fr,en}.lproj/Localizable.strings` → `FSL10n.*` (`Bundle.module`), via `FoodScannerUI/swiftgen.yml`. Regeneration documented in `FoodScannerUI/README.md`.
- Assets and SF Symbols split the same way: app → `Asset.*` / `SFSymbol.*` (internal); package → `FSAsset.*` / `FSSymbol.*` (public). SF Symbols are declared in `SFSymbols.yml` per side.
- **Never** hardcode `Image("name")` / `UIImage(named:)` / `Image(systemName:)` / `Label(_:systemImage:)` — always the generated key. **Never** hand-edit `Generated/*.swift` — edit the source `.strings` / `.xcassets` / `.yml` and regenerate.
- Use `localization-engineer` whenever a user-facing string changes or a literal is found.

## FoodScannerUI (design system)

Local SPM package, `import FoodScannerUI`. Tokens (`FSColor`, `FSFont`, `FSMetrics`, `FSSeason`), atoms (`FSButton`, `FSScoreBadge`, `FSInputs` = `FSBarcodeField`/`FSKeypad`/`FSToggleRow`/`FSTextSizeSlider`, `FSStatusRow`, `FSPattern`, `FSMascot`), molecules (`FSNutrientRow`, `FSProductCard`, `FSScanStatusBanner`, `FSHistoryRow`, `FSOfflineBanner`, `FSSceneFooter`). `FSNutrientRing` exists but is intentionally unused. `FSNutrient` has 5 cases — carbs/fat/protein/salt/fiber (sugars is plain text, no bar).

Enforced design rules, audited on every screen change:
- Nutri-Score colors never re-themed by light/dark; never color alone without an `FSPattern`.
- Text ≥ 19pt, tap targets ≥ 44pt, Dynamic Type to AX5, nothing truncated at max text size.
- **No component does its own async work** — it receives already-resolved values (e.g. `FSProductCard(thumbnail: Image?)`); loading/caching is the app's job.

`FoodScannerUI/MIGRATION.md` has the original screen-by-screen mapping.

## Conventions

- **No singletons / no `sharedInstance`.** A new service gets a protocol, an `InjectionManager` property, and a `nil`-defaulted constructor parameter on its view-model consumers.
- **Code docs and comments are English**; user-facing strings stay French. `.claude/` files (this file, every `.claude/agents/*.md` incl. frontmatter) are English regardless of the request language.
- **No comments in code**, four exceptions only: (1) `// SECURITY: ...` on security-relevant logic, (2) `// TODO: ...` for real outstanding work, (3) `// MARK:` navigation markers, (4) a `///` doc comment stating a **design-system visual constant** (a color's role/appearance, a pt size, a spacing/radius/touch-target value) — not narration. Enforced by the `no_explanatory_comments` SwiftLint rule; fix the comment, never `// swiftlint:disable` it. The copyright header is exempt.
- **SwiftLint** (`.swiftlint.yml` at repo root) is the lint referent — run `swiftlint lint` before calling a change done. The Xcode SwiftLint run-script build phase runs `swiftlint lint --strict`, so **any warning fails the build** (locally and in CI, since `build-for-testing` runs the phase) — there is no warnings-are-ignorable tier. Don't weaken a rule or add `disabled_rules` to hide a warning; fix the code, or raise a deliberate `.swiftlint.yml` change.
- **Copyright header** on every Swift file: `Copyright © MULLOT Romain EI. All rights reserved.` then `Created on MM/DD/YYYY.` Use the file's real creation date (`git log --follow --diff-filter=A --format=%ad --date=format:%m/%d/%Y -- <file>`). Don't rewrite a header already in another format. `Generated/*.swift` exempt.
- **SECURITY** — `CacheManager`'s default Realm file is encrypted at rest (`Realm.Configuration.encryptionKey`, AES-256 via `RealmEncryptionKeyStore`); the key lives in the Keychain (`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`), generated on first launch, never stored beside the `.realm`. Tests inject an in-memory config, which skips this.
- `CacheManager` is an actor — never let a Realm `Object`/`List` cross an async boundary; convert to a `Sendable` struct first. `Food`/`Nutrient` are created/mutated only through `CacheManager`.
- UIKit↔SwiftUI and Realm↔design-system bridging belongs in the app (e.g. `FoodBridge.swift`), never in the package.
- Accessibility settings from `SettingsScreenView` (text size, reduce animations) are app-scoped: propagated by `AppAccessibilitySettings.swift` (`View.appWideAccessibilitySettings()`) at each tab's hosting-controller root. "Reduce animations" uses an app-only `EnvironmentKey` `appReduceAnimations` via `View.appAnimation(_:value:)` (system `\.accessibilityReduceMotion` is read-only). High-contrast **is** wired up, driven by the real system signal `@Environment(\.colorSchemeContrast) == .increased` (no custom contrast toggle): design-system controls (`FSButton`, `FSIconButton`, `FSKeypad`, `FSBarcodeField`) thicken their borders via `FSMetrics.borderWidth(for:)` / `borderWidthStrong(for:)`, swap to the `Color.fsBorderStrong` / `Color.fsAccentSoftStrong` tokens, and bump label/glyph weight (`Font.fsBodyHeavy`). Nutri-Score colors stay untouched. `fsCard()` is contrast-aware too, via `FSCardModifier` reading `\.fsResolvedContrast` (the shared resolver on `EnvironmentValues`: system `\.colorSchemeContrast` OR-ed with the preview-only `fsIncreasedContrastOverride`); under increased contrast it swaps to `Color.fsBorderStrong` at `FSMetrics.borderWidthStrongIncreased`. Atoms read the same `\.fsResolvedContrast` resolver.

## Agents

- `mvvmc-architecture-orchestrator` — entry point for any non-trivial feature/refactor. Referent for MVVM-C + DI, testability, TDD/SOLID/Clean Architecture, design-system compliance. Plans and delegates (to `swiftui-uikit-engineer`, the reviewers, `test-suite-engineer`). Converges touched code toward MVVM-C + DI; doesn't mass-migrate unprompted. Coordinator + `Router` layer exists for the Scanner flow (`FoodScanner/View/Coordinator/`); History/Settings not yet migrated.
- `swiftui-uikit-engineer` — implements/consumes the design system inside app screens. Fine to call directly for a small self-contained visual change; it self-audits with the reviewers below before concluding.
- `design-system-engineer` — builds/extends the **package itself** (tokens/atoms/molecules), choosing SwiftUI/UIKit/Metal per component; also owns brand identity (app icon in `FoodScanner/Assets.xcassets/AppIcon.appiconset/` — every size, no alpha, no baked corners) and flags stale App Store screenshots.
- `design-system-reviewer` — read-only audit of consumer code vs. the package + Apple HIG + supported iOS/device range.
- `rgaa-accessibility-reviewer` — accessibility referent, pinned to **RGAA 4.1.2**, transposed to native iOS. Consult before/during/after, not just after. A monthly cloud routine watches for a newer RGAA version; don't bump the pin without a human decision.
- `rgpd-privacy-reviewer` — GDPR/data-protection referent (collection, Realm storage, network to Open Food Facts, retention, access/erasure). Technical, not legal advice.
- `app-store-submission-reviewer` — read-only submission-readiness (capabilities vs. use, Info.plist usage strings, ATS, `PrivacyInfo.xcprivacy`, icon completeness, version/build, secrets). Run before any App Store Connect submission or when a capability/entitlement/Info.plist key changes. (No HealthKit — the app doesn't use it.)
- `test-suite-engineer` — writes tests after implementation is green: unit always, UI only if views changed, performance only if asked. Never touches production code.
- `localization-engineer` — maintains the two localization layers (see Localization).
- `technical-debt-migration-orchestrator` — all technical-debt work (legacy Obj-C, misspelled symbols, storyboards, pre-MVVM code, non-injected singletons). 5 strictly sequential phases, one `techdebt/phase-<n>-*` branch each, human validation + merge to `develop` between phases. Never merges/pushes/opens a PR itself.
