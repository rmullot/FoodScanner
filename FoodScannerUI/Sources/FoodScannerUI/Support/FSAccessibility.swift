import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Retours haptiques nommés par intention, pas par moteur.
public enum FSHaptics {
    public enum Intent { case scanSuccess, scanFailure, selection, warning }

    public static func play(_ intent: Intent) {
        #if canImport(UIKit) && !targetEnvironment(macCatalyst)
        switch intent {
        case .scanSuccess:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .scanFailure:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        }
        #endif
    }
}

/// Annonces VoiceOver : à utiliser pour tout changement d'état non focalisé
/// (score reçu, produit introuvable, passage hors ligne).
public enum FSAnnounce {
    public static func say(_ message: String) {
        #if canImport(UIKit)
        guard UIAccessibility.isVoiceOverRunning else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
        #endif
    }
}

public extension View {
    /// Anime uniquement si l'utilisateur n'a pas demandé la réduction des animations.
    func fsAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        modifier(FSRespectfulAnimation(animation: animation, value: value))
    }
}

private struct FSRespectfulAnimation<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}

/// Vrai quand le corps de texte dépasse la taille standard : les composants
/// basculent alors leurs lignes en disposition verticale.
struct FSStackedLayoutKey {
    static func isStacked(_ size: DynamicTypeSize) -> Bool { size >= .accessibility1 }
}
