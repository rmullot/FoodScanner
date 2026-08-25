import SwiftUI

/// Les deux palettes saisonnières de la charte FoodScanner.
///
/// Par défaut la saison suit le `ColorScheme` (clair → printemps-été,
/// sombre → automne-hiver). Elle peut être forcée par date réelle ou
/// injectée explicitement dans un sous-arbre.
public enum FSSeason: String, CaseIterable, Sendable {
    case springSummer
    case autumnWinter

    public var frenchName: String {
        switch self {
        case .springSummer: return "Printemps-été"
        case .autumnWinter: return "Automne-hiver"
        }
    }

    /// Saison déduite du mois courant (mars→août : printemps-été).
    public static func current(_ date: Date = Date(), calendar: Calendar = .current) -> FSSeason {
        let month = calendar.component(.month, from: date)
        return (3...8).contains(month) ? .springSummer : .autumnWinter
    }

    public static func matching(_ scheme: ColorScheme) -> FSSeason {
        scheme == .dark ? .autumnWinter : .springSummer
    }

    /// Les trois aliments-mascottes de la saison.
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
    /// Saison forcée pour ce sous-arbre. `nil` = suit le thème.
    var fsSeasonOverride: FSSeason? {
        get { self[FSSeasonKey.self] }
        set { self[FSSeasonKey.self] = newValue }
    }
}

public extension View {
    /// Force une saison sur ce sous-arbre.
    func fsSeason(_ season: FSSeason?) -> some View {
        environment(\.fsSeasonOverride, season)
    }

    /// Fait suivre la saison au calendrier réel plutôt qu'au thème.
    func fsSeasonFollowsCalendar(_ date: Date = Date()) -> some View {
        environment(\.fsSeasonOverride, FSSeason.current(date))
    }
}

/// Lit la saison effective : surcharge d'environnement, sinon le thème.
@propertyWrapper
public struct FSResolvedSeason: DynamicProperty {
    @Environment(\.fsSeasonOverride) private var override
    @Environment(\.colorScheme) private var scheme

    public init() {}

    public var wrappedValue: FSSeason {
        override ?? .matching(scheme)
    }
}
