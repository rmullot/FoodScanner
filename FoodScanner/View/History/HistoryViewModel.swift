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

    private let cacheManager: CacheProviding
    private let reachability: ReachabilityProviding
    private var reachabilityCancellable: AnyCancellable?

    init(cacheManager: CacheProviding? = nil,
         reachability: ReachabilityProviding? = nil) {
        self.cacheManager = cacheManager ?? InjectionManager.shared.cacheManager
        self.reachability = reachability ?? InjectionManager.shared.reachability
        isOffline = self.reachability.onlineMode == .offline
        reachabilityCancellable = self.reachability.onlineModePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] onlineMode in
                self?.isOffline = onlineMode == .offline
            }
    }

    func load() async {
        items = await cacheManager.allFoodSummaries()
    }
}
