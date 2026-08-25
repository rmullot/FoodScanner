import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Le package déclare les noms de la charte et retombe proprement sur les
/// polices système si les fichiers ne sont pas embarqués par l'app hôte.
/// Toutes les tailles sont relatives : Dynamic Type fonctionne jusqu'à AX5.
public enum FSTypeface {
    public static let headingName = "Caprasimo-Regular"
    public static let bodyName = "Figtree-Regular"

    static func isAvailable(_ name: String) -> Bool {
        #if canImport(UIKit)
        return UIFont(name: name, size: 12) != nil
        #else
        return false
        #endif
    }

    static let hasHeading = isAvailable(headingName)
    static let hasBody = isAvailable(bodyName)

    static func heading(_ size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        hasHeading
            ? .custom(headingName, size: size, relativeTo: style)
            : .system(style, design: .rounded).weight(.heavy)
    }

    static func body(_ size: CGFloat, relativeTo style: Font.TextStyle, weight: Font.Weight) -> Font {
        hasBody
            ? .custom(bodyName, size: size, relativeTo: style).weight(weight)
            : .system(style, design: .default).weight(weight)
    }
}

public extension Font {
    /// 34 pt — titre d'accueil.
    static let fsDisplay = FSTypeface.heading(34, relativeTo: .largeTitle)
    /// 28 pt — titre d'écran.
    static let fsTitle = FSTypeface.heading(28, relativeTo: .title)
    /// 22 pt — titre de carte.
    static let fsHeadline = FSTypeface.heading(22, relativeTo: .title3)
    /// 19 pt — corps de texte accessible (plancher de la charte).
    static let fsBody = FSTypeface.body(19, relativeTo: .body, weight: .regular)
    static let fsBodyStrong = FSTypeface.body(19, relativeTo: .body, weight: .bold)
    /// 16 pt — texte secondaire.
    static let fsCaption = FSTypeface.body(16, relativeTo: .subheadline, weight: .regular)
    /// 12 pt — surtitre en capitales, toujours avec `tracking`.
    static let fsOverline = FSTypeface.body(12, relativeTo: .caption, weight: .bold)

    static func fsHeading(_ size: CGFloat, relativeTo style: Font.TextStyle = .title) -> Font {
        FSTypeface.heading(size, relativeTo: style)
    }

    static func fsText(_ size: CGFloat, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle = .body) -> Font {
        FSTypeface.body(size, relativeTo: style, weight: weight)
    }
}
