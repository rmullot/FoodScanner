//
//  SettingsScreenView.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//

import SwiftUI
import UIKit
import FoodScannerUI

struct SettingsScreenView: View {
    @ObservedObject var model: SettingsViewModel
    @Environment(\.scenePhase) private var scenePhase
    @AccessibilityFocusState private var reduceAnimationsFocused: Bool
    @State private var isVisible = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FSMetrics.space4) {
                    Text(L10n.Settings.accessibilitySectionTitle)
                        .font(.fsBody)
                        .foregroundStyle(Color.fsInkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    contrastRow

                    reduceAnimationsRow
                        .accessibilityFocused($reduceAnimationsFocused)
                        .appAnimation(.default, value: model.reduceAnimationsForcedBySystem)

                    VStack(alignment: .leading, spacing: FSMetrics.space3) {
                        FSTextSizeSlider(scale: $model.textScale)
                            .disabled(model.systemTextSizeIsAtMaximum)
                            .opacity(model.systemTextSizeIsAtMaximum ? 0.4 : 1)
                            .accessibilityIdentifier(.settingsTextSizeSlider)
                            .accessibilityHint(model.systemTextSizeIsAtMaximum
                                ? Text(L10n.Settings.textSizeSystemMaximumCaption)
                                : Text(""))

                        if model.systemTextSizeIsAtMaximum {
                            Text(L10n.Settings.textSizeSystemMaximumCaption)
                                .font(.fsCaption)
                                .foregroundStyle(Color.fsInkSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .padding(FSMetrics.space5)
                .fsReadableContentWidth()
            }
            .background(Color.fsBackground)
            .navigationTitle(L10n.Common.tabSettings)
            .navigationBarTitleDisplayMode(.large)
            .dynamicTypeSize(...AppDynamicTypeScale.dynamicTypeSize(for: model.textScale))
        }
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                model.recalibrateTextScale()
            } else {
                isVisible = false
            }
        }
        .onChange(of: model.reduceAnimationsForcedBySystem) { _, forced in
            guard isVisible else { return }
            reduceAnimationsFocused = true
            FSAnnounce.say("\(L10n.Settings.reduceAnimationsTitle) : "
                + (forced ? L10n.Settings.stateEnabledSystemManaged : L10n.Settings.stateDisabled))
        }
        .onChange(of: model.systemIncreasedContrastEnabled) { _, enabled in
            guard isVisible else { return }
            FSAnnounce.say("\(L10n.Settings.contrastTitle) : "
                + (enabled ? L10n.Settings.stateEnabled : L10n.Settings.stateDisabled))
        }
    }

    @ViewBuilder
    private var contrastRow: some View {
        FSStatusRow(L10n.Settings.contrastTitle,
                    value: model.systemIncreasedContrastEnabled
                        ? L10n.Settings.stateEnabled
                        : L10n.Settings.stateDisabled,
                    caption: L10n.Settings.contrastSystemManagedCaption,
                    systemImage: SFSymbol.highContrast,
                    statusIdentifier: AccessibilityID.settingsContrastStatus.identifier,
                    action: (L10n.Settings.openIOSSettings, { openIOSSettings() }),
                    actionIdentifier: AccessibilityID.settingsOpenIOSSettings.identifier)
    }

    @ViewBuilder
    private var reduceAnimationsRow: some View {
        if model.reduceAnimationsForcedBySystem {
            FSStatusRow(L10n.Settings.reduceAnimationsTitle,
                        value: L10n.Settings.stateEnabledSystemManaged,
                        caption: L10n.Settings.reduceAnimationsSystemManagedCaption,
                        systemImage: SFSymbol.reduceMotion,
                        statusIdentifier: AccessibilityID.settingsReduceAnimationsStatus.identifier)
        } else {
            FSToggleRow(L10n.Settings.reduceAnimationsTitle,
                        explanation: L10n.Settings.reduceAnimationsExplanation,
                        systemImage: SFSymbol.reduceMotion,
                        isOn: $model.reduceAnimations)
                .accessibilityIdentifier(.settingsReduceAnimationsToggle)
        }
    }

    private func openIOSSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
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
