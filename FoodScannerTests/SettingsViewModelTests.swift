//
//  SettingsViewModelTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/10/2026.
//

import SwiftUI
import UIKit
import XCTest
@testable import FoodScanner

@MainActor
final class SettingsViewModelTests: XCTestCase {

    private let keys = ["settings.reduceAnimations", "settings.textScale"]

    override func setUp() {
        super.setUp()
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }

    override func tearDown() {
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        super.tearDown()
    }

    private func pumpMainRunLoop() {
        let done = expectation(description: "run loop pumped")
        DispatchQueue.main.async { done.fulfill() }
        wait(for: [done], timeout: 1.0)
    }

    // MARK: - Defaults & persistence

    func test_defaults_matchAccessibilityNeutralValues() {
        let sut = SettingsViewModel(systemAccessibility: SystemAccessibilityFake())

        XCTAssertFalse(sut.reduceAnimations)
        XCTAssertEqual(sut.textScale, 1.0)
    }

    func test_reduceAnimations_isPersistedAndReadBack() {
        SettingsViewModel(systemAccessibility: SystemAccessibilityFake()).reduceAnimations = true

        XCTAssertTrue(SettingsViewModel(systemAccessibility: SystemAccessibilityFake()).reduceAnimations)
    }

    func test_textScale_isPersistedWithinASession() {
        let fake = SystemAccessibilityFake()
        let sut = SettingsViewModel(systemAccessibility: fake)

        sut.textScale = 1.3

        XCTAssertEqual(sut.textScale, 1.3)
    }

    /// A stale local value from a previous session must not survive a fresh launch:
    /// `init` always recalibrates onto whatever the system reports right now.
    func test_textScale_recalibratesOnLaunchRegardlessOfPersistedValue() {
        SettingsViewModel(systemAccessibility: SystemAccessibilityFake()).textScale = 1.8

        let sut = SettingsViewModel(systemAccessibility: SystemAccessibilityFake(contentSizeCategory: .large))

        XCTAssertEqual(sut.textScale, 1.0)
    }

    // MARK: - Seeding from the system seam

    func test_init_seedsPublishedStateFromSystemAccessibilitySeam() {
        let fake = SystemAccessibilityFake(reduceMotion: true,
                                          increasedContrast: true,
                                          contentSizeCategory: .accessibilityLarge)

        let sut = SettingsViewModel(systemAccessibility: fake)

        XCTAssertTrue(sut.systemReduceMotionEnabled)
        XCTAssertTrue(sut.systemIncreasedContrastEnabled)
        XCTAssertEqual(sut.systemContentSizeCategory, .accessibilityLarge)
    }

    // MARK: - Live refresh on changesPublisher

    func test_whenSeamEmitsChange_publishedStateAndDerivedPropsRefresh() {
        let fake = SystemAccessibilityFake()
        let sut = SettingsViewModel(systemAccessibility: fake)

        XCTAssertFalse(sut.systemIncreasedContrastEnabled)
        XCTAssertFalse(sut.reduceAnimationsForcedBySystem)

        fake.isReduceMotionEnabled = true
        fake.isIncreasedContrastEnabled = true
        fake.preferredContentSizeCategory = .accessibilityExtraLarge
        fake.emitChange()
        pumpMainRunLoop()

        XCTAssertTrue(sut.systemReduceMotionEnabled)
        XCTAssertTrue(sut.systemIncreasedContrastEnabled)
        XCTAssertEqual(sut.systemContentSizeCategory, .accessibilityExtraLarge)
        XCTAssertTrue(sut.reduceAnimationsForcedBySystem)
        XCTAssertTrue(sut.effectiveReduceAnimations)
        XCTAssertTrue(sut.systemContentSizeIsAccessibilitySize)
    }

    // MARK: - reduce-animations truth table

    func test_reduceAnimationsForced_and_effective_truthTable() {
        let offOff = SettingsViewModel(systemAccessibility: SystemAccessibilityFake(reduceMotion: false))
        offOff.reduceAnimations = false
        XCTAssertFalse(offOff.reduceAnimationsForcedBySystem)
        XCTAssertFalse(offOff.effectiveReduceAnimations)

        let offOn = SettingsViewModel(systemAccessibility: SystemAccessibilityFake(reduceMotion: false))
        offOn.reduceAnimations = true
        XCTAssertFalse(offOn.reduceAnimationsForcedBySystem)
        XCTAssertTrue(offOn.effectiveReduceAnimations)

        let onOff = SettingsViewModel(systemAccessibility: SystemAccessibilityFake(reduceMotion: true))
        onOff.reduceAnimations = false
        XCTAssertTrue(onOff.reduceAnimationsForcedBySystem)
        XCTAssertTrue(onOff.effectiveReduceAnimations)

        let onOn = SettingsViewModel(systemAccessibility: SystemAccessibilityFake(reduceMotion: true))
        onOn.reduceAnimations = true
        XCTAssertTrue(onOn.reduceAnimationsForcedBySystem)
        XCTAssertTrue(onOn.effectiveReduceAnimations)
    }

    // MARK: - Text-scale recalibration

    func test_textScale_matchesSystemCategoryOnInit() {
        let cases: [(UIContentSizeCategory, Double)] = [
            (.medium, 0.9),
            (.large, 1.0),
            (.extraLarge, 1.1),
            (.accessibilityMedium, 1.4),
            (.accessibilityExtraExtraExtraLarge, 1.8)
        ]

        for (category, expected) in cases {
            let sut = SettingsViewModel(systemAccessibility: SystemAccessibilityFake(contentSizeCategory: category))
            XCTAssertEqual(sut.textScale, expected, "scale for \(category)")
        }
    }

    /// Recalibration overwrites the local value in *either* direction: a user who had
    /// diverged from the system setting loses that divergence once the system itself
    /// moves, whether up or down.
    func test_textScale_recalibratesInEitherDirectionOnSystemChange() {
        let fake = SystemAccessibilityFake(contentSizeCategory: .accessibilityMedium)
        let sut = SettingsViewModel(systemAccessibility: fake)
        sut.textScale = 1.0

        fake.preferredContentSizeCategory = .small
        fake.emitChange()
        pumpMainRunLoop()
        XCTAssertEqual(sut.textScale, 0.8)

        sut.textScale = 0.8
        fake.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        fake.emitChange()
        pumpMainRunLoop()
        XCTAssertEqual(sut.textScale, 1.8)
    }

    func test_systemTextSizeIsAtMaximum_onlyAtTheLastSystemCategory() {
        let atMax = SettingsViewModel(
            systemAccessibility: SystemAccessibilityFake(contentSizeCategory: .accessibilityExtraExtraExtraLarge))
        XCTAssertTrue(atMax.systemTextSizeIsAtMaximum)

        let belowMax = SettingsViewModel(
            systemAccessibility: SystemAccessibilityFake(contentSizeCategory: .accessibilityExtraExtraLarge))
        XCTAssertFalse(belowMax.systemTextSizeIsAtMaximum)
    }

    // MARK: - Accessibility-size detection

    func test_systemContentSizeIsAccessibilitySize_reflectsCategory() {
        let standard = SettingsViewModel(systemAccessibility: SystemAccessibilityFake(contentSizeCategory: .large))
        XCTAssertFalse(standard.systemContentSizeIsAccessibilitySize)

        let accessibility = SettingsViewModel(
            systemAccessibility: SystemAccessibilityFake(contentSizeCategory: .accessibilityLarge))
        XCTAssertTrue(accessibility.systemContentSizeIsAccessibilitySize)
    }

    // MARK: - AppDynamicTypeScale ceiling clamp (rgaa reviewer)

    func test_appDynamicTypeScale_isMonotonicAndClampsAtAccessibility5() {
        var previous = AppDynamicTypeScale.dynamicTypeSize(for: 0.5)
        for step in stride(from: 0.6, through: 2.5, by: 0.1) {
            let current = AppDynamicTypeScale.dynamicTypeSize(for: step)
            XCTAssertGreaterThanOrEqual(current, previous, "scale \(step) regressed the Dynamic Type size")
            previous = current
        }

        XCTAssertEqual(AppDynamicTypeScale.dynamicTypeSize(for: 2.0), .accessibility5)
        XCTAssertEqual(AppDynamicTypeScale.dynamicTypeSize(for: 3.0), .accessibility5)
    }
}
