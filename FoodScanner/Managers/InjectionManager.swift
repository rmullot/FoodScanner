//
//  InjectionManager.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/03/2026.
//

import Foundation
import Combine
import UIKit

protocol FoodStoring: AnyObject, Sendable {
    func food(barcode: String) async -> FoodStruct?
    func updateFood(_ foodStruct: FoodStruct) async
    func allFoodSummaries() async -> [FoodSummary]
}

protocol WebServiceProviding: AnyObject, Sendable {
    func getFoodDescription(barcode: String) async throws -> FoodStruct
    func cancelRequests()
}

protocol ReachabilityProviding: AnyObject {
    var onlineMode: OnlineMode { get }
    var onlineModePublisher: AnyPublisher<OnlineMode, Never> { get }
}

@MainActor
protocol NetworkActivityTracking: AnyObject, Sendable {
    var isActive: Bool { get }
    @discardableResult func newRequestStarted() -> Int
    @discardableResult func requestFinished() -> Int
    func disableActivityIndicator()
}

protocol ImageCaching: AnyObject, Sendable {
    func image(for urlString: String) async -> UIImage?
}

@MainActor
final class InjectionManager {
    static let shared = InjectionManager()

    let reachability: ReachabilityProviding
    let networkActivity: NetworkActivityManager
    let foodStore: FoodStoring
    let imageCache: ImageCaching
    let webService: WebServiceProviding

    private init() {
        let networkActivity = NetworkActivityManager()
        let foodStore = RealmManager()

        self.networkActivity = networkActivity
        self.reachability = ReachabilityManager()
        self.foodStore = foodStore
        self.imageCache = ImageCacheManager(networkActivity: networkActivity)
        self.webService = WebServiceManager(foodStore: foodStore, networkActivity: networkActivity)
    }
}
