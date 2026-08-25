import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Tous les tokens couleur vivent dans `Resources/FoodScannerUI.xcassets`
/// avec une variante Any (printemps-été) et une variante Dark (automne-hiver).
/// Les couleurs du Nutri-Score sont volontairement hors thème : la charte
/// officielle impose les mêmes aplats en clair comme en sombre.
public extension Color {

    // MARK: Surfaces
    static let fsBackground = Color.fsAsset("fsBackground")
    static let fsSurface = Color.fsAsset("fsSurface")
    static let fsSurfaceRaised = Color.fsAsset("fsSurfaceRaised")
    static let fsAccentSoft = Color.fsAsset("fsAccentSoft")

    // MARK: Texte
    static let fsInk = Color.fsAsset("fsInk")
    static let fsInkSecondary = Color.fsAsset("fsInkSecondary")
    static let fsInkOnAccent = Color.fsAsset("fsInkOnAccent")

    // MARK: Traits
    static let fsBorder = Color.fsAsset("fsBorder")
    static let fsFocus = Color.fsAsset("fsFocus")

    // MARK: Saison
    /// Rouge fraise en clair, orange potimarron en sombre.
    static let fsAccent = Color.fsAsset("fsAccent")
    /// Vert feuille (petit pois / chou).
    static let fsLeaf = Color.fsAsset("fsLeaf")
    /// Jaune citron en clair, miel-bougie en sombre.
    static let fsSun = Color.fsAsset("fsSun")
    /// Brun châtaigne / écorce.
    static let fsBark = Color.fsAsset("fsBark")

    // MARK: Nutriments (couleurs d'aliments de saison)
    /// Glucides : blé en clair, courge en sombre.
    static let fsCarbs = Color.fsAsset("fsCarbs")
    /// Lipides : huile d'olive en clair, noix en sombre.
    static let fsFat = Color.fsAsset("fsFat")
    /// Protéines : haricot rouge en clair, chou en sombre.
    static let fsProtein = Color.fsAsset("fsProtein")
    /// Sel / minéraux.
    static let fsSalt = Color.fsAsset("fsSalt")
    /// Fibres : petit pois en clair, châtaigne en sombre.
    static let fsFiber = Color.fsAsset("fsFiber")

    private static func fsAsset(_ name: String) -> Color {
        Color(name, bundle: .fsModule)
    }
}

/// Aplats officiels du Nutri-Score. Identiques dans les deux thèmes.
public extension Color {
    static let fsScoreA = Color(hex: 0x038141)
    static let fsScoreB = Color(hex: 0x85BB2F)
    static let fsScoreC = Color(hex: 0xFECB02)
    static let fsScoreD = Color(hex: 0xEE8100)
    static let fsScoreE = Color(hex: 0xE63E11)
}

extension Bundle {
    /// Fonctionne comme package SPM comme en simple dossier de sources dans l'app.
    static var fsModule: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return Bundle(for: FSBundleToken.self)
        #endif
    }
}

private final class FSBundleToken {}
