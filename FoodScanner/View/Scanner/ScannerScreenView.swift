//
//  ScannerScreenView.swift
//  FoodScanner
//
//  Écran Scanner : remplace ScannerViewController (AVFoundation) + saisie
//  manuelle UISearchBar/UIToolbar par FSBarcodeField/FSKeypad. Succès de
//  scan/saisie pousse ProductSheetView -> NutrientsScreenView via une
//  NavigationStack locale à cet onglet.
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
                        // Masqué tant que FSScanStatusBanner occupe le haut de l'écran,
                        // pour éviter tout chevauchement visuel avec le bandeau.
                        .opacity(model.banner == nil ? 1 : 0)
                }

                if let banner = model.banner {
                    FSScanStatusBanner(banner)
                        .padding(.horizontal, FSMetrics.space3)
                        .padding(.top, FSMetrics.space3)
                }

                // Panneau ancré en bas via VStack+Spacer : sa position de repos est
                // toujours au-dessus de la safe area fournie par RootTabBarController
                // (donc au-dessus de la tabbar). Le contenu qui peut grandir (champ +
                // FSKeypad) est isolé dans un `ScrollView` borné à une fraction de la
                // hauteur RÉELLEMENT disponible (mesurée via `GeometryReader`, comme le
                // fait déjà FSSceneFooter dans FoodScannerUI — jamais `UIScreen.main`,
                // non fiable en Split View/paysage) : quand FSKeypad apparaît, la zone
                // défile plutôt que de déborder du panneau — sans ce plafond, le
                // panneau dépassait la hauteur écran et les boutons pavé/lampe se
                // retrouvaient rendus sous la tabbar (invisibles, cachés derrière
                // elle). Ces boutons restent hors du ScrollView, donc toujours
                // visibles et jamais recouverts par la tabbar, quel que soit l'état
                // du clavier/pavé.
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
                                    // On ferme le clavier système avant d'afficher le FSKeypad :
                                    // les deux ne doivent jamais être visibles en même temps,
                                    // sinon leur hauteur cumulée peut repousser le panneau
                                    // au-delà de la safe area (sous la tabbar).
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
