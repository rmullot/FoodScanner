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

## Localisation (SwiftGen)

Les textes en dur du package (labels/hints VoiceOver, textes visibles par
défaut) vivent dans `Resources/fr.lproj/Localizable.strings` (base) et
`Resources/en.lproj/Localizable.strings` (traduction), déclarés comme
ressources SPM dans `Package.swift`. Ils sont accédés via l'enum généré
`FSL10n` (namespace dédié, distinct du `L10n` de l'app cible, pour éviter
toute collision côté consommateur). Les couleurs/images de
`FoodScannerUI.xcassets` sont accédées via l'enum généré `FSAsset`.

Ces deux fichiers sont produits par SwiftGen à partir de
`FoodScannerUI/swiftgen.yml`. **La régénération reste manuelle, par choix
délibéré après investigation d'un plugin SPM build-tool** (voir ci-dessous) —
ce n'est pas un oubli. Après toute modification de `Localizable.strings` ou
de `FoodScannerUI.xcassets`, régénérez à la main :

```sh
swiftgen config run --config FoodScannerUI/swiftgen.yml
```

puis committez les fichiers générés (`Sources/FoodScannerUI/Generated/Strings.swift`,
`Sources/FoodScannerUI/Generated/Assets.swift`) — ils sont suivis par git
plutôt qu'ignorés, contrairement à `FoodScanner/Generated/` côté app qui se
régénère à chaque build via son Run Script.

### Pourquoi pas un plugin SPM build-tool (2026-09-02)

Un build-tool plugin (`plugin(name:, capability: .buildTool)`) est
l'approche moderne recommandée pour automatiser SwiftGen dans un package SPM.
Investigation menée avant de l'écarter :

- **Plugin officiel SwiftGen : inexistant à la version installée (6.6.3).**
  Le dépôt `SwiftGen/SwiftGen` ne contient aucun target `plugin` dans son
  `Package.swift` à ce tag (ni sur sa branche `stable`, qui pointe exactement
  sur le commit du tag `6.6.3` — donc aucune version plus récente ne l'ajoute
  non plus à ce jour). Il n'y a donc rien à ajouter en dépendance côté
  `SwiftGen/SwiftGen` lui-même.
- **Plugins tiers communautaires : existants mais inadaptés à un package
  partagé.** Plusieurs wrappers non officiels existent (ex. dépôts
  `SwiftGenPlugin` de différents auteurs individuels), mais tous ont une très
  faible adoption (0 à quelques étoiles), pas de garantie de maintenance ni
  de version épinglée stable compatible avec les templates utilisés ici
  (`structured-swift5`, `swift5` avec `bundle: Bundle.module`). Ajouter une
  dépendance SPM externe peu maintenue au design system consommé par tout
  l'écran serait un risque de chaîne d'approvisionnement disproportionné par
  rapport au gain (éviter une commande manuelle).
- **Un plugin maison enveloppant le binaire `swiftgen` serait fragile.** Les
  build-tool plugins SPM tournent en sandbox et n'ont pas d'accès réseau ; ils
  ne peuvent invoquer de façon fiable qu'un exécutable qui fait partie du
  graphe du package (binary target ou exécutable buildé depuis les sources),
  pas un binaire Homebrew à un chemin non garanti (`/opt/homebrew/bin/swiftgen`
  sur Apple Silicon vs `/usr/local/bin/swiftgen` sur Intel vs le PATH d'un
  runner CI). De plus, Xcode affiche une invite de confiance ponctuelle
  ("Enable this plugin?") au premier lancement d'un plugin build-tool non
  signé référencé par un package local — cette invite bloque tout build
  headless (`xcodebuild`, CI) tant qu'elle n'est pas acceptée une fois
  manuellement, sauf à ajouter `-skipPackagePluginValidation`, ce qui
  désactive la même protection pour tous les plugins du graphe.
- **Sortie générée dans les sources, pas dans un répertoire dérivé.**
  `swiftgen.yml` écrit `Sources/FoodScannerUI/Generated/*.swift` (source du
  package, committée) alors que la convention SPM pour un build-tool plugin
  est d'écrire dans `context.pluginWorkDirectory` (répertoire de build,
  jamais committé) et de déclarer ce fichier en sortie du plugin. Basculer
  sur ce modèle changerait la source de vérité (les fichiers committés ne
  seraient plus à jour) et n'apporte rien ici pour un template qui a rarement
  besoin d'évoluer.

**Décision : régénération manuelle documentée, statu quo.** Ce n'est pas
automatisé, mais c'est délibéré : chaque option d'automatisation disponible
aujourd'hui est soit inexistante (plugin officiel), soit un risque de
maintenance/fragilité CI qui dépasse le bénéfice (plugin tiers ou plugin
maison). Si SwiftGen publie un jour un plugin officiel `SwiftGenPlugin`, ou si
ce même risque est jugé acceptable par l'équipe, revisiter ce choix à ce
moment-là plutôt que de forcer une solution fragile maintenant.

## Tests

```sh
swift test          # ou ⌘U sur le schéma FoodScannerUI dans Xcode
```
