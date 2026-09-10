//
//  NetworkActivityManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation

@MainActor
public final class NetworkActivityManager: ObservableObject, NetworkActivityTracking {

    @Published private(set) var isActive: Bool = false

    private var countRequest: Int = 0

    private let maxActivityDuration: Double = 120

    private var disableActivityIndicatorTask: Task<Void, Never>?

    init() {}

    @discardableResult
    func newRequestStarted() -> Int {
        countRequest += 1
        isActive = true

        disableActivityIndicatorTask?.cancel()
        let maxDuration = maxActivityDuration
        disableActivityIndicatorTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(maxDuration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.disableActivityIndicator()
        }

        return countRequest
    }

    @discardableResult
    func requestFinished() -> Int {
        countRequest = max(0, countRequest - 1)

        if countRequest <= 0 {
            disableActivityIndicatorTask?.cancel()
            disableActivityIndicatorTask = nil
            countRequest = 0
            isActive = false
        }

        return countRequest
    }

    func disableActivityIndicator() {
        disableActivityIndicatorTask?.cancel()
        disableActivityIndicatorTask = nil
        countRequest = 0
        isActive = false
    }
}
