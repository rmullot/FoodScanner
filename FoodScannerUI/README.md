# FoodScannerUI

FoodScanner's SwiftUI design system: atoms, molecules, seasonal tokens,
mascots, and scene vignettes. Targets iOS 17, no external dependencies.

## Adding the package to the project

1. Copy the `FoodScannerUI/` folder to the repo root, next to `FoodScanner.xcodeproj`.
2. Xcode → `File ▸ Add Package Dependencies… ▸ Add Local…` → select `FoodScannerUI`.
3. Target `FoodScanner` → `General` tab → `Frameworks, Libraries, and Embedded Content` → add `FoodScannerUI`.
4. In code: `import FoodScannerUI`.

To see the gallery in the simulator, present `FSGalleryView()`:

```swift
NavigationStack {
    FSGalleryView()
}
```

## Structure

| Folder | Contents |
| --- | --- |
| `Tokens/` | `FSSeason`, `Color.fs*`, `Font.fs*`, `FSMetrics` |
| `Atoms/` | `FSButton`, `FSIconButton`, `FSTag`, `FSScoreBadge`, `FSScoreScale`, `FSBarcodeField`, `FSKeypad`, `FSToggleRow`, `FSTextSizeSlider`, `FSPattern`, `FSPatternSwatch`, `FSMascot` |
| `Molecules/` | `FSNutrientRow`, `FSNutrientRing`, `FSNutrientLegend`, `FSProductCard`, `FSSeasonalHint`, `FSScanStatusBanner`, `FSHistoryRow`, `FSOfflineBanner`, `FSSceneFooter` |
| `Support/` | `FSHaptics`, `FSAnnounce`, `fsAnimation` (respects Reduce Motion) |
| `Gallery/` | `FSGalleryView` — two tabs: components, screens |
| `Resources/` | Any/Dark asset catalog + SVG sources for the scene vignettes |

## The two non-negotiable rules

**1. The Nutri-Score never follows the theme.** `FSNutriScore.color` returns the
official flat colors (#038141, #85BB2F, #FECB02, #EE8100, #E63E11) in both light
and dark, and `letterColor` puts black on the yellow C, white everywhere else.
Never override these colors.

**2. Never information by color alone.** Every nutrient carries a pattern
(`FSPattern.Motif`) alongside its color, and the score's letter is always
written out. A unit test checks that patterns stay unique.

## Season

```swift
FSGalleryView()                          // season follows the light/dark theme
    .fsSeason(.autumnWinter)             // or forced on a subtree
    .fsSeasonFollowsCalendar()           // or derived from the real month
```

Inside a component: `@FSResolvedSeason private var season`.

Spring-summer draws its colors from strawberry, pea, lemon, wheat, and olive
oil; autumn-winter from squash, chestnut, cabbage, and walnut.

## Fonts

The module declares `Caprasimo-Regular` and `Figtree-Regular` and falls back to
SF Rounded / SF Pro if the files aren't in the app's bundle. To enable them:
add the `.ttf` files to the `FoodScanner` target and declare them in
`Info.plist` (`UIAppFonts`) — check the license before embedding.

## Scene vignettes

`FSSceneFooter` works with no asset: the scenes are drawn in `Canvas`. For the
full vector version, export the PDFs and drop them into
`Resources/FoodScannerUI.xcassets/Scenes/*.imageset`:

```sh
brew install librsvg
sh Sources/FoodScannerUI/Resources/Scenes/make-pdfs.sh
```

`FSSceneFooter` uses the PDF as soon as it's present, falling back to the
drawing otherwise.

## Localization (SwiftGen)

The package's hardcoded text (VoiceOver labels/hints, default visible text)
lives in `Resources/fr.lproj/Localizable.strings` (base) and
`Resources/en.lproj/Localizable.strings` (translation), declared as SPM
resources in `Package.swift`. They're accessed through the generated
`FSL10n` enum (its own namespace, distinct from the target app's `L10n`, to
avoid any collision on the consumer side). Colors/images from
`FoodScannerUI.xcassets` are accessed through the generated `FSAsset` enum.
SF Symbols are listed (semantic key → symbol name) in
`Sources/FoodScannerUI/SFSymbols.yml` and accessed through the generated
`FSSymbol` enum (distinct from the target app's `SFSymbol`): no symbol
literal should ever be passed to `Image(systemName:)` / `systemImage:`.

These three generated files (`Generated/Strings.swift`, `Generated/Assets.swift`,
`Generated/SFSymbols.swift`) are produced by SwiftGen from
`FoodScannerUI/swiftgen.yml`. **Regeneration stays manual, a deliberate choice
made after investigating an SPM build-tool plugin** (see below) — it's not an
oversight. After any change to `Localizable.strings`, `FoodScannerUI.xcassets`,
or `SFSymbols.yml`, regenerate by hand:

```sh
swiftgen config run --config FoodScannerUI/swiftgen.yml
```

then commit the generated files (`Sources/FoodScannerUI/Generated/Strings.swift`,
`Sources/FoodScannerUI/Generated/Assets.swift`) — they're tracked by git rather
than ignored, unlike `FoodScanner/Generated/` on the app side, which
regenerates on every build via its Run Script.

### Why not an SPM build-tool plugin (2026-09-02)

A build-tool plugin (`plugin(name:, capability: .buildTool)`) is the modern
recommended way to automate SwiftGen inside an SPM package. Investigation
carried out before ruling it out:

- **No official SwiftGen plugin at the installed version (6.6.3).** The
  `SwiftGen/SwiftGen` repo has no `plugin` target in its `Package.swift` at
  that tag (nor on its `stable` branch, which points at exactly the `6.6.3`
  tag commit — so no newer version adds one either as of today). There's
  nothing to add as a dependency on the `SwiftGen/SwiftGen` side itself.
- **Community third-party plugins exist but don't fit a shared package.**
  Several unofficial wrappers exist (e.g. `SwiftGenPlugin` repos from
  various individual authors), but all have very low adoption (0 to a few
  stars), no maintenance guarantee, and no stable pinned version compatible
  with the templates used here (`structured-swift5`, `swift5` with
  `bundle: Bundle.module`). Adding a poorly-maintained external SPM
  dependency to the design system consumed by every screen would be a
  supply-chain risk disproportionate to the gain (avoiding one manual
  command).
- **A homemade plugin wrapping the `swiftgen` binary would be fragile.** SPM
  build-tool plugins run sandboxed with no network access; they can only
  reliably invoke an executable that's part of the package's own graph
  (a binary target or an executable built from source), not a Homebrew
  binary at a non-guaranteed path (`/opt/homebrew/bin/swiftgen` on Apple
  Silicon vs. `/usr/local/bin/swiftgen` on Intel vs. a CI runner's PATH).
  On top of that, Xcode shows a one-time trust prompt ("Enable this
  plugin?") the first time an unsigned build-tool plugin referenced by a
  local package runs — this prompt blocks any headless build (`xcodebuild`,
  CI) until accepted once manually, short of adding
  `-skipPackagePluginValidation`, which disables the same protection for
  every plugin in the graph.
- **Output is generated into sources, not a derived directory.**
  `swiftgen.yml` writes `Sources/FoodScannerUI/Generated/*.swift` (package
  source, committed), while the SPM convention for a build-tool plugin is to
  write into `context.pluginWorkDirectory` (build directory, never
  committed) and declare that file as the plugin's output. Switching to
  that model would change the source of truth (committed files would no
  longer be current) and buys nothing here for a template that rarely needs
  to change.

**Decision: documented manual regeneration, status quo.** This isn't
automated, but it's deliberate: every automation option available today is
either nonexistent (official plugin) or a maintenance/CI-fragility risk that
outweighs the benefit (third-party or homemade plugin). If SwiftGen ever
ships an official `SwiftGenPlugin`, or if that same risk becomes acceptable
to the team, revisit this choice then rather than forcing a fragile solution
now.

## Tests

```sh
swift test          # or ⌘U on the FoodScannerUI scheme in Xcode
```
