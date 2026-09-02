//
//  RootTabBarController.swift
//  FoodScanner
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//  3-tab root (Scanner / History / Settings), each a UIHostingController
//  hosted directly in the tab — no wrapping UINavigationController (see the
//  comment on `embed` below). Replaces the push-based storyboard navigation
//  (NavigationManager) and the storyboard SceneDelegate.
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

        // Presenting here (rather than viewDidLoad) is required: the view
        // isn't in the window hierarchy yet at viewDidLoad time, which is
        // exactly what produces "whose view is not in the window hierarchy"
        // when `present` is called too early. `presentOnboardingIfNeeded`
        // is itself idempotent (guarded by `hasSeenOnboarding`), so it's
        // safe to call again on every reappearance after the modal dismisses.
        presentOnboardingIfNeeded()
    }

    /// Each screen already owns its own SwiftUI `NavigationStack` (navigation
    /// bar + `.navigationTitle` managed on the SwiftUI side). We therefore
    /// host the `UIHostingController` directly in the tab, without wrapping
    /// it in an additional UIKit `UINavigationController` — otherwise two
    /// navigation bars stack up and the title is displayed twice.
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
