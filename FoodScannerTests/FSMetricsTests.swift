//
//  FSMetricsTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/24/2026.
//

import FoodScannerUI
import XCTest

final class FSMetricsTests: XCTestCase {
    func test_readableContentMaxWidth_is640() {
        XCTAssertEqual(FSMetrics.readableContentMaxWidth, 640)
    }
}
