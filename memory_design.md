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

### No readable-width container modifier
FoodScannerUI has no `fsReadableWidth()` equivalent, so full-width SwiftUI screens (Settings, History, Product detail) stretch edge-to-edge on iPad / iPad Split View / large landscape.
- Affected: all app screens built on `ScrollView` + `VStack`
- Fix: add a `fsReadableContentWidth()` view modifier to the package (max content width + centering, tuned to the type sizes) and apply it at each screen root.
- Surfaced by: design-system-reviewer during the Settings accessibility rework.

### FSKeypad disabled submit button lacks an accessibilityHint / enable announcement
Since the `FSBarcodeField` / `FSKeypad` submit-button merge, the keypad's bottom button ("Chercher ce produit", `keypad.validate`) is the only manual-entry submit path. While `code.count < 8` it is disabled with no `accessibilityHint` explaining the 8–14 digit requirement, and VoiceOver gets no announcement when `code` crosses 8 digits and the button becomes enabled.
- Affected: `FoodScannerUI/Sources/FoodScannerUI/Atoms/FSInputs.swift` (`FSKeypad`)
- Fix: add a localized `accessibilityHint` on the submit `FSButton` stating the digit-count requirement; optionally `UIAccessibility.post(.announcement)` on the disabled→enabled transition (no repo precedent for the announcement — decide with rgaa reviewer).
- Surfaced by: design-system-reviewer + rgaa-accessibility-reviewer during the submit-button merge.
