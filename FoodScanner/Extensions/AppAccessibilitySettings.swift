//
//  AppAccessibilitySettings.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//

import SwiftUI

extension View {
    func appWideAccessibilitySettings() -> some View {
        modifier(AppWideAccessibilitySettings())
    }
}

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
