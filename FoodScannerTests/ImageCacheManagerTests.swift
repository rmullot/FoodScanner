//
//  ImageCacheManagerTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/03/2026.
//

import XCTest
@testable import FoodScanner

@MainActor
final class ImageCacheManagerTests: XCTestCase {

    private var activity: NetworkActivitySpy!
    private var sut: ImageCacheManager!

    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(StubURLProtocol.self)
        StubURLProtocol.reset()
        activity = NetworkActivitySpy()
        sut = ImageCacheManager(networkActivity: activity)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(StubURLProtocol.self)
        StubURLProtocol.reset()
        super.tearDown()
    }

    private static func pngData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
        let image = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }
        return image.pngData() ?? Data()
    }

    func test_image_whenURLStringIsInvalid_returnsNil() async {
        let result = await sut.image(for: "")

        XCTAssertNil(result)
    }

    func test_image_whenDownloadSucceeds_returnsDecodedImage() async {
        StubURLProtocol.responseData = Self.pngData()

        let result = await sut.image(for: "https://img.example/a.png")

        XCTAssertNotNil(result)
    }

    func test_image_whenDownloadFails_returnsNil() async {
        StubURLProtocol.failWithError = URLError(.timedOut)

        let result = await sut.image(for: "https://img.example/b.png")

        XCTAssertNil(result)
    }

    func test_image_secondCallForSameURL_isServedFromCacheWithoutSecondDownload() async {
        StubURLProtocol.responseData = Self.pngData()

        _ = await sut.image(for: "https://img.example/c.png")
        StubURLProtocol.failWithError = URLError(.notConnectedToInternet)
        let cached = await sut.image(for: "https://img.example/c.png")

        XCTAssertNotNil(cached)
        XCTAssertEqual(activity.startCount, 1)
    }
}
