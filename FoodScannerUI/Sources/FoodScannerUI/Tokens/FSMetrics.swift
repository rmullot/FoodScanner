//
//  FSMetrics.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import SwiftUI

/// Spacing, radii, and touch targets of the design system.
public enum FSMetrics {
    /// 4 pt scale.
    public static let space1: CGFloat = 4
    public static let space2: CGFloat = 8
    public static let space3: CGFloat = 12
    public static let space4: CGFloat = 16
    public static let space5: CGFloat = 20
    public static let space6: CGFloat = 24
    public static let space8: CGFloat = 32
    public static let space10: CGFloat = 40

    public static let radiusSmall: CGFloat = 10
    public static let radiusMedium: CGFloat = 14
    public static let radiusLarge: CGFloat = 20
    public static let radiusPill: CGFloat = 999

    /// No interactive element goes below this height.
    public static let minTouchTarget: CGFloat = 44
    /// Nominal height of design system buttons and fields.
    public static let controlHeight: CGFloat = 60
    /// 19 pt — smallest readable glyph the design system allows (matches `fsBody`).
    public static let minReadableText: CGFloat = 19
    /// 28 pt — nominal size of a numeric keypad key glyph before it scales down to fit.
    public static let keypadKeyGlyph: CGFloat = 28
    /// 72 pt — comfortable ceiling for an adaptive keypad key; it grows from the
    /// 44 pt touch-target floor up to this before stopping.
    public static let keypadKeyMaxHeight: CGFloat = 72
    /// 172 pt — shortest usable keypad region: 2 key rows at the 44 pt floor + 1
    /// gap + the validate button (`controlHeight`) + its top gap. Consumers must
    /// offer `FSKeypad` at least this much height.
    public static let keypadMinRegionHeight: CGFloat =
        minTouchTarget * 2 + space3 + controlHeight + space3
    /// 420 pt — keypad width ceiling so keys stay phone-proportioned on iPad / wide panes.
    public static let keypadMaxWidth: CGFloat = 420

    public static let borderWidth: CGFloat = 1.5
    public static let borderWidthStrong: CGFloat = 2
    /// Thickness of nutrient rings.
    public static let ringWidth: CGFloat = 22
}

public extension View {
    /// Guarantees the 44 pt touch target without changing the visual rendering.
    func fsMinTouchTarget() -> some View {
        frame(minWidth: FSMetrics.minTouchTarget, minHeight: FSMetrics.minTouchTarget)
            .contentShape(Rectangle())
    }

    func fsCard(radius: CGFloat = FSMetrics.radiusLarge) -> some View {
        background(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color.fsSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(Color.fsBorder, lineWidth: FSMetrics.borderWidth)
        )
    }
}
