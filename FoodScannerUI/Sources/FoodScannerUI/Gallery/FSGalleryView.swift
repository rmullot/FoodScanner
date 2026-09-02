//
//  FSGalleryView.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 08/25/2026.
//

import SwiftUI

/// Design system gallery: one tab per atoms/molecules, one tab
/// per reconstructed screen. Serves as a QA and demo playground.
public struct FSGalleryView: View {
    @State private var seasonOverride: FSSeason?
    @State private var code = "3017620422003"
    @State private var offlineOnly = false
    @State private var textScale = 1.0

    public init() {}

    public var body: some View {
        TabView {
            NavigationStack {
                componentsTab
                    .navigationTitle("Composants")
                    .background(Color.fsBackground.ignoresSafeArea())
            }
            .tabItem { Label("Composants", systemImage: "square.grid.2x2") }

            NavigationStack {
                screensTab
                    .navigationTitle("Écrans")
                    .background(Color.fsBackground.ignoresSafeArea())
            }
            .tabItem { Label("Écrans", systemImage: "iphone") }
        }
        .fsSeason(seasonOverride)
        .tint(Color.fsAccent)
    }

    // MARK: Components tab

    private var componentsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FSMetrics.space6) {
                seasonPicker

                section("Mascottes") {
                    HStack(spacing: FSMetrics.space3) {
                        ForEach(FSMascot.Kind.allCases) { kind in
                            VStack(spacing: 4) {
                                FSMascot(kind, size: 58)
                                Text(kind.frenchName)
                                    .font(.fsText(12))
                                    .foregroundStyle(Color.fsInkSecondary)
                            }
                        }
                    }
                }

                section("Boutons et puces") {
                    VStack(spacing: FSMetrics.space3) {
                        FSButton("Scanner un produit", systemImage: "barcode.viewfinder") {}
                        FSButton("Saisir le code", role: .outline) {}
                        FSButton("Plus tard", role: .quiet) {}
                        HStack {
                            FSTag("Bio", tone: .leaf, systemImage: "leaf")
                            FSTag("Trop salé", tone: .alert, systemImage: "exclamationmark.triangle")
                            FSTag("Hors ligne")
                        }
                    }
                }

                section("Nutri-Score") {
                    VStack(alignment: .leading, spacing: FSMetrics.space4) {
                        HStack(spacing: FSMetrics.space2) {
                            ForEach(FSNutriScore.allCases) { FSScoreBadge($0, size: .small) }
                        }
                        FSScoreScale(.d)
                    }
                }

                section("Nutriments") {
                    VStack(alignment: .leading, spacing: FSMetrics.space3) {
                        FSNutrientRow(.carbs, grams: 57.5)
                        FSNutrientRow(.fat, grams: 30.9)
                        FSNutrientRow(.protein, grams: 6.3)
                        FSNutrientRow(.salt, grams: 0.4)
                        HStack(alignment: .center, spacing: FSMetrics.space5) {
                            FSNutrientRing(segments: [
                                .init(nutrient: .carbs, grams: 57.5),
                                .init(nutrient: .fat, grams: 30.9),
                                .init(nutrient: .protein, grams: 6.3),
                                .init(nutrient: .fiber, grams: 3.4),
                                .init(nutrient: .salt, grams: 0.4)
                            ], score: .e, diameter: 170)
                            FSNutrientLegend()
                        }
                    }
                }

                section("Saisie") {
                    VStack(spacing: FSMetrics.space4) {
                        FSBarcodeField(code: $code) { _ in }
                        FSKeypad(code: $code) {}
                    }
                }

                section("Réglages") {
                    VStack(spacing: FSMetrics.space3) {
                        FSToggleRow("Lecture hors ligne uniquement",
                                    explanation: "N'interroge jamais le réseau, utilise le cache.",
                                    systemImage: "arrow.down.circle",
                                    isOn: $offlineOnly)
                        FSTextSizeSlider(scale: $textScale)
                    }
                }

                section("États et bandeaux") {
                    VStack(spacing: FSMetrics.space3) {
                        FSScanStatusBanner(.aiming)
                        FSScanStatusBanner(.found("Pâte à tartiner noisettes"), onFoundTap: {})
                        FSScanStatusBanner(.notFound)
                        FSOfflineBanner()
                    }
                }

                section("Saynètes") {
                    VStack(spacing: FSMetrics.space4) {
                        FSSceneFooter(.laboratory, caption: "Chaque valeur est relevée sur Open Food Facts, puis vérifiée ligne par ligne.")
                        FSSceneFooter(.picnic, caption: "Tout reste sur votre téléphone : les douze dernières fiches sont lisibles hors ligne.")
                    }
                }
            }
            .padding(FSMetrics.space5)
        }
    }

    // MARK: Screens tab

    private var screensTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FSMetrics.space6) {
                seasonPicker

                section("Fiche produit") {
                    VStack(alignment: .leading, spacing: FSMetrics.space4) {
                        FSProductCard(name: "Pâte à tartiner aux noisettes",
                                      brand: "Marque repère",
                                      quantity: "400 g",
                                      score: .e,
                                      seasonalHint: "De saison en ce moment : la fraise, notée A.")
                        FSScoreScale(.e)
                        FSNutrientRow(.carbs, grams: 57.5)
                        FSNutrientRow(.fat, grams: 30.9)
                        FSNutrientRow(.protein, grams: 6.3)
                        FSSceneFooter(.laboratory, caption: "Un doute sur une valeur ? Signalez-le, la fiche est corrigée pour tout le monde.")
                    }
                }

                section("Historique") {
                    VStack(spacing: FSMetrics.space3) {
                        FSOfflineBanner()
                        FSHistoryRow(name: "Yaourt nature", subtitle: "Scanné hier", score: .a) {}
                        FSHistoryRow(name: "Céréales chocolat", subtitle: "Scanné lundi", score: .c) {}
                        FSHistoryRow(name: "Code 5410041000122", subtitle: "Fiche incomplète hors ligne", isCached: true) {}
                        FSSceneFooter(.picnic, caption: "Tout reste sur votre téléphone : les douze dernières fiches sont lisibles hors ligne.")
                    }
                }

                section("Scan") {
                    VStack(spacing: FSMetrics.space4) {
                        FSScanStatusBanner(.aiming)
                        FSMascotRow(size: 56)
                        FSBarcodeField(code: $code) { _ in }
                    }
                }
            }
            .padding(FSMetrics.space5)
        }
    }

    // MARK: Tools

    private var seasonPicker: some View {
        VStack(alignment: .leading, spacing: FSMetrics.space2) {
            Text("Saison")
                .font(.fsOverline).tracking(1.4).textCase(.uppercase)
                .foregroundStyle(Color.fsInkSecondary)
            Picker("Saison", selection: $seasonOverride) {
                Text("Suit le thème").tag(FSSeason?.none)
                Text("Printemps-été").tag(FSSeason?.some(.springSummer))
                Text("Automne-hiver").tag(FSSeason?.some(.autumnWinter))
            }
            .pickerStyle(.segmented)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: FSMetrics.space3) {
            Text(title)
                .font(.fsTitle)
                .foregroundStyle(Color.fsInk)
            content()
        }
    }
}

struct FSGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        FSGalleryView()
        FSGalleryView().preferredColorScheme(.dark)
    }
}
