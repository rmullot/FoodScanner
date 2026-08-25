import SwiftUI

/// Espacements, rayons et cibles tactiles de la charte.
public enum FSMetrics {
    /// Échelle 4 pt.
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

    /// Aucun élément interactif ne descend sous cette hauteur.
    public static let minTouchTarget: CGFloat = 44
    /// Hauteur nominale des boutons et champs de la charte.
    public static let controlHeight: CGFloat = 60

    public static let borderWidth: CGFloat = 1.5
    public static let borderWidthStrong: CGFloat = 2
    /// Épaisseur des anneaux de nutriments.
    public static let ringWidth: CGFloat = 22
}

public extension View {
    /// Garantit la cible tactile de 44 pt sans changer le rendu visuel.
    func fsMinTouchTarget() -> some View {
        frame(minWidth: FSMetrics.minTouchTarget, minHeight: FSMetrics.minTouchTarget)
            .contentShape(Rectangle())
    }

    /// Carte de la charte : fond, rayon, bordure fine.
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
