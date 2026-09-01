//
//  NetworkActivityManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//
//  In-flight request counter exposed via `@Published var isActive`, confined
//  to the main actor: directly consumable by a SwiftUI view (@ObservedObject)
//  without going through a global UIKit indicator.
//

import Foundation

@MainActor
public final class NetworkActivityManager: ObservableObject {
    static let sharedInstance = NetworkActivityManager()

    @Published private(set) var isActive: Bool = false

    private var countRequest: Int = 0

    private let maxActivityDuration: Double = 120 //in seconds

    private var disableActivityIndicatorClosure: DispatchQueue.CancellableClosure = nil

    private init() {}

    @discardableResult
    func newRequestStarted() -> Int {
        countRequest += 1
        isActive = true

        disableActivityIndicatorClosure?()
        disableActivityIndicatorClosure = DispatchQueue.main.cancellableAsyncAfter(secondsDeadline: maxActivityDuration) { [weak self] in
            self?.disableActivityIndicator()
        }

        return countRequest
    }

    @discardableResult
    func requestFinished() -> Int {
        countRequest = max(0, countRequest - 1)

        if countRequest <= 0 {
            disableActivityIndicatorClosure?()
            disableActivityIndicatorClosure = nil
            countRequest = 0
            isActive = false
        }

        return countRequest
    }

    func disableActivityIndicator() {
        disableActivityIndicatorClosure?()
        disableActivityIndicatorClosure = nil
        countRequest = 0
        isActive = false
    }
}
