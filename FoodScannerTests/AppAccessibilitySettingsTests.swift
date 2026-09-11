//
//  AppAccessibilitySettingsTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/11/2026.
//

import Combine
import SwiftUI
import UIKit
import XCTest
@testable import FoodScanner

@MainActor
final class AppAccessibilitySettingsTests: XCTestCase {

    private func pumpMainRunLoop() {
        let done = expectation(description: "run loop pumped")
        DispatchQueue.main.async { done.fulfill() }
        wait(for: [done], timeout: 1.0)
    }

    // MARK: - AppDynamicTypeScale.scale(for:) — one-to-one category -> scale

    func test_scaleForCategory_mapsEachCategoryToItsOwnStep() {
        let cases: [(UIContentSizeCategory, Double)] = [
            (.extraSmall, 0.7),
            (.small, 0.8),
            (.medium, 0.9),
            (.large, 1.0),
            (.extraLarge, 1.1),
            (.extraExtraLarge, 1.2),
            (.extraExtraExtraLarge, 1.3),
            (.accessibilityMedium, 1.4),
            (.accessibilityLarge, 1.5),
            (.accessibilityExtraLarge, 1.6),
            (.accessibilityExtraExtraLarge, 1.7),
            (.accessibilityExtraExtraExtraLarge, 1.8)
        ]

        for (category, expected) in cases {
            XCTAssertEqual(AppDynamicTypeScale.scale(for: category), expected, "scale for \(category)")
        }
    }

    func test_scaleForCategory_unknownCategory_defaultsToLargeNeutralScale() {
        XCTAssertEqual(AppDynamicTypeScale.scale(for: .unspecified), 1.0)
    }

    /// `dynamicTypeSize(for:)` must be the inverse of `scale(for:)`, so the slider's
    /// own `scale` value and the live system category never disagree about what they
    /// represent (requirement: a round trip through either direction must match).
    func test_dynamicTypeSizeForScale_isInverseOfScaleForCategory() {
        let categories: [UIContentSizeCategory] = [
            .extraSmall, .small, .medium, .large, .extraLarge, .extraExtraLarge,
            .extraExtraExtraLarge, .accessibilityMedium, .accessibilityLarge,
            .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge
        ]
        let dynamicTypeSizes: [DynamicTypeSize] = [
            .xSmall, .small, .medium, .large, .xLarge, .xxLarge,
            .xxxLarge, .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5
        ]

        for (category, expected) in zip(categories, dynamicTypeSizes) {
            let scale = AppDynamicTypeScale.scale(for: category)
            XCTAssertEqual(AppDynamicTypeScale.dynamicTypeSize(for: scale), expected, "round trip for \(category)")
        }
    }

    // MARK: - AppDynamicTypeScale.isSystemAtMaximum

    func test_isSystemAtMaximum_trueOnlyForTheLastCategory() {
        XCTAssertTrue(AppDynamicTypeScale.isSystemAtMaximum(.accessibilityExtraExtraExtraLarge))
        XCTAssertFalse(AppDynamicTypeScale.isSystemAtMaximum(.accessibilityExtraExtraLarge))
        XCTAssertFalse(AppDynamicTypeScale.isSystemAtMaximum(.large))
    }

    // MARK: - AppWideAccessibilitySettingsModel

    func test_init_seedsSystemContentSizeCategoryFromSeam() {
        let fake = SystemAccessibilityFake(contentSizeCategory: .accessibilityLarge)

        let sut = AppWideAccessibilitySettingsModel(systemAccessibility: fake)

        XCTAssertEqual(sut.systemContentSizeCategory, .accessibilityLarge)
    }

    func test_whenSeamEmitsChange_systemContentSizeCategoryRefreshesLive() {
        let fake = SystemAccessibilityFake(contentSizeCategory: .large)
        let sut = AppWideAccessibilitySettingsModel(systemAccessibility: fake)

        fake.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        fake.emitChange()
        pumpMainRunLoop()

        XCTAssertEqual(sut.systemContentSizeCategory, .accessibilityExtraExtraExtraLarge)
    }
}
