//
//  ScannerKeypadUITests.swift
//  FoodScannerUITests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/10/2026.
//

import XCTest

/// UI journey for the Scanner manual-entry panel: reveal the keypad, confirm every
/// key and the pinned "Valider" button stay on screen and hittable, then type a
/// full barcode and confirm the primary button enables.
///
/// Queries target stable `.accessibilityIdentifier` values set in production
/// (`keypad.key.<digit>`, `keypad.key.delete`, `keypad.validate`,
/// `scanner.toggleKeypad`, `onboarding.skip`), so the tests are locale-independent.
final class ScannerKeypadUITests: XCTestCase {

    private let barcode = "3017620422003"

    private func makeApp(extraLaunchArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += extraLaunchArguments
        return app
    }

    override func setUp() {
        continueAfterFailure = false
    }

    /// The app presents `OnboardingView` as a first-launch `.fullScreenCover`; dismiss it
    /// (without granting the camera) so the Scanner screen and its manual-entry panel are
    /// reachable. A no-op on subsequent launches where onboarding was already completed.
    private func dismissOnboardingIfPresent(in app: XCUIApplication) {
        let skipOnboarding = app.buttons["onboarding.skip"]
        if skipOnboarding.waitForExistence(timeout: 10) {
            skipOnboarding.tap()
        }
    }

    private func revealKeypad(in app: XCUIApplication,
                              file: StaticString = #filePath,
                              line: UInt = #line) {
        dismissOnboardingIfPresent(in: app)
        let showKeypad = app.buttons["scanner.toggleKeypad"]
        XCTAssertTrue(showKeypad.waitForExistence(timeout: 10),
                      "The keypad-toggle button should be visible on the Scanner screen",
                      file: file, line: line)
        showKeypad.tap()
    }

    // MARK: - Presence & hittability

    func test_whenKeypadRevealed_allKeysAndValidateButtonAreHittable() {
        let app = makeApp()
        app.launch()
        revealKeypad(in: app)

        for digit in (0...9).map(String.init) {
            let key = app.buttons["keypad.key.\(digit)"]
            XCTAssertTrue(key.waitForExistence(timeout: 5), "Key \"\(digit)\" should exist")
            XCTAssertTrue(key.isHittable, "Key \"\(digit)\" should be hittable")
        }

        let deleteKey = app.buttons["keypad.key.delete"]
        XCTAssertTrue(deleteKey.exists, "The delete key should exist")
        XCTAssertTrue(deleteKey.isHittable, "The delete key should be hittable")

        let validate = app.buttons["keypad.validate"]
        XCTAssertTrue(validate.exists, "The \"Valider\" button should exist")
        XCTAssertTrue(validate.isHittable, "The \"Valider\" button should be hittable")
    }

    // MARK: - "Valider" stays above the fold

    func test_whenKeypadRevealed_validateButtonStaysWithinWindowBounds() {
        let app = makeApp()
        app.launch()
        revealKeypad(in: app)

        let validate = app.buttons["keypad.validate"]
        XCTAssertTrue(validate.waitForExistence(timeout: 5))

        let window = app.windows.firstMatch
        XCTAssertTrue(window.frame.contains(validate.frame),
                      "The \"Valider\" button frame \(validate.frame) should sit fully "
                      + "within the window \(window.frame) — it must not be pushed below the fold")
        XCTAssertTrue(validate.isHittable,
                      "The \"Valider\" button should remain hittable once the keypad is shown")
    }

    // MARK: - Typing a full barcode enables the primary button

    func test_whenFullBarcodeTyped_validateButtonBecomesEnabled() {
        let app = makeApp()
        app.launch()
        revealKeypad(in: app)

        let validate = app.buttons["keypad.validate"]
        XCTAssertTrue(validate.waitForExistence(timeout: 5))
        XCTAssertFalse(validate.isEnabled,
                       "The \"Valider\" button should start disabled with an empty barcode")

        for digit in barcode.map(String.init) {
            let key = app.buttons["keypad.key.\(digit)"]
            XCTAssertTrue(key.waitForExistence(timeout: 5), "Key \"\(digit)\" should exist")
            key.tap()
        }

        XCTAssertTrue(validate.isEnabled,
                      "The \"Valider\" button should be enabled once a full \(barcode.count)-digit "
                      + "barcode has been entered")
        XCTAssertTrue(validate.isHittable)
    }

    // MARK: - Large Dynamic Type

    /// Forces an accessibility content-size category via the simulator-honored
    /// `-UIPreferredContentSizeCategoryName` launch argument and re-checks that the
    /// pinned "Valider" button is still on screen and hittable when the flexing key
    /// grid is at its tallest.
    func test_withAccessibilityContentSize_validateButtonRemainsHittable() {
        let app = makeApp(extraLaunchArguments: [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXL"
        ])
        app.launch()
        revealKeypad(in: app)

        let validate = app.buttons["keypad.validate"]
        XCTAssertTrue(validate.waitForExistence(timeout: 5),
                      "The \"Valider\" button should exist at accessibility text sizes")

        let window = app.windows.firstMatch
        XCTAssertTrue(window.frame.contains(validate.frame),
                      "At accessibility text size the \"Valider\" button frame \(validate.frame) "
                      + "should still sit within the window \(window.frame)")
        XCTAssertTrue(validate.isHittable,
                      "The \"Valider\" button should stay hittable at accessibility text sizes")

        for digit in ["1", "9", "0"] {
            let key = app.buttons["keypad.key.\(digit)"]
            XCTAssertTrue(key.exists, "Key \"\(digit)\" should exist at accessibility text size")
            XCTAssertTrue(key.isHittable, "Key \"\(digit)\" should be hittable at accessibility text size")
        }
    }
}
