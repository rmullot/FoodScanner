//
//  RouterTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/11/2026.
//

import XCTest
@testable import FoodScanner

@MainActor
final class RouterTests: XCTestCase {

    func test_newRouter_isAtRootWithEmptyPath() {
        let router = Router<Int>()

        XCTAssertTrue(router.isAtRoot)
        XCTAssertTrue(router.path.isEmpty)
    }

    func test_push_appendsRouteAndLeavesRoot() {
        let router = Router<Int>()

        router.push(1)

        XCTAssertEqual(router.path, [1])
        XCTAssertFalse(router.isAtRoot)
    }

    func test_push_preservesOrderOfMultipleRoutes() {
        let router = Router<Int>()

        router.push(1)
        router.push(2)
        router.push(3)

        XCTAssertEqual(router.path, [1, 2, 3])
    }

    func test_pop_removesOnlyTheLastRoute() {
        let router = Router<Int>()
        router.push(1)
        router.push(2)

        router.pop()

        XCTAssertEqual(router.path, [1])
    }

    func test_pop_whenAlreadyAtRoot_doesNothing() {
        let router = Router<Int>()

        router.pop()

        XCTAssertTrue(router.path.isEmpty)
    }

    func test_popToRoot_clearsTheWholePath() {
        let router = Router<Int>()
        router.push(1)
        router.push(2)
        router.push(3)

        router.popToRoot()

        XCTAssertTrue(router.path.isEmpty)
        XCTAssertTrue(router.isAtRoot)
    }
}
