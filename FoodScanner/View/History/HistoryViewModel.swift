//
//  HistoryViewModel.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//

import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var items: [FoodSummary] = []
    @Published private(set) var isOffline: Bool = false

    private let foodStore: FoodStoring
    private let reachability: ReachabilityProviding
    private var reachabilityCancellable: AnyCancellable?

    init(foodStore: FoodStoring? = nil,
         reachability: ReachabilityProviding? = nil) {
        self.foodStore = foodStore ?? InjectionManager.shared.foodStore
        self.reachability = reachability ?? InjectionManager.shared.reachability
        isOffline = self.reachability.onlineMode == .offline
        reachabilityCancellable = self.reachability.onlineModePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] onlineMode in
                self?.isOffline = onlineMode == .offline
            }
    }

    func load() async {
        items = await foodStore.allFoodSummaries()
    }
}
