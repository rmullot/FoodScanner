//
//  ScannerLayoutTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/24/2026.
//

import FoodScannerUI
import SwiftUI
import XCTest
@testable import FoodScanner

final class ScannerLayoutTests: XCTestCase {

    func test_isSideBySide_whenRegularWidth_isTrue() {
        XCTAssertTrue(ScannerLayout(horizontalSizeClass: .regular, verticalSizeClass: .regular).isSideBySide)
    }

    func test_isSideBySide_whenCompactHeight_isFalse() {
        XCTAssertFalse(ScannerLayout(horizontalSizeClass: .compact, verticalSizeClass: .compact).isSideBySide)
    }

    func test_isSideBySide_whenRegularWidthCompactHeight_isFalse() {
        XCTAssertFalse(ScannerLayout(horizontalSizeClass: .regular, verticalSizeClass: .compact).isSideBySide)
    }

    func test_isSideBySide_whenCompactWidthRegularHeight_isFalse() {
        XCTAssertFalse(ScannerLayout(horizontalSizeClass: .compact, verticalSizeClass: .regular).isSideBySide)
    }

    func test_isSideBySide_whenSizeClassesNil_isFalse() {
        XCTAssertFalse(ScannerLayout(horizontalSizeClass: nil, verticalSizeClass: nil).isSideBySide)
    }

    func test_keypadHeight_neverBelowMinimum() {
        for layout in [ScannerLayout(horizontalSizeClass: .compact, verticalSizeClass: .regular),
                       ScannerLayout(horizontalSizeClass: .regular, verticalSizeClass: .regular)] {
            XCTAssertGreaterThanOrEqual(layout.keypadHeight(containerHeight: 0), FSMetrics.keypadMinRegionHeight)
            XCTAssertGreaterThanOrEqual(layout.keypadHeight(containerHeight: 100), FSMetrics.keypadMinRegionHeight)
        }
    }

    func test_panelMaxHeight_stackedLeavesRoomForCamera() {
        let layout = ScannerLayout(horizontalSizeClass: .compact, verticalSizeClass: .regular)

        XCTAssertEqual(layout.panelMaxHeight(containerHeight: 800), 680)
    }

    func test_panelMaxHeight_compactHeightIsFullContainer() {
        let layout = ScannerLayout(horizontalSizeClass: .regular, verticalSizeClass: .compact)

        XCTAssertEqual(layout.panelMaxHeight(containerHeight: 400), 400)
    }

    func test_panelMaxWidth_compactHeightWithKeypadIsTwoColumns() {
        let layout = ScannerLayout(horizontalSizeClass: .compact, verticalSizeClass: .compact)

        XCTAssertEqual(layout.panelMaxWidth(showsKeypad: true), FSMetrics.keypadMaxWidth * 2 + FSMetrics.space10 * 2)
        XCTAssertEqual(layout.panelMaxWidth(showsKeypad: false), FSMetrics.keypadMaxWidth + FSMetrics.space10 * 2)
    }

    func test_panelMaxHeight_sideBySideIsFullContainer() {
        let layout = ScannerLayout(horizontalSizeClass: .regular, verticalSizeClass: .regular)

        XCTAssertEqual(layout.panelMaxHeight(containerHeight: 800), 800)
    }
}
