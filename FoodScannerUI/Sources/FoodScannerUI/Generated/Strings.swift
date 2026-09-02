// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum FSL10n {
  public enum BarcodeField {
    /// Huit à quatorze chiffres
    public static let accessibilityHint = FSL10n.tr("Localizable", "barcodeField.accessibilityHint", fallback: "Huit à quatorze chiffres")
    /// Code-barres du produit
    public static let accessibilityLabel = FSL10n.tr("Localizable", "barcodeField.accessibilityLabel", fallback: "Code-barres du produit")
    /// Effacer le code
    public static let clearLabel = FSL10n.tr("Localizable", "barcodeField.clearLabel", fallback: "Effacer le code")
    /// Un code-barres compte entre 8 et 14 chiffres.
    public static let invalidHint = FSL10n.tr("Localizable", "barcodeField.invalidHint", fallback: "Un code-barres compte entre 8 et 14 chiffres.")
    /// FSBarcodeField / FSKeypad / FSTextSizeSlider
    public static let label = FSL10n.tr("Localizable", "barcodeField.label", fallback: "Code-barres")
    /// Chercher ce produit
    public static let submitButton = FSL10n.tr("Localizable", "barcodeField.submitButton", fallback: "Chercher ce produit")
  }
  public enum Keypad {
    /// Effacer le dernier chiffre
    public static let deleteHint = FSL10n.tr("Localizable", "keypad.deleteHint", fallback: "Effacer le dernier chiffre")
    /// Valider
    public static let validateButton = FSL10n.tr("Localizable", "keypad.validateButton", fallback: "Valider")
  }
  public enum Mascot {
    /// %@, mascotte %@
    public static func accessibilityLabel(_ p1: Any, _ p2: Any) -> String {
      return FSL10n.tr("Localizable", "mascot.accessibilityLabel", String(describing: p1), String(describing: p2), fallback: "%@, mascotte %@")
    }
    public enum Name {
      /// Chou
      public static let cabbage = FSL10n.tr("Localizable", "mascot.name.cabbage", fallback: "Chou")
      /// Châtaigne
      public static let chestnut = FSL10n.tr("Localizable", "mascot.name.chestnut", fallback: "Châtaigne")
      /// Citron
      public static let lemon = FSL10n.tr("Localizable", "mascot.name.lemon", fallback: "Citron")
      /// Petit pois
      public static let pea = FSL10n.tr("Localizable", "mascot.name.pea", fallback: "Petit pois")
      /// Potimarron
      public static let squash = FSL10n.tr("Localizable", "mascot.name.squash", fallback: "Potimarron")
      /// FSMascot.Kind — mascot names
      public static let strawberry = FSL10n.tr("Localizable", "mascot.name.strawberry", fallback: "Fraise")
    }
  }
  public enum Nutrient {
    public enum Name {
      /// FSNutrient — nutrient names
      public static let carbs = FSL10n.tr("Localizable", "nutrient.name.carbs", fallback: "Glucides")
      /// Lipides
      public static let fat = FSL10n.tr("Localizable", "nutrient.name.fat", fallback: "Lipides")
      /// Fibres
      public static let fiber = FSL10n.tr("Localizable", "nutrient.name.fiber", fallback: "Fibres")
      /// Protéines
      public static let protein = FSL10n.tr("Localizable", "nutrient.name.protein", fallback: "Protéines")
      /// Sel
      public static let salt = FSL10n.tr("Localizable", "nutrient.name.salt", fallback: "Sel")
    }
    public enum Source {
      /// fleur de sel
      public static let salt = FSL10n.tr("Localizable", "nutrient.source.salt", fallback: "fleur de sel")
      public enum Carbs {
        /// courge
        public static let autumnWinter = FSL10n.tr("Localizable", "nutrient.source.carbs.autumnWinter", fallback: "courge")
        /// FSNutrient — seasonal color source, shown in the legend
        public static let springSummer = FSL10n.tr("Localizable", "nutrient.source.carbs.springSummer", fallback: "blé")
      }
      public enum Fat {
        /// noix
        public static let autumnWinter = FSL10n.tr("Localizable", "nutrient.source.fat.autumnWinter", fallback: "noix")
        /// huile d'olive
        public static let springSummer = FSL10n.tr("Localizable", "nutrient.source.fat.springSummer", fallback: "huile d'olive")
      }
      public enum Fiber {
        /// châtaigne
        public static let autumnWinter = FSL10n.tr("Localizable", "nutrient.source.fiber.autumnWinter", fallback: "châtaigne")
        /// petit pois
        public static let springSummer = FSL10n.tr("Localizable", "nutrient.source.fiber.springSummer", fallback: "petit pois")
      }
      public enum Protein {
        /// chou
        public static let autumnWinter = FSL10n.tr("Localizable", "nutrient.source.protein.autumnWinter", fallback: "chou")
        /// haricot rouge
        public static let springSummer = FSL10n.tr("Localizable", "nutrient.source.protein.springSummer", fallback: "haricot rouge")
      }
    }
  }
  public enum NutrientRing {
    /// Répartition des nutriments
    public static let accessibilityLabel = FSL10n.tr("Localizable", "nutrientRing.accessibilityLabel", fallback: "Répartition des nutriments")
    /// %@ %@ pour cent
    public static func distributionItem(_ p1: Any, _ p2: Any) -> String {
      return FSL10n.tr("Localizable", "nutrientRing.distributionItem", String(describing: p1), String(describing: p2), fallback: "%@ %@ pour cent")
    }
  }
  public enum NutrientRow {
    /// %@ pour %@ grammes, couleur %@, motif %@
    public static func accessibilityValue(_ p1: Any, _ p2: Any, _ p3: Any, _ p4: Any) -> String {
      return FSL10n.tr("Localizable", "nutrientRow.accessibilityValue", String(describing: p1), String(describing: p2), String(describing: p3), String(describing: p4), fallback: "%@ pour %@ grammes, couleur %@, motif %@")
    }
    /// pour 100 g
    public static let per100g = FSL10n.tr("Localizable", "nutrientRow.per100g", fallback: "pour 100 g")
    /// · %@
    public static func seasonalSourcePrefix(_ p1: Any) -> String {
      return FSL10n.tr("Localizable", "nutrientRow.seasonalSourcePrefix", String(describing: p1), fallback: "· %@")
    }
    /// FSNutrientRow / FSNutrientRing
    public static func totalValue(_ p1: Any) -> String {
      return FSL10n.tr("Localizable", "nutrientRow.totalValue", String(describing: p1), fallback: "%@ g")
    }
  }
  public enum Pattern {
    public enum Name {
      /// hachures
      public static let diagonalStripes = FSL10n.tr("Localizable", "pattern.name.diagonalStripes", fallback: "hachures")
      /// pois
      public static let dots = FSL10n.tr("Localizable", "pattern.name.dots", fallback: "pois")
      /// quadrillage
      public static let grid = FSL10n.tr("Localizable", "pattern.name.grid", fallback: "quadrillage")
      /// FSPattern.Motif — pattern names
      public static let verticalBars = FSL10n.tr("Localizable", "pattern.name.verticalBars", fallback: "barres verticales")
      /// vagues
      public static let waves = FSL10n.tr("Localizable", "pattern.name.waves", fallback: "vagues")
    }
  }
  public enum ProductCard {
    public enum History {
      /// FSProductCard
      public static let hint = FSL10n.tr("Localizable", "productCard.history.hint", fallback: "Ouvre la fiche du produit")
      /// Nutri-Score %@. %@
      public static func scoreValue(_ p1: Any, _ p2: Any) -> String {
        return FSL10n.tr("Localizable", "productCard.history.scoreValue", String(describing: p1), String(describing: p2), fallback: "Nutri-Score %@. %@")
      }
    }
    public enum OfflineBanner {
      /// Vous êtes hors ligne. Les fiches déjà consultées restent lisibles.
      public static let defaultText = FSL10n.tr("Localizable", "productCard.offlineBanner.defaultText", fallback: "Vous êtes hors ligne. Les fiches déjà consultées restent lisibles.")
    }
    public enum ScanStatus {
      /// Ouvre la fiche du produit
      public static let foundHint = FSL10n.tr("Localizable", "productCard.scanStatus.foundHint", fallback: "Ouvre la fiche du produit")
      public enum Detail {
        /// Approchez l'appareil à dix centimètres, la lumière aide.
        public static let aiming = FSL10n.tr("Localizable", "productCard.scanStatus.detail.aiming", fallback: "Approchez l'appareil à dix centimètres, la lumière aide.")
        /// Fiche prête, tapez pour voir les nutriments.
        public static let found = FSL10n.tr("Localizable", "productCard.scanStatus.detail.found", fallback: "Fiche prête, tapez pour voir les nutriments.")
        /// Ce code n'existe pas encore dans la base. Vous pouvez l'ajouter.
        public static let notFound = FSL10n.tr("Localizable", "productCard.scanStatus.detail.notFound", fallback: "Ce code n'existe pas encore dans la base. Vous pouvez l'ajouter.")
        /// Les douze dernières fiches restent consultables.
        public static let offline = FSL10n.tr("Localizable", "productCard.scanStatus.detail.offline", fallback: "Les douze dernières fiches restent consultables.")
        /// On interroge Open Food Facts.
        public static let reading = FSL10n.tr("Localizable", "productCard.scanStatus.detail.reading", fallback: "On interroge Open Food Facts.")
      }
      public enum Title {
        /// Cadrez le code-barres
        public static let aiming = FSL10n.tr("Localizable", "productCard.scanStatus.title.aiming", fallback: "Cadrez le code-barres")
        /// Produit introuvable
        public static let notFound = FSL10n.tr("Localizable", "productCard.scanStatus.title.notFound", fallback: "Produit introuvable")
        /// Hors ligne
        public static let offline = FSL10n.tr("Localizable", "productCard.scanStatus.title.offline", fallback: "Hors ligne")
        /// Lecture en cours…
        public static let reading = FSL10n.tr("Localizable", "productCard.scanStatus.title.reading", fallback: "Lecture en cours…")
      }
    }
  }
  public enum SceneFooter {
    public enum Alt {
      /// Les mascottes d'automne à table dans un chalet, le soir
      public static let chalet = FSL10n.tr("Localizable", "sceneFooter.alt.chalet", fallback: "Les mascottes d'automne à table dans un chalet, le soir")
      /// FSSceneFooter — vignette alt text
      public static let laboratory = FSL10n.tr("Localizable", "sceneFooter.alt.laboratory", fallback: "Les mascottes en blouse analysent une étiquette nutritionnelle dans un laboratoire")
      /// Les mascottes de printemps en pique-nique sous un arbre
      public static let picnic = FSL10n.tr("Localizable", "sceneFooter.alt.picnic", fallback: "Les mascottes de printemps en pique-nique sous un arbre")
    }
  }
  public enum Score {
    public enum Badge {
      /// Nutri-Score %@. %@.
      public static func accessibilityLabel(_ p1: Any, _ p2: Any) -> String {
        return FSL10n.tr("Localizable", "score.badge.accessibilityLabel", String(describing: p1), String(describing: p2), fallback: "Nutri-Score %@. %@.")
      }
    }
    public enum Meaning {
      /// FSNutriScore — meanings
      public static let a = FSL10n.tr("Localizable", "score.meaning.a", fallback: "Très bonne qualité nutritionnelle")
      /// Bonne qualité nutritionnelle
      public static let b = FSL10n.tr("Localizable", "score.meaning.b", fallback: "Bonne qualité nutritionnelle")
      /// Qualité nutritionnelle moyenne
      public static let c = FSL10n.tr("Localizable", "score.meaning.c", fallback: "Qualité nutritionnelle moyenne")
      /// Qualité nutritionnelle faible
      public static let d = FSL10n.tr("Localizable", "score.meaning.d", fallback: "Qualité nutritionnelle faible")
      /// Qualité nutritionnelle très faible
      public static let e = FSL10n.tr("Localizable", "score.meaning.e", fallback: "Qualité nutritionnelle très faible")
    }
    public enum Scale {
      /// Échelle Nutri-Score de A à E. Ce produit est noté %@ : %@.
      public static func accessibilityLabel(_ p1: Any, _ p2: Any) -> String {
        return FSL10n.tr("Localizable", "score.scale.accessibilityLabel", String(describing: p1), String(describing: p2), fallback: "Échelle Nutri-Score de A à E. Ce produit est noté %@ : %@.")
      }
    }
  }
  public enum Season {
    public enum Name {
      /// Automne-hiver
      public static let autumnWinter = FSL10n.tr("Localizable", "season.name.autumnWinter", fallback: "Automne-hiver")
      /// FSSeason — season names
      public static let springSummer = FSL10n.tr("Localizable", "season.name.springSummer", fallback: "Printemps-été")
    }
  }
  public enum TextSizeSlider {
    /// Taille du texte
    public static let label = FSL10n.tr("Localizable", "textSizeSlider.label", fallback: "Taille du texte")
    /// Un produit noté A est un bon choix.
    public static let preview = FSL10n.tr("Localizable", "textSizeSlider.preview", fallback: "Un produit noté A est un bon choix.")
    /// %@ pour cent
    public static func valuePercent(_ p1: Any) -> String {
      return FSL10n.tr("Localizable", "textSizeSlider.valuePercent", String(describing: p1), fallback: "%@ pour cent")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension FSL10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
