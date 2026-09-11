//
//  Router.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/11/2026.
//

import SwiftUI

/// Owns a typed navigation stack for one flow. A `Coordinator` mutates it in
/// response to navigation intents; the flow's container view binds a
/// `NavigationStack` to `path`. Views never see this type.
@MainActor
final class Router<Route: Hashable>: ObservableObject {
    @Published var path: [Route] = []

    var isAtRoot: Bool { path.isEmpty }

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}

/// A coordinator translates a flow's navigation intents into `Router` mutations
/// and builds the destination screens with their dependencies. It holds no
/// business logic and is invisible to the views it drives.
@MainActor
protocol Coordinator: AnyObject {
    associatedtype Route: Hashable
    var router: Router<Route> { get }
}
