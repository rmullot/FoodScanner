//
//  ScannerCoordinator.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/11/2026.
//

import Combine
import SwiftUI

enum ScannerRoute: Hashable {
    case productDetail(FoodStruct)
}

@MainActor
final class ScannerCoordinator: Coordinator, ObservableObject {
    let router: Router<ScannerRoute>
    let scannerViewModel: ScannerViewModel

    private var routerCancellable: AnyCancellable?

    convenience init() {
        self.init(router: Router<ScannerRoute>(), scannerViewModel: ScannerViewModel())
    }

    init(router: Router<ScannerRoute>, scannerViewModel: ScannerViewModel) {
        self.router = router
        self.scannerViewModel = scannerViewModel
        routerCancellable = router.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }

    func showProductDetail(for food: FoodStruct) {
        router.push(.productDetail(food))
        scannerViewModel.consumeScannedFood()
    }

    @ViewBuilder
    func destination(for route: ScannerRoute) -> some View {
        switch route {
        case .productDetail(let food):
            ProductDetailScreenView(model: FoodDetailViewModel(food: food))
        }
    }
}

struct ScannerCoordinatorView: View {
    @StateObject private var coordinator = ScannerCoordinator()

    init() {}

    init(coordinator: ScannerCoordinator) {
        _coordinator = StateObject(wrappedValue: coordinator)
    }

    var body: some View {
        NavigationStack(path: Binding(
            get: { coordinator.router.path },
            set: { coordinator.router.path = $0 }
        )) {
            ScannerScreenView(model: coordinator.scannerViewModel,
                              onProductFound: coordinator.showProductDetail(for:))
                .navigationDestination(for: ScannerRoute.self) { route in
                    coordinator.destination(for: route)
                }
        }
        .onChange(of: coordinator.router.path) { _, newPath in
            if newPath.isEmpty {
                coordinator.scannerViewModel.resetForNewScan()
            }
        }
    }
}
