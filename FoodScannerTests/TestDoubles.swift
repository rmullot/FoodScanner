//
//  TestDoubles.swift
//  FoodScannerTests
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/03/2026.
//

import Combine
import UIKit
@testable import FoodScanner

final class CacheManagerFake: CacheProviding, @unchecked Sendable {
    private(set) var storage: [String: FoodStruct] = [:]
    private(set) var updatedFoods: [FoodStruct] = []
    private(set) var summariesCallCount = 0
    var summariesToReturn: [FoodSummary] = []

    init(initial: [FoodStruct] = []) {
        for food in initial {
            storage[food.barcode] = food
        }
    }

    func food(barcode: String) async -> FoodStruct? {
        storage[barcode]
    }

    func updateFood(_ foodStruct: FoodStruct) async {
        updatedFoods.append(foodStruct)
        storage[foodStruct.barcode] = foodStruct
    }

    func allFoodSummaries() async -> [FoodSummary] {
        summariesCallCount += 1
        return summariesToReturn
    }
}

final class WebServiceStub: WebServiceProviding, @unchecked Sendable {
    var result: Result<FoodStruct, Error> = .failure(WebServiceError.notInCache)
    private(set) var requestedBarcodes: [String] = []
    private(set) var cancelCallCount = 0

    func getFoodDescription(barcode: String) async throws -> FoodStruct {
        requestedBarcodes.append(barcode)
        return try result.get()
    }

    func cancelRequests() {
        cancelCallCount += 1
    }
}

final class ReachabilityFake: ReachabilityProviding {
    private let subject: CurrentValueSubject<OnlineMode, Never>

    init(mode: OnlineMode = .online) {
        subject = CurrentValueSubject(mode)
    }

    var onlineMode: OnlineMode { subject.value }

    var onlineModePublisher: AnyPublisher<OnlineMode, Never> {
        subject.eraseToAnyPublisher()
    }

    func send(_ mode: OnlineMode) {
        subject.send(mode)
    }
}

@MainActor
final class NetworkActivitySpy: NetworkActivityTracking {
    private let isActiveSubject = CurrentValueSubject<Bool, Never>(false)
    var isActivePublisher: AnyPublisher<Bool, Never> { isActiveSubject.eraseToAnyPublisher() }
    private(set) var isActive: Bool = false {
        didSet { isActiveSubject.send(isActive) }
    }
    private(set) var startCount = 0
    private(set) var finishCount = 0
    private(set) var disableCount = 0

    @discardableResult
    func newRequestStarted() -> Int {
        startCount += 1
        isActive = true
        return startCount
    }

    @discardableResult
    func requestFinished() -> Int {
        finishCount += 1
        if finishCount >= startCount {
            isActive = false
        }
        return max(0, startCount - finishCount)
    }

    func disableActivityIndicator() {
        disableCount += 1
        isActive = false
    }
}

final class ReachabilitySourceFake: ReachabilitySource {
    var isReachable: Bool = true
    var currentRadioAccessTechnologies: [String: String]?
    var reachabilityDidChange: (() -> Void)?
    private(set) var startCallCount = 0

    func start() {
        startCallCount += 1
    }

    func fireReachabilityDidChange() {
        reachabilityDidChange?()
    }
}

final class AlertPresenterSpy: AlertPresenting {
    private(set) var invocations: [(title: String, message: String, style: UIAlertController.Style)] = []

    func present(title: String, message: String, style: UIAlertController.Style) {
        invocations.append((title, message, style))
    }
}

@MainActor
final class SystemAccessibilityFake: SystemAccessibilityProviding {
    var isReduceMotionEnabled: Bool
    var isIncreasedContrastEnabled: Bool
    var preferredContentSizeCategory: UIContentSizeCategory

    private let subject = PassthroughSubject<Void, Never>()

    var changesPublisher: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(reduceMotion: Bool = false,
         increasedContrast: Bool = false,
         contentSizeCategory: UIContentSizeCategory = .large) {
        self.isReduceMotionEnabled = reduceMotion
        self.isIncreasedContrastEnabled = increasedContrast
        self.preferredContentSizeCategory = contentSizeCategory
    }

    func emitChange() {
        subject.send(())
    }
}

final class ImageCacheStub: ImageCaching, @unchecked Sendable {
    var imageToReturn: UIImage?
    private(set) var requestedURLs: [String] = []

    init(imageToReturn: UIImage? = nil) {
        self.imageToReturn = imageToReturn
    }

    func image(for urlString: String) async -> UIImage? {
        requestedURLs.append(urlString)
        return imageToReturn
    }
}
