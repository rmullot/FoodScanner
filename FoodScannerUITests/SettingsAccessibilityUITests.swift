//
//  SettingsAccessibilityUITests.swift
//  FoodScannerUITests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/10/2026.
//

import XCTest

/// UI journey for the reworked Réglages accessibility section: the contrast row is
/// read-only status plus an "Ouvrir les Réglages iOS" button, the reduce-animations
/// row is an interactive toggle in the default simulator state (system Reduce Motion
/// off), and the text-size slider is present.
///
/// Queries target stable `.accessibilityIdentifier` values set in production
/// (`settings.contrastStatus`, `settings.reduceAnimationsToggle`,
/// `settings.reduceAnimationsStatus`, `settings.textSizeSlider`), so the tests are
/// locale-independent. The contrast row's inner "Ouvrir les Réglages iOS" button
/// carries `settings.openIOSSettings`, independently reachable from the
/// `settings.contrastStatus` status line.
final class SettingsAccessibilityUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    private func dismissOnboardingIfPresent(in app: XCUIApplication) {
        let skipOnboarding = app.buttons["onboarding.skip"]
        if skipOnboarding.waitForExistence(timeout: 10) {
            skipOnboarding.tap()
        }
    }

    private func openSettingsTab() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(in: app)

        let settingsTab = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10),
                      "The Réglages tab should be reachable from the root tab bar")
        settingsTab.tap()
        return app
    }

    func test_contrastRow_showsStatusAndHittableOpenSettingsButton() {
        let app = openSettingsTab()

        let contrastStatusText = app.staticTexts["settings.contrastStatus"]
        XCTAssertTrue(contrastStatusText.waitForExistence(timeout: 5),
                      "The read-only contrast status line should exist and expose a state string")
        XCTAssertFalse(contrastStatusText.label.isEmpty,
                       "The contrast status line should carry a non-empty state label")

        let openIOSSettings = app.buttons["settings.openIOSSettings"]
        XCTAssertTrue(openIOSSettings.waitForExistence(timeout: 5),
                      "The \"Ouvrir les Réglages iOS\" button should exist inside the contrast row")
        XCTAssertTrue(openIOSSettings.isHittable,
                      "The \"Ouvrir les Réglages iOS\" button should be hittable")
    }

    func test_reduceAnimations_isAnInteractiveToggleInDefaultSimulatorState() {
        let app = openSettingsTab()

        let toggle = app.switches["settings.reduceAnimationsToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5),
                      "With system Reduce Motion off the reduce-animations row should be an interactive toggle")
        XCTAssertTrue(toggle.isHittable, "The reduce-animations toggle should be hittable")

        let forcedRow = app.descendants(matching: .any)["settings.reduceAnimationsStatus"]
        XCTAssertFalse(forcedRow.exists,
                       "The forced read-only reduce-animations row must be absent when system Reduce Motion is off")

        toggle.tap()
    }

    func test_textSizeSlider_exists() {
        let app = openSettingsTab()

        let slider = app.sliders["settings.textSizeSlider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 5),
                      "The text-size slider should be present on the Réglages screen")
        XCTAssertTrue(slider.isHittable, "The text-size slider should be hittable")
    }
}
