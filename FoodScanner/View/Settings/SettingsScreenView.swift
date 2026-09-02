//
//  SettingsScreenView.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//

import SwiftUI
import FoodScannerUI

struct SettingsScreenView: View {
    @ObservedObject var model: SettingsViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FSMetrics.space4) {
                    FSToggleRow(L10n.Settings.highContrastTitle,
                                explanation: L10n.Settings.highContrastExplanation,
                                systemImage: SFSymbol.highContrast,
                                isOn: $model.highContrast)

                    FSToggleRow(L10n.Settings.reduceAnimationsTitle,
                                explanation: L10n.Settings.reduceAnimationsExplanation,
                                systemImage: SFSymbol.reduceMotion,
                                isOn: $model.reduceAnimations)

                    FSTextSizeSlider(scale: $model.textScale)
                }
                .padding(FSMetrics.space5)
            }
            .background(Color.fsBackground)
            .navigationTitle(L10n.Common.tabSettings)
            .navigationBarTitleDisplayMode(.large)
            .dynamicTypeSize(AppDynamicTypeScale.dynamicTypeSize(for: model.textScale))
        }
    }
}

#Preview("Clair") {
    SettingsScreenView(model: SettingsViewModel())
        .preferredColorScheme(.light)
}

#Preview("Sombre") {
    SettingsScreenView(model: SettingsViewModel())
        .preferredColorScheme(.dark)
}

#Preview("Accessibilité XL") {
    SettingsScreenView(model: SettingsViewModel())
        .environment(\.dynamicTypeSize, .accessibility5)
}
