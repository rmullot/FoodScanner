//
//  RootTabBarController.swift
//  FoodScanner
//
//  Racine à 3 onglets (Scanner / Historique / Réglages), chacun un
//  UIHostingController dans son propre UINavigationController. Remplace la
//  navigation push storyboard (NavigationManager) et le SceneDelegate storyboard.
//

import UIKit
import SwiftUI
import FoodScannerUI

final class RootTabBarController: UITabBarController {

    private let settingsModel = SettingsScreenModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        let scannerTab = Self.embed(ScannerScreenView(),
                                     title: "Scanner",
                                     systemImage: "barcode.viewfinder")

        let historyTab = Self.embed(HistoryScreenView(),
                                     title: "Historique",
                                     systemImage: "clock.arrow.circlepath")

        let settingsTab = Self.embed(SettingsScreenView(model: settingsModel),
                                      title: "Réglages",
                                      systemImage: "gearshape")

        viewControllers = [scannerTab, historyTab, settingsTab]
        tabBar.tintColor = UIColor(Color.fsAccent)

        presentOnboardingIfNeeded()
    }

    /// Chaque écran possède déjà sa propre `NavigationStack` SwiftUI (barre de
    /// navigation + `.navigationTitle` gérés côté SwiftUI). On héberge donc le
    /// `UIHostingController` directement dans l'onglet, sans l'envelopper dans
    /// un `UINavigationController` UIKit supplémentaire — sinon deux barres de
    /// navigation se superposent et le titre s'affiche en double.
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
