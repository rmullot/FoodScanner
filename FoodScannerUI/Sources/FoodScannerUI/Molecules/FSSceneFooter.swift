//
//  FSSceneFooter.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// List footer vignette: the mascots in a scene.
///
/// If the app embeds the vector PDFs (`Resources/FoodScannerUI.xcassets`,
/// images `scene-laboratory`, `scene-picnic`, `scene-chalet`), they are used.
/// Otherwise the vignette is drawn in `Canvas` — the component therefore
/// works without any binary asset.
public struct FSSceneFooter: View {

    public enum Kind: String, CaseIterable, Sendable {
        /// Nutrients screen — the mascots analyze the label.
        case laboratory
        /// History screen, light theme.
        case picnic
        /// History screen, dark theme.
        case chalet

        /// Generated SwiftGen asset for this vignette (`FoodScannerUI.xcassets`, `Scenes/`).
        var asset: ImageAsset {
            switch self {
            case .laboratory: return FSAsset.sceneLaboratory
            case .picnic: return FSAsset.scenePicnic
            case .chalet: return FSAsset.sceneChalet
            }
        }

        var altText: String {
            switch self {
            case .laboratory: return FSL10n.SceneFooter.Alt.laboratory
            case .picnic: return FSL10n.SceneFooter.Alt.picnic
            case .chalet: return FSL10n.SceneFooter.Alt.chalet
            }
        }
    }

    private let kind: Kind
    private let caption: String
    @FSResolvedSeason private var season

    /// - Parameter kind: `.laboratory` is fixed; `.picnic` and `.chalet`
    ///   designate the same history vignette, which then switches with the
    ///   season (picnic in spring-summer, chalet in autumn-winter).
    public init(_ kind: Kind, caption: String) {
        self.kind = kind
        self.caption = caption
    }

    public var body: some View {
        VStack(spacing: 0) {
            scene
                .frame(height: 150)
                .clipped()
            Text(caption)
                .font(.fsCaption)
                .foregroundStyle(Color.fsInkSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(FSMetrics.space4)
        }
        .background(
            RoundedRectangle(cornerRadius: FSMetrics.radiusLarge, style: .continuous)
                .fill(Color.fsSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: FSMetrics.radiusLarge, style: .continuous)
                .strokeBorder(Color.fsBorder, lineWidth: FSMetrics.borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: FSMetrics.radiusLarge, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(resolved.altText). \(caption)")
        // Note: composed at the call site rather than via a dedicated
        // FSL10n format string, since `caption` is app-supplied text.
    }

    /// History switches between picnic / chalet with the season.
    private var resolved: Kind {
        switch kind {
        case .laboratory: return .laboratory
        case .picnic, .chalet: return season == .springSummer ? .picnic : .chalet
        }
    }

    @ViewBuilder private var scene: some View {
        #if canImport(UIKit)
        if let image = UIImage(asset: resolved.asset) {
            Image(uiImage: image).resizable().scaledToFill()
        } else {
            FSSceneCanvas(kind: resolved, season: season)
        }
        #else
        FSSceneCanvas(kind: resolved, season: season)
        #endif
    }
}

/// Fallback drawing for the vignettes: layered backgrounds + mascots.
struct FSSceneCanvas: View {
    let kind: FSSceneFooter.Kind
    let season: FSSeason

    var body: some View {
        ZStack {
            Canvas { ctx, size in
                switch kind {
                case .laboratory: Self.drawLab(&ctx, size, season)
                case .picnic: Self.drawPicnic(&ctx, size)
                case .chalet: Self.drawChalet(&ctx, size)
                }
            }
            mascots
        }
    }

    private var mascots: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                FSMascot(season.mascots[0], size: 52).position(x: w * 0.20, y: h * 0.62)
                FSMascot(season.mascots[1], size: 46).position(x: w * 0.36, y: h * 0.70)
                FSMascot(season.mascots[2], size: 50).position(x: w * 0.82, y: h * 0.64)
            }
        }
    }

    // MARK: Backgrounds

    static func drawLab(_ ctx: inout GraphicsContext, _ s: CGSize, _ season: FSSeason) {
        let wall = season == .springSummer ? Color(hex: 0xE7F0D6) : Color(hex: 0x36311F)
        let grid = season == .springSummer ? Color(hex: 0xC3D3AA) : Color(hex: 0x4D4732)
        let bench = season == .springSummer ? Color(hex: 0xCDBE9B) : Color(hex: 0x4A4230)
        let metal = season == .springSummer ? Color(hex: 0x8A9270) : Color(hex: 0xB3A888)
        let liquid = season == .springSummer ? Color(hex: 0xA97527) : Color(hex: 0xE0B36A)
        let glow = season == .springSummer ? Color(hex: 0xF7DB8A) : Color(hex: 0xF0A24A)

        ctx.fill(Path(CGRect(origin: .zero, size: s)), with: .color(wall))
        var lines = Path()
        var y: CGFloat = 22
        while y < s.height * 0.7 { lines.move(to: CGPoint(x: 0, y: y)); lines.addLine(to: CGPoint(x: s.width, y: y)); y += 30 }
        var x: CGFloat = 40
        while x < s.width { lines.move(to: CGPoint(x: x, y: 0)); lines.addLine(to: CGPoint(x: x, y: s.height * 0.7)); x += 58 }
        ctx.stroke(lines, with: .color(grid.opacity(0.6)), lineWidth: 1)

        // hanging lamp + glow
        let cx = s.width * 0.5
        ctx.stroke(Path { $0.move(to: CGPoint(x: cx, y: 0)); $0.addLine(to: CGPoint(x: cx, y: 14)) },
                   with: .color(metal), lineWidth: 2.4)
        var shade = Path()
        shade.move(to: CGPoint(x: cx - 18, y: 30))
        shade.addQuadCurve(to: CGPoint(x: cx + 18, y: 30), control: CGPoint(x: cx, y: 12))
        shade.closeSubpath()
        ctx.fill(shade, with: .color(glow))
        ctx.fill(Path(ellipseIn: CGRect(x: cx - 80, y: 22, width: 160, height: 70)),
                 with: .color(glow.opacity(0.22)))

        // jar shelf
        ctx.fill(Path(CGRect(x: 14, y: 40, width: 104, height: 7)), with: .color(metal.opacity(0.8)))
        for (i, jar) in [CGRect(x: 22, y: 20, width: 18, height: 20),
                         CGRect(x: 50, y: 14, width: 20, height: 26),
                         CGRect(x: 80, y: 24, width: 18, height: 16)].enumerated() {
            ctx.stroke(Path(roundedRect: jar, cornerRadius: 3), with: .color(metal), lineWidth: 1.6)
            let fills = [Color(hex: 0xE04A30), Color(hex: 0x7D9152), Color(hex: 0xF0C73F)]
            ctx.fill(Path(ellipseIn: CGRect(x: jar.midX - 4, y: jar.midY - 4, width: 8, height: 8)),
                     with: .color(fills[i]))
        }

        // bar chart
        let board = CGRect(x: s.width - 100, y: 18, width: 86, height: 58)
        ctx.fill(Path(roundedRect: board, cornerRadius: 5), with: .color(metal.opacity(0.35)))
        for (i, h) in [16.0, 26.0, 10.0, 34.0].enumerated() {
            let bar = CGRect(x: board.minX + 10 + CGFloat(i) * 16, y: board.maxY - 8 - h, width: 10, height: h)
            ctx.fill(Path(roundedRect: bar, cornerRadius: 2), with: .color(liquid))
        }

        // workbench
        ctx.fill(Path(CGRect(x: 0, y: s.height - 56, width: s.width, height: 56)), with: .color(bench))
        ctx.fill(Path(CGRect(x: 0, y: s.height - 56, width: s.width, height: 8)), with: .color(bench.opacity(0.6)))

        // erlenmeyer flask
        var flask = Path()
        flask.move(to: CGPoint(x: s.width * 0.66, y: s.height - 94))
        flask.addLine(to: CGPoint(x: s.width * 0.66 + 30, y: s.height - 94))
        flask.addLine(to: CGPoint(x: s.width * 0.66 + 38, y: s.height - 44))
        flask.addLine(to: CGPoint(x: s.width * 0.66 - 8, y: s.height - 44))
        flask.closeSubpath()
        ctx.stroke(flask, with: .color(metal), lineWidth: 2.4)
        var juice = Path()
        juice.move(to: CGPoint(x: s.width * 0.66 + 1, y: s.height - 62))
        juice.addLine(to: CGPoint(x: s.width * 0.66 + 29, y: s.height - 62))
        juice.addLine(to: CGPoint(x: s.width * 0.66 + 38, y: s.height - 44))
        juice.addLine(to: CGPoint(x: s.width * 0.66 - 8, y: s.height - 44))
        juice.closeSubpath()
        ctx.fill(juice, with: .color(liquid))

        // label + magnifying glass
        let card = CGRect(x: 26, y: s.height - 48, width: 56, height: 34)
        ctx.fill(Path(roundedRect: card, cornerRadius: 4), with: .color(.white.opacity(0.92)))
        var text = Path()
        for i in 0..<3 {
            let ly = card.minY + 9 + CGFloat(i) * 8
            text.move(to: CGPoint(x: card.minX + 8, y: ly))
            text.addLine(to: CGPoint(x: card.maxX - CGFloat(8 + i * 10), y: ly))
        }
        ctx.stroke(text, with: .color(Color(hex: 0x5A5240)), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
        let lens = CGRect(x: card.maxX - 6, y: card.minY - 12, width: 26, height: 26)
        ctx.fill(Path(ellipseIn: lens), with: .color(Color(hex: 0xCFE4F2).opacity(0.4)))
        ctx.stroke(Path(ellipseIn: lens), with: .color(metal), lineWidth: 4)
        ctx.stroke(Path { $0.move(to: CGPoint(x: lens.maxX - 3, y: lens.maxY - 3)); $0.addLine(to: CGPoint(x: lens.maxX + 8, y: lens.maxY + 8)) },
                   with: .color(metal), style: StrokeStyle(lineWidth: 5, lineCap: .round))
    }

    static func drawPicnic(_ ctx: inout GraphicsContext, _ s: CGSize) {
        ctx.fill(Path(CGRect(origin: .zero, size: s)), with: .color(Color(hex: 0xCFE6F2)))
        ctx.fill(Path(ellipseIn: CGRect(x: s.width - 90, y: -30, width: 120, height: 120)),
                 with: .color(Color(hex: 0xF7DB8A).opacity(0.5)))
        ctx.fill(Path(ellipseIn: CGRect(x: s.width - 68, y: 8, width: 40, height: 40)),
                 with: .color(Color(hex: 0xF0C73F)))
        // hills
        var hill = Path()
        hill.move(to: CGPoint(x: 0, y: s.height * 0.56))
        hill.addQuadCurve(to: CGPoint(x: s.width, y: s.height * 0.52), control: CGPoint(x: s.width * 0.5, y: s.height * 0.36))
        hill.addLine(to: CGPoint(x: s.width, y: s.height))
        hill.addLine(to: CGPoint(x: 0, y: s.height))
        ctx.fill(hill, with: .color(Color(hex: 0xA7C07C)))
        var hill2 = Path()
        hill2.move(to: CGPoint(x: 0, y: s.height * 0.72))
        hill2.addQuadCurve(to: CGPoint(x: s.width, y: s.height * 0.68), control: CGPoint(x: s.width * 0.55, y: s.height * 0.58))
        hill2.addLine(to: CGPoint(x: s.width, y: s.height))
        hill2.addLine(to: CGPoint(x: 0, y: s.height))
        ctx.fill(hill2, with: .color(Color(hex: 0x8EA963)))
        // tree
        ctx.stroke(Path { $0.move(to: CGPoint(x: 34, y: s.height * 0.68)); $0.addLine(to: CGPoint(x: 34, y: 40)) },
                   with: .color(Color(hex: 0x7A5232)), style: StrokeStyle(lineWidth: 11, lineCap: .round))
        for c in [CGRect(x: 2, y: 12, width: 44, height: 44), CGRect(x: 32, y: 6, width: 38, height: 38),
                  CGRect(x: 0, y: 32, width: 32, height: 32), CGRect(x: 28, y: 34, width: 32, height: 32)] {
            ctx.fill(Path(ellipseIn: c), with: .color(Color(hex: 0x5F7A3A)))
        }
        // tablecloth
        var cloth = Path()
        cloth.move(to: CGPoint(x: s.width * 0.15, y: s.height))
        cloth.addQuadCurve(to: CGPoint(x: s.width * 0.87, y: s.height), control: CGPoint(x: s.width * 0.5, y: s.height * 0.72))
        ctx.fill(cloth, with: .color(Color(hex: 0xF4EAD4)))
        var checks = Path()
        var y = s.height * 0.86
        var row = 0
        while y < s.height {
            var x = s.width * (row % 2 == 0 ? 0.22 : 0.28)
            while x < s.width * 0.82 {
                checks.addRect(CGRect(x: x, y: y, width: 20, height: 9))
                x += 42
            }
            y += 16; row += 1
        }
        ctx.fill(checks, with: .color(Color(hex: 0xD2432C).opacity(0.35)))
        // basket
        let basket = CGRect(x: s.width * 0.66, y: s.height * 0.58, width: 46, height: 32)
        ctx.fill(Path(roundedRect: basket, cornerRadius: 4), with: .color(Color(hex: 0xB58A44)))
        ctx.stroke(Path { $0.addArc(center: CGPoint(x: basket.midX, y: basket.minY), radius: 18,
                                    startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) },
                   with: .color(Color(hex: 0x7A5232)), lineWidth: 4)
    }

    static func drawChalet(_ ctx: inout GraphicsContext, _ s: CGSize) {
        ctx.fill(Path(CGRect(origin: .zero, size: s)), with: .color(Color(hex: 0x3E3125)))
        var logs = Path()
        var y: CGFloat = 26
        while y < s.height * 0.72 { logs.move(to: CGPoint(x: 0, y: y)); logs.addLine(to: CGPoint(x: s.width, y: y)); y += 28 }
        ctx.stroke(logs, with: .color(Color(hex: 0x2B2117)), lineWidth: 1.8)
        // night window
        let win = CGRect(x: 20, y: 18, width: 96, height: 68)
        ctx.fill(Path(roundedRect: win, cornerRadius: 6), with: .color(Color(hex: 0x1D2733)))
        ctx.stroke(Path(roundedRect: win, cornerRadius: 6), with: .color(Color(hex: 0x6B5334)), lineWidth: 4)
        ctx.stroke(Path { $0.move(to: CGPoint(x: win.midX, y: win.minY)); $0.addLine(to: CGPoint(x: win.midX, y: win.maxY))
                          $0.move(to: CGPoint(x: win.minX, y: win.midY)); $0.addLine(to: CGPoint(x: win.maxX, y: win.midY)) },
                   with: .color(Color(hex: 0x6B5334)), lineWidth: 4)
        ctx.fill(Path(ellipseIn: CGRect(x: win.maxX - 24, y: win.minY + 10, width: 16, height: 16)),
                 with: .color(Color(hex: 0xF2EAD2)))
        for p in [CGPoint(x: 40, y: 34), CGPoint(x: 56, y: 50), CGPoint(x: 34, y: 66), CGPoint(x: 88, y: 72)] {
            ctx.fill(Path(ellipseIn: CGRect(x: p.x, y: p.y, width: 3.4, height: 3.4)), with: .color(Color(hex: 0xF2EAD2)))
        }
        // fireplace + glow
        let fire = CGRect(x: s.width - 106, y: 44, width: 72, height: 66)
        ctx.fill(Path(roundedRect: fire, cornerRadius: 6), with: .color(Color(hex: 0x2A211A)))
        ctx.stroke(Path(roundedRect: fire, cornerRadius: 6), with: .color(Color(hex: 0x6B5334)), lineWidth: 4)
        ctx.fill(Path(ellipseIn: fire.insetBy(dx: -40, dy: -30)), with: .color(Color(hex: 0xF0A24A).opacity(0.18)))
        var flame = Path()
        flame.move(to: CGPoint(x: fire.midX - 16, y: fire.maxY - 6))
        flame.addQuadCurve(to: CGPoint(x: fire.midX, y: fire.minY + 18), control: CGPoint(x: fire.midX - 18, y: fire.midY))
        flame.addQuadCurve(to: CGPoint(x: fire.midX + 16, y: fire.maxY - 6), control: CGPoint(x: fire.midX + 18, y: fire.midY))
        ctx.fill(flame, with: .color(Color(hex: 0xF0A24A)))
        ctx.fill(flame.applying(CGAffineTransform(scaleX: 0.6, y: 0.7).concatenating(
            CGAffineTransform(translationX: fire.midX * 0.4, y: fire.maxY * 0.3))),
                 with: .color(Color(hex: 0xF7DB8A)))
        // table
        ctx.fill(Path(CGRect(x: 0, y: s.height - 56, width: s.width, height: 56)), with: .color(Color(hex: 0x5B4227)))
        ctx.fill(Path(roundedRect: CGRect(x: 0, y: s.height - 60, width: s.width, height: 10), cornerRadius: 3),
                 with: .color(Color(hex: 0x775636)))
        // steaming soup
        let bowl = CGRect(x: s.width * 0.40, y: s.height - 74, width: 56, height: 20)
        ctx.fill(Path(ellipseIn: CGRect(x: bowl.minX, y: bowl.minY - 6, width: bowl.width, height: 12)),
                 with: .color(Color(hex: 0xE8C39A)))
        ctx.fill(Path(roundedRect: bowl, cornerRadius: 8), with: .color(Color(hex: 0xD8834A)))
        var steam = Path()
        for i in 0..<3 {
            let sx = bowl.minX + 14 + CGFloat(i) * 14
            steam.move(to: CGPoint(x: sx, y: bowl.minY - 10))
            steam.addQuadCurve(to: CGPoint(x: sx, y: bowl.minY - 26), control: CGPoint(x: sx + 8, y: bowl.minY - 18))
        }
        ctx.stroke(steam, with: .color(Color(hex: 0xE8E1CD).opacity(0.6)), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
    }
}
