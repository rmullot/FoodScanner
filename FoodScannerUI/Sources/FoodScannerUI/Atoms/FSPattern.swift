//
//  FSPattern.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import SwiftUI

/// A design system nutrient: its seasonal food color AND its pattern.
/// The pattern is mandatory: no information is conveyed by color alone.
public enum FSNutrient: String, CaseIterable, Identifiable, Sendable {
    case carbs, fat, protein, salt, fiber

    public var id: String { rawValue }

    public var frenchName: String {
        switch self {
        case .carbs: return "Glucides"
        case .fat: return "Lipides"
        case .protein: return "Protéines"
        case .salt: return "Sel"
        case .fiber: return "Fibres"
        }
    }

    /// The seasonal food whose color is used, for the legend.
    public func seasonalSource(_ season: FSSeason) -> String {
        switch (self, season) {
        case (.carbs, .springSummer): return "blé"
        case (.carbs, .autumnWinter): return "courge"
        case (.fat, .springSummer): return "huile d'olive"
        case (.fat, .autumnWinter): return "noix"
        case (.protein, .springSummer): return "haricot rouge"
        case (.protein, .autumnWinter): return "chou"
        case (.salt, _): return "fleur de sel"
        case (.fiber, .springSummer): return "petit pois"
        case (.fiber, .autumnWinter): return "châtaigne"
        }
    }

    public var color: Color {
        switch self {
        case .carbs: return .fsCarbs
        case .fat: return .fsFat
        case .protein: return .fsProtein
        case .salt: return .fsSalt
        case .fiber: return .fsFiber
        }
    }

    public var pattern: FSPattern.Motif {
        switch self {
        case .carbs: return .verticalBars
        case .fat: return .diagonalStripes
        case .protein: return .dots
        case .salt: return .grid
        case .fiber: return .waves
        }
    }
}

/// Distinctive patterns, drawn in `Canvas` and usable as a fill.
public struct FSPattern: View {

    public enum Motif: String, CaseIterable, Sendable {
        case verticalBars, diagonalStripes, dots, grid, waves

        public var frenchName: String {
            switch self {
            case .verticalBars: return "barres verticales"
            case .diagonalStripes: return "hachures"
            case .dots: return "pois"
            case .grid: return "quadrillage"
            case .waves: return "vagues"
            }
        }
    }

    private let motif: Motif
    private let base: Color
    private let ink: Color
    private let scale: CGFloat

    public init(_ motif: Motif, base: Color, ink: Color = .fsInk, scale: CGFloat = 1) {
        self.motif = motif
        self.base = base
        self.ink = ink
        self.scale = scale
    }

    /// Ready-to-use fill for a nutrient.
    public init(_ nutrient: FSNutrient, scale: CGFloat = 1) {
        self.init(nutrient.pattern, base: nutrient.color, ink: .fsInk, scale: scale)
    }

    public var body: some View {
        Canvas { ctx, size in
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(base))
            let stroke = ink.opacity(0.4)
            let step: CGFloat = 9 * scale
            var path = Path()
            switch motif {
            case .verticalBars:
                var x: CGFloat = 0
                while x < size.width { path.addRect(CGRect(x: x, y: 0, width: 3 * scale, height: size.height)); x += step }
                ctx.fill(path, with: .color(stroke))
            case .diagonalStripes:
                var x: CGFloat = -size.height
                while x < size.width { 
                    path.move(to: CGPoint(x: x, y: size.height))
                    path.addLine(to: CGPoint(x: x + size.height, y: 0))
                    x += step
                }
                ctx.stroke(path, with: .color(stroke), lineWidth: 3 * scale)
            case .dots:
                var y: CGFloat = step / 2
                var row = 0
                while y < size.height {
                    var x: CGFloat = (row % 2 == 0) ? step / 2 : step
                    while x < size.width {
                        path.addEllipse(in: CGRect(x: x - 2 * scale, y: y - 2 * scale, width: 4 * scale, height: 4 * scale))
                        x += step
                    }
                    y += step; row += 1
                }
                ctx.fill(path, with: .color(stroke))
            case .grid:
                var x: CGFloat = 0
                while x < size.width { path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height)); x += step }
                var y: CGFloat = 0
                while y < size.height { path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y)); y += step }
                ctx.stroke(path, with: .color(stroke), lineWidth: 1.6 * scale)
            case .waves:
                var y: CGFloat = step / 2
                while y < size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    var x: CGFloat = 0
                    while x < size.width {
                        path.addQuadCurve(to: CGPoint(x: x + step, y: y),
                                          control: CGPoint(x: x + step / 2, y: y - step / 2))
                        x += step
                    }
                    y += step
                }
                ctx.stroke(path, with: .color(stroke), lineWidth: 2 * scale)
            }
        }
        .accessibilityHidden(true)
    }
}

/// Legend swatch: the pattern inside a small rounded square.
public struct FSPatternSwatch: View {
    private let nutrient: FSNutrient
    private let side: CGFloat

    public init(_ nutrient: FSNutrient, side: CGFloat = 26) {
        self.nutrient = nutrient
        self.side = side
    }

    public var body: some View {
        FSPattern(nutrient, scale: 0.55)
            .frame(width: side, height: side)
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(Color.fsInk.opacity(0.35), lineWidth: 1)
            )
    }
}

struct FSPattern_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 12) {
                ForEach(FSNutrient.allCases) { n in
                    HStack(spacing: 12) {
                        FSPatternSwatch(n, side: 34)
                        Text("\(n.frenchName) — \(n.pattern.frenchName)").font(.fsCaption)
                    }
                }
            }
            .padding(24)
            .background(Color.fsBackground)
    }
}
