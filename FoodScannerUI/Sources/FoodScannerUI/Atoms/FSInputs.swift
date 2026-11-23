//
//  FSInputs.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import SwiftUI

public struct FSBarcodeField: View {
    @Binding private var code: String
    @FocusState private var focused: Bool
    @Environment(\.fsResolvedContrast) private var contrast

    public init(code: Binding<String>) {
        self._code = code
    }

    private var isValid: Bool { (8...14).contains(code.count) }

    private var strokeColor: Color {
        if focused { return .fsFocus }
        return contrast == .increased ? .fsBorderStrong : .fsBorder
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: FSMetrics.space2) {
            Text(FSL10n.BarcodeField.label)
                .font(.fsOverline)
                .tracking(1.4)
                .textCase(.uppercase)
                .foregroundStyle(Color.fsInkSecondary)

            HStack(spacing: FSMetrics.space3) {
                Image(systemName: FSSymbol.barcode)
                    .foregroundStyle(Color.fsInkSecondary)
                    .accessibilityHidden(true)

                TextField("3017620422003", text: $code)
                    .font(.fsText(22, weight: .bold))
                    .foregroundStyle(Color.fsInk)
                    .keyboardType(.numberPad)
                    .textContentType(.none)
                    .focused($focused)
                    .accessibilityLabel(FSL10n.BarcodeField.accessibilityLabel)
                    .accessibilityHint(FSL10n.BarcodeField.accessibilityHint)
                    .accessibilityValue(!code.isEmpty && !isValid ? FSL10n.BarcodeField.invalidHint : "")

                if !code.isEmpty {
                    Button {
                        code = ""
                        FSHaptics.play(.selection)
                    } label: {
                        Image(systemName: FSSymbol.clear)
                            .foregroundStyle(Color.fsInkSecondary)
                    }
                    .fsMinTouchTarget()
                    .accessibilityLabel(FSL10n.BarcodeField.clearLabel)
                }
            }
            .padding(.horizontal, FSMetrics.space4)
            .frame(minHeight: FSMetrics.controlHeight)
            .background(
                RoundedRectangle(cornerRadius: FSMetrics.radiusMedium, style: .continuous)
                    .fill(Color.fsSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: FSMetrics.radiusMedium, style: .continuous)
                    .strokeBorder(strokeColor,
                                  lineWidth: focused ? 3 : FSMetrics.borderWidth(for: contrast))
            )

            if !code.isEmpty && !isValid {
                Label(FSL10n.BarcodeField.invalidHint, systemImage: FSSymbol.info)
                    .font(.fsCaption)
                    .foregroundStyle(Color.fsAccent)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(FSL10n.BarcodeField.invalidHint)
            }
        }
    }
}

/// Key height clamps 44 pt (min touch target) … 72 pt (comfortable ceiling);
/// key glyph is 28 pt bold with a 19 pt minimum scale floor. Width clamps to 420 pt.
public struct FSKeypad: View {
    @Binding private var code: String
    private let onValidate: () -> Void
    @Environment(\.fsResolvedContrast) private var contrast

    public init(code: Binding<String>, onValidate: @escaping () -> Void) {
        self._code = code
        self.onValidate = onValidate
    }

    private let keys: [[String]] = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["", "0", "⌫"]]

    public var body: some View {
        VStack(spacing: FSMetrics.space3) {
            GeometryReader { proxy in
                ScrollView {
                    keyGrid
                        .frame(minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .frame(maxHeight: keyGridMaxHeight)

            FSButton(FSL10n.Keypad.submitButton, systemImage: FSSymbol.search, action: onValidate)
                .disabled(code.count < 8)
                .lineLimit(1)
                .fsAccessibilityIdentifier(.keypadValidate)
        }
        .frame(maxWidth: FSMetrics.keypadMaxWidth)
    }

    private var keyGrid: some View {
        VStack(spacing: FSMetrics.space3) {
            ForEach(keys.indices, id: \.self) { row in
                HStack(spacing: FSMetrics.space3) {
                    ForEach(keys[row], id: \.self) { key in
                        if key.isEmpty {
                            Color.clear
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .frame(minHeight: FSMetrics.minTouchTarget,
                                       maxHeight: FSMetrics.keypadKeyMaxHeight)
                                .accessibilityHidden(true)
                        } else {
                            keyButton(key)
                        }
                    }
                }
            }
        }
    }

    /// Tallest the key grid gets: every key row at its 72 pt ceiling plus the inter-row gaps.
    private var keyGridMaxHeight: CGFloat {
        FSMetrics.keypadKeyMaxHeight * CGFloat(keys.count)
            + FSMetrics.space3 * CGFloat(keys.count - 1)
    }

    private func keyFill(for key: String) -> Color {
        guard key == "⌫" else { return .fsSurface }
        return contrast == .increased ? .fsAccentSoftStrong : .fsAccentSoft
    }

    private func keyButton(_ key: String) -> some View {
        Button {
            FSHaptics.play(.selection)
            if key == "⌫" {
                if !code.isEmpty { code.removeLast() }
            } else if code.count < 14 {
                code.append(key)
            }
        } label: {
            Text(key)
                .font(.fsText(FSMetrics.keypadKeyGlyph, weight: contrast == .increased ? .heavy : .bold))
                .minimumScaleFactor(FSMetrics.minReadableText / FSMetrics.keypadKeyGlyph)
                .lineLimit(1)
                .foregroundStyle(Color.fsInk)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: FSMetrics.minTouchTarget,
                       maxHeight: FSMetrics.keypadKeyMaxHeight)
                .background(
                    RoundedRectangle(cornerRadius: FSMetrics.radiusMedium, style: .continuous)
                        .fill(keyFill(for: key))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: FSMetrics.radiusMedium, style: .continuous)
                        .strokeBorder(contrast == .increased ? Color.fsBorderStrong : Color.fsBorder,
                                      lineWidth: FSMetrics.borderWidth(for: contrast))
                )
        }
        .buttonStyle(FSPressStyle())
        .accessibilityLabel(key == "⌫" ? FSL10n.Keypad.deleteHint : key)
        .fsAccessibilityIdentifier(key == "⌫" ? .keypadKeyDelete : .keypadKey(key))
    }
}

public struct FSToggleRow: View {
    private let title: String
    private let explanation: String?
    private let systemImage: String?
    @Binding private var isOn: Bool

    public init(_ title: String, explanation: String? = nil, systemImage: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.explanation = explanation
        self.systemImage = systemImage
        self._isOn = isOn
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
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
                    if let explanation {
                        Text(explanation)
                            .font(.fsCaption)
                            .foregroundStyle(Color.fsInkSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .tint(Color.fsLeaf)
        .padding(FSMetrics.space4)
        .frame(minHeight: FSMetrics.minTouchTarget)
        .fsCard(radius: FSMetrics.radiusMedium)
        .onChange(of: isOn) { FSHaptics.play(.selection) }
    }
}

public struct FSTextSizeSlider: View {
    @Binding private var scale: Double

    public init(scale: Binding<Double>) {
        self._scale = scale
    }

    /// Matches `AppDynamicTypeScale`'s step table 1:1 (one `UIContentSizeCategory` per
    /// 0.1 step, `.large` anchored at 1.0): the app owns whether/why the control is
    /// disabled (system already at its maximum), this component just renders the range.
    private static let lowerBound = 0.7
    private static let upperBound = 1.8
    private static let step = 0.1
    private static let range = lowerBound...upperBound

    public var body: some View {
        VStack(alignment: .leading, spacing: FSMetrics.space3) {
            Text(FSL10n.TextSizeSlider.label)
                .font(.fsBody)
                .foregroundStyle(Color.fsInk)

            HStack(spacing: FSMetrics.space3) {
                Text("A").font(.fsText(15, weight: .bold)).accessibilityHidden(true)
                Slider(value: $scale, in: Self.range, step: Self.step) {
                    Text(FSL10n.TextSizeSlider.label)
                } minimumValueLabel: {
                    EmptyView()
                } maximumValueLabel: {
                    EmptyView()
                }
                .tint(Color.fsLeaf)
                .accessibilityValue(FSL10n.TextSizeSlider.valuePercent(String(Int(scale * 100))))
                Text("A").font(.fsText(28, weight: .bold)).accessibilityHidden(true)
            }

            Text(FSL10n.TextSizeSlider.preview)
                .font(.fsText(19 * scale))
                .foregroundStyle(Color.fsInkSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(FSMetrics.space3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: FSMetrics.radiusSmall, style: .continuous)
                        .fill(Color.fsAccentSoft)
                )
        }
        .padding(FSMetrics.space4)
        .fsCard(radius: FSMetrics.radiusMedium)
    }
}

struct FSKeypad_Previews: PreviewProvider {
    private struct Demo: View {
        @State private var code = "30176204"

        /// Grid at its 72 pt-per-key ceiling + validate button + spacing: nothing scrolls.
        private static let roomy = FSMetrics.keypadKeyMaxHeight * 4 + FSMetrics.space3 * 3
            + FSMetrics.controlHeight + FSMetrics.space3
        /// Keys sit between the 44 pt floor and the 72 pt ceiling: comfortable fit.
        private static let fit: CGFloat = 320
        /// Below the compressed grid height: the grid scrolls, the button stays pinned.
        private static let compact: CGFloat = 220

        var body: some View {
            HStack(alignment: .top, spacing: FSMetrics.space4) {
                FSKeypad(code: $code) {}.frame(height: Self.roomy)
                FSKeypad(code: $code) {}.frame(height: Self.fit)
                FSKeypad(code: $code) {}.frame(height: Self.compact)
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

struct FSTextSizeSlider_Previews: PreviewProvider {
    private struct Demo: View {
        @State private var free = 1.0
        @State private var atSystemMaximum = 1.8

        var body: some View {
            VStack(spacing: FSMetrics.space4) {
                FSTextSizeSlider(scale: $free)
                FSTextSizeSlider(scale: $atSystemMaximum)
                    .disabled(true)
                    .opacity(0.4)
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

struct FSBarcodeField_Previews: PreviewProvider {
    private struct Demo: View {
        @State private var code = "301762"

        var body: some View {
            FSBarcodeField(code: $code)
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
