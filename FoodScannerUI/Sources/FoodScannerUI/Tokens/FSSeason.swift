//
//  FSSeason.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import SwiftUI

/// The two seasonal palettes of the FoodScanner design system.
///
/// By default the season follows the `ColorScheme` (light → spring-summer,
/// dark → autumn-winter). It can be forced by real date or explicitly
/// injected in a subtree.
public enum FSSeason: String, CaseIterable, Sendable {
    case springSummer
    case autumnWinter

    public var frenchName: String {
        switch self {
        case .springSummer: return "Printemps-été"
        case .autumnWinter: return "Automne-hiver"
        }
    }

    /// Season inferred from the current month (March→August: spring-summer).
    public static func current(_ date: Date = Date(), calendar: Calendar = .current) -> FSSeason {
        let month = calendar.component(.month, from: date)
        return (3...8).contains(month) ? .springSummer : .autumnWinter
    }

    public static func matching(_ scheme: ColorScheme) -> FSSeason {
        scheme == .dark ? .autumnWinter : .springSummer
    }

    /// The season's three food mascots.
    public var mascots: [FSMascot.Kind] {
        switch self {
        case .springSummer: return [.strawberry, .pea, .lemon]
        case .autumnWinter: return [.squash, .chestnut, .cabbage]
        }
    }
}

// MARK: - Environment

private struct FSSeasonKey: EnvironmentKey {
    static let defaultValue: FSSeason? = nil
}

public extension EnvironmentValues {
    /// Season forced for this subtree. `nil` = follows the theme.
    var fsSeasonOverride: FSSeason? {
        get { self[FSSeasonKey.self] }
        set { self[FSSeasonKey.self] = newValue }
    }
}

public extension View {
    /// Forces a season on this subtree.
    func fsSeason(_ season: FSSeason?) -> some View {
        environment(\.fsSeasonOverride, season)
    }

    /// Makes the season follow the real calendar rather than the theme.
    func fsSeasonFollowsCalendar(_ date: Date = Date()) -> some View {
        environment(\.fsSeasonOverride, FSSeason.current(date))
    }
}

/// Reads the effective season: environment override, otherwise the theme.
@propertyWrapper
public struct FSResolvedSeason: DynamicProperty {
    @Environment(\.fsSeasonOverride) private var override
    @Environment(\.colorScheme) private var scheme

    public init() {}

    public var wrappedValue: FSSeason {
        override ?? .matching(scheme)
    }
}
