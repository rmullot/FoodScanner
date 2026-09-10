//
//  SettingsViewModelTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/03/2026.
//

import XCTest
@testable import FoodScanner

@MainActor
final class SettingsViewModelTests: XCTestCase {

    private let keys = ["settings.highContrast", "settings.reduceAnimations", "settings.textScale"]

    override func setUp() {
        super.setUp()
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }

    override func tearDown() {
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        super.tearDown()
    }

    func test_defaults_matchAccessibilityNeutralValues() {
        let sut = SettingsViewModel()

        XCTAssertFalse(sut.highContrast)
        XCTAssertFalse(sut.reduceAnimations)
        XCTAssertEqual(sut.textScale, 1.0)
    }

    func test_reduceAnimations_isPersistedAndReadBack() {
        SettingsViewModel().reduceAnimations = true

        XCTAssertTrue(SettingsViewModel().reduceAnimations)
    }

    func test_textScale_isPersistedAndReadBack() {
        SettingsViewModel().textScale = 1.5

        XCTAssertEqual(SettingsViewModel().textScale, 1.5)
    }
}
