//
//  ScannerScreenView.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//  Scanner screen: replaces ScannerViewController (AVFoundation) + manual
//  UISearchBar/UIToolbar entry with FSBarcodeField/FSKeypad. A successful
//  scan/entry shows a tappable "found" banner; tapping it pushes
//  ProductDetailScreenView via a NavigationStack local to this tab.
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
    // Camera authorization is only ever requested from OnboardingView
    // (AVCaptureDevice.requestAccess, triggered by the "Autoriser la caméra"
    // button). This screen must never itself be the trigger of the implicit
    // system permission prompt: `.startRunning()` on the capture session
    // triggers it, so `CameraPreviewView` is only constructed once the
    // authorization status is already `.authorized`. Before onboarding runs
    // (status `.notDetermined`), or if the user denied/restricted access, a
    // placeholder is shown instead — manual entry (FSBarcodeField/FSKeypad)
    // stays available regardless, so scanning by barcode is never blocked.
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
                        // Hidden while FSScanStatusBanner occupies the top of the screen,
                        // to avoid any visual overlap with the banner.
                        .opacity(model.banner == nil ? 1 : 0)
                }

                if let banner = model.banner {
                    FSScanStatusBanner(banner, onFoundTap: onFoundTap(for: banner))
                        .padding(.horizontal, FSMetrics.space3)
                        .padding(.top, FSMetrics.space3)
                }

                // Panel anchored to the bottom via VStack+Spacer: its resting position is
                // always above the safe area provided by RootTabBarController
                // (i.e. above the tab bar). Content that can grow (field +
                // FSKeypad) is confined to a `ScrollView` bounded to a fraction of the
                // ACTUALLY available height (measured via `GeometryReader`, as
                // FSSceneFooter already does in FoodScannerUI — never `UIScreen.main`,
                // unreliable in Split View/landscape): when FSKeypad appears, the area
                // scrolls instead of overflowing the panel — without this cap, the
                // panel would exceed the screen height and the keypad/flashlight
                // buttons would end up rendered under the tab bar (invisible, hidden
                // behind it). These buttons stay outside the ScrollView, so they
                // remain always visible and never covered by the tab bar, regardless
                // of the keyboard/keypad state.
                GeometryReader { proxy in
                    VStack {
                        Spacer()

                        VStack(spacing: FSMetrics.space3) {
                            // The whole field+keypad panel is collapsed by default and only
                            // appears once the user taps "Pavé numérique" — it must never be
                            // open on first launch. It grows bottom-to-top on appear and
                            // retracts top-to-bottom on disappear (the `.move(edge: .bottom)`
                            // transition below, since the panel is anchored to the bottom of
                            // the card) rather than just vanishing instantly. Driven by
                            // `.appAnimation(value: showsKeypad)` further down so it's skipped
                            // when the system or app "Reduce animations" setting is on.
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
                                    // Gives the system scroll indicator its own lane on the
                                    // trailing edge, matched by an equal leading inset so the
                                    // panel's content stays visually centered within its card
                                    // rather than shifting off-center relative to the card's
                                    // otherwise-symmetric margins (`.padding(FSMetrics.space4)`
                                    // + `.padding(.horizontal, FSMetrics.space3)` below).
                                    .padding(.horizontal, FSMetrics.space2)
                                }
                                .frame(maxHeight: proxy.size.height * 0.55)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }

                            HStack {
                                FSButton(showsKeypad ? L10n.Scanner.hideKeypadButton : L10n.Scanner.showKeypadButton,
                                         role: .quiet,
                                         systemImage: "square.grid.3x3") {
                                    // Dismiss the system keyboard before showing FSKeypad:
                                    // the two must never be visible at the same time,
                                    // otherwise their combined height can push the panel
                                    // past the safe area (under the tab bar).
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
                // Back at root (fiche popped/dismissed): re-arm detection so the
                // same barcode can be scanned again. See
                // `ScannerScreenModel.resetForNewScan()`.
                if newPath.isEmpty {
                    model.resetForNewScan()
                }
            }
            .onChange(of: model.banner) { newBanner in
                // Navigation is no longer automatic once a product is found
                // (the user must tap the banner — see `onFoundTap(for:)`), so
                // a VoiceOver user not already focused on the banner needs an
                // explicit announcement that it just became tappable;
                // otherwise the state change is silent for them, unlike a
                // sighted user who sees the banner appear.
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
                // Covers returning from the iOS Settings app after granting
                // camera access there (status changes without this view
                // reappearing via SwiftUI's own lifecycle).
                updateCameraAuthorizationStatus()
            }
        }
    }

    /// Builds the tap action for `FSScanStatusBanner`: only the `.found` state
    /// gets a tappable banner (pushes the resolved product onto this tab's
    /// NavigationStack); every other state (`.reading`, `.notFound`, `.offline`)
    /// gets `nil`, so `FSScanStatusBanner` renders passively with no tap
    /// affordance for those states.
    private func onFoundTap(for banner: FSScanStatusBanner.State) -> (() -> Void)? {
        guard case .found = banner else { return nil }
        return {
            guard let food = model.scannedFood else { return }
            path.append(food)
            model.consumeScannedFood()
        }
    }

    /// Refreshes `cameraAuthorizationStatus` (it may have changed since the
    /// last time this view was on screen — onboarding just finished, or the
    /// user granted/revoked access in iOS Settings), and, when access just
    /// became available, posts a VoiceOver announcement: the camera preview
    /// silently replaces the placeholder otherwise, which would leave
    /// screen-reader users unaware the screen's content just changed.
    private func updateCameraAuthorizationStatus() {
        let newStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let wasAuthorized = cameraAuthorizationStatus == .authorized
        cameraAuthorizationStatus = newStatus
        if !wasAuthorized && newStatus == .authorized {
            UIAccessibility.post(notification: .announcement,
                                  argument: L10n.Scanner.cameraActivatedAnnouncement)
        }
    }

    /// Shown instead of `CameraPreviewView` whenever camera authorization
    /// hasn't been granted yet (not requested, denied, or restricted).
    /// Manual barcode entry (FSBarcodeField/FSKeypad, below the safe area)
    /// remains fully usable in every case.
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
