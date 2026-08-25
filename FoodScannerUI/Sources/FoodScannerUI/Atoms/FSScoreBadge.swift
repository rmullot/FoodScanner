import SwiftUI

/// Le Nutri-Score. Les aplats sont ceux de la charte officielle et ne
/// changent pas avec le thème ; seul l'entourage suit la saison.
public enum FSNutriScore: String, CaseIterable, Identifiable, Sendable {
    case a = "A", b = "B", c = "C", d = "D", e = "E"

    public var id: String { rawValue }

    public var color: Color {
        switch self {
        case .a: return .fsScoreA
        case .b: return .fsScoreB
        case .c: return .fsScoreC
        case .d: return .fsScoreD
        case .e: return .fsScoreE
        }
    }

    /// Blanc partout sauf sur le jaune C, où le noir est requis pour le contraste.
    public var letterColor: Color {
        self == .c ? Color(hex: 0x1D1D1B) : .white
    }

    public var frenchMeaning: String {
        switch self {
        case .a: return "Très bonne qualité nutritionnelle"
        case .b: return "Bonne qualité nutritionnelle"
        case .c: return "Qualité nutritionnelle moyenne"
        case .d: return "Qualité nutritionnelle faible"
        case .e: return "Qualité nutritionnelle très faible"
        }
    }

    public init?(letter: String) {
        self.init(rawValue: letter.uppercased())
    }
}

/// Badge unitaire : la lettre sur son aplat officiel.
public struct FSScoreBadge: View {
    public enum Size { case small, medium, large

        var side: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 52
            case .large: return 76
            }
        }

        var font: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 28
            case .large: return 42
            }
        }
    }

    private let score: FSNutriScore
    private let size: Size
    private let showsMeaning: Bool

    public init(_ score: FSNutriScore, size: Size = .medium, showsMeaning: Bool = false) {
        self.score = score
        self.size = size
        self.showsMeaning = showsMeaning
    }

    public var body: some View {
        HStack(spacing: FSMetrics.space3) {
            Text(score.rawValue)
                .font(.fsHeading(size.font, relativeTo: .title))
                .foregroundStyle(score.letterColor)
                .frame(width: size.side, height: size.side)
                .background(
                    RoundedRectangle(cornerRadius: size.side * 0.24, style: .continuous)
                        .fill(score.color)
                )
                .accessibilityHidden(true)

            if showsMeaning {
                Text(score.frenchMeaning)
                    .font(.fsCaption)
                    .foregroundStyle(Color.fsInkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Nutri-Score \(score.rawValue). \(score.frenchMeaning).")
    }
}

/// Échelle A–E complète avec la lettre courante mise en avant.
/// La sélection est signalée par la taille et un liseré, jamais par la couleur seule.
public struct FSScoreScale: View {
    private let score: FSNutriScore
    @Environment(\.dynamicTypeSize) private var typeSize

    public init(_ score: FSNutriScore) { self.score = score }

    public var body: some View {
        VStack(alignment: .leading, spacing: FSMetrics.space2) {
            HStack(spacing: FSMetrics.space1) {
                ForEach(FSNutriScore.allCases) { letter in
                    let selected = letter == score
                    Text(letter.rawValue)
                        .font(.fsHeading(selected ? 26 : 19, relativeTo: .title3))
                        .foregroundStyle(letter.letterColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: selected ? 56 : 44)
                        .background(
                            RoundedRectangle(cornerRadius: FSMetrics.radiusSmall, style: .continuous)
                                .fill(letter.color)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: FSMetrics.radiusSmall, style: .continuous)
                                .strokeBorder(Color.fsInk, lineWidth: selected ? 3 : 0)
                        )
                        .overlay(alignment: .bottom) {
                            if selected {
                                Circle().fill(Color.fsInk).frame(width: 6, height: 6).offset(y: 10)
                            }
                        }
                }
            }
            .padding(.bottom, FSMetrics.space3)

            Text(score.frenchMeaning)
                .font(.fsCaption)
                .foregroundStyle(Color.fsInkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Échelle Nutri-Score de A à E. Ce produit est noté \(score.rawValue) : \(score.frenchMeaning).")
    }
}

struct FSScoreBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 12) {
                    ForEach(FSNutriScore.allCases) { FSScoreBadge($0, size: .small) }
                }
                FSScoreBadge(.e, size: .large, showsMeaning: true)
                FSScoreScale(.d)
            }
            .padding(24)
            .background(Color.fsBackground)
    }
}
