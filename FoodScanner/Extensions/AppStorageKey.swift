//
//  AppStorageKey.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/24/2026.
//

import SwiftUI

enum AppStorageKey: String {
    case hasSeenOnboarding
    case settingsReduceAnimations = "settings.reduceAnimations"
    case settingsTextScale = "settings.textScale"
}

extension AppStorage where Value == Bool {
    init(wrappedValue: Bool, _ key: AppStorageKey, store: UserDefaults? = nil) {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}

extension AppStorage where Value == Double {
    init(wrappedValue: Double, _ key: AppStorageKey, store: UserDefaults? = nil) {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}
