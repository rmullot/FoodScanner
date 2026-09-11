//
//  ScannerCoordinatorTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/11/2026.
//

import Combine
import XCTest
@testable import FoodScanner

@MainActor
final class ScannerCoordinatorTests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    private func makeScannerViewModel(with web: WebServiceStub) -> ScannerViewModel {
        ScannerViewModel(webService: web,
                         reachability: ReachabilityFake(),
                         networkActivity: NetworkActivitySpy())
    }

    private func makeCoordinator(scannerViewModel: ScannerViewModel) -> ScannerCoordinator {
        ScannerCoordinator(router: Router<ScannerRoute>(), scannerViewModel: scannerViewModel)
    }

    private func waitForScannedFood(_ model: ScannerViewModel) {
        let expectation = expectation(description: "scanned food published")
        model.$scannedFood
            .sink { if $0 != nil { expectation.fulfill() } }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
    }

    func test_showProductDetail_pushesMatchingProductDetailRoute() {
        let coordinator = makeCoordinator(scannerViewModel: makeScannerViewModel(with: WebServiceStub()))
        let food = FoodStruct(barcode: "3017620422003", name: "Nutella")

        coordinator.showProductDetail(for: food)

        XCTAssertEqual(coordinator.router.path, [.productDetail(food)])
    }

    func test_showProductDetail_clearsScannerViewModelScannedFood() throws {
        let web = WebServiceStub()
        web.result = .success(FoodStruct(barcode: "3017620422003", name: "Nutella"))
        let scannerViewModel = makeScannerViewModel(with: web)
        let coordinator = makeCoordinator(scannerViewModel: scannerViewModel)
        scannerViewModel.getFoodInformations(barcode: "3017620422003")
        waitForScannedFood(scannerViewModel)
        let scanned = try XCTUnwrap(scannerViewModel.scannedFood)

        coordinator.showProductDetail(for: scanned)

        XCTAssertNil(scannerViewModel.scannedFood)
    }

    func test_routerChange_isForwardedToCoordinatorObjectWillChange() {
        let coordinator = makeCoordinator(scannerViewModel: makeScannerViewModel(with: WebServiceStub()))
        let expectation = expectation(description: "coordinator relays router objectWillChange")
        coordinator.objectWillChange
            .sink { expectation.fulfill() }
            .store(in: &cancellables)

        coordinator.router.push(.productDetail(FoodStruct(barcode: "1", name: "X")))

        wait(for: [expectation], timeout: 2)
    }
}
