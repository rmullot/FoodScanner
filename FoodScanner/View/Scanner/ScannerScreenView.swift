//
//  ScannerScreenView.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//

import SwiftUI
import AVFoundation
import FoodScannerUI

struct ScannerScreenView: View {
    @ObservedObject private var model: ScannerViewModel
    private let onProductFound: (FoodStruct) -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @AppStorage(.hasSeenOnboarding) private var hasSeenOnboarding = false
    @State private var code: String = ""
    @State private var showsKeypad: Bool = false
    @State private var panelHeight: CGFloat = 0
    @State private var cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    init(model: ScannerViewModel, onProductFound: @escaping (FoodStruct) -> Void) {
        self.model = model
        self.onProductFound = onProductFound
    }

    private var layout: ScannerLayout {
        ScannerLayout(horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                cameraLayer
                if layout.isSideBySide {
                    HStack(spacing: 0) {
                        statusArea
                        inputPanel(containerHeight: proxy.size.height)
                            .frame(maxWidth: layout.panelMaxWidth(showsKeypad: showsKeypad))
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                } else {
                    ZStack(alignment: .bottom) {
                        statusArea
                            .padding(.bottom, panelHeight)
                        inputPanel(containerHeight: proxy.size.height)
                            .frame(maxWidth: layout.panelMaxWidth(showsKeypad: showsKeypad))
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .navigationTitle(L10n.Common.tabScanner)
        .navigationBarTitleDisplayMode(.large)
        .toolbar(layout.isCompactHeight && showsKeypad ? .hidden : .automatic, for: .navigationBar)
        .onChange(of: model.banner) { _, newBanner in
            if case .found = newBanner {
                UIAccessibility.post(notification: .announcement,
                                      argument: L10n.Scanner.productFoundAnnouncement)
            }
        }
        .onDisappear {
            model.forceSwitchOffLamp()
        }
        .onAppear {
            updateCameraAuthorizationStatus()
        }
        .onChange(of: hasSeenOnboarding) { _, _ in
            updateCameraAuthorizationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            updateCameraAuthorizationStatus()
        }
    }

    @ViewBuilder
    private var cameraLayer: some View {
        if cameraAuthorizationStatus == .authorized {
            CameraPreviewView { barcode in
                model.getFoodInformations(barcode: barcode)
            }
            .ignoresSafeArea()
        } else {
            Color.fsBackground.ignoresSafeArea()
        }
    }

    private var statusArea: some View {
        Color.clear
            .overlay(alignment: .top) {
                ZStack(alignment: .top) {
                    if cameraAuthorizationStatus != .authorized {
                        ViewThatFits(in: .vertical) {
                            cameraUnavailablePlaceholder(showsMascot: true, showsHint: true)
                            cameraUnavailablePlaceholder(showsMascot: false, showsHint: true)
                            cameraUnavailablePlaceholder(showsMascot: false, showsHint: false)
                        }
                    }

                    if model.isNetworkActive {
                        ProgressView()
                            .controlSize(.small)
                            .tint(Color.fsAccent)
                            .padding(FSMetrics.space3)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(L10n.Scanner.networkActivityLabel)
                            .frame(maxWidth: .infinity, alignment: .topTrailing)
                            .opacity(model.banner == nil ? 1 : 0)
                    }

                    if let banner = model.banner {
                        FSScanStatusBanner(banner, onFoundTap: onFoundTap(for: banner))
                            .padding(.horizontal, FSMetrics.space3)
                            .padding(.top, FSMetrics.space3)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
    }

    private func inputPanel(containerHeight: CGFloat) -> some View {
        ViewThatFits(in: .vertical) {
            panelBody(containerHeight: containerHeight)
            ScrollView { panelBody(containerHeight: containerHeight) }
                .scrollBounceBehavior(.basedOnSize)
        }
        .background {
            GeometryReader { geometry in
                Color.clear.preference(key: PanelHeightKey.self, value: geometry.size.height)
            }
        }
        .onPreferenceChange(PanelHeightKey.self) { panelHeight = $0 }
        .frame(maxHeight: layout.panelMaxHeight(containerHeight: containerHeight), alignment: .bottom)
    }

    @ViewBuilder
    private func panelBody(containerHeight: CGFloat) -> some View {
        if layout.isCompactHeight && showsKeypad {
            twoColumnPanel(containerHeight: containerHeight)
        } else {
            stackedPanel(containerHeight: containerHeight)
        }
    }

    private func stackedPanel(containerHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            ZStack {
                if showsKeypad {
                    VStack(spacing: FSMetrics.space3) {
                        FSBarcodeField(code: $code)
                        keypad(containerHeight: containerHeight)
                    }
                    .padding(.horizontal, FSMetrics.space2)
                    .padding(.bottom, FSMetrics.space3)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .clipped()

            controlsRow
        }
        .appAnimation(.easeInOut, value: showsKeypad)
        .modifier(PanelCard(topPadding: layout.panelTopPadding, bottomPadding: layout.panelBottomPadding))
    }

    private func twoColumnPanel(containerHeight: CGFloat) -> some View {
        HStack(alignment: .top, spacing: FSMetrics.space4) {
            VStack(spacing: FSMetrics.space3) {
                FSBarcodeField(code: $code)
                Spacer(minLength: 0)
                controlsRow
            }
            keypad(containerHeight: containerHeight)
        }
        .appAnimation(.easeInOut, value: showsKeypad)
        .modifier(PanelCard(topPadding: layout.panelTopPadding, bottomPadding: layout.panelBottomPadding))
    }

    private func keypad(containerHeight: CGFloat) -> some View {
        FSKeypad(code: $code) {
            model.getFoodInformations(barcode: code)
        }
        .frame(height: layout.keypadHeight(containerHeight: containerHeight))
    }

    private var controlsRow: some View {
        HStack {
            FSButton(showsKeypad ? L10n.Scanner.hideKeypadButton : L10n.Scanner.showKeypadButton,
                     role: .quiet,
                     systemImage: SFSymbol.keypad) {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                 to: nil, from: nil, for: nil)
                showsKeypad.toggle()
            }
            .accessibilityIdentifier(.scannerToggleKeypad)
            FSIconButton(systemImage: model.lampActivated ? SFSymbol.flashlightOn : SFSymbol.flashlightOff,
                         label: model.lampActivated ? L10n.Scanner.lampOffLabel : L10n.Scanner.lampOnLabel) {
                model.toggleLamp()
            }
        }
        .background(Color.fsSurface)
    }

    private func onFoundTap(for banner: FSScanStatusBanner.State) -> (() -> Void)? {
        guard case .found = banner else { return nil }
        return {
            guard let food = model.scannedFood else { return }
            onProductFound(food)
        }
    }

    private func updateCameraAuthorizationStatus() {
        let newStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let wasAuthorized = cameraAuthorizationStatus == .authorized
        cameraAuthorizationStatus = newStatus
        if !wasAuthorized && newStatus == .authorized {
            UIAccessibility.post(notification: .announcement,
                                  argument: L10n.Scanner.cameraActivatedAnnouncement)
        }
    }

    private func cameraUnavailablePlaceholder(showsMascot: Bool, showsHint: Bool) -> some View {
        VStack(spacing: FSMetrics.space4) {
            Spacer()

            if showsMascot {
                FSMascot(.strawberry, size: 96)
            }

            Text(cameraAuthorizationStatus == .notDetermined
                 ? L10n.Scanner.cameraPendingTitle
                 : L10n.Scanner.cameraUnavailableTitle)
                .font(.fsHeadline)
                .foregroundStyle(Color.fsInk)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if showsHint {
                Text(L10n.Scanner.manualEntryHint)
                    .font(.fsBody)
                    .foregroundStyle(Color.fsInkSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(FSMetrics.space6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Clair") {
    NavigationStack {
        ScannerScreenView(model: ScannerViewModel(), onProductFound: { _ in })
    }
    .preferredColorScheme(.light)
}

#Preview("Sombre") {
    NavigationStack {
        ScannerScreenView(model: ScannerViewModel(), onProductFound: { _ in })
    }
    .preferredColorScheme(.dark)
}

#Preview("iPad paysage", traits: .landscapeLeft) {
    NavigationStack {
        ScannerScreenView(model: ScannerViewModel(), onProductFound: { _ in })
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("Accessibilité XL") {
    NavigationStack {
        ScannerScreenView(model: ScannerViewModel(), onProductFound: { _ in })
    }
    .environment(\.dynamicTypeSize, .accessibility5)
}

private struct PanelCard: ViewModifier {
    let topPadding: CGFloat
    let bottomPadding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(FSMetrics.space4)
            .fsCard(radius: FSMetrics.radiusLarge)
            .padding(.horizontal, FSMetrics.space3)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
    }
}

private struct PanelHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
