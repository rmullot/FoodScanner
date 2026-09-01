import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// The package declares the design system font names and cleanly falls back
/// to system fonts if the files are not embedded by the host app.
/// All sizes are relative: Dynamic Type works up to AX5.
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
    /// 34 pt — welcome title.
    static let fsDisplay = FSTypeface.heading(34, relativeTo: .largeTitle)
    /// 28 pt — screen title.
    static let fsTitle = FSTypeface.heading(28, relativeTo: .title)
    /// 22 pt — card title.
    static let fsHeadline = FSTypeface.heading(22, relativeTo: .title3)
    /// 19 pt — accessible body text (design system floor).
    static let fsBody = FSTypeface.body(19, relativeTo: .body, weight: .regular)
    static let fsBodyStrong = FSTypeface.body(19, relativeTo: .body, weight: .bold)
    /// 16 pt — secondary text.
    static let fsCaption = FSTypeface.body(16, relativeTo: .subheadline, weight: .regular)
    /// 12 pt — all-caps overline, always with `tracking`.
    static let fsOverline = FSTypeface.body(12, relativeTo: .caption, weight: .bold)

    static func fsHeading(_ size: CGFloat, relativeTo style: Font.TextStyle = .title) -> Font {
        FSTypeface.heading(size, relativeTo: style)
    }

    static func fsText(_ size: CGFloat, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle = .body) -> Font {
        FSTypeface.body(size, relativeTo: style, weight: weight)
    }
}
