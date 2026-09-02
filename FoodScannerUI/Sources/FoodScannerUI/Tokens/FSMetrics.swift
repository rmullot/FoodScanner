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
