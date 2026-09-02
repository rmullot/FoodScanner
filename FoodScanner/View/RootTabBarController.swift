//
//  RootTabBarController.swift
//  FoodScanner
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//

import UIKit
import SwiftUI
import FoodScannerUI

final class RootTabBarController: UITabBarController {

    private let settingsModel = SettingsScreenModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        let scannerTab = Self.embed(ScannerScreenView(),
                                     title: L10n.Common.tabScanner,
                                     systemImage: "barcode.viewfinder")

        let historyTab = Self.embed(HistoryScreenView(),
                                     title: L10n.Common.tabHistory,
                                     systemImage: "clock.arrow.circlepath")

        let settingsTab = Self.embed(SettingsScreenView(model: settingsModel),
                                      title: L10n.Common.tabSettings,
                                      systemImage: "gearshape")

        viewControllers = [scannerTab, historyTab, settingsTab]
        tabBar.tintColor = UIColor(Color.fsAccent)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presentOnboardingIfNeeded()
    }

    private static func embed<Content: View>(_ view: Content, title: String, systemImage: String) -> UIViewController {
        let hosting = UIHostingController(rootView: view.appWideAccessibilitySettings())
        hosting.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: systemImage), selectedImage: nil)
        return hosting
    }

    private func presentOnboardingIfNeeded() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        guard !hasSeenOnboarding else { return }

        let onboarding = OnboardingView { [weak self] in
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            self?.dismiss(animated: true)
        }
        let hosting = UIHostingController(rootView: onboarding.appWideAccessibilitySettings())
        hosting.modalPresentationStyle = .fullScreen
        present(hosting, animated: false)
    }
}
