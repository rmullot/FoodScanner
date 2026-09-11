//
//  ScannerKeypadUITests.swift
//  FoodScannerUITests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/10/2026.
//

import XCTest

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
        XCTAssertTrue(validate.exists, "The \"Chercher ce produit\" button should exist")
        XCTAssertTrue(validate.isHittable, "The \"Chercher ce produit\" button should be hittable")
    }

    // MARK: - "Chercher ce produit" stays above the fold

    func test_whenKeypadRevealed_validateButtonStaysWithinWindowBounds() {
        let app = makeApp()
        app.launch()
        revealKeypad(in: app)

        let validate = app.buttons["keypad.validate"]
        XCTAssertTrue(validate.waitForExistence(timeout: 5))

        let window = app.windows.firstMatch
        XCTAssertTrue(window.frame.contains(validate.frame),
                      "The \"Chercher ce produit\" button frame \(validate.frame) should sit fully "
                      + "within the window \(window.frame) — it must not be pushed below the fold")
        XCTAssertTrue(validate.isHittable,
                      "The \"Chercher ce produit\" button should remain hittable once the keypad is shown")
    }

    // MARK: - Typing a full barcode enables the primary button

    func test_whenFullBarcodeTyped_validateButtonBecomesEnabled() {
        let app = makeApp()
        app.launch()
        revealKeypad(in: app)

        let validate = app.buttons["keypad.validate"]
        XCTAssertTrue(validate.waitForExistence(timeout: 5))
        XCTAssertFalse(validate.isEnabled,
                       "The \"Chercher ce produit\" button should start disabled with an empty barcode")

        for digit in barcode.map(String.init) {
            let key = app.buttons["keypad.key.\(digit)"]
            XCTAssertTrue(key.waitForExistence(timeout: 5), "Key \"\(digit)\" should exist")
            key.tap()
        }

        XCTAssertTrue(validate.isEnabled,
                      "The \"Chercher ce produit\" button should be enabled once a full \(barcode.count)-digit "
                      + "barcode has been entered")
        XCTAssertTrue(validate.isHittable)
    }

    // MARK: - Large Dynamic Type

    func test_withAccessibilityContentSize_validateButtonRemainsHittable() {
        let app = makeApp(extraLaunchArguments: [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityXL"
        ])
        app.launch()
        revealKeypad(in: app)

        let validate = app.buttons["keypad.validate"]
        XCTAssertTrue(validate.waitForExistence(timeout: 5),
                      "The \"Chercher ce produit\" button should exist at accessibility text sizes")

        let window = app.windows.firstMatch
        XCTAssertTrue(window.frame.contains(validate.frame),
                      "At accessibility text size the \"Chercher ce produit\" button frame \(validate.frame) "
                      + "should still sit within the window \(window.frame)")
        XCTAssertTrue(validate.isHittable,
                      "The \"Chercher ce produit\" button should stay hittable at accessibility text sizes")

        for digit in ["1", "9", "0"] {
            let key = app.buttons["keypad.key.\(digit)"]
            XCTAssertTrue(key.exists, "Key \"\(digit)\" should exist at accessibility text size")
            XCTAssertTrue(key.isHittable, "Key \"\(digit)\" should be hittable at accessibility text size")
        }
    }

    // MARK: - AX5 on the smallest device does not clip live controls

    func test_atAX5OnSmallDevice_midGridKeyAndValidateAreNotClipped() {
        let app = makeApp(extraLaunchArguments: [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibility5"
        ])
        app.launch()
        revealKeypad(in: app)

        let midKey = app.buttons["keypad.key.5"]
        XCTAssertTrue(midKey.waitForExistence(timeout: 5),
                      "Key \"5\" should not be clipped by the reveal container at AX5")
        XCTAssertTrue(midKey.isHittable,
                      "Key \"5\" should stay hittable at AX5 on the smallest screen")

        let validate = app.buttons["keypad.validate"]
        XCTAssertTrue(validate.waitForExistence(timeout: 5),
                      "The \"Chercher ce produit\" button should not be clipped by the reveal container at AX5")
        XCTAssertTrue(validate.isHittable,
                      "The \"Chercher ce produit\" button should stay hittable at AX5 on the smallest screen")
    }
}
