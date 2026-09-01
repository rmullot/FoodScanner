//
//  HistoryScreenModel.swift
//  FoodScanner
//
//  ObservableObject exposant les produits déjà consultés (FoodSummary,
//  Sendable) : lecture cache via RealmManager, jamais d'objet Realm managé.
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
