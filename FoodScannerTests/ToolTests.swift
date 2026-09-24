//
//  ToolTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/24/2026.
//

import XCTest
@testable import FoodScanner

final class ToolTests: XCTestCase {
    private let resolutions = ["640x480", "1280x720", "1920x1080"]

    func test_getBestPicture_picksSmallestResolutionReachingContainerHeight() {
        XCTAssertEqual(Tool.getBestPicture(resolutions: resolutions, containerHeight: 700), "1280x720")
    }

    func test_getBestPicture_whenNoResolutions_returnsEmpty() {
        XCTAssertEqual(Tool.getBestPicture(resolutions: [], containerHeight: 700), "")
    }

    func test_getBestPicture_ignoresMalformedResolutions() {
        XCTAssertEqual(Tool.getBestPicture(resolutions: ["abc", "640x480"], containerHeight: 300), "640x480")
    }
}
