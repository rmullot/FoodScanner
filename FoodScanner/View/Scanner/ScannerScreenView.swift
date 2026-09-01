//
//  ScannerScreenView.swift
//  FoodScanner
//
//  Scanner screen: replaces ScannerViewController (AVFoundation) + manual
//  UISearchBar/UIToolbar entry with FSBarcodeField/FSKeypad. A successful
//  scan/entry pushes ProductSheetView -> NutrientsScreenView via a
//  NavigationStack local to this tab.
//

import SwiftUI
import FoodScannerUI

struct ScannerScreenView: View {
    @StateObject private var model = ScannerScreenModel()
    @ObservedObject private var networkActivity = NetworkActivityManager.sharedInstance
    @State private var code: String = ""
    @State private var showsKeypad: Bool = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .top) {
                CameraPreviewView { barcode in
                    model.getFoodInformations(barcode: barcode)
                }
                .ignoresSafeArea()

                if networkActivity.isActive {
                    ProgressView()
                        .controlSize(.small)
                        .tint(Color.fsAccent)
                        .padding(FSMetrics.space3)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Requête réseau en cours")
                        .frame(maxWidth: .infinity, alignment: .topTrailing)
                        // Hidden while FSScanStatusBanner occupies the top of the screen,
                        // to avoid any visual overlap with the banner.
                        .opacity(model.banner == nil ? 1 : 0)
                }

                if let banner = model.banner {
                    FSScanStatusBanner(banner)
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
                            ScrollView {
                                VStack(spacing: FSMetrics.space3) {
                                    FSBarcodeField(code: $code) { submitted in
                                        model.getFoodInformations(barcode: submitted)
                                    }

                                    if showsKeypad {
                                        FSKeypad(code: $code) {
                                            model.getFoodInformations(barcode: code)
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: showsKeypad ? proxy.size.height * 0.55 : nil)

                            HStack {
                                FSButton(showsKeypad ? "Masquer le pavé" : "Pavé numérique",
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
                                             label: model.lampActivated ? "Éteindre la lampe" : "Allumer la lampe") {
                                    model.toggleLamp()
                                }
                            }
                        }
                        .padding(FSMetrics.space4)
                        .fsCard(radius: FSMetrics.radiusLarge)
                        .padding(.horizontal, FSMetrics.space3)
                        .padding(.bottom, FSMetrics.space4)
                    }
                }
            }
            .navigationTitle("Scanner")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: FoodStruct.self) { food in
                ProductSheetView(model: FoodDetailModel(food: food))
            }
            .onChange(of: model.scannedFood) { food in
                guard let food else { return }
                path.append(food)
                model.consumeScannedFood()
            }
            .onDisappear {
                model.forceSwitchOffLamp()
            }
        }
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
