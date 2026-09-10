//
//  NetworkActivityManagerTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/03/2026.
//

import XCTest
@testable import FoodScanner

@MainActor
final class NetworkActivityManagerTests: XCTestCase {

    private var sut: NetworkActivityManager!

    override func setUp() {
        super.setUp()
        sut = NetworkActivityManager()
    }

    func test_newRequestStarted_marksActivityActive() {
        sut.newRequestStarted()

        XCTAssertTrue(sut.isActive)
    }

    func test_newRequestStarted_returnsRunningRequestCount() {
        XCTAssertEqual(sut.newRequestStarted(), 1)
        XCTAssertEqual(sut.newRequestStarted(), 2)
    }

    func test_requestFinished_whileOtherRequestsPending_keepsActivityActive() {
        sut.newRequestStarted()
        sut.newRequestStarted()

        sut.requestFinished()

        XCTAssertTrue(sut.isActive)
    }

    func test_requestFinished_whenLastRequestCompletes_stopsActivity() {
        sut.newRequestStarted()

        sut.requestFinished()

        XCTAssertFalse(sut.isActive)
    }

    func test_requestFinished_neverDrivesCountNegative() {
        XCTAssertEqual(sut.requestFinished(), 0)
        XCTAssertFalse(sut.isActive)
    }

    func test_disableActivityIndicator_forcesActivityOffRegardlessOfPendingCount() {
        sut.newRequestStarted()
        sut.newRequestStarted()

        sut.disableActivityIndicator()

        XCTAssertFalse(sut.isActive)
    }
}
