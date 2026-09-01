import SwiftUI

/// Product card: the identity block of a scanned food item.
/// Only accepts primitives — no coupling to the app's Realm models.
///
/// Does no asynchronous work (no downloading, no caching):
/// `thumbnail` is an already resolved image, loaded and cached upstream
/// by the app (see `ImageCacheManager`). FoodScannerUI stays a pure
/// synchronous render, reusable independently of the loading/caching
/// strategy chosen on the app side.
public struct FSProductCard: View {
    private let name: String
    private let brand: String?
    private let quantity: String?
    private let score: FSNutriScore?
    private let thumbnail: Image?
    private let seasonalHint: String?

    @Environment(\.dynamicTypeSize) private var typeSize

    public init(name: String,
                brand: String? = nil,
                quantity: String? = nil,
                score: FSNutriScore? = nil,
                thumbnail: Image? = nil,
                seasonalHint: String? = nil) {
        self.name = name
        self.brand = brand
        self.quantity = quantity
        self.score = score
        self.thumbnail = thumbnail
        self.seasonalHint = seasonalHint
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: FSMetrics.space4) {
            HStack(alignment: .top, spacing: FSMetrics.space4) {
                thumbnailView
                VStack(alignment: .leading, spacing: FSMetrics.space1) {
                    if let brand {
                        Text(brand.uppercased())
                            .font(.fsOverline)
                            .tracking(1.4)
                            .foregroundStyle(Color.fsInkSecondary)
                    }
                    Text(name)
                        .font(.fsHeadline)
                        .foregroundStyle(Color.fsInk)
                        .fixedSize(horizontal: false, vertical: true)
                    if let quantity {
                        Text(quantity)
                            .font(.fsCaption)
                            .foregroundStyle(Color.fsInkSecondary)
                    }
                }
                Spacer(minLength: 0)
                if let score, typeSize < .accessibility1 {
                    FSScoreBadge(score, size: .medium)
                }
            }

            if let score, typeSize >= .accessibility1 {
                FSScoreBadge(score, size: .medium, showsMeaning: true)
            }

            if let seasonalHint {
                FSSeasonalHint(text: seasonalHint)
            }
        }
        .padding(FSMetrics.space5)
        .fsCard()
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder private var thumbnailView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: FSMetrics.radiusMedium, style: .continuous)
                .fill(Color.fsAccentSoft)
            if let thumbnail {
                thumbnail.resizable().scaledToFit()
            } else {
                Image(systemName: "shippingbox")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.fsInkSecondary)
            }
        }
        .frame(width: 76, height: 76)
        .accessibilityHidden(true)
    }
}

/// "In season" panel: a mascot and an educational sentence.
public struct FSSeasonalHint: View {
    private let text: String
    @FSResolvedSeason private var season

    public init(text: String) { self.text = text }

    public var body: some View {
        HStack(spacing: FSMetrics.space3) {
            FSMascot(season.mascots[0], size: 46)
            Text(text)
                .font(.fsCaption)
                .foregroundStyle(Color.fsInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(FSMetrics.space3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: FSMetrics.radiusMedium, style: .continuous)
                .fill(Color.fsAccentSoft)
        )
    }
}

/// Scan status banner, from the viewfinder to the result.
public struct FSScanStatusBanner: View {
    public enum State: Equatable {
        case aiming
        case reading
        case found(String)
        case notFound
        case offline

        var title: String {
            switch self {
            case .aiming: return "Cadrez le code-barres"
            case .reading: return "Lecture en cours…"
            case .found(let name): return name
            case .notFound: return "Produit introuvable"
            case .offline: return "Hors ligne"
            }
        }

        var detail: String {
            switch self {
            case .aiming: return "Approchez l'appareil à dix centimètres, la lumière aide."
            case .reading: return "On interroge Open Food Facts."
            case .found: return "Fiche prête, faites glisser pour voir les nutriments."
            case .notFound: return "Ce code n'existe pas encore dans la base. Vous pouvez l'ajouter."
            case .offline: return "Les douze dernières fiches restent consultables."
            }
        }

        var icon: String {
            switch self {
            case .aiming: return "viewfinder"
            case .reading: return "arrow.triangle.2.circlepath"
            case .found: return "checkmark.circle.fill"
            case .notFound: return "questionmark.circle.fill"
            case .offline: return "wifi.slash"
            }
        }
    }

    private let state: State

    public init(_ state: State) { self.state = state }

    public var body: some View {
        HStack(spacing: FSMetrics.space3) {
            Image(systemName: state.icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(state.title)
                    .font(.fsBodyStrong)
                    .foregroundStyle(Color.fsInk)
                Text(state.detail)
                    .font(.fsCaption)
                    .foregroundStyle(Color.fsInkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(FSMetrics.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: FSMetrics.radiusLarge, style: .continuous)
                .fill(Color.fsSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: FSMetrics.radiusLarge, style: .continuous)
                .strokeBorder(tint.opacity(0.4), lineWidth: FSMetrics.borderWidthStrong)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(state.title). \(state.detail)")
        .onChange(of: state) { newValue in
            FSAnnounce.say("\(newValue.title). \(newValue.detail)")
            switch newValue {
            case .found: FSHaptics.play(.scanSuccess)
            case .notFound: FSHaptics.play(.scanFailure)
            case .offline: FSHaptics.play(.warning)
            default: break
            }
        }
    }

    private var tint: Color {
        switch state {
        case .aiming, .reading: return .fsInkSecondary
        case .found: return .fsLeaf
        case .notFound, .offline: return .fsAccent
        }
    }
}

/// History row: already viewed product, with its score and recency.
public struct FSHistoryRow: View {
    private let name: String
    private let subtitle: String
    private let score: FSNutriScore?
    private let isCached: Bool
    private let action: () -> Void

    public init(name: String,
                subtitle: String,
                score: FSNutriScore? = nil,
                isCached: Bool = false,
                action: @escaping () -> Void) {
        self.name = name
        self.subtitle = subtitle
        self.score = score
        self.isCached = isCached
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: FSMetrics.space4) {
                if let score {
                    FSScoreBadge(score, size: .small)
                } else {
                    Image(systemName: "questionmark")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.fsInkSecondary)
                        .frame(width: 36, height: 36)
                        .background(RoundedRectangle(cornerRadius: 9).fill(Color.fsAccentSoft))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.fsBodyStrong)
                        .foregroundStyle(Color.fsInk)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: FSMetrics.space1) {
                        if isCached {
                            Image(systemName: "arrow.down.circle")
                                .imageScale(.small)
                                .foregroundStyle(Color.fsInkSecondary)
                        }
                        Text(subtitle)
                            .font(.fsCaption)
                            .foregroundStyle(Color.fsInkSecondary)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.fsInkSecondary)
                    .accessibilityHidden(true)
            }
            .padding(FSMetrics.space4)
            .frame(minHeight: FSMetrics.minTouchTarget)
            .fsCard(radius: FSMetrics.radiusMedium)
        }
        .buttonStyle(FSPressStyle())
        .accessibilityLabel(name)
        .accessibilityValue(score.map { "Nutri-Score \($0.rawValue). \(subtitle)" } ?? subtitle)
        .accessibilityHint("Ouvre la fiche du produit")
    }
}

/// Offline banner, to place at the top of a list.
public struct FSOfflineBanner: View {
    private let text: String

    public init(text: String = "Vous êtes hors ligne. Les fiches déjà consultées restent lisibles.") {
        self.text = text
    }

    public var body: some View {
        HStack(spacing: FSMetrics.space3) {
            Image(systemName: "wifi.slash").foregroundStyle(Color.fsAccent).accessibilityHidden(true)
            Text(text)
                .font(.fsCaption)
                .foregroundStyle(Color.fsInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(FSMetrics.space3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: FSMetrics.radiusMedium, style: .continuous)
                .fill(Color.fsAccent.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: FSMetrics.radiusMedium, style: .continuous)
                .strokeBorder(Color.fsAccent.opacity(0.4), lineWidth: 1.5)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}
