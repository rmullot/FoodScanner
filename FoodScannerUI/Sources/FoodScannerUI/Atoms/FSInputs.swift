import SwiftUI

/// Barcode entry field. Numeric keyboard, large characters,
/// visible validation, and a custom keypad for hurried fingers.
public struct FSBarcodeField: View {
    @Binding private var code: String
    private let onSubmit: (String) -> Void
    @FocusState private var focused: Bool

    public init(code: Binding<String>, onSubmit: @escaping (String) -> Void) {
        self._code = code
        self.onSubmit = onSubmit
    }

    private var isValid: Bool { (8...14).contains(code.count) }

    public var body: some View {
        VStack(alignment: .leading, spacing: FSMetrics.space2) {
            Text("Code-barres")
                .font(.fsOverline)
                .tracking(1.4)
                .textCase(.uppercase)
                .foregroundStyle(Color.fsInkSecondary)

            HStack(spacing: FSMetrics.space3) {
                Image(systemName: "barcode")
                    .foregroundStyle(Color.fsInkSecondary)
                    .accessibilityHidden(true)

                TextField("3017620422003", text: $code)
                    .font(.fsText(22, weight: .bold))
                    .foregroundStyle(Color.fsInk)
                    .keyboardType(.numberPad)
                    .textContentType(.none)
                    .focused($focused)
                    .accessibilityLabel("Code-barres du produit")
                    .accessibilityHint("Huit à quatorze chiffres")

                if !code.isEmpty {
                    Button {
                        code = ""
                        FSHaptics.play(.selection)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.fsInkSecondary)
                    }
                    .fsMinTouchTarget()
                    .accessibilityLabel("Effacer le code")
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
                    .strokeBorder(focused ? Color.fsFocus : Color.fsBorder,
                                  lineWidth: focused ? 3 : FSMetrics.borderWidth)
            )

            if !code.isEmpty && !isValid {
                Label("Un code-barres compte entre 8 et 14 chiffres.", systemImage: "info.circle")
                    .font(.fsCaption)
                    .foregroundStyle(Color.fsAccent)
                    .fixedSize(horizontal: false, vertical: true)
            }

            FSButton("Chercher ce produit", systemImage: "magnifyingglass") {
                onSubmit(code)
            }
            .disabled(!isValid)
        }
    }
}

/// Accessible numeric keypad: 12 keys of 64 pt, haptic feedback,
/// explicit VoiceOver labels.
public struct FSKeypad: View {
    @Binding private var code: String
    private let onValidate: () -> Void

    public init(code: Binding<String>, onValidate: @escaping () -> Void) {
        self._code = code
        self.onValidate = onValidate
    }

    private let keys: [[String]] = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["", "0", "⌫"]]

    public var body: some View {
        VStack(spacing: FSMetrics.space3) {
            ForEach(keys.indices, id: \.self) { row in
                HStack(spacing: FSMetrics.space3) {
                    ForEach(keys[row], id: \.self) { key in
                        if key.isEmpty {
                            Color.clear.frame(height: 64)
                        } else {
                            keyButton(key)
                        }
                    }
                }
            }
            FSButton("Valider", action: onValidate)
                .disabled(code.count < 8)
        }
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
                .font(.fsText(28, weight: .bold))
                .foregroundStyle(Color.fsInk)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: FSMetrics.radiusMedium, style: .continuous)
                        .fill(key == "⌫" ? Color.fsAccentSoft : Color.fsSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: FSMetrics.radiusMedium, style: .continuous)
                        .strokeBorder(Color.fsBorder, lineWidth: FSMetrics.borderWidth)
                )
        }
        .buttonStyle(FSPressStyle())
        .accessibilityLabel(key == "⌫" ? "Effacer le dernier chiffre" : key)
    }
}

/// Settings row with a toggle, explanation, and full-width target.
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
        .onChange(of: isOn) { _ in FSHaptics.play(.selection) }
    }
}

/// Text size slider, with an immediate preview of the chosen scale.
public struct FSTextSizeSlider: View {
    @Binding private var scale: Double

    public init(scale: Binding<Double>) { self._scale = scale }

    public var body: some View {
        VStack(alignment: .leading, spacing: FSMetrics.space3) {
            Text("Taille du texte")
                .font(.fsBody)
                .foregroundStyle(Color.fsInk)

            HStack(spacing: FSMetrics.space3) {
                Text("A").font(.fsText(15, weight: .bold)).accessibilityHidden(true)
                Slider(value: $scale, in: 0.9...2.0, step: 0.1) {
                    Text("Taille du texte")
                } minimumValueLabel: {
                    EmptyView()
                } maximumValueLabel: {
                    EmptyView()
                }
                .tint(Color.fsLeaf)
                .accessibilityValue("\(Int(scale * 100)) pour cent")
                Text("A").font(.fsText(28, weight: .bold)).accessibilityHidden(true)
            }

            Text("Un produit noté A est un bon choix.")
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
