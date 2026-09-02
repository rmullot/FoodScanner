//
//  ScannerScreenModelTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/02/2026.
//

import XCTest
import FoodScannerUI
@testable import FoodScanner

@MainActor
final class ScannerScreenModelTests: XCTestCase {

    func test_getFoodInformations_setsReadingBannerAndStatusMessageSynchronously() {
        let model = ScannerScreenModel()

        model.getFoodInformations(barcode: "3017620422003")

        XCTAssertEqual(model.banner, .reading)
    }

    func test_getFoodInformations_sameBarcodeWhileAlreadyResolved_isNoOp() {
        let model = ScannerScreenModel()
        let barcode = "3017620422003"

        model.getFoodInformations(barcode: barcode)
        model.banner = .found("Pâte à tartiner")

        model.getFoodInformations(barcode: barcode)

        XCTAssertEqual(model.banner, .found("Pâte à tartiner"))
    }

    func test_getFoodInformations_differentBarcode_isNotNoOp() {
        let model = ScannerScreenModel()

        model.getFoodInformations(barcode: "3017620422003")
        model.banner = .found("Pâte à tartiner")

        model.getFoodInformations(barcode: "0000000000017")

        XCTAssertEqual(model.banner, .reading)
    }

    func test_resetForNewScan_clearsBanner() {
        let model = ScannerScreenModel()
        model.getFoodInformations(barcode: "3017620422003")
        model.banner = .found("Pâte à tartiner")

        model.resetForNewScan()

        XCTAssertNil(model.banner)
    }

    func test_resetForNewScan_reArmsDetectionForThePreviouslyResolvedBarcode() {
        let model = ScannerScreenModel()
        let barcode = "3017620422003"

        model.getFoodInformations(barcode: barcode)
        model.banner = .found("Pâte à tartiner")

        model.resetForNewScan()
        model.getFoodInformations(barcode: barcode)

        XCTAssertEqual(model.banner, .reading)
    }

    func test_isValidBarcode_emptyString_isValid() {
        let model = ScannerScreenModel()
        XCTAssertTrue(model.isValidBarcode(""))
    }

    func test_isValidBarcode_digitsOnly_isValid() {
        let model = ScannerScreenModel()
        XCTAssertTrue(model.isValidBarcode("3017620422003"))
    }

    func test_isValidBarcode_containingLetters_isInvalid() {
        let model = ScannerScreenModel()
        XCTAssertFalse(model.isValidBarcode("30176A0422003"))
    }
}
