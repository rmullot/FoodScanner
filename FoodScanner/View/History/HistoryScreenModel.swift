//
//  HistoryScreenModel.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//  ObservableObject exposing already viewed products (FoodSummary,
//  Sendable): cache read via RealmManager, never a managed Realm object.
//

import Foundation
import Combine

@MainActor
final class HistoryScreenModel: ObservableObject {
    @Published private(set) var items: [FoodSummary] = []
    @Published private(set) var isOffline: Bool = false

    private var reachabilityCancellable: AnyCancellable?

    init() {
        isOffline = ReachabilityManager.sharedInstance.onlineMode == .offline
        reachabilityCancellable = ReachabilityManager.sharedInstance.$onlineMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] onlineMode in
                self?.isOffline = onlineMode == .offline
            }
    }

    func load() async {
        items = await RealmManager.sharedInstance.allFoodSummaries()
    }
}
