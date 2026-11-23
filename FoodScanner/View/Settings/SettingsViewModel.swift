//
//  SettingsViewModel.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//

import Combine
import Foundation
import SwiftUI
import UIKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage(.settingsReduceAnimations) var reduceAnimations: Bool = false
    @AppStorage(.settingsTextScale) var textScale: Double = 1.0

    @Published private(set) var systemReduceMotionEnabled: Bool
    @Published private(set) var systemIncreasedContrastEnabled: Bool
    @Published private(set) var systemContentSizeCategory: UIContentSizeCategory

    private let systemAccessibility: SystemAccessibilityProviding
    private var cancellables = Set<AnyCancellable>()

    init(systemAccessibility: SystemAccessibilityProviding? = nil) {
        let resolved = systemAccessibility ?? InjectionManager.shared.systemAccessibility
        self.systemAccessibility = resolved
        self.systemReduceMotionEnabled = resolved.isReduceMotionEnabled
        self.systemIncreasedContrastEnabled = resolved.isIncreasedContrastEnabled
        self.systemContentSizeCategory = resolved.preferredContentSizeCategory

        resolved.changesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.refreshSystemState() }
            .store(in: &cancellables)

        recalibrateTextScale()
    }

    /// The reduce-animations behavior is currently imposed by the system: the
    /// app override can only add restriction, so the row must show it forced on.
    var reduceAnimationsForcedBySystem: Bool { systemReduceMotionEnabled }

    /// Effective reduce-animations value once the additive app override is merged
    /// with the read-only system setting.
    var effectiveReduceAnimations: Bool { systemReduceMotionEnabled || reduceAnimations }

    var systemContentSizeIsAccessibilitySize: Bool {
        systemContentSizeCategory.isAccessibilityCategory
    }

    /// True once the system is already at its own largest text size: there is no
    /// room left for the in-app slider to go any further, so it is disabled.
    var systemTextSizeIsAtMaximum: Bool {
        AppDynamicTypeScale.isSystemAtMaximum(systemContentSizeCategory)
    }

    private func refreshSystemState() {
        systemReduceMotionEnabled = systemAccessibility.isReduceMotionEnabled
        systemIncreasedContrastEnabled = systemAccessibility.isIncreasedContrastEnabled
        systemContentSizeCategory = systemAccessibility.preferredContentSizeCategory
        recalibrateTextScale()
    }

    /// Re-syncs the slider onto the live system setting: called on init (app launch),
    /// whenever the system category changes, and whenever the app returns to the
    /// foreground (`SettingsScreenView` calls this on `scenePhase` becoming `.active`).
    /// `textScale` is `@AppStorage`, not `@Published`, so mutating it alone wouldn't
    /// redraw the view — `objectWillChange` is sent explicitly.
    func recalibrateTextScale() {
        let systemScale = AppDynamicTypeScale.scale(for: systemContentSizeCategory)
        guard textScale != systemScale else { return }
        objectWillChange.send()
        textScale = systemScale
    }
}
