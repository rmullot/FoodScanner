//
//  FSTokensTests.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import XCTest
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
@testable import FoodScannerUI

final class FSTokensTests: XCTestCase {

    func testScoreLetterContrastRule() {
        for score in FSNutriScore.allCases {
            if score == .c {
                XCTAssertNotEqual(score.letterColor, .white, "Le C jaune exige une lettre sombre.")
            } else {
                XCTAssertEqual(score.letterColor, .white)
            }
        }
    }

    func testSeasonFollowsScheme() {
        XCTAssertEqual(FSSeason.matching(.light), .springSummer)
        XCTAssertEqual(FSSeason.matching(.dark), .autumnWinter)
    }

    func testSeasonFollowsCalendar() throws {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = try XCTUnwrap(TimeZone(identifier: "Europe/Paris"))
        let june = try XCTUnwrap(DateComponents(calendar: cal, year: 2026, month: 6, day: 15).date)
        let december = try XCTUnwrap(DateComponents(calendar: cal, year: 2026, month: 12, day: 15).date)
        XCTAssertEqual(FSSeason.current(june, calendar: cal), .springSummer)
        XCTAssertEqual(FSSeason.current(december, calendar: cal), .autumnWinter)
    }

    func testEverySeasonHasThreeMascots() {
        for season in FSSeason.allCases {
            XCTAssertEqual(season.mascots.count, 3)
            XCTAssertTrue(season.mascots.allSatisfy { $0.season == season })
        }
    }

    func testEveryNutrientHasADistinctPattern() {
        let patterns = FSNutrient.allCases.map(\.pattern)
        XCTAssertEqual(Set(patterns).count, patterns.count, "Aucune info ne doit reposer sur la couleur seule.")
    }

    func testTouchTargetFloor() {
        XCTAssertGreaterThanOrEqual(FSMetrics.minTouchTarget, 44)
        XCTAssertGreaterThanOrEqual(FSMetrics.controlHeight, FSMetrics.minTouchTarget)
    }

    // MARK: - Increased-contrast border widths

    func testIncreasedContrastBorderConstants() {
        XCTAssertEqual(FSMetrics.borderWidthIncreased, 2.5)
        XCTAssertEqual(FSMetrics.borderWidthStrongIncreased, 3)
        XCTAssertGreaterThan(FSMetrics.borderWidthIncreased, FSMetrics.borderWidth)
        XCTAssertGreaterThan(FSMetrics.borderWidthStrongIncreased, FSMetrics.borderWidthStrong)
    }

    func testBorderWidthMapsContrastToThickness() {
        XCTAssertEqual(FSMetrics.borderWidth(for: .standard), FSMetrics.borderWidth)
        XCTAssertEqual(FSMetrics.borderWidth(for: .increased), FSMetrics.borderWidthIncreased)
    }

    func testBorderWidthStrongMapsContrastToThickness() {
        XCTAssertEqual(FSMetrics.borderWidthStrong(for: .standard), FSMetrics.borderWidthStrong)
        XCTAssertEqual(FSMetrics.borderWidthStrong(for: .increased), FSMetrics.borderWidthStrongIncreased)
    }

    // MARK: - New contrast-hardening colour & font tokens resolve

    func testIncreasedContrastColorTokensResolve() {
        XCTAssertNotNil(UIColor(named: "fsBorderStrong", in: .fsModule, compatibleWith: nil),
                        "fsBorderStrong colorset should ship in the package bundle.")
        XCTAssertNotNil(UIColor(named: "fsAccentSoftStrong", in: .fsModule, compatibleWith: nil),
                        "fsAccentSoftStrong colorset should ship in the package bundle.")
    }

    func testBodyHeavyFontIsDistinctWeight() {
        XCTAssertNotEqual(Font.fsBodyHeavy, Font.fsBody)
        XCTAssertNotEqual(Font.fsBodyHeavy, Font.fsBodyStrong)
    }
}
