# Migration de l'app existante vers FoodScannerUI

Écrit à partir du code de la branche courante : `Model/Food.swift`,
`Model/Nutrient.swift`, `ViewModel/FoodViewModel.swift`,
`View/FoodViewController/*`, `Managers/ErrorManager.swift`.

L'app est en UIKit + storyboard, le design system en SwiftUI : la migration se
fait écran par écran par `UIHostingController` / `UIHostingConfiguration`, sans
toucher aux managers ni à Realm. Aucun composant ne connaît `Food` ni
`Nutrient` — ils prennent `String`, `Double`, `FSNutrient`, `FSNutriScore`.

## Ce que le modèle contient réellement

| Type | Propriétés | Conséquence pour le design system |
| --- | --- | --- |
| `Food` (Realm) | `barcode`, `imageURL: String`, `name`, `lastUpdate: TimeInterval`, `nutrients: List<Nutrient>` | `FSProductCard` ne peut recevoir que `name` et `imageURL` |
| `Nutrient` (Realm) | `quantity: Double`, `name: String`, `type: Int` (`NutrientType`) | alimente `FSNutrientRow` / `FSNutrientRing` |
| `MainNutrientName` | `Protéines`, `Glucides`, `Lipides`, `Fibres`, `Sel` | c'est la clé de mapping vers `FSNutrient` |
| `NutrientType` | `calories`, `mainNutrient`, `subNutrient` | les calories ne sont pas un segment d'anneau |

**Il n'y a pas de Nutri-Score dans le modèle**, ni de marque, ni de quantité :
`FoodStruct` ne décode que `code`, `image_small_url`, `product_name`,
`last_modified_t` et `nutriments`. Pour utiliser `FSScoreBadge` /
`FSScoreScale` il faut d'abord ajouter `nutriscore_grade` au décodage
(`CodingKeys` de `FoodStruct`) et à `Food`. Tant que ce n'est pas fait,
passez `score: nil` : tous les composants l'acceptent.

## Correspondances écran par écran

| Vue actuelle | Fichier | Composants FoodScannerUI |
| --- | --- | --- |
| Cellule d'un nutriment (`typeLabel` / `quantityLabel`) | `View/FoodViewController/NutrientTableViewCell.swift` | `FSNutrientRow` |
| Cellule collection des nutriments | `NutrientsCollectionViewCell.swift` | `FSNutrientRow` |
| Camembert DGCharts (`PieChartView`, enum privée `ColorChart`) | `ChartCollectionViewCell.swift` | `FSNutrientRing` + `FSNutrientLegend` |
| En-tête produit (nom + image) | `FoodCollectionReusableView.swift` | `FSProductCard`, `FSSeasonalHint` |
| Viseur et messages du scan | `View/ScannerViewController.swift` | `FSScanStatusBanner`, `FSMascotRow` |
| Saisie manuelle du code (`UISearchBar`) | idem | `FSBarcodeField`, `FSKeypad` |
| Alertes d'erreur (`ErrorManager.showAlertWith`) | `Managers/ErrorManager.swift` | `FSScanStatusBanner(.notFound / .offline)` + `FSAnnounce.say` |
| Liste des produits en cache | `RealmManager` (écran à créer) | `FSHistoryRow`, `FSOfflineBanner`, `FSSceneFooter(.picnic)` |

## Le pont à écrire (dans la cible app, pas dans le package)

```swift
import FoodScannerUI

extension Nutrient {
    /// Mappe les noms français de MainNutrientName vers le design system.
    var fsKind: FSNutrient? {
        switch name {
        case MainNutrientName.carbohydrates.rawValue: return .carbs
        case MainNutrientName.fats.rawValue:          return .fat
        case MainNutrientName.proteins.rawValue:      return .protein
        case MainNutrientName.salt.rawValue:          return .salt
        case MainNutrientName.fibers.rawValue:        return .fiber
        default:                                      return nil   // Calories, Sucres, Lipides Saturées
        }
    }
}

extension Food {
    var fsRingSegments: [FSNutrientRing.Segment] {
        nutrients.compactMap { nutrient in
            guard nutrient.type == NutrientType.mainNutrient.rawValue,
                  nutrient.quantity > 0,
                  let kind = nutrient.fsKind else { return nil }
            return FSNutrientRing.Segment(nutrient: kind, grams: nutrient.quantity)
        }
    }
}
```

## Écran témoin : la fiche produit

### Avant

`ChartCollectionViewCell` porte sa propre table de couleurs, en dur, sans
équivalent en thème sombre ni motif :

```swift
private enum ColorChart: Int {
    case carbohydrates = 0, fat, fibers, protein, salt, unknown
    var rawValue: UIColor { /* #colorLiteral(...) par cas */ }
}

pieChartDataSet.colors = viewModel.nutrientsColorIndex.map { ColorChart(rawValue: $0).rawValue }
```

et `FoodViewModel` formate le texte des lignes :

```swift
func getQuantityNutrient(index: Int) -> String {
    let nutrient = nutrients[index]
    return nutrient.type == NutrientType.calories.rawValue
        ? "\(Int(nutrient.quantity))kCal"
        : "\(nutrient.quantity)g pour 100g"
}
```

### Après

L'anneau remplace le camembert, et `ColorChart` disparaît — la couleur ET le
motif viennent du design system :

```swift
final class NutrientRingCell: UICollectionViewCell {
    func configure(food: Food) {
        contentConfiguration = UIHostingConfiguration {
            VStack(spacing: 20) {
                FSNutrientRing(segments: food.fsRingSegments)   // score: .some(...) quand le grade sera décodé
                FSNutrientLegend()
            }
        }
    }
}
```

La ligne de nutriment n'a plus besoin du formatage texte du view model
(`FSNutrientRow` compose la valeur et le libellé VoiceOver) :

```swift
final class NutrientRowCell: UICollectionViewCell {
    func configure(nutrient: Nutrient) {
        guard let kind = nutrient.fsKind else { return }
        contentConfiguration = UIHostingConfiguration {
            FSNutrientRow(kind, grams: nutrient.quantity)
        }
    }
}
```

Et l'en-tête, avec les seules données disponibles aujourd'hui :

```swift
let header = UIHostingController(rootView:
    FSProductCard(name: viewModel.name,
                  imageURL: URL(string: viewModel.imageUrl),
                  seasonalHint: "De saison en ce moment : la fraise, notée A.")
)
```

## Erreurs et états

`ErrorManager.showAlertWith(title:message:)` présente un `UIAlertController`
modal : à remplacer, pour les cas « produit introuvable » et « hors ligne », par
un bandeau non bloquant. `FSScanStatusBanner` déclenche seul l'annonce
VoiceOver et le retour haptique correspondant — supprimez les appels haptiques
existants pour éviter la double vibration. Gardez l'alerte pour les erreurs
réellement bloquantes (permission caméra refusée).

## Ordre conseillé

1. **Fiche produit** — plus gros gain visuel, aucune logique touchée.
2. **Bandeaux d'état** du scanner, en remplacement des alertes non bloquantes.
3. **Saisie du code** — `FSBarcodeField` à la place de la `UISearchBar`.
4. **Décodage du `nutriscore_grade`**, puis activation de `FSScoreBadge` / `FSScoreScale` partout.
5. **Historique** — écran neuf, à écrire directement en SwiftUI.
6. **Retrait de DGCharts** — seulement après validation de `FSNutrientRing`.

## Deux anomalies repérées en chemin (hors périmètre du design system)

Dans `FoodStruct.init(from:)`, le sel et les sucres sont construits à partir de
la mauvaise clé :

```swift
NutrientStruct(quantity: nutrientsJSON.fibers, name: MainNutrientName.salt.rawValue, …)
NutrientStruct(quantity: nutrientsJSON.saturatedFats, name: "Sucres", …)
```

`nutrientsJSON.salt` et `nutrientsJSON.sugars` sont décodés mais jamais
utilisés. À corriger avant de faire confiance à la ligne « Sel » de l'écran,
sinon le design system affichera fidèlement une valeur fausse.
