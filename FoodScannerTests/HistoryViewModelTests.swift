//
//  HistoryViewModelTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/03/2026.
//

import Combine
import XCTest
@testable import FoodScanner

@MainActor
final class HistoryViewModelTests: XCTestCase {

    private func makeSummary(_ barcode: String) -> FoodSummary {
        FoodSummary(barcode: barcode, name: "Produit \(barcode)", imageURL: "", nutriscoreGrade: nil, lastUpdate: 0)
    }

    func test_init_whenReachabilityOffline_startsOffline() {
        let sut = HistoryViewModel(cacheManager: CacheManagerFake(), reachability: ReachabilityFake(mode: .offline))

        XCTAssertTrue(sut.isOffline)
    }

    func test_init_whenReachabilityOnline_startsOnline() {
        let sut = HistoryViewModel(cacheManager: CacheManagerFake(), reachability: ReachabilityFake(mode: .online))

        XCTAssertFalse(sut.isOffline)
    }

    func test_reachabilityBecomingOffline_updatesIsOffline() {
        let reachability = ReachabilityFake(mode: .online)
        let sut = HistoryViewModel(cacheManager: CacheManagerFake(), reachability: reachability)
        var cancellables: Set<AnyCancellable> = []
        let expectation = expectation(description: "isOffline turns true")
        sut.$isOffline
            .dropFirst()
            .sink { if $0 { expectation.fulfill() } }
            .store(in: &cancellables)

        reachability.send(.offline)

        wait(for: [expectation], timeout: 2)
    }

    func test_load_populatesItemsFromStore() async {
        let store = CacheManagerFake()
        store.summariesToReturn = [makeSummary("1"), makeSummary("2")]
        let sut = HistoryViewModel(cacheManager: store, reachability: ReachabilityFake())

        await sut.load()

        XCTAssertEqual(sut.items.map(\.barcode), ["1", "2"])
    }

    func test_load_whenStoreEmpty_leavesItemsEmpty() async {
        let sut = HistoryViewModel(cacheManager: CacheManagerFake(), reachability: ReachabilityFake())

        await sut.load()

        XCTAssertTrue(sut.items.isEmpty)
    }
}
