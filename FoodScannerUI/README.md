# FoodScannerUI

Design system SwiftUI de FoodScanner : atomes, molécules, tokens saisonniers,
mascottes et saynètes. Cible iOS 16, aucune dépendance externe.

## Ajouter le package au projet

1. Copier le dossier `FoodScannerUI/` à la racine du dépôt, à côté de `FoodScanner.xcodeproj`.
2. Xcode → `File ▸ Add Package Dependencies… ▸ Add Local…` → choisir `FoodScannerUI`.
3. Cible `FoodScanner` → onglet `General` → `Frameworks, Libraries, and Embedded Content` → ajouter `FoodScannerUI`.
4. Dans le code : `import FoodScannerUI`.

Pour voir la galerie sur simulateur, présenter `FSGalleryView()` depuis un
`UIHostingController` (l'app est en UIKit) :

```swift
let vc = UIHostingController(rootView: FSGalleryView())
navigationController?.pushViewController(vc, animated: true)
```

## Structure

| Dossier | Contenu |
| --- | --- |
| `Tokens/` | `FSSeason`, `Color.fs*`, `Font.fs*`, `FSMetrics` |
| `Atoms/` | `FSButton`, `FSIconButton`, `FSTag`, `FSScoreBadge`, `FSScoreScale`, `FSBarcodeField`, `FSKeypad`, `FSToggleRow`, `FSTextSizeSlider`, `FSPattern`, `FSPatternSwatch`, `FSMascot` |
| `Molecules/` | `FSNutrientRow`, `FSNutrientRing`, `FSNutrientLegend`, `FSProductCard`, `FSSeasonalHint`, `FSScanStatusBanner`, `FSHistoryRow`, `FSOfflineBanner`, `FSSceneFooter` |
| `Support/` | `FSHaptics`, `FSAnnounce`, `fsAnimation` (respecte Reduce Motion) |
| `Gallery/` | `FSGalleryView` — deux onglets : composants, écrans |
| `Resources/` | asset catalog Any/Dark + sources SVG des saynètes |

## Les deux règles non négociables

**1. Le Nutri-Score ne suit pas le thème.** `FSNutriScore.color` renvoie les
aplats officiels (#038141, #85BB2F, #FECB02, #EE8100, #E63E11) en clair comme en
sombre, et `letterColor` met du noir sur le C jaune, du blanc partout ailleurs.
Ne surchargez jamais ces couleurs.

**2. Jamais d'information par la couleur seule.** Chaque nutriment porte un
motif (`FSPattern.Motif`) en plus de sa couleur, et la lettre du score est
toujours écrite en clair. Un test unitaire vérifie l'unicité des motifs.

## Saison

```swift
FSGalleryView()                          // la saison suit le thème clair/sombre
    .fsSeason(.autumnWinter)             // ou forcée sur un sous-arbre
    .fsSeasonFollowsCalendar()           // ou déduite du mois réel
```

Dans un composant : `@FSResolvedSeason private var season`.

Printemps-été tire ses couleurs de la fraise, du petit pois, du citron, du blé
et de l'huile d'olive ; automne-hiver du potimarron, de la châtaigne, du chou et
de la noix.

## Polices

Le module déclare `Caprasimo-Regular` et `Figtree-Regular` et retombe sur
SF Rounded / SF Pro si les fichiers ne sont pas dans le bundle de l'app. Pour
les activer : ajouter les `.ttf` à la cible `FoodScanner` et les déclarer dans
`Info.plist` (`UIAppFonts`) — vérifiez la licence avant embarquement.

## Saynètes

`FSSceneFooter` fonctionne sans asset : les décors sont dessinés en `Canvas`.
Pour la version vectorielle complète, exportez les PDF puis déposez-les dans
`Resources/FoodScannerUI.xcassets/Scenes/*.imageset` :

```sh
brew install librsvg
sh Sources/FoodScannerUI/Resources/Scenes/make-pdfs.sh
```

`FSSceneFooter` utilise le PDF dès qu'il est présent, sinon le dessin.

## Tests

```sh
swift test          # ou ⌘U sur le schéma FoodScannerUI dans Xcode
```
