//
//  FoodDetailModelTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/02/2026.
//
//  Covers the computed properties `ProductDetailScreenView` (the merged
//  product+nutrients screen) reads from `FoodDetailModel`: since the screen
//  now shows the score badge, calories text, AND the nutrient bars in one
//  place (no more intermediate "Voir les nutriments" step), all three must
//  be simultaneously available from a single `FoodStruct`.

import XCTest
import FoodScannerUI
@testable import FoodScanner

@MainActor
final class FoodDetailModelTests: XCTestCase {

    func test_name_reflectsFoodName() {
        let model = FoodDetailModel(food: .previewFixture)
        XCTAssertEqual(model.name, "Pâte à tartiner noisettes et cacao")
    }

    func test_name_isEmptyWhenFoodIsNil() {
        let model = FoodDetailModel(food: nil)
        XCTAssertEqual(model.name, "")
    }

    func test_nutriScore_decodedFromNutriscoreGrade() {
        let model = FoodDetailModel(food: .previewFixture)
        XCTAssertEqual(model.nutriScore, FSNutriScore(letter: "e"))
    }

    func test_nutrientBars_containsOnlyMainNutrientsWithAnFSNutrientEquivalent() {
        let model = FoodDetailModel(food: .previewFixture)

        // previewFixture has 5 main nutrients (carbs/proteins/fats/fibers/salt),
        // one sub-nutrient ("Sucres", no FSNutrient case), and one calories entry.
        // Only the 5 main nutrients should surface as bars.
        XCTAssertEqual(model.nutrientBars.count, 5)
        let kinds = Set(model.nutrientBars.map(\.0))
        XCTAssertEqual(kinds, [.carbs, .protein, .fat, .fiber, .salt])
    }

    func test_caloriesText_formatsTheCaloriesNutrient() {
        let model = FoodDetailModel(food: .previewFixture)
        XCTAssertEqual(model.caloriesText, L10n.Nutrients.caloriesFormat(539))
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
        let model = FoodDetailModel(food: foodWithoutCalories)
        XCTAssertNil(model.caloriesText)
    }
}
