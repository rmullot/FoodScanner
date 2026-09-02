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

public extension Color {

    static let fsBackground = Color.fsAsset("fsBackground")
    static let fsSurface = Color.fsAsset("fsSurface")
    static let fsSurfaceRaised = Color.fsAsset("fsSurfaceRaised")
    static let fsAccentSoft = Color.fsAsset("fsAccentSoft")

    static let fsInk = Color.fsAsset("fsInk")
    static let fsInkSecondary = Color.fsAsset("fsInkSecondary")
    static let fsInkOnAccent = Color.fsAsset("fsInkOnAccent")

    static let fsBorder = Color.fsAsset("fsBorder")
    static let fsFocus = Color.fsAsset("fsFocus")

    static let fsAccent = Color.fsAsset("fsAccent")
    static let fsLeaf = Color.fsAsset("fsLeaf")
    static let fsSun = Color.fsAsset("fsSun")
    static let fsBark = Color.fsAsset("fsBark")

    static let fsCarbs = Color.fsAsset("fsCarbs")
    static let fsFat = Color.fsAsset("fsFat")
    static let fsProtein = Color.fsAsset("fsProtein")
    static let fsSalt = Color.fsAsset("fsSalt")
    static let fsFiber = Color.fsAsset("fsFiber")

    private static func fsAsset(_ name: String) -> Color {
        Color(name, bundle: .fsModule)
    }
}

public extension Color {
    static let fsScoreA = Color(hex: 0x038141)
    static let fsScoreB = Color(hex: 0x85BB2F)
    static let fsScoreC = Color(hex: 0xFECB02)
    static let fsScoreD = Color(hex: 0xEE8100)
    static let fsScoreE = Color(hex: 0xE63E11)
}

extension Bundle {
    static var fsModule: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return Bundle(for: FSBundleToken.self)
        #endif
    }
}

private final class FSBundleToken {}
