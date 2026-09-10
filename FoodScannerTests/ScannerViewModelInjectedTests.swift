//
//  ScannerViewModelInjectedTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/03/2026.
//

import Combine
import FoodScannerUI
import XCTest
@testable import FoodScanner

@MainActor
final class ScannerViewModelInjectedTests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    private func waitForBanner(_ model: ScannerViewModel, where predicate: @escaping (FSScanStatusBanner.State?) -> Bool) {
        let expectation = expectation(description: "banner reaches expected state")
        model.$banner
            .sink { state in
                if predicate(state) { expectation.fulfill() }
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
    }

    func test_getFoodInformations_whenLookupSucceeds_publishesFoundBannerAndScannedFood() {
        let web = WebServiceStub()
        web.result = .success(FoodStruct(barcode: "3017620422003", name: "Nutella"))
        let model = ScannerViewModel(webService: web, reachability: ReachabilityFake())

        model.getFoodInformations(barcode: "3017620422003")

        waitForBanner(model) { $0 == .found("Nutella") }
        XCTAssertEqual(model.scannedFood?.name, "Nutella")
    }

    func test_getFoodInformations_whenLookupFailsWhileOnline_publishesNotFoundBanner() {
        let web = WebServiceStub()
        web.result = .failure(ParserError.foodNotFoundError)
        let model = ScannerViewModel(webService: web, reachability: ReachabilityFake(mode: .online))

        model.getFoodInformations(barcode: "0000000000000")

        waitForBanner(model) { $0 == .notFound }
    }

    func test_getFoodInformations_whenLookupFailsWhileOffline_publishesOfflineBanner() {
        let web = WebServiceStub()
        web.result = .failure(WebServiceError.notInCache)
        let model = ScannerViewModel(webService: web, reachability: ReachabilityFake(mode: .offline))

        model.getFoodInformations(barcode: "0000000000000")

        waitForBanner(model) { $0 == .offline }
    }

    func test_reachabilityBecomingOffline_raisesOfflineBanner() {
        let reachability = ReachabilityFake(mode: .online)
        let model = ScannerViewModel(webService: WebServiceStub(), reachability: reachability)

        reachability.send(.offline)

        waitForBanner(model) { $0 == .offline }
    }

    func test_consumeScannedFood_clearsScannedFood() {
        let web = WebServiceStub()
        web.result = .success(FoodStruct(barcode: "1", name: "X"))
        let model = ScannerViewModel(webService: web, reachability: ReachabilityFake())
        model.getFoodInformations(barcode: "1")
        waitForBanner(model) { $0 == .found("X") }

        model.consumeScannedFood()

        XCTAssertNil(model.scannedFood)
    }
}
