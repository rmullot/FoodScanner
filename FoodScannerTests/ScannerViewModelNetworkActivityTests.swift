//
//  ScannerViewModelNetworkActivityTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/11/2026.
//

import Combine
import XCTest
@testable import FoodScanner

@MainActor
final class ScannerViewModelNetworkActivityTests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    private func makeModel(networkActivity: NetworkActivitySpy) -> ScannerViewModel {
        ScannerViewModel(webService: WebServiceStub(),
                         reachability: ReachabilityFake(),
                         networkActivity: networkActivity)
    }

    private func waitForNetworkActive(_ model: ScannerViewModel, toEqual expected: Bool) {
        let expectation = expectation(description: "isNetworkActive == \(expected)")
        model.$isNetworkActive
            .sink { if $0 == expected { expectation.fulfill() } }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
    }

    func test_isNetworkActive_startsFalse() {
        let model = makeModel(networkActivity: NetworkActivitySpy())

        XCTAssertFalse(model.isNetworkActive)
    }

    func test_isNetworkActive_becomesTrueWhenInjectedTrackerStartsARequest() {
        let spy = NetworkActivitySpy()
        let model = makeModel(networkActivity: spy)

        spy.newRequestStarted()

        waitForNetworkActive(model, toEqual: true)
    }

    func test_isNetworkActive_returnsToFalseWhenInjectedTrackerFinishesRequest() {
        let spy = NetworkActivitySpy()
        let model = makeModel(networkActivity: spy)
        spy.newRequestStarted()
        waitForNetworkActive(model, toEqual: true)

        spy.requestFinished()

        waitForNetworkActive(model, toEqual: false)
    }
}
