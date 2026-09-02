//
//  FSButton.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import SwiftUI

public struct FSButton: View {

    public enum Role { case primary, outline, quiet }

    private let title: String
    private let role: Role
    private let systemImage: String?
    private let isLoading: Bool
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    public init(_ title: String,
                role: Role = .primary,
                systemImage: String? = nil,
                isLoading: Bool = false,
                action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button {
            FSHaptics.play(.selection)
            action()
        } label: {
            HStack(spacing: FSMetrics.space2) {
                if isLoading {
                    ProgressView().tint(foreground)
                } else if let systemImage {
                    Image(systemName: systemImage).imageScale(.medium)
                }
                Text(title)
                    .font(.fsBodyStrong)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(foreground)
            .padding(.horizontal, FSMetrics.space5)
            .frame(maxWidth: .infinity, minHeight: FSMetrics.controlHeight)
            .background(
                RoundedRectangle(cornerRadius: FSMetrics.radiusPill, style: .continuous)
                    .fill(background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: FSMetrics.radiusPill, style: .continuous)
                    .strokeBorder(border, lineWidth: FSMetrics.borderWidthStrong)
            )
            .opacity(isEnabled ? 1 : 0.45)
        }
        .buttonStyle(FSPressStyle())
        .accessibilityAddTraits(.isButton)
    }

    private var foreground: Color {
        switch role {
        case .primary: return .fsInkOnAccent
        case .outline, .quiet: return .fsInk
        }
    }

    private var background: Color {
        switch role {
        case .primary: return .fsAccent
        case .outline: return .clear
        case .quiet: return .fsAccentSoft
        }
    }

    private var border: Color {
        switch role {
        case .primary: return .clear
        case .outline: return .fsInk
        case .quiet: return .clear
        }
    }
}

public struct FSIconButton: View {
    private let systemImage: String
    private let label: String
    private let action: () -> Void

    public init(systemImage: String, label: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.label = label
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.fsInk)
                .frame(width: 52, height: 52)
                .background(Circle().fill(Color.fsAccentSoft))
        }
        .buttonStyle(FSPressStyle())
        .fsMinTouchTarget()
        .accessibilityLabel(label)
    }
}

struct FSPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

public struct FSTag: View {
    public enum Tone { case neutral, leaf, alert }

    private let text: String
    private let tone: Tone
    private let systemImage: String?

    public init(_ text: String, tone: Tone = .neutral, systemImage: String? = nil) {
        self.text = text
        self.tone = tone
        self.systemImage = systemImage
    }

    public var body: some View {
        HStack(spacing: FSMetrics.space1) {
            if let systemImage { Image(systemName: systemImage).imageScale(.small) }
            Text(text).font(.fsCaption)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, FSMetrics.space3)
        .padding(.vertical, FSMetrics.space2)
        .background(Capsule().fill(fill))
        .overlay(Capsule().strokeBorder(foreground.opacity(0.35), lineWidth: 1))
    }

    private var fill: Color {
        switch tone {
        case .neutral: return .fsAccentSoft
        case .leaf: return Color.fsLeaf.opacity(0.18)
        case .alert: return Color.fsAccent.opacity(0.16)
        }
    }

    private var foreground: Color {
        switch tone {
        case .neutral: return .fsInk
        case .leaf: return .fsLeaf
        case .alert: return .fsAccent
        }
    }
}

struct FSButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
                FSButton("Scanner un produit", systemImage: "barcode.viewfinder") {}
                FSButton("Saisir le code", role: .outline) {}
                FSButton("Plus tard", role: .quiet) {}
                HStack {
                    FSTag("Sans gluten", tone: .leaf, systemImage: "checkmark")
                    FSTag("Trop salé", tone: .alert, systemImage: "exclamationmark.triangle")
                    FSIconButton(systemImage: "gearshape", label: "Réglages") {}
                }
            }
            .padding(24)
            .background(Color.fsBackground)
    }
}
