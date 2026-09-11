//
//  Router.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/11/2026.
//

import SwiftUI

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

@MainActor
protocol Coordinator: AnyObject {
    associatedtype Route: Hashable
    var router: Router<Route> { get }
}
