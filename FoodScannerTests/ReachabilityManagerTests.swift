//
//  ReachabilityManagerTests.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/03/2026.
//

import Combine
import CoreTelephony
import XCTest
@testable import FoodScanner

@MainActor
final class ReachabilityManagerTests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func test_changeOnlineMode_toOnline_publishesImmediately() {
        let sut = ReachabilityManager()

        sut.changeOnlineMode(.onlineSlow)

        XCTAssertEqual(sut.onlineMode, .onlineSlow)
    }

    func test_changeOnlineMode_toOnline_isPublishedToSubscribers() {
        let sut = ReachabilityManager()
        let expectation = expectation(description: "online is published")
        expectation.assertForOverFulfill = false

        sut.onlineModePublisher
            .sink { mode in
                if mode == .online { expectation.fulfill() }
            }
            .store(in: &cancellables)

        sut.changeOnlineMode(.online)

        wait(for: [expectation], timeout: 2)
    }

    func test_changeOnlineMode_toOffline_isDebouncedByConfiguredDelay() {
        let sut = ReachabilityManager(source: ReachabilitySourceFake(), changeOperatingModeDelay: 0.05)

        sut.changeOnlineMode(.offline)

        XCTAssertEqual(sut.onlineMode, .online)

        let expectation = expectation(description: "offline is published after the delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { expectation.fulfill() }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(sut.onlineMode, .offline)
    }

    func test_onlineSignalDuringDebounceWindow_cancelsPendingOffline() {
        let source = ReachabilitySourceFake()
        let sut = ReachabilityManager(source: source, changeOperatingModeDelay: 0.05)

        sut.changeOnlineMode(.offline)
        source.isReachable = true
        source.currentRadioAccessTechnologies = nil
        source.fireReachabilityDidChange()

        let expectation = expectation(description: "wait past the debounce window")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { expectation.fulfill() }
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(sut.onlineMode, .online)
    }

    func test_reachabilityChanged_withSlowRadioAccessTechnology_publishesOnlineSlow() {
        let source = ReachabilitySourceFake()
        source.isReachable = true
        source.currentRadioAccessTechnologies = ["a": CTRadioAccessTechnologyEdge]
        let sut = ReachabilityManager(source: source, changeOperatingModeDelay: 0.05)

        source.fireReachabilityDidChange()

        XCTAssertEqual(sut.onlineMode, .onlineSlow)
    }

    func test_reachabilityChanged_withNormalRadioAccessTechnology_publishesOnline() {
        let source = ReachabilitySourceFake()
        source.isReachable = true
        source.currentRadioAccessTechnologies = ["a": CTRadioAccessTechnologyLTE]
        let sut = ReachabilityManager(source: source, changeOperatingModeDelay: 0.05)

        source.fireReachabilityDidChange()

        XCTAssertEqual(sut.onlineMode, .online)
    }

    func test_reachabilityChanged_withEmptyRadioAccessTechnology_publishesOnline() {
        let source = ReachabilitySourceFake()
        source.isReachable = true
        source.currentRadioAccessTechnologies = [:]
        let sut = ReachabilityManager(source: source, changeOperatingModeDelay: 0.05)

        source.fireReachabilityDidChange()

        XCTAssertEqual(sut.onlineMode, .online)
    }

    func test_reachabilityChanged_withNilRadioAccessTechnology_publishesOnline() {
        let source = ReachabilitySourceFake()
        source.isReachable = true
        source.currentRadioAccessTechnologies = nil
        let sut = ReachabilityManager(source: source, changeOperatingModeDelay: 0.05)

        source.fireReachabilityDidChange()

        XCTAssertEqual(sut.onlineMode, .online)
    }

    func test_onlineModePublisher_emitsOnTheMainThread() {
        let sut = ReachabilityManager(source: ReachabilitySourceFake(), changeOperatingModeDelay: 0.05)
        let expectation = expectation(description: "publisher emits on the main thread")
        expectation.assertForOverFulfill = false

        sut.onlineModePublisher
            .dropFirst()
            .sink { _ in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.changeOnlineMode(.onlineSlow)

        wait(for: [expectation], timeout: 2)
    }
}
