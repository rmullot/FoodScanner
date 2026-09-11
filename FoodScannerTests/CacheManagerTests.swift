//
//  CacheManagerTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/04/2026.
//

import XCTest
import RealmSwift
@testable import FoodScanner

final class CacheManagerTests: XCTestCase {

    private var keepAliveRealm: Realm?

    override func tearDown() {
        keepAliveRealm = nil
        super.tearDown()
    }

    private func makeInMemoryCacheManager() -> CacheManager {
        let configuration = Realm.Configuration(inMemoryIdentifier: "test-\(UUID())")
        keepAliveRealm = try? Realm(configuration: configuration)
        return CacheManager(configuration: configuration)
    }

    func test_whenFoodIsUpdatedThenFetched_roundTripsBarcodeAndNutrients() async {
        let sut = makeInMemoryCacheManager()
        let nutrients = [
            NutrientStruct(quantity: 12.5, name: "Glucides", type: NutrientType.mainNutrient.rawValue),
            NutrientStruct(quantity: 3.2, name: "Sel", type: NutrientType.subNutrient.rawValue)
        ]
        let food = FoodStruct(
            barcode: "1234567890123",
            imageURL: "https://example.com/image.png",
            name: "Test Product",
            lastUpdate: 1_000,
            nutriscoreGrade: "a",
            nutrients: nutrients
        )

        await sut.updateFood(food)
        let fetched = await sut.food(barcode: "1234567890123")

        XCTAssertEqual(fetched?.barcode, food.barcode)
        XCTAssertEqual(fetched?.name, food.name)
        XCTAssertEqual(fetched?.imageURL, food.imageURL)
        XCTAssertEqual(fetched?.nutriscoreGrade, food.nutriscoreGrade)
        XCTAssertEqual(fetched?.nutrients.count, 2)
        XCTAssertEqual(fetched?.nutrients.map(\.name).sorted(), ["Glucides", "Sel"])
    }

    func test_whenBarcodeIsUnknown_foodReturnsNil() async {
        let sut = makeInMemoryCacheManager()

        let fetched = await sut.food(barcode: "does-not-exist")

        XCTAssertNil(fetched)
    }

    func test_whenSameBarcodeUpdatedTwice_upsertsInsteadOfDuplicating() async {
        let sut = makeInMemoryCacheManager()
        let firstVersion = FoodStruct(barcode: "999", imageURL: "", name: "Old Name", lastUpdate: 1, nutriscoreGrade: nil, nutrients: [])
        let secondVersion = FoodStruct(barcode: "999", imageURL: "", name: "New Name", lastUpdate: 2, nutriscoreGrade: nil, nutrients: [])

        await sut.updateFood(firstVersion)
        await sut.updateFood(secondVersion)

        let summaries = await sut.allFoodSummaries()
        let fetched = await sut.food(barcode: "999")

        XCTAssertEqual(summaries.count, 1)
        XCTAssertEqual(fetched?.name, "New Name")
    }

    func test_allFoodSummaries_returnsEntriesSortedByLastUpdateDescending() async {
        let sut = makeInMemoryCacheManager()
        let oldest = FoodStruct(barcode: "1", imageURL: "", name: "Oldest", lastUpdate: 100, nutriscoreGrade: nil, nutrients: [])
        let newest = FoodStruct(barcode: "2", imageURL: "", name: "Newest", lastUpdate: 300, nutriscoreGrade: nil, nutrients: [])
        let middle = FoodStruct(barcode: "3", imageURL: "", name: "Middle", lastUpdate: 200, nutriscoreGrade: nil, nutrients: [])

        await sut.updateFood(oldest)
        await sut.updateFood(newest)
        await sut.updateFood(middle)

        let summaries = await sut.allFoodSummaries()

        XCTAssertEqual(summaries.map(\.name), ["Newest", "Middle", "Oldest"])
    }

    func test_allFoodSummaries_onEmptyStore_returnsEmptyArray() async {
        let sut = makeInMemoryCacheManager()

        let summaries = await sut.allFoodSummaries()

        XCTAssertTrue(summaries.isEmpty)
    }
}
