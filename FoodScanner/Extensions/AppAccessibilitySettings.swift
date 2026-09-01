//
//  AppAccessibilitySettings.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//  Propagates app-wide the accessibility settings chosen in
//  SettingsScreenView (@AppStorage "settings.textScale",
//  "settings.reduceAnimations"), instead of keeping them local to the
//  Settings screen.
//
//  - Text size: converted to `DynamicTypeSize` and applied via
//    `.dynamicTypeSize(...)` (up to AX5, see CLAUDE.md).
//  - Reduce animations: `\.accessibilityReduceMotion` is read-only in
//    `EnvironmentValues` (iOS SDK) — it cannot be overridden via
//    `.environment(_:_:)` (requires a WritableKeyPath). FoodScannerUI
//    (`FSButton`, `FSMascot`, `fsAnimation(_:value:)`) only consults the
//    system value and therefore cannot be influenced by this app setting
//    without modifying the package (out of scope here). We therefore
//    introduce an app-only `EnvironmentKey`, `appReduceAnimations`, to be
//    consulted in any future `.animation(...)`/`withAnimation` written
//    directly in app screens (none exist as of today in
//    `FoodScanner/View/`) — see `AppAnimation.animation(_:enabled:)`.
//
//  NB — High contrast (`settings.highContrast`) is intentionally NOT
//  propagated here: FoodScannerUI exposes no `EnvironmentKey`/mechanism
//  for enhanced contrast independent of the system `colorSchemeContrast`
//  (verified in FSAccessibility.swift, FSColor, FSScoreBadge, FSButton,
//  FSMascot). Hard-coding a value on the app side would go against the
//  design system's rules; this point was flagged rather than improvised.
//

import SwiftUI

extension View {
    /// Apply at the root of each tab (root view of the
    /// `UIHostingController`) so that the text size and reduce animations
    /// choices made in Settings apply app-wide.
    func appWideAccessibilitySettings() -> some View {
        modifier(AppWideAccessibilitySettings())
    }
}

/// Converts `settings.textScale` (0...2, driven by `FSTextSizeSlider`) into
/// a `DynamicTypeSize`. Shared between `SettingsScreenView` (local slider
/// preview) and `AppWideAccessibilitySettings` (root propagation).
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

/// App-only environment key (not part of FoodScannerUI): true if the user
/// enabled "Reduce animations" in Settings, to be consulted in app screens
/// that trigger their own SwiftUI animations (`.animation`, `withAnimation`).
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
    /// To use in app screens (not in FoodScannerUI) to animate only if
    /// neither the system setting nor the "Reduce animations" Settings
    /// toggle disables it.
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
