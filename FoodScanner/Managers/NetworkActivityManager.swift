//
//  NetworkActivityManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//
//  Compteur de requêtes en vol exposé via `@Published var isActive`, confiné
//  au main actor : consommable directement par une vue SwiftUI
//  (@ObservedObject) sans passer par un indicateur UIKit global.
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
