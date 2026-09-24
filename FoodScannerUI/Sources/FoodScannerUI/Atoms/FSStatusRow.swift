//
//  FSStatusRow.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/10/2026.
//

import SwiftUI

public struct FSStatusRow: View {
    private let title: String
    private let value: String
    private let caption: String?
    private let systemImage: String?
    private let statusIdentifier: String?
    private let action: (String, () -> Void)?
    private let actionIdentifier: String?

    public init(_ title: String,
                value: String,
                caption: String? = nil,
                systemImage: String? = nil,
                statusIdentifier: String? = nil,
                action: (String, () -> Void)? = nil,
                actionIdentifier: String? = nil) {
        self.title = title
        self.value = value
        self.caption = caption
        self.systemImage = systemImage
        self.statusIdentifier = statusIdentifier
        self.action = action
        self.actionIdentifier = actionIdentifier
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: FSMetrics.space3) {
            HStack(spacing: FSMetrics.space3) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 20))
                        .foregroundStyle(Color.fsLeaf)
                        .frame(width: 28)
                        .accessibilityHidden(true)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.fsBody).foregroundStyle(Color.fsInk)
                    if let caption {
                        Text(caption)
                            .font(.fsCaption)
                            .foregroundStyle(Color.fsInkSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityHidden(true)
                    }
                }
                Spacer(minLength: FSMetrics.space3)
                Text(value)
                    .font(.fsBody)
                    .foregroundStyle(Color.fsInk)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minHeight: FSMetrics.minTouchTarget)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(accessibleValue)
            .accessibilityAddTraits(.isStaticText)
            .modifier(HintIfPresent(action == nil ? nil : caption))
            .modifier(IdentifierIfPresent(statusIdentifier))

            if let action {
                FSButton(action.0, action: action.1)
                    .modifier(IdentifierIfPresent(actionIdentifier))
            }
        }
        .padding(FSMetrics.space4)
        .frame(minHeight: FSMetrics.minTouchTarget)
        .fsCard(radius: FSMetrics.radiusMedium)
    }

    private var accessibleValue: String {
        guard action == nil, let caption, !caption.isEmpty else { return value }
        return "\(value). \(caption)"
    }
}

private struct IdentifierIfPresent: ViewModifier {
    let identifier: String?

    init(_ identifier: String?) { self.identifier = identifier }

    func body(content: Content) -> some View {
        if let identifier, !identifier.isEmpty {
            content.accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}

private struct HintIfPresent: ViewModifier {
    let hint: String?

    init(_ hint: String?) { self.hint = hint }

    func body(content: Content) -> some View {
        if let hint, !hint.isEmpty {
            content.accessibilityHint(Text(hint))
        } else {
            content
        }
    }
}

struct FSStatusRow_Previews: PreviewProvider {
    private struct Demo: View {
        var body: some View {
            VStack(spacing: FSMetrics.space4) {
                FSStatusRow("Taille du texte (système)",
                            value: "Très grand",
                            caption: "Réglée dans Réglages iOS › Affichage et luminosité.",
                            systemImage: "textformat.size",
                            statusIdentifier: FSAccessibilityID.statusRowTextSizeStatus.identifier)

                FSStatusRow("Réduire les animations",
                            value: "Activé",
                            systemImage: "wand.and.stars")

                FSStatusRow("Taille du texte (système)",
                            value: "Très grand",
                            caption: "Réglée dans Réglages iOS. Ouvrez-les pour l’ajuster.",
                            systemImage: "textformat.size",
                            action: ("Ouvrir Réglages", {}),
                            actionIdentifier: FSAccessibilityID.statusRowTextSizeOpenSettings.identifier)

                FSStatusRow("Contraste élevé",
                            value: "Désactivé",
                            action: ("Ouvrir Réglages", {}))
            }
            .padding(FSMetrics.space4)
            .background(Color.fsBackground)
        }
    }

    static var previews: some View {
        Demo()
            .preferredColorScheme(.light)
            .previewDisplayName("Clair")

        Demo()
            .preferredColorScheme(.dark)
            .previewDisplayName("Sombre")

        Demo()
            .environment(\.dynamicTypeSize, .accessibility5)
            .previewDisplayName("Accessibilité XL")

        Demo()
            .modifier(FSIncreasedContrastPreview())
            .previewDisplayName("Contraste élevé")
    }
}
