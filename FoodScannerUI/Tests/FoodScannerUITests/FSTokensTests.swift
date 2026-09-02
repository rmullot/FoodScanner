//
//  FSTokensTests.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import XCTest
import SwiftUI
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
}
