//
//  AppAccessibilitySettings.swift
//  FoodScanner
//
//  Propage à toute l'app les réglages d'accessibilité choisis dans
//  SettingsScreenView (@AppStorage "settings.textScale",
//  "settings.reduceAnimations"), au lieu de rester locaux à l'écran Réglages.
//
//  - Taille de texte : converti en `DynamicTypeSize` et appliqué via
//    `.dynamicTypeSize(...)` (jusqu'à AX5, cf. CLAUDE.md).
//  - Réduction des animations : `\.accessibilityReduceMotion` est en lecture
//    seule dans `EnvironmentValues` (SDK iOS) — impossible de le surcharger
//    via `.environment(_:_:)` (WritableKeyPath requis). FoodScannerUI
//    (`FSButton`, `FSMascot`, `fsAnimation(_:value:)`) ne consulte QUE la
//    valeur système et ne peut donc pas être influencé par ce réglage
//    applicatif sans modifier le package (hors périmètre ici). On introduit
//    donc une `EnvironmentKey` propre à l'app, `appReduceAnimations`, à
//    consulter dans tout futur `.animation(...)`/`withAnimation` écrit
//    directement dans les écrans de l'app (aucun n'existe à ce jour dans
//    `FoodScanner/View/`) — voir `AppAnimation.animation(_:enabled:)`.
//
//  NB — Contraste élevé (`settings.highContrast`) n'est volontairement PAS
//  propagé ici : FoodScannerUI n'expose aucune `EnvironmentKey`/mécanisme
//  pour un contraste renforcé indépendant du `colorSchemeContrast` système
//  (vérifié dans FSAccessibility.swift, FSColor, FSScoreBadge, FSButton,
//  FSMascot). Ajouter une valeur en dur côté app irait à l'encontre des
//  règles du design system ; ce point a été remonté plutôt qu'improvisé.
//

import SwiftUI

extension View {
    /// À appliquer à la racine de chaque onglet (root view du
    /// `UIHostingController`) pour que la taille de texte et la réduction des
    /// animations choisies dans Réglages s'appliquent à toute l'app.
    func appWideAccessibilitySettings() -> some View {
        modifier(AppWideAccessibilitySettings())
    }
}

/// Convertit `settings.textScale` (0...2, piloté par `FSTextSizeSlider`) en
/// `DynamicTypeSize`. Partagé entre `SettingsScreenView` (aperçu local du
/// slider) et `AppWideAccessibilitySettings` (propagation racine).
enum AppDynamicTypeScale {
    static func dynamicTypeSize(for scale: Double) -> DynamicTypeSize {
        switch scale {
        case ..<1.0: return .medium
        case 1.0..<1.2: return .large
        case 1.2..<1.4: return .xLarge
        case 1.4..<1.6: return .xxLarge
        case 1.6..<1.8: return .xxxLarge
        case 1.8..<1.9: return .accessibility1
        case 1.9..<1.95: return .accessibility2
        case 1.95..<1.98: return .accessibility3
        case 1.98..<2.0: return .accessibility4
        default: return .accessibility5
        }
    }
}

private struct AppWideAccessibilitySettings: ViewModifier {
    @AppStorage("settings.textScale") private var textScale: Double = 1.0
    @AppStorage("settings.reduceAnimations") private var reduceAnimations: Bool = false

    func body(content: Content) -> some View {
        content
            .dynamicTypeSize(AppDynamicTypeScale.dynamicTypeSize(for: textScale))
            .environment(\.appReduceAnimations, reduceAnimations)
    }
}

/// Clé d'environnement propre à l'app (ne fait pas partie de FoodScannerUI) :
/// vrai si l'utilisateur a activé "Réduire les animations" dans Réglages,
/// à consulter dans les écrans de l'app qui déclenchent eux-mêmes des
/// animations SwiftUI (`.animation`, `withAnimation`).
private struct AppReduceAnimationsKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var appReduceAnimations: Bool {
        get { self[AppReduceAnimationsKey.self] }
        set { self[AppReduceAnimationsKey.self] = newValue }
    }
}

extension View {
    /// À utiliser dans les écrans de l'app (pas dans FoodScannerUI) pour animer
    /// uniquement si ni le système, ni le réglage "Réduire les animations" de
    /// Réglages ne le désactivent.
    func appAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        modifier(AppRespectfulAnimation(animation: animation, value: value))
    }
}

private struct AppRespectfulAnimation<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.appReduceAnimations) private var appReduceAnimations
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation((systemReduceMotion || appReduceAnimations) ? nil : animation, value: value)
    }
}
