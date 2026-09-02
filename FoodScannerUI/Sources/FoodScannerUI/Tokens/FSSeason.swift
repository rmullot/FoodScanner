//
//  FSSeason.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import SwiftUI

public enum FSSeason: String, CaseIterable, Sendable {
    case springSummer
    case autumnWinter

    public var frenchName: String {
        switch self {
        case .springSummer: return FSL10n.Season.Name.springSummer
        case .autumnWinter: return FSL10n.Season.Name.autumnWinter
        }
    }

    public static func current(_ date: Date = Date(), calendar: Calendar = .current) -> FSSeason {
        let month = calendar.component(.month, from: date)
        return (3...8).contains(month) ? .springSummer : .autumnWinter
    }

    public static func matching(_ scheme: ColorScheme) -> FSSeason {
        scheme == .dark ? .autumnWinter : .springSummer
    }

    public var mascots: [FSMascot.Kind] {
        switch self {
        case .springSummer: return [.strawberry, .pea, .lemon]
        case .autumnWinter: return [.squash, .chestnut, .cabbage]
        }
    }
}

private struct FSSeasonKey: EnvironmentKey {
    static let defaultValue: FSSeason? = nil
}

public extension EnvironmentValues {
    var fsSeasonOverride: FSSeason? {
        get { self[FSSeasonKey.self] }
        set { self[FSSeasonKey.self] = newValue }
    }
}

public extension View {
    func fsSeason(_ season: FSSeason?) -> some View {
        environment(\.fsSeasonOverride, season)
    }

    func fsSeasonFollowsCalendar(_ date: Date = Date()) -> some View {
        environment(\.fsSeasonOverride, FSSeason.current(date))
    }
}

@propertyWrapper
public struct FSResolvedSeason: DynamicProperty {
    @Environment(\.fsSeasonOverride) private var override
    @Environment(\.colorScheme) private var scheme

    public init() {}

    public var wrappedValue: FSSeason {
        override ?? .matching(scheme)
    }
}
