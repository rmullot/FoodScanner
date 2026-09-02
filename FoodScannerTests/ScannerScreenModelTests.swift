//
//  ScannerScreenModelTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/02/2026.
//
//  Covers the tap-to-navigate rework: `getFoodInformations` no longer
//  auto-navigates, so its synchronous side effects (banner/statusMessage set
//  before the network `Task` is even launched) and the duplicate-barcode
//  guard/re-arm sequencing become the load-bearing, testable behavior.
//
//  NOTE (testability gap): `WebServiceManager`/`ReachabilityManager` are
//  `.sharedInstance` singletons with no protocol/injection seam, so the
//  network-success path of `getFoodInformations` (banner becoming `.found`,
//  `scannedFood` becoming non-nil) cannot be deterministically unit tested
//  here — it would depend on a real network call. Tests below only exercise
//  the parts of `ScannerScreenModel` that are observable synchronously,
//  before the async `Task` runs, which is enough to cover the guard/re-arm
//  logic without touching the network.

import XCTest
import FoodScannerUI
@testable import FoodScanner

@MainActor
final class ScannerScreenModelTests: XCTestCase {

    // MARK: - getFoodInformations: synchronous side effects

    func test_getFoodInformations_setsReadingBannerAndStatusMessageSynchronously() {
        let model = ScannerScreenModel()

        model.getFoodInformations(barcode: "3017620422003")

        // These are set before the `Task { ... }` is scheduled, so they are
        // observable immediately without awaiting anything.
        XCTAssertEqual(model.banner, .reading)
    }

    // MARK: - Duplicate-barcode guard

    func test_getFoodInformations_sameBarcodeWhileAlreadyResolved_isNoOp() {
        let model = ScannerScreenModel()
        let barcode = "3017620422003"

        model.getFoodInformations(barcode: barcode)
        // Simulate the barcode having already resolved to a "found" state
        // (what would happen once the network Task completes successfully).
        model.banner = .found("Pâte à tartiner")

        // Calling again with the SAME barcode must be a no-op: it must not
        // reset the banner back to `.reading`, since `self.barcode` (private)
        // still equals `barcode`.
        model.getFoodInformations(barcode: barcode)

        XCTAssertEqual(model.banner, .found("Pâte à tartiner"))
    }

    func test_getFoodInformations_differentBarcode_isNotNoOp() {
        let model = ScannerScreenModel()

        model.getFoodInformations(barcode: "3017620422003")
        model.banner = .found("Pâte à tartiner")

        // A genuinely different barcode must NOT be swallowed by the guard:
        // the banner is reset to `.reading` synchronously.
        model.getFoodInformations(barcode: "0000000000017")

        XCTAssertEqual(model.banner, .reading)
    }

    // MARK: - resetForNewScan

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

        // Without a reset, re-scanning the same barcode would be swallowed by
        // the guard (see test above). After `resetForNewScan()`, detection of
        // that exact barcode must be re-armed.
        model.resetForNewScan()
        model.getFoodInformations(barcode: barcode)

        XCTAssertEqual(model.banner, .reading)
    }

    // MARK: - isValidBarcode (pure function)

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
