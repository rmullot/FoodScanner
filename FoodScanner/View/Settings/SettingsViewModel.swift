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
    @AppStorage("settings.reduceAnimations") var reduceAnimations: Bool = false
    @AppStorage("settings.textScale") var textScale: Double = 1.0

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
    }

    /// The reduce-animations behavior is currently imposed by the system: the
    /// app override can only add restriction, so the row must show it forced on.
    var reduceAnimationsForcedBySystem: Bool { systemReduceMotionEnabled }

    /// Effective reduce-animations value once the additive app override is merged
    /// with the read-only system setting.
    var effectiveReduceAnimations: Bool { systemReduceMotionEnabled || reduceAnimations }

    /// System Dynamic Type category acts as a floor: the app slider can only
    /// enlarge text beyond it, never shrink below it.
    var systemContentSizeIsAccessibilitySize: Bool {
        systemContentSizeCategory.isAccessibilityCategory
    }

    /// Lower bound for the in-app text-size slider, derived from the current
    /// system Dynamic Type category so the app override can only enlarge text.
    var systemTextScaleFloor: Double {
        switch systemContentSizeCategory {
        case .extraSmall, .small, .medium: return 0.9
        case .large: return 1.0
        case .extraLarge: return 1.2
        case .extraExtraLarge: return 1.4
        case .extraExtraExtraLarge: return 1.6
        case .accessibilityMedium: return 1.8
        case .accessibilityLarge: return 1.9
        case .accessibilityExtraLarge: return 1.95
        case .accessibilityExtraExtraLarge: return 1.98
        case .accessibilityExtraExtraExtraLarge: return 2.0
        default: return 1.0
        }
    }

    /// Effective slider value once the system floor is applied.
    var effectiveTextScale: Double { max(textScale, systemTextScaleFloor) }

    /// The system Dynamic Type category constrains the in-app slider (its floor
    /// sits above the 1.0 baseline), so the rationale caption must be shown.
    var systemConstrainsTextSize: Bool { systemTextScaleFloor > 1.0 }

    private func refreshSystemState() {
        systemReduceMotionEnabled = systemAccessibility.isReduceMotionEnabled
        systemIncreasedContrastEnabled = systemAccessibility.isIncreasedContrastEnabled
        systemContentSizeCategory = systemAccessibility.preferredContentSizeCategory
    }
}
