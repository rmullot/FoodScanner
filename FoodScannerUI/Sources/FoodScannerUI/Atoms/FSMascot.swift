import SwiftUI

/// The design system's food mascots, drawn in `Path`/`Canvas`
/// (super-deformed comic style: big eyes, thick outline, rosy cheeks).
/// No asset: they follow the accent color and animate.
public struct FSMascot: View {

    public enum Kind: String, CaseIterable, Identifiable, Sendable {
        case strawberry, pea, lemon      // spring-summer
        case squash, chestnut, cabbage   // autumn-winter

        public var id: String { rawValue }

        public var frenchName: String {
            switch self {
            case .strawberry: return "Fraise"
            case .pea: return "Petit pois"
            case .lemon: return "Citron"
            case .squash: return "Potimarron"
            case .chestnut: return "Châtaigne"
            case .cabbage: return "Chou"
            }
        }

        public var season: FSSeason {
            switch self {
            case .strawberry, .pea, .lemon: return .springSummer
            case .squash, .chestnut, .cabbage: return .autumnWinter
            }
        }

        var palette: (fill: Color, shade: Color, shine: Color, leaf: Color) {
            switch self {
            case .strawberry:
                return (Color(hex: 0xE04A30), Color(hex: 0x7A1C12), Color(hex: 0xFF9078), Color(hex: 0x5F7A3A))
            case .pea:
                return (Color(hex: 0x7D9152), Color(hex: 0x3F5024), Color(hex: 0xC6DA96), Color(hex: 0x3F5024))
            case .lemon:
                return (Color(hex: 0xF0C73F), Color(hex: 0x8A6314), Color(hex: 0xFBE6A0), Color(hex: 0x5F7A3A))
            case .squash:
                return (Color(hex: 0xE0872F), Color(hex: 0x8F4D11), Color(hex: 0xF6B877), Color(hex: 0x4F6A2C))
            case .chestnut:
                return (Color(hex: 0xB07A3E), Color(hex: 0x4F2C0D), Color(hex: 0xD9A86E), Color(hex: 0x7C4C1C))
            case .cabbage:
                return (Color(hex: 0x6E8145), Color(hex: 0x3F5024), Color(hex: 0xB3C983), Color(hex: 0x3F5024))
            }
        }

        /// Face center and mouth width in the 48×48 coordinate space.
        var face: (eyesY: CGFloat, eyeGap: CGFloat, eyeR: CGFloat, mouthY: CGFloat) {
            switch self {
            case .strawberry: return (28.4, 5.4, 4.2, 34.6)
            case .pea: return (30.2, 3.2, 2.8, 34.0)
            case .lemon: return (28.6, 5.4, 4.2, 34.4)
            case .squash: return (29.4, 5.4, 4.2, 35.2)
            case .chestnut: return (26.6, 5.4, 4.2, 32.6)
            case .cabbage: return (29.8, 3.6, 3.1, 34.2)
            }
        }
    }

    private let kind: Kind
    private let size: CGFloat
    private let isDecorative: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var bounce = false

    /// - Parameters:
    ///   - kind: the food.
    ///   - size: side of the drawing square (44 pt by default).
    ///   - decorative: `true` (default) hides the mascot from VoiceOver;
    ///     `false` exposes it with its food name.
    public init(_ kind: Kind, size: CGFloat = 44, decorative: Bool = true) {
        self.kind = kind
        self.size = size
        self.isDecorative = decorative
    }

    public var body: some View {
        Canvas { ctx, canvasSize in
            let scale = min(canvasSize.width, canvasSize.height) / 48
            ctx.scaleBy(x: scale, y: scale)
            Self.draw(kind, in: &ctx)
        }
        .frame(width: size, height: size)
        .scaleEffect(bounce ? 1.04 : 1.0)
        .fsAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: bounce)
        .onAppear { if !reduceMotion { bounce = true } }
        .accessibilityHidden(isDecorative)
        .accessibilityLabel(isDecorative ? "" : "\(kind.frenchName), mascotte \(kind.season.frenchName.lowercased())")
    }

    // MARK: - Drawing

    static func draw(_ kind: Kind, in ctx: inout GraphicsContext) {
        let p = kind.palette
        let outline = Color(hex: 0x3A2418)

        // cast shadow
        ctx.fill(Path(ellipseIn: CGRect(x: 12, y: 43.4, width: 24, height: 4.6)),
                 with: .color(outline.opacity(0.13)))

        // feet + arms
        for x in [CGFloat(18), CGFloat(30)] {
            ctx.fill(Path(ellipseIn: CGRect(x: x - 3.6, y: 41, width: 7.2, height: 4.8)), with: .color(p.shade))
        }
        var arms = Path()
        arms.move(to: CGPoint(x: 11, y: 31))
        arms.addQuadCurve(to: CGPoint(x: 5.8, y: 34.6), control: CGPoint(x: 7, y: 31.6))
        arms.move(to: CGPoint(x: 37, y: 31))
        arms.addQuadCurve(to: CGPoint(x: 42.2, y: 34.6), control: CGPoint(x: 41, y: 31.6))
        ctx.stroke(arms, with: .color(p.shade), style: StrokeStyle(lineWidth: 3.2, lineCap: .round))

        // body
        let body = bodyPath(kind)
        ctx.fill(body, with: .color(p.fill))
        ctx.stroke(body, with: .color(p.shade), lineWidth: 2.2)

        // shine
        var shine = Path()
        shine.move(to: CGPoint(x: 12.6, y: 26.4))
        shine.addQuadCurve(to: CGPoint(x: 24, y: 20.8), control: CGPoint(x: 16, y: 21.4))
        ctx.stroke(shine, with: .color(p.shine.opacity(0.7)), style: StrokeStyle(lineWidth: 3, lineCap: .round))

        decorations(kind, in: &ctx)

        // face
        let f = kind.face
        for dx in [-f.eyeGap, f.eyeGap] {
            let eye = CGRect(x: 24 + dx - f.eyeR, y: f.eyesY - f.eyeR * 1.16,
                             width: f.eyeR * 2, height: f.eyeR * 2.32)
            ctx.fill(Path(ellipseIn: eye), with: .color(.white))
            ctx.stroke(Path(ellipseIn: eye), with: .color(outline), lineWidth: 1.5)
            ctx.fill(Path(ellipseIn: CGRect(x: 24 + dx - 2.3 + 0.7, y: f.eyesY - 1.4 + 0.9, width: 4.6, height: 4.6)),
                     with: .color(Color(hex: 0x241608)))
            ctx.fill(Path(ellipseIn: CGRect(x: 24 + dx - 1.6, y: f.eyesY - 2.4, width: 2.3, height: 2.3)),
                     with: .color(.white))
        }

        var mouth = Path()
        mouth.move(to: CGPoint(x: 20.4, y: f.mouthY))
        mouth.addQuadCurve(to: CGPoint(x: 27.6, y: f.mouthY), control: CGPoint(x: 24, y: f.mouthY + 4.6))
        mouth.closeSubpath()
        ctx.fill(mouth, with: .color(Color(hex: 0x8C2B22)))
        ctx.stroke(mouth, with: .color(outline), lineWidth: 1.35)

        for x in [CGFloat(14.2), CGFloat(33.8)] {
            ctx.fill(Path(ellipseIn: CGRect(x: x - 2.5, y: f.mouthY - 1.6, width: 5, height: 3.2)),
                     with: .color(p.shine.opacity(0.8)))
        }
    }

    private static func bodyPath(_ kind: Kind) -> Path {
        var path = Path()
        switch kind {
        case .strawberry:
            path.move(to: CGPoint(x: 24, y: 43.4))
            path.addCurve(to: CGPoint(x: 9.4, y: 29.2), control1: CGPoint(x: 15.6, y: 43.4), control2: CGPoint(x: 9.4, y: 37.2))
            path.addCurve(to: CGPoint(x: 24, y: 16.6), control1: CGPoint(x: 9.4, y: 21.8), control2: CGPoint(x: 15.6, y: 16.6))
            path.addCurve(to: CGPoint(x: 38.6, y: 29.2), control1: CGPoint(x: 32.4, y: 16.6), control2: CGPoint(x: 38.6, y: 21.8))
            path.addCurve(to: CGPoint(x: 24, y: 43.4), control1: CGPoint(x: 38.6, y: 37.2), control2: CGPoint(x: 32.4, y: 43.4))
        case .pea:
            path.addEllipse(in: CGRect(x: 8, y: 17.4, width: 32, height: 25.6))
        case .lemon:
            path.addEllipse(in: CGRect(x: 9, y: 17.2, width: 30, height: 24.8))
        case .squash:
            path.addEllipse(in: CGRect(x: 8.6, y: 17.8, width: 30.8, height: 25.2))
        case .chestnut:
            path.move(to: CGPoint(x: 24, y: 13.4))
            path.addCurve(to: CGPoint(x: 38.8, y: 28.8), control1: CGPoint(x: 32.4, y: 13.4), control2: CGPoint(x: 38.8, y: 20.4))
            path.addCurve(to: CGPoint(x: 24, y: 41.4), control1: CGPoint(x: 38.8, y: 36.4), control2: CGPoint(x: 32.2, y: 41.4))
            path.addCurve(to: CGPoint(x: 9.2, y: 28.8), control1: CGPoint(x: 15.8, y: 41.4), control2: CGPoint(x: 9.2, y: 36.4))
            path.addCurve(to: CGPoint(x: 24, y: 13.4), control1: CGPoint(x: 9.2, y: 20.4), control2: CGPoint(x: 15.6, y: 13.4))
        case .cabbage:
            path.addEllipse(in: CGRect(x: 9.4, y: 14.8, width: 29.2, height: 29.2))
        }
        return path
    }

    private static func decorations(_ kind: Kind, in ctx: inout GraphicsContext) {
        let p = kind.palette
        switch kind {
        case .strawberry:
            for pt in [CGPoint(x: 15.6, y: 32), CGPoint(x: 20.6, y: 37.4), CGPoint(x: 30.4, y: 34),
                       CGPoint(x: 33, y: 27.6), CGPoint(x: 27, y: 40.4)] {
                ctx.fill(Path(ellipseIn: CGRect(x: pt.x - 1.05, y: pt.y - 1.7, width: 2.1, height: 3.4)),
                         with: .color(Color(hex: 0xFFE6A6)))
            }
            var crown = Path()
            crown.move(to: CGPoint(x: 24, y: 17.6))
            crown.addLine(to: CGPoint(x: 12.6, y: 14.7))
            crown.addQuadCurve(to: CGPoint(x: 20, y: 12.1), control: CGPoint(x: 16.4, y: 11.6))
            crown.addQuadCurve(to: CGPoint(x: 24, y: 6), control: CGPoint(x: 19.4, y: 7.6))
            crown.addQuadCurve(to: CGPoint(x: 28.2, y: 12.1), control: CGPoint(x: 28.6, y: 7.8))
            crown.addQuadCurve(to: CGPoint(x: 35.4, y: 14.7), control: CGPoint(x: 33, y: 11.6))
            crown.closeSubpath()
            ctx.fill(crown, with: .color(p.leaf))
            ctx.stroke(crown, with: .color(Color(hex: 0x3C5122)), lineWidth: 1.8)
        case .pea:
            for x in [CGFloat(15), CGFloat(24), CGFloat(33)] {
                let r: CGFloat = x == 24 ? 6.4 : 5
                ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: 31 - r, width: r * 2, height: r * 2)),
                         with: .color(p.shine))
                ctx.stroke(Path(ellipseIn: CGRect(x: x - r, y: 31 - r, width: r * 2, height: r * 2)),
                           with: .color(p.shade), lineWidth: 1.4)
            }
            var stem = Path()
            stem.move(to: CGPoint(x: 24, y: 17.2))
            stem.addLine(to: CGPoint(x: 24, y: 12.6))
            stem.addQuadCurve(to: CGPoint(x: 28.8, y: 9.2), control: CGPoint(x: 28, y: 12))
            ctx.stroke(stem, with: .color(p.shade), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
        case .lemon:
            var tips = Path()
            tips.addEllipse(in: CGRect(x: 37.4, y: 27.6, width: 6, height: 4))
            tips.addEllipse(in: CGRect(x: 4.6, y: 27.6, width: 6, height: 4))
            ctx.fill(tips, with: .color(p.fill))
            ctx.stroke(tips, with: .color(p.shade), lineWidth: 1.6)
            var leaf = Path()
            leaf.move(to: CGPoint(x: 24, y: 17.4))
            leaf.addQuadCurve(to: CGPoint(x: 32, y: 13), control: CGPoint(x: 26.6, y: 12.6))
            leaf.addQuadCurve(to: CGPoint(x: 26.6, y: 18.6), control: CGPoint(x: 31.6, y: 17.4))
            ctx.fill(leaf, with: .color(p.leaf))
            ctx.stroke(leaf, with: .color(Color(hex: 0x3C5122)), lineWidth: 1.7)
        case .squash:
            var ribs = Path()
            for x in [CGFloat(15.4), CGFloat(24), CGFloat(32.6)] {
                ribs.move(to: CGPoint(x: x, y: 19.6))
                ribs.addQuadCurve(to: CGPoint(x: x, y: 41.2), control: CGPoint(x: x == 24 ? x : (x < 24 ? 12 : 36), y: 30.4))
            }
            ctx.stroke(ribs, with: .color(p.shade.opacity(0.6)), lineWidth: 1.9)
            var stem = Path()
            stem.move(to: CGPoint(x: 24, y: 18.2))
            stem.addLine(to: CGPoint(x: 24, y: 12.8))
            stem.addQuadCurve(to: CGPoint(x: 29.8, y: 9.8), control: CGPoint(x: 29, y: 12.8))
            ctx.stroke(stem, with: .color(p.leaf), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        case .chestnut:
            var cap = Path()
            cap.move(to: CGPoint(x: 10.2, y: 33.4))
            cap.addQuadCurve(to: CGPoint(x: 37.8, y: 33.4), control: CGPoint(x: 24, y: 41))
            cap.addQuadCurve(to: CGPoint(x: 10.2, y: 33.4), control: CGPoint(x: 24, y: 46))
            ctx.fill(cap, with: .color(Color(hex: 0x7C4C1C)))
            var tip = Path()
            tip.move(to: CGPoint(x: 24, y: 13.6))
            tip.addLine(to: CGPoint(x: 24, y: 8.6))
            ctx.stroke(tip, with: .color(p.shade), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
        case .cabbage:
            var veins = Path()
            veins.move(to: CGPoint(x: 24, y: 15))
            veins.addQuadCurve(to: CGPoint(x: 31.4, y: 29.4), control: CGPoint(x: 31, y: 19))
            veins.move(to: CGPoint(x: 24, y: 15))
            veins.addQuadCurve(to: CGPoint(x: 16.6, y: 29.4), control: CGPoint(x: 17, y: 19))
            veins.move(to: CGPoint(x: 9.6, y: 31))
            veins.addQuadCurve(to: CGPoint(x: 38.4, y: 31), control: CGPoint(x: 24, y: 35))
            ctx.stroke(veins, with: .color(p.shine), lineWidth: 2.1)
            let heart = CGRect(x: 16, y: 22.4, width: 16, height: 16)
            ctx.fill(Path(ellipseIn: heart), with: .color(p.shine))
            ctx.stroke(Path(ellipseIn: heart), with: .color(p.shade), lineWidth: 1.5)
        }
    }
}

/// Trio of the current season's mascots, aligned and decorative.
public struct FSMascotRow: View {
    @FSResolvedSeason private var season
    private let size: CGFloat

    public init(size: CGFloat = 46) { self.size = size }

    public var body: some View {
        HStack(spacing: FSMetrics.space2) {
            ForEach(season.mascots) { FSMascot($0, size: size) }
        }
        .accessibilityHidden(true)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

struct FSMascot_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
                FSMascotRow(size: 72)
                FSMascotRow(size: 72).fsSeason(.autumnWinter)
            }
            .padding(40)
            .background(Color.fsBackground)
    }
}
