//
//  FSFont.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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
    static let fsDisplay = FSTypeface.heading(34, relativeTo: .largeTitle)
    static let fsTitle = FSTypeface.heading(28, relativeTo: .title)
    static let fsHeadline = FSTypeface.heading(22, relativeTo: .title3)
    static let fsBody = FSTypeface.body(19, relativeTo: .body, weight: .regular)
    static let fsBodyStrong = FSTypeface.body(19, relativeTo: .body, weight: .bold)
    static let fsCaption = FSTypeface.body(16, relativeTo: .subheadline, weight: .regular)
    static let fsOverline = FSTypeface.body(12, relativeTo: .caption, weight: .bold)

    static func fsHeading(_ size: CGFloat, relativeTo style: Font.TextStyle = .title) -> Font {
        FSTypeface.heading(size, relativeTo: style)
    }

    static func fsText(_ size: CGFloat, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle = .body) -> Font {
        FSTypeface.body(size, relativeTo: style, weight: weight)
    }
}
