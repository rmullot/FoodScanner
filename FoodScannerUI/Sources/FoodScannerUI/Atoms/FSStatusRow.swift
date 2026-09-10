//
//  FSStatusRow.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/10/2026.
//

import SwiftUI

/// Non-interactive, read-only row mirroring a system setting the app cannot change.
/// Visual parity with `FSToggleRow`: same `fsCard(radius: FSMetrics.radiusMedium)`,
/// `FSMetrics.space4` padding, `FSMetrics.minTouchTarget` minimum height, optional
/// leading 20 pt `Color.fsLeaf` SF Symbol in a 28 pt-wide slot.
///
/// The status line is a single static-text VoiceOver stop (label = title,
/// value = value, caption folded into the hint). An optional trailing `FSButton`
/// below it stays a normal focusable button. `statusIdentifier`, when set, is
/// applied to the status element itself, and `actionIdentifier`, when set, is
/// forwarded to the button as its `accessibilityIdentifier` for UI tests (a
/// no-op when no `action` is supplied). The two identifiers are independent, so
/// consumers never need a row-level identifier that would shadow the inner
/// button in XCUITest. No async work: every string is caller-supplied and
/// already localized.
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

    /// With an action button the caption stays contextual to it and is safe as a
    /// hint; with no button the caption is the only guidance, so it is folded into
    /// the value to survive VoiceOver's "Hints off" setting.
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
                            statusIdentifier: "statusRow.textSize.status")

                FSStatusRow("Réduire les animations",
                            value: "Activé",
                            systemImage: "wand.and.stars")

                FSStatusRow("Taille du texte (système)",
                            value: "Très grand",
                            caption: "Réglée dans Réglages iOS. Ouvrez-les pour l’ajuster.",
                            systemImage: "textformat.size",
                            action: ("Ouvrir Réglages", {}),
                            actionIdentifier: "statusRow.textSize.openSettings")

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
