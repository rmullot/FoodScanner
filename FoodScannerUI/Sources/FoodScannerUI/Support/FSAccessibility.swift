import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Haptic feedback named by intent, not by engine.
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

/// VoiceOver announcements: use for any unfocused state change
/// (score received, product not found, switch to offline).
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
    /// Animates only if the user has not requested reduced animations.
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

/// True when the body text exceeds the standard size: components then
/// switch their rows to a vertical layout.
struct FSStackedLayoutKey {
    static func isStacked(_ size: DynamicTypeSize) -> Bool { size >= .accessibility1 }
}
