# Design system — open follow-ups

Running backlog of still-open design-system points. Remove an entry the same change it is resolved; append new ones as `### ` blocks (context, affected files, suggested fix).

### No section-header atom in FoodScannerUI
`SettingsScreenView` hand-assembles its "Accessibilité" section header from `Text` + `.fsBody` + `Color.fsInkSecondary` + `.accessibilityAddTraits(.isHeader)`. Any future grouped screen will re-duplicate this.
- Affected: `FoodScanner/View/Settings/SettingsScreenView.swift`
- Fix: add an `FSSectionHeader(_ title:)` atom to FoodScannerUI (correct token, uppercase/tracking per design intent, `.isHeader` trait baked in) and adopt it in Settings.
- Surfaced by: design-system-reviewer during the Settings accessibility rework.

### SettingsScreenView VoiceOver announcements can collide on return from iOS Settings
`SettingsScreenView` posts `FSAnnounce.say(...)` from two separate `.onChange` handlers (`reduceAnimationsForcedBySystem`, `systemIncreasedContrastEnabled`). If the user flips several toggles in iOS Settings and returns, both can fire in the same runloop and the second `UIAccessibility.post(.announcement)` clobbers the first.
- Affected: `FoodScanner/View/Settings/SettingsScreenView.swift`, `FoodScanner/View/Settings/SettingsViewModel.swift`
- Fix: expose a single `Equatable` accessibility snapshot + a composed announcement string on `SettingsViewModel`; observe that one value in the view and announce once. Touches the VM contract + `SettingsViewModelTests`, so out of scope for the initial fix.
- Surfaced by: design-system-reviewer + rgaa-accessibility-reviewer during the Settings accessibility rework.

### Scanner panel overflows below the tab bar in portrait on iOS 27
Reproduced on the iOS 27.0 iPhone 17 with the keypad open: the input panel is taller than the space above the floating tab bar (toggle button at y≈886 in an 874pt window), and with the camera unauthorized the "En attente de l'autorisation caméra" text is covered by the panel. Landscape was fixed (two-column panel, bottom-anchored, nav bar hidden); portrait is being reworked: camera as a background layer, status area + panel stacked in a `VStack` inside the `GeometryReader`, panel height capped by `ScannerLayout.panelMaxHeight`. The container height reported by the `GeometryReader` in portrait is not yet explained (landscape reports the safe-area height correctly: 750×260, top 78, bottom 64).
- Affected: `FoodScanner/View/Scanner/ScannerScreenView.swift`, `FoodScanner/View/Scanner/ScannerLayout.swift`
- Fix: measure `proxy.size` / `safeAreaInsets` in portrait on iOS 27, make the panel end exactly at the tab bar's top edge, then validate with `ScannerKeypadUITests` (see `memory_testing.md`).
- Also open: the `FSMascot` breathing animation (`repeatForever`, scale 1.0-1.04) runs continuously on the Scanner placeholder and the onboarding; reported as "never stops moving" — decide whether to stop it after a few cycles or tie it to an explicit state.

### iPhone Duo APIs (ReservedRegion, ArrangementView) not adopted yet
The HIG iPhone Duo page (`designing-for-iphone-duo`) and the developer article `TechnologyOverviews/preparing-your-app-for-iphone-duo` recommend `ReservedRegion` (keep custom content clear of the fold / cameras) and `ArrangementView` for two-pane layouts. Both are iOS/iPadOS 27.1+; local Xcode is 27.0 with no Duo simulator, and the deployment target is 17.0.
- Affected: `FoodScanner/View/Scanner/ScannerScreenView.swift` (camera + keypad layout), History master/detail
- Fix: once an Xcode with the 27.1 SDK is installed, adopt them behind `#available(iOS 27.1, *)` with the size-class layout as fallback; use `toolbarVerticalEdge` / `ToolbarItemPlacement` / `visibilityPriority` for bars; test with Device Hub. Read pages via `apple-docs-referent` (`tutorials/data/...md`).
- Surfaced by: iPhone Duo adaptive-layout planning.

### FSKeypad disabled submit button lacks an accessibilityHint / enable announcement
Since the `FSBarcodeField` / `FSKeypad` submit-button merge, the keypad's bottom button ("Chercher ce produit", `keypad.validate`) is the only manual-entry submit path. While `code.count < 8` it is disabled with no `accessibilityHint` explaining the 8–14 digit requirement, and VoiceOver gets no announcement when `code` crosses 8 digits and the button becomes enabled.
- Affected: `FoodScannerUI/Sources/FoodScannerUI/Atoms/FSInputs.swift` (`FSKeypad`)
- Fix: add a localized `accessibilityHint` on the submit `FSButton` stating the digit-count requirement; optionally `UIAccessibility.post(.announcement)` on the disabled→enabled transition (no repo precedent for the announcement — decide with rgaa reviewer).
- Surfaced by: design-system-reviewer + rgaa-accessibility-reviewer during the submit-button merge.
