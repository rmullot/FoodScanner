//
//  HistoryScreenView.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//

import SwiftUI
import FoodScannerUI

struct HistoryScreenView: View {
    @StateObject private var model = HistoryViewModel()
    @State private var path = NavigationPath()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                splitView
            } else {
                stackView
            }
        }
        .onChange(of: horizontalSizeClass) { _, _ in
            path = NavigationPath()
            model.selectedBarcode = nil
        }
    }

    private var stackView: some View {
        NavigationStack(path: $path) {
            list(onSelect: { path.append($0) })
                .navigationDestination(for: String.self) { barcode in
                    HistoryDetailLoader(barcode: barcode, model: model)
                }
        }
    }

    private var splitView: some View {
        NavigationSplitView {
            list(onSelect: {
                model.selectedBarcode = $0
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            })
        } detail: {
            if let barcode = model.selectedBarcode {
                NavigationStack {
                    HistoryDetailLoader(barcode: barcode, model: model)
                }
                .id(barcode)
            } else {
                Text(L10n.History.selectPlaceholder)
                    .font(.fsBody)
                    .foregroundStyle(Color.fsInkSecondary)
                    .multilineTextAlignment(.center)
                    .padding(FSMetrics.space6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.fsBackground)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier(.historyDetailPlaceholder)
            }
        }
    }

    private func list(onSelect: @escaping (String) -> Void) -> some View {
        HistoryListContent(items: model.items,
                           isOffline: model.isOffline,
                           onSelect: onSelect)
            .navigationTitle(L10n.Common.tabHistory)
            .navigationBarTitleDisplayMode(.large)
            .task {
                await model.load()
            }
    }
}

private struct HistoryListContent: View {
    let items: [FoodSummary]
    let isOffline: Bool
    var onSelect: (String) -> Void = { _ in }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FSMetrics.space4) {
                if isOffline {
                    FSOfflineBanner()
                }

                if items.isEmpty {
                    Text(L10n.History.emptyState)
                        .font(.fsBody)
                        .foregroundStyle(Color.fsInkSecondary)
                } else {
                    ForEach(items, id: \.barcode) { summary in
                        FSHistoryRow(name: summary.name,
                                     subtitle: subtitle(for: summary),
                                     score: summary.nutriscoreGrade.flatMap(FSNutriScore.init(letter:)),
                                     isCached: true) {
                            onSelect(summary.barcode)
                        }
                    }
                }

                FSSceneFooter(.picnic, caption: L10n.History.footerCaption)
            }
            .padding(FSMetrics.space5)
            .fsReadableContentWidth()
        }
        .background(Color.fsBackground)
    }

    private func subtitle(for summary: FoodSummary) -> String {
        let date = Date(timeIntervalSince1970: summary.lastUpdate)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return L10n.History.subtitleFormat(formatter.localizedString(for: date, relativeTo: Date()))
    }
}

private struct HistoryDetailLoader: View {
    let barcode: String
    let model: HistoryViewModel
    @State private var food: FoodStruct?

    var body: some View {
        Group {
            if let food {
                ProductDetailScreenView(model: FoodDetailViewModel(food: food))
            } else {
                ProgressView()
                    .task {
                        food = await model.food(barcode: barcode)
                    }
            }
        }
    }
}

private extension Array where Element == FoodSummary {
    static var previewFixtures: [FoodSummary] {
        [
            FoodSummary(barcode: "3017620422003",
                        name: "Pâte à tartiner noisettes et cacao",
                        imageURL: "https://images.openfoodfacts.org/images/products/301/762/042/2003/front_fr.jpg",
                        nutriscoreGrade: "e",
                        lastUpdate: Date().timeIntervalSince1970 - 3600),
            FoodSummary(barcode: "3229820129488",
                        name: "Compote de pommes sans sucres ajoutés",
                        imageURL: "",
                        nutriscoreGrade: "a",
                        lastUpdate: Date().timeIntervalSince1970 - 86_400)
        ]
    }
}

#Preview("Clair") {
    NavigationStack {
        HistoryListContent(items: .previewFixtures, isOffline: false)
            .navigationTitle("Historique")
    }
    .preferredColorScheme(.light)
}

#Preview("Sombre") {
    NavigationStack {
        HistoryListContent(items: .previewFixtures, isOffline: true)
            .navigationTitle("Historique")
    }
    .preferredColorScheme(.dark)
}

#Preview("Accessibilité XL") {
    NavigationStack {
        HistoryListContent(items: .previewFixtures, isOffline: false)
            .navigationTitle("Historique")
    }
    .environment(\.dynamicTypeSize, .accessibility5)
}

#Preview("iPad", traits: .landscapeLeft) {
    HistoryScreenView()
        .environment(\.horizontalSizeClass, .regular)
}
