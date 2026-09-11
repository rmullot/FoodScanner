//
//  ErrorManagerTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/04/2026.
//

import UIKit
import XCTest
@testable import FoodScanner

final class ErrorManagerTests: XCTestCase {

    func test_showAlertWith_forwardsTitleMessageAndStyleToPresenter() {
        let spy = AlertPresenterSpy()
        let sut = ErrorManager(presenter: spy)

        sut.showAlertWith(title: "Titre", message: "Message", style: .actionSheet)

        XCTAssertEqual(spy.invocations.count, 1)
        XCTAssertEqual(spy.invocations.first?.title, "Titre")
        XCTAssertEqual(spy.invocations.first?.message, "Message")
        XCTAssertEqual(spy.invocations.first?.style, .actionSheet)
    }

    func test_showAlertWith_usesAlertStyleByDefault() {
        let spy = AlertPresenterSpy()
        let sut = ErrorManager(presenter: spy)

        sut.showAlertWith(title: "T", message: "M")

        XCTAssertEqual(spy.invocations.first?.style, .alert)
    }
}
