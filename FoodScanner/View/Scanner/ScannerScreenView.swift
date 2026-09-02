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
    @StateObject private var model = ScannerScreenModel()
    @ObservedObject private var networkActivity = NetworkActivityManager.sharedInstance
    @State private var code: String = ""
    @State private var showsKeypad: Bool = false
    @State private var path = NavigationPath()
    @State private var cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    var body: some View {
        NavigationStack(path: $path) {
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

                if networkActivity.isActive {
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

                        VStack(spacing: FSMetrics.space3) {
                            if showsKeypad {
                                ScrollView {
                                    VStack(spacing: FSMetrics.space3) {
                                        FSBarcodeField(code: $code) { submitted in
                                            model.getFoodInformations(barcode: submitted)
                                        }

                                        FSKeypad(code: $code) {
                                            model.getFoodInformations(barcode: code)
                                        }
                                    }
                                    .padding(.horizontal, FSMetrics.space2)
                                }
                                .frame(maxHeight: proxy.size.height * 0.55)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }

                            HStack {
                                FSButton(showsKeypad ? L10n.Scanner.hideKeypadButton : L10n.Scanner.showKeypadButton,
                                         role: .quiet,
                                         systemImage: "square.grid.3x3") {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                                     to: nil, from: nil, for: nil)
                                    showsKeypad.toggle()
                                }
                                FSIconButton(systemImage: model.lampActivated ? "flashlight.on.fill" : "flashlight.off.fill",
                                             label: model.lampActivated ? L10n.Scanner.lampOffLabel : L10n.Scanner.lampOnLabel) {
                                    model.toggleLamp()
                                }
                            }
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
            .navigationDestination(for: FoodStruct.self) { food in
                ProductDetailScreenView(model: FoodDetailModel(food: food))
            }
            .onChange(of: path) { newPath in
                if newPath.isEmpty {
                    model.resetForNewScan()
                }
            }
            .onChange(of: model.banner) { newBanner in
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
    }

    private func onFoundTap(for banner: FSScanStatusBanner.State) -> (() -> Void)? {
        guard case .found = banner else { return nil }
        return {
            guard let food = model.scannedFood else { return }
            path.append(food)
            model.consumeScannedFood()
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

extension FoodStruct: Hashable {
    static func == (lhs: FoodStruct, rhs: FoodStruct) -> Bool {
        lhs.barcode == rhs.barcode && lhs.lastUpdate == rhs.lastUpdate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(barcode)
        hasher.combine(lastUpdate)
    }
}

#Preview("Clair") {
    ScannerScreenView()
        .preferredColorScheme(.light)
}

#Preview("Sombre") {
    ScannerScreenView()
        .preferredColorScheme(.dark)
}

#Preview("Accessibilité XL") {
    ScannerScreenView()
        .environment(\.dynamicTypeSize, .accessibility5)
}
