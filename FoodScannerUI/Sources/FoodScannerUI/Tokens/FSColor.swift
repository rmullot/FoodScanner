//
//  FSColor.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// All color tokens live in `Resources/FoodScannerUI.xcassets`
/// with an Any variant (spring-summer) and a Dark variant (autumn-winter).
/// Nutri-Score colors are intentionally out of theme: the official chart
/// mandates the same flat colors in both light and dark.
public extension Color {

    // MARK: Surfaces
    static let fsBackground = Color.fsAsset("fsBackground")
    static let fsSurface = Color.fsAsset("fsSurface")
    static let fsSurfaceRaised = Color.fsAsset("fsSurfaceRaised")
    static let fsAccentSoft = Color.fsAsset("fsAccentSoft")

    // MARK: Text
    static let fsInk = Color.fsAsset("fsInk")
    static let fsInkSecondary = Color.fsAsset("fsInkSecondary")
    static let fsInkOnAccent = Color.fsAsset("fsInkOnAccent")

    // MARK: Strokes
    static let fsBorder = Color.fsAsset("fsBorder")
    static let fsFocus = Color.fsAsset("fsFocus")

    // MARK: Season
    /// Strawberry red in light, squash orange in dark.
    static let fsAccent = Color.fsAsset("fsAccent")
    /// Leaf green (pea / cabbage).
    static let fsLeaf = Color.fsAsset("fsLeaf")
    /// Lemon yellow in light, honey-candle in dark.
    static let fsSun = Color.fsAsset("fsSun")
    /// Chestnut brown / bark.
    static let fsBark = Color.fsAsset("fsBark")

    // MARK: Nutrients (seasonal food colors)
    /// Carbs: wheat in light, squash in dark.
    static let fsCarbs = Color.fsAsset("fsCarbs")
    /// Fat: olive oil in light, walnut in dark.
    static let fsFat = Color.fsAsset("fsFat")
    /// Protein: kidney bean in light, cabbage in dark.
    static let fsProtein = Color.fsAsset("fsProtein")
    /// Salt / minerals.
    static let fsSalt = Color.fsAsset("fsSalt")
    /// Fiber: pea in light, chestnut in dark.
    static let fsFiber = Color.fsAsset("fsFiber")

    private static func fsAsset(_ name: String) -> Color {
        Color(name, bundle: .fsModule)
    }
}

/// Official Nutri-Score flat colors. Identical in both themes.
public extension Color {
    static let fsScoreA = Color(hex: 0x038141)
    static let fsScoreB = Color(hex: 0x85BB2F)
    static let fsScoreC = Color(hex: 0xFECB02)
    static let fsScoreD = Color(hex: 0xEE8100)
    static let fsScoreE = Color(hex: 0xE63E11)
}

extension Bundle {
    /// Works both as an SPM package and as a plain sources folder in the app.
    static var fsModule: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return Bundle(for: FSBundleToken.self)
        #endif
    }
}

private final class FSBundleToken {}
