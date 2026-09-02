//
//  FSNutrientViews.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import SwiftUI

/// Nutrient row: patterned swatch, name, proportional bar, value.
public struct FSNutrientRow: View {
    private let nutrient: FSNutrient
    private let grams: Double
    private let referenceGrams: Double
    private let unit: String

    @FSResolvedSeason private var season

    public init(_ nutrient: FSNutrient, grams: Double, referenceGrams: Double = 100, unit: String = "g") {
        self.nutrient = nutrient
        self.grams = grams
        self.referenceGrams = max(referenceGrams, 0.001)
        self.unit = unit
    }

    private var ratio: Double { min(grams / referenceGrams, 1) }

    private var valueText: String {
        let formatted = grams < 10
            ? String(format: "%.1f", grams).replacingOccurrences(of: ".", with: ",")
            : String(format: "%.0f", grams)
        return "\(formatted) \(unit)"
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: FSMetrics.space2) {
            HStack(spacing: FSMetrics.space3) {
                FSPatternSwatch(nutrient)
                Text(nutrient.frenchName)
                    .font(.fsBody)
                    .foregroundStyle(Color.fsInk)
                Spacer(minLength: FSMetrics.space2)
                Text(valueText)
                    .font(.fsBodyStrong)
                    .foregroundStyle(Color.fsInk)
                    .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.fsInk.opacity(0.08))
                    FSPattern(nutrient, scale: 0.5)
                        .frame(width: max(geo.size.width * ratio, 10))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.fsInk.opacity(0.25), lineWidth: 1)
                                .frame(width: max(geo.size.width * ratio, 10)),
                            alignment: .leading
                        )
                }
            }
            .frame(height: 14)
        }
        .padding(.vertical, FSMetrics.space2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(nutrient.frenchName)
        .accessibilityValue(FSL10n.NutrientRow.accessibilityValue(
            valueText, String(Int(referenceGrams)), nutrient.seasonalSource(season), nutrient.pattern.frenchName
        ))
    }
}

/// Nutrient breakdown ring: a distinct pattern per segment,
/// score and total at the center.
public struct FSNutrientRing: View {
    public struct Segment: Identifiable {
        public let nutrient: FSNutrient
        public let grams: Double
        public var id: String { nutrient.rawValue }

        public init(nutrient: FSNutrient, grams: Double) {
            self.nutrient = nutrient
            self.grams = grams
        }
    }

    private let segments: [Segment]
    private let score: FSNutriScore?
    private let diameter: CGFloat

    public init(segments: [Segment], score: FSNutriScore? = nil, diameter: CGFloat = 190) {
        self.segments = segments
        self.score = score
        self.diameter = diameter
    }

    private var total: Double { max(segments.reduce(0) { $0 + $1.grams }, 0.001) }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color.fsInk.opacity(0.07), lineWidth: FSMetrics.ringWidth)

            ForEach(offsets) { item in
                FSPattern(item.segment.nutrient, scale: 0.6)
                    .mask(arc(item))
                    .overlay(arc(item).foregroundColor(Color.fsInk.opacity(0.16)))
            }

            VStack(spacing: FSMetrics.space1) {
                if let score {
                    FSScoreBadge(score, size: .medium)
                }
                Text(FSL10n.NutrientRow.totalValue(String(Int(total))))
                    .font(.fsHeadline)
                    .foregroundStyle(Color.fsInk)
                Text(FSL10n.NutrientRow.per100g)
                    .font(.fsCaption)
                    .foregroundStyle(Color.fsInkSecondary)
            }
        }
        .frame(width: diameter, height: diameter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(FSL10n.NutrientRing.accessibilityLabel)
        .accessibilityValue(summary)
    }

    private func arc(_ item: Offset) -> some View {
        Circle()
            .trim(from: item.start, to: item.end)
            .stroke(style: StrokeStyle(lineWidth: FSMetrics.ringWidth, lineCap: .butt))
            .rotationEffect(.degrees(-90))
    }

    struct Offset: Identifiable {
        let segment: Segment
        let start: CGFloat
        let end: CGFloat
        var id: String { segment.id }
    }

    private var offsets: [Offset] {
        var cursor: CGFloat = 0
        return segments.map { segment in
            let share = CGFloat(segment.grams / total)
            let item = Offset(segment: segment, start: cursor, end: cursor + share)
            cursor += share
            return item
        }
    }

    private var summary: String {
        segments
            .map { FSL10n.NutrientRing.distributionItem($0.nutrient.frenchName, String(Int(($0.grams / total) * 100))) }
            .joined(separator: ", ")
    }
}

/// Ring legend: pattern, name, and the seasonal food the color comes from.
public struct FSNutrientLegend: View {
    private let nutrients: [FSNutrient]
    @FSResolvedSeason private var season

    public init(_ nutrients: [FSNutrient] = FSNutrient.allCases) {
        self.nutrients = nutrients
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: FSMetrics.space2) {
            ForEach(nutrients) { n in
                HStack(spacing: FSMetrics.space3) {
                    FSPatternSwatch(n, side: 22)
                    Text(n.frenchName).font(.fsCaption).foregroundStyle(Color.fsInk)
                    Text(FSL10n.NutrientRow.seasonalSourcePrefix(n.seasonalSource(season)))
                        .font(.fsCaption)
                        .foregroundStyle(Color.fsInkSecondary)
                }
            }
        }
    }
}
