//
//  AccessibilityID.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/24/2026.
//

import SwiftUI

enum AccessibilityID: String {
    case tabScanner = "tab.scanner"
    case tabHistory = "tab.history"
    case tabSettings = "tab.settings"
    case onboardingSkip = "onboarding.skip"
    case scannerToggleKeypad = "scanner.toggleKeypad"
    case historyDetailPlaceholder = "history.detailPlaceholder"
    case settingsTextSizeSlider = "settings.textSizeSlider"
    case settingsReduceAnimationsToggle = "settings.reduceAnimationsToggle"
    case settingsReduceAnimationsStatus = "settings.reduceAnimationsStatus"
    case settingsContrastStatus = "settings.contrastStatus"
    case settingsOpenIOSSettings = "settings.openIOSSettings"

    var identifier: String { rawValue }
}

extension View {
    func accessibilityIdentifier(_ id: AccessibilityID) -> some View {
        accessibilityIdentifier(id.identifier)
    }
}
