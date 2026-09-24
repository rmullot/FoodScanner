//
//  RootView.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//

import SwiftUI
import FoodScannerUI

struct RootView: View {
    private enum Tab: Hashable {
        case scanner
        case history
        case settings
    }

    @AppStorage(.hasSeenOnboarding) private var hasSeenOnboarding = false
    @StateObject private var settingsModel = SettingsViewModel()
    @StateObject private var scannerCoordinator = ScannerCoordinator()
    @State private var selectedTab: Tab = .scanner

    private var onboardingPresented: Binding<Bool> {
        Binding(
            get: { !hasSeenOnboarding },
            set: { isPresented in
                if !isPresented { hasSeenOnboarding = true }
            }
        )
    }

    private var tabSelection: Binding<Tab> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                if newValue == .scanner && selectedTab == .scanner {
                    scannerCoordinator.router.popToRoot()
                }
                selectedTab = newValue
            }
        )
    }

    var body: some View {
        TabView(selection: tabSelection) {
            ScannerCoordinatorView(coordinator: scannerCoordinator)
                .tabItem { Label(L10n.Common.tabScanner, systemImage: SFSymbol.scannerTab) }
                .tag(Tab.scanner)
                .accessibilityIdentifier(.tabScanner)

            HistoryScreenView()
                .tabItem { Label(L10n.Common.tabHistory, systemImage: SFSymbol.historyTab) }
                .tag(Tab.history)
                .accessibilityIdentifier(.tabHistory)

            SettingsScreenView(model: settingsModel)
                .tabItem { Label(L10n.Common.tabSettings, systemImage: SFSymbol.settingsTab) }
                .tag(Tab.settings)
                .accessibilityIdentifier(.tabSettings)
        }
        .tint(Color.fsAccent)
        .appWideAccessibilitySettings()
        .fullScreenCover(isPresented: onboardingPresented) {
            OnboardingView { hasSeenOnboarding = true }
                .appWideAccessibilitySettings()
        }
    }
}

#Preview("Clair") {
    RootView()
        .preferredColorScheme(.light)
}

#Preview("Sombre") {
    RootView()
        .preferredColorScheme(.dark)
}
