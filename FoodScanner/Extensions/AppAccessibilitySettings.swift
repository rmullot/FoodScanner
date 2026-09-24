//
//  AppAccessibilitySettings.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//

import Combine
import SwiftUI
import UIKit

extension View {
    func appWideAccessibilitySettings() -> some View {
        modifier(AppWideAccessibilitySettings())
    }
}

enum AppDynamicTypeScale {
    private struct Step {
        let category: UIContentSizeCategory
        let scale: Double
        let dynamicTypeSize: DynamicTypeSize
    }

    /// The single, one-to-one correspondence between iOS' `UIContentSizeCategory`,
    /// the app's own text-size scale and SwiftUI's `DynamicTypeSize` — every other
    /// function in this enum converts through this table so a scale and a system
    /// category always map back into each other without loss. `.large` (the system
    /// default) is anchored at the neutral 1.0 scale, stepped by 0.1 either side.
    private static let steps: [Step] = [
        Step(category: .extraSmall, scale: 0.7, dynamicTypeSize: .xSmall),
        Step(category: .small, scale: 0.8, dynamicTypeSize: .small),
        Step(category: .medium, scale: 0.9, dynamicTypeSize: .medium),
        Step(category: .large, scale: 1.0, dynamicTypeSize: .large),
        Step(category: .extraLarge, scale: 1.1, dynamicTypeSize: .xLarge),
        Step(category: .extraExtraLarge, scale: 1.2, dynamicTypeSize: .xxLarge),
        Step(category: .extraExtraExtraLarge, scale: 1.3, dynamicTypeSize: .xxxLarge),
        Step(category: .accessibilityMedium, scale: 1.4, dynamicTypeSize: .accessibility1),
        Step(category: .accessibilityLarge, scale: 1.5, dynamicTypeSize: .accessibility2),
        Step(category: .accessibilityExtraLarge, scale: 1.6, dynamicTypeSize: .accessibility3),
        Step(category: .accessibilityExtraExtraLarge, scale: 1.7, dynamicTypeSize: .accessibility4),
        Step(category: .accessibilityExtraExtraExtraLarge, scale: 1.8, dynamicTypeSize: .accessibility5)
    ]

    private static var defaultStep: Step { steps[3] }

    static func dynamicTypeSize(for scale: Double) -> DynamicTypeSize {
        nearestStep(to: scale).dynamicTypeSize
    }

    /// The app scale that exactly corresponds to `category` — used to recalibrate
    /// the in-app slider onto the live system setting.
    static func scale(for category: UIContentSizeCategory) -> Double {
        (steps.first { $0.category == category } ?? defaultStep).scale
    }

    /// True when `category` is the system's own largest step: there is no more room
    /// for the in-app slider to add on top of it.
    static func isSystemAtMaximum(_ category: UIContentSizeCategory) -> Bool {
        category == steps.last?.category
    }

    private static func nearestStep(to scale: Double) -> Step {
        steps.min { abs($0.scale - scale) < abs($1.scale - scale) } ?? defaultStep
    }
}

@MainActor
final class AppWideAccessibilitySettingsModel: ObservableObject {
    @Published private(set) var systemContentSizeCategory: UIContentSizeCategory

    private let systemAccessibility: SystemAccessibilityProviding
    private var cancellables = Set<AnyCancellable>()

    init(systemAccessibility: SystemAccessibilityProviding? = nil) {
        let resolved = systemAccessibility ?? InjectionManager.shared.systemAccessibility
        self.systemAccessibility = resolved
        self.systemContentSizeCategory = resolved.preferredContentSizeCategory

        resolved.changesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.systemContentSizeCategory = resolved.preferredContentSizeCategory
            }
            .store(in: &cancellables)
    }
}

private struct AppWideAccessibilitySettings: ViewModifier {
    @AppStorage(.settingsTextScale) private var textScale: Double = 1.0
    @AppStorage(.settingsReduceAnimations) private var reduceAnimations: Bool = false
    @StateObject private var model = AppWideAccessibilitySettingsModel()
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .dynamicTypeSize(AppDynamicTypeScale.dynamicTypeSize(for: textScale))
            .environment(\.appReduceAnimations, reduceAnimations)
            .task { recalibrateTextScale() }
            .onChange(of: model.systemContentSizeCategory) { _, _ in recalibrateTextScale() }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                recalibrateTextScale()
            }
    }

    /// Re-syncs onto the live system setting: on first appearance (app launch), on a
    /// system category change, and whenever the app returns to the foreground — the
    /// in-app scale is never stale with respect to what iOS Settings last reported.
    private func recalibrateTextScale() {
        textScale = AppDynamicTypeScale.scale(for: model.systemContentSizeCategory)
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
