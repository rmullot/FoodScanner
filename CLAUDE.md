# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

FoodScanner is an iOS app (Swift, UIKit) that scans a product barcode (or accepts a typed barcode), fetches nutrition data from the Open Food Facts API (`https://world.openfoodfacts.org/api/v0/product/<barcode>.json`), caches it in Realm, and displays nutrient breakdowns including a pie chart.

- Deployment target: iOS 16.0
- Dependencies are managed via **Swift Package Manager** (resolved by the `FoodScanner.xcodeproj`, not the workspace). This branch (`feature/update_to_spm`) migrated the project off CocoaPods to SPM.

## Build, run, and test

Open `FoodScanner.xcworkspace` (or the `.xcodeproj`) in Xcode, or use the command line. The scheme is `FoodScanner`.

```bash
# Build for simulator
xcodebuild -scheme FoodScanner -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run the full test suite (unit + UI)
xcodebuild -scheme FoodScanner -destination 'platform=iOS Simulator,name=iPhone 15' test

# Run a single test class or method
xcodebuild -scheme FoodScanner -destination 'platform=iOS Simulator,name=iPhone 15' \
  test -only-testing:FoodScannerTests/FoodScannerTests/testExample

# Resolve SPM dependencies (Xcode does this automatically on open)
xcodebuild -list   # also triggers package graph resolution
```

Note: the existing `FoodScannerTests`/`FoodScannerUITests` are Xcode-template stubs with no real assertions.

## SPM dependencies

Declared as remote package references in `FoodScanner.xcodeproj/project.pbxproj`:
- `realm-swift` (Realm community branch) — local persistence, imported as `RealmSwift`
- `Charts` (ChartsOrg, ≥5.1.0) — imported as `DGCharts` for the nutrient pie chart
- `FTLinearActivityIndicator` (≥2.0.2) — network activity indicator

## Architecture

MVVM with a set of singleton "Manager" services. Layers live under `FoodScanner/`:

- **View** (`View/`) — `ScannerViewController` (camera + AVFoundation barcode capture, search bar) and `FoodViewController` (collection-view-based nutrient display with chart cells). UI is defined in `View/Base.lproj/Main.storyboard`.
- **ViewModel** (`ViewModel/`) — `ScannerViewModel`, `FoodViewModel`. View models expose a `propertyChanged: ((key: String) -> Void)?` callback and a `PropertyKeys` enum; view controllers subscribe to it for one-way data binding (no Combine/RxSwift).
- **Model** (`Model/`) — `Food`/`Nutrient` are Realm `Object` subclasses (persisted, keyed by `barcode`). `FoodStruct`/`ProductRoot` are `Codable` structs used to decode the API JSON before conversion into Realm objects.

### Data flow (barcode → screen)

`ScannerViewController` → `ScannerViewModel.getFoodInformations(barcode:)` → `WebServiceManager.getFoodDescription` → `ParserManager.parseFoodFromJSON` (Codable decode into `FoodStruct`) → `RealmManager.updateFood` (persist) → `RealmManager.getFood` (read back the managed `Food`) → `NavigationManager.navigateToFoodDescription` pushes `FoodViewController`. On network/parse failure, `WebServiceManager` falls back to the Realm cache for that barcode.

### Managers (`Managers/`, mostly `sharedInstance` singletons)

- `WebServiceManager` — Open Food Facts HTTP calls; defines a local `Result<T>` enum (`.Success`/`.Error`) distinct from the `ParserResult` enum used by the parser.
- `ParserManager` — JSON → model decoding; `ParserResult`/`ParserError`.
- `RealmManager` — all Realm reads/writes; uses a background dispatch queue and a per-user Realm file. Disables file protection on the Realm directory.
- `NavigationManager` — programmatic navigation; reaches the root `UINavigationController` via `UIApplication.shared.keyWindow`.
- `ReachabilityManager` / `NetworkActivityManager` / `ErrorManager` — connectivity, activity indicator, error surfacing.

### Tools and Open Source Code

- `Tools/` — utilities: `CameraTool`, `MulticastDelegate<T>` (thread-safe weak delegate set guarded by `PThreadMutex`), `MutexCounter`, `Tool` (e.g. `getBestPicture` resolution picking).
- `Open Source Code/` — vendored third-party sources: `Reachability` and `CwlMutex` (`PThreadMutex`). Edit with care; these track upstream projects.
- `Extensions/` — `DispatchQueue+Events`, `String+Regex`, `UIImageView+ImageCache`.

## Conventions

- Singletons are accessed via `Type.sharedInstance` (not `.shared`).
- Async APIs use completion handlers, not async/await or Combine.
- View-to-ViewModel binding is the `propertyChanged` closure + `PropertyKeys` string-enum pattern; follow it when adding observable state.
- Realm model objects (`Food`, `Nutrient`) must only be created/mutated through `RealmManager`; pass `Codable` structs (`FoodStruct`) across layer boundaries and let `RealmManager` produce the persisted objects.
