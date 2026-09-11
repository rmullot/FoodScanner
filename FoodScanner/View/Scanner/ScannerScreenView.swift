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
    @State private var code: String = ""
    @State private var showsKeypad: Bool = false
    @State private var cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    init(model: ScannerViewModel, onProductFound: @escaping (FoodStruct) -> Void) {
        self.model = model
        self.onProductFound = onProductFound
    }

    var body: some View {
        ZStack(alignment: .top) {
            if cameraAuthorizationStatus == .authorized {
                CameraPreviewView { barcode in
                    model.getFoodInformations(barcode: barcode)
                }
                .ignoresSafeArea()
            } else {
                cameraUnavailablePlaceholder
                    .ignoresSafeArea()
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

            GeometryReader { proxy in
                VStack {
                    Spacer()

                    VStack(spacing: 0) {
                        ZStack {
                            if showsKeypad {
                                ScrollView {
                                    VStack(spacing: FSMetrics.space3) {
                                        FSBarcodeField(code: $code)

                                        FSKeypad(code: $code) {
                                            model.getFoodInformations(barcode: code)
                                        }
                                        .frame(height: max(FSMetrics.keypadMinRegionHeight, proxy.size.height * 0.45))
                                    }
                                    .padding(.horizontal, FSMetrics.space2)
                                    .padding(.bottom, FSMetrics.space3)
                                }
                                .frame(maxHeight: proxy.size.height * 0.75)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .clipped()

                        HStack {
                            FSButton(showsKeypad ? L10n.Scanner.hideKeypadButton : L10n.Scanner.showKeypadButton,
                                     role: .quiet,
                                     systemImage: SFSymbol.keypad) {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                                 to: nil, from: nil, for: nil)
                                showsKeypad.toggle()
                            }
                            .accessibilityIdentifier("scanner.toggleKeypad")
                            FSIconButton(systemImage: model.lampActivated ? SFSymbol.flashlightOn : SFSymbol.flashlightOff,
                                         label: model.lampActivated ? L10n.Scanner.lampOffLabel : L10n.Scanner.lampOnLabel) {
                                model.toggleLamp()
                            }
                        }
                        .background(Color.fsSurface)
                    }
                    .appAnimation(.easeInOut, value: showsKeypad)
                    .padding(FSMetrics.space4)
                    .fsCard(radius: FSMetrics.radiusLarge)
                    .padding(.horizontal, FSMetrics.space3)
                    .padding(.bottom, FSMetrics.space4)
                }
            }
        }
        .navigationTitle(L10n.Common.tabScanner)
        .navigationBarTitleDisplayMode(.large)
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            updateCameraAuthorizationStatus()
        }
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

    private var cameraUnavailablePlaceholder: some View {
        VStack(spacing: FSMetrics.space4) {
            Spacer()

            FSMascot(.strawberry, size: 96)

            Text(cameraAuthorizationStatus == .notDetermined
                 ? L10n.Scanner.cameraPendingTitle
                 : L10n.Scanner.cameraUnavailableTitle)
                .font(.fsHeadline)
                .foregroundStyle(Color.fsInk)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(L10n.Scanner.manualEntryHint)
                .font(.fsBody)
                .foregroundStyle(Color.fsInkSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(FSMetrics.space6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.fsBackground)
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

#Preview("Accessibilité XL") {
    NavigationStack {
        ScannerScreenView(model: ScannerViewModel(), onProductFound: { _ in })
    }
    .environment(\.dynamicTypeSize, .accessibility5)
}
