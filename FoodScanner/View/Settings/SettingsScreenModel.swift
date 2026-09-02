//
//  SettingsScreenModel.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//

import Foundation
import SwiftUI

final class SettingsScreenModel: ObservableObject {
    @AppStorage("settings.highContrast") var highContrast: Bool = false
    @AppStorage("settings.reduceAnimations") var reduceAnimations: Bool = false
    @AppStorage("settings.textScale") var textScale: Double = 1.0
}
