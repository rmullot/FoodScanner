//
//  WebServiceManagerTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/03/2026.
//

import XCTest
@testable import FoodScanner

/// Intercepts `URLSession.shared` traffic so `WebServiceManager` never hits the network.
class StubURLProtocol: URLProtocol {
    nonisolated(unsafe) static var responseData: Data?
    nonisolated(unsafe) static var failWithError: Error?

    static func reset() {
        responseData = nil
        failWithError = nil
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func stopLoading() {}

    override func startLoading() {
        if let error = Self.failWithError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        if let url = request.url,
           let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocol(self, didLoad: Self.responseData ?? Data())
        client?.urlProtocolDidFinishLoading(self)
    }
}

@MainActor
final class WebServiceManagerTests: XCTestCase {

    private var store: CacheManagerFake!
    private var activity: NetworkActivitySpy!
    private var sut: WebServiceManager!

    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(StubURLProtocol.self)
        StubURLProtocol.reset()
        store = CacheManagerFake()
        activity = NetworkActivitySpy()
        sut = WebServiceManager(cacheManager: store, networkActivity: activity)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(StubURLProtocol.self)
        StubURLProtocol.reset()
        super.tearDown()
    }

    private var validPayload: Data {
        Data("""
        {
          "code": "3017620422003", "status_verbose": "ok", "status": 1,
          "product": {
            "code": "3017620422003", "image_small_url": "", "product_name": "Nutella",
            "last_modified_t": 1600000000, "nutriscore_grade": "e",
            "nutriments": { "sugars_100g": 56.3 }
          }
        }
        """.utf8)
    }

    func test_getFoodDescription_onSuccess_persistsParsedFood() async throws {
        StubURLProtocol.responseData = validPayload

        _ = try await sut.getFoodDescription(barcode: "3017620422003")

        XCTAssertEqual(store.updatedFoods.map(\.barcode), ["3017620422003"])
    }

    func test_getFoodDescription_onSuccess_returnsCachedReadBack() async throws {
        StubURLProtocol.responseData = validPayload

        let food = try await sut.getFoodDescription(barcode: "3017620422003")

        XCTAssertEqual(food.name, "Nutella")
    }

    func test_getFoodDescription_whenNetworkFailsButBarcodeCached_returnsCachedFood() async throws {
        StubURLProtocol.failWithError = URLError(.notConnectedToInternet)
        let cached = FoodStruct(barcode: "111", name: "Cached product")
        await store.updateFood(cached)

        let food = try await sut.getFoodDescription(barcode: "111")

        XCTAssertEqual(food.name, "Cached product")
    }

    func test_getFoodDescription_whenNetworkFailsAndNoCache_rethrows() async {
        StubURLProtocol.failWithError = URLError(.notConnectedToInternet)

        do {
            _ = try await sut.getFoodDescription(barcode: "999")
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }

    func test_getFoodDescription_whenServerReturnsProductNotFound_andNoCache_throwsParserError() async {
        let notFoundProduct = #"{"code":"","image_small_url":"","product_name":"","last_modified_t":0,"nutriments":{}}"#
        StubURLProtocol.responseData = Data(#"{"code":"1","status_verbose":"not found","status":0,"product":\#(notFoundProduct)}"#.utf8)

        do {
            _ = try await sut.getFoodDescription(barcode: "42")
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertEqual(error as? ParserError, .foodNotFoundError)
        }
    }

    func test_getFoodDescription_balancesNetworkActivityStartAndFinish() async throws {
        StubURLProtocol.responseData = validPayload

        _ = try await sut.getFoodDescription(barcode: "3017620422003")
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(activity.startCount, 1)
        XCTAssertEqual(activity.finishCount, 1)
    }
}
