//
//  FoodDetailViewModelTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/02/2026.
//

import UIKit
import XCTest
import FoodScannerUI
@testable import FoodScanner

@MainActor
final class FoodDetailViewModelTests: XCTestCase {

    func test_name_reflectsFoodName() {
        let model = FoodDetailViewModel(food: .previewFixture)
        XCTAssertEqual(model.name, "Pâte à tartiner noisettes et cacao")
    }

    func test_name_isEmptyWhenFoodIsNil() {
        let model = FoodDetailViewModel(food: nil)
        XCTAssertEqual(model.name, "")
    }

    func test_nutriScore_decodedFromNutriscoreGrade() {
        let model = FoodDetailViewModel(food: .previewFixture)
        XCTAssertEqual(model.nutriScore, FSNutriScore(letter: "e"))
    }

    func test_nutrientBars_containsOnlyMainNutrientsWithAnFSNutrientEquivalent() {
        let model = FoodDetailViewModel(food: .previewFixture)

        XCTAssertEqual(model.nutrientBars.count, 5)
        let kinds = Set(model.nutrientBars.map(\.0))
        XCTAssertEqual(kinds, [.carbs, .protein, .fat, .fiber, .salt])
    }

    func test_caloriesText_formatsTheCaloriesNutrient() {
        let model = FoodDetailViewModel(food: .previewFixture)
        XCTAssertEqual(model.caloriesText, L10n.Nutrients.caloriesFormat(539))
    }

    func test_loadThumbnail_whenImageURLPresentAndCacheReturnsImage_setsThumbnail() async {
        let cache = ImageCacheStub(imageToReturn: UIImage())
        let model = FoodDetailViewModel(food: .previewFixture, imageCache: cache)

        await model.loadThumbnail()

        XCTAssertNotNil(model.thumbnail)
    }

    func test_loadThumbnail_whenFoodIsNil_doesNotHitCache() async {
        let cache = ImageCacheStub(imageToReturn: UIImage())
        let model = FoodDetailViewModel(food: nil, imageCache: cache)

        await model.loadThumbnail()

        XCTAssertNil(model.thumbnail)
        XCTAssertTrue(cache.requestedURLs.isEmpty)
    }

    func test_loadThumbnail_whenCacheReturnsNil_leavesThumbnailNil() async {
        let cache = ImageCacheStub(imageToReturn: nil)
        let model = FoodDetailViewModel(food: .previewFixture, imageCache: cache)

        await model.loadThumbnail()

        XCTAssertNil(model.thumbnail)
    }

    func test_caloriesText_isNilWhenNoCaloriesNutrient() {
        let foodWithoutCalories = FoodStruct(
            barcode: "0000000000000",
            imageURL: "",
            name: "Produit test",
            lastUpdate: Date().timeIntervalSince1970,
            nutriscoreGrade: nil,
            nutrients: []
        )
        let model = FoodDetailViewModel(food: foodWithoutCalories)
        XCTAssertNil(model.caloriesText)
    }
}
