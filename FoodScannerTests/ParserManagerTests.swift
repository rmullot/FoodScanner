//
//  ParserManagerTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/03/2026.
//

import XCTest
@testable import FoodScanner

final class ParserManagerTests: XCTestCase {

    private func json(status: Int) -> Data {
        Data("""
        {
          "code": "3017620422003",
          "status_verbose": "product found",
          "status": \(status),
          "product": {
            "code": "3017620422003",
            "image_small_url": "https://img.example/nutella.jpg",
            "product_name": "Nutella",
            "last_modified_t": 1600000000,
            "nutriscore_grade": "e",
            "nutriments": {
              "carbohydrates_100g": 57.5,
              "proteins_100g": 6.3,
              "fat_100g": 30.9,
              "fiber_100g": 0,
              "salt_100g": "0.107",
              "saturated-fat_100g": 10.6,
              "sugars_100g": 56.3,
              "energy-kcal_100g": 539
            }
          }
        }
        """.utf8)
    }

    func test_parseFood_whenStatusIsOne_returnsDecodedProduct() throws {
        let food = try ParserManager.parseFood(from: json(status: 1))

        XCTAssertEqual(food.barcode, "3017620422003")
        XCTAssertEqual(food.name, "Nutella")
        XCTAssertEqual(food.nutriscoreGrade, "e")
        XCTAssertEqual(food.lastUpdate, 1600000000)
    }

    func test_parseFood_keepsOnlyNutrientsWithPositiveQuantity() throws {
        let food = try ParserManager.parseFood(from: json(status: 1))

        XCTAssertFalse(food.nutrients.contains { $0.quantity <= 0 })
        XCTAssertTrue(food.nutrients.contains { $0.name == MainNutrientName.carbohydrates.rawValue })
        XCTAssertFalse(food.nutrients.contains { $0.name == MainNutrientName.fibers.rawValue })
    }

    func test_parseFood_decodesStringEncodedNumericNutriment() throws {
        let food = try ParserManager.parseFood(from: json(status: 1))

        let salt = food.nutrients.first { $0.name == MainNutrientName.salt.rawValue }
        XCTAssertEqual(salt?.quantity, 0.107)
    }

    func test_parseFood_whenStatusIsZero_throwsFoodNotFound() {
        XCTAssertThrowsError(try ParserManager.parseFood(from: json(status: 0))) { error in
            XCTAssertEqual(error as? ParserError, .foodNotFoundError)
        }
    }

    func test_parseFood_whenPayloadIsNotJSON_throwsDecodeObject() {
        let garbage = Data("not json".utf8)

        XCTAssertThrowsError(try ParserManager.parseFood(from: garbage)) { error in
            XCTAssertEqual(error as? ParserError, .decodeObject)
        }
    }

    func test_parseFood_whenRequiredKeyMissing_throwsDecodeObject() {
        let missingProduct = Data(#"{"code":"1","status_verbose":"x","status":1}"#.utf8)

        XCTAssertThrowsError(try ParserManager.parseFood(from: missingProduct)) { error in
            XCTAssertEqual(error as? ParserError, .decodeObject)
        }
    }
}
