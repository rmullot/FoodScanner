//
//  NutrientsScreenView.swift
//  FoodScanner
//
//  Écran Nutriments : "Score puis barres" (FSScoreBadge + FSNutrientRow),
//  remplace ChartCollectionViewCell/NutrientsCollectionViewCell/NutrientTableViewCell.
//

import SwiftUI
import FoodScannerUI

struct NutrientsScreenView: View {
    @ObservedObject var model: FoodDetailModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FSMetrics.space5) {
                if let score = model.nutriScore {
                    FSScoreBadge(score, size: .large, showsMeaning: true)
                }

                if let caloriesText = model.caloriesText {
                    Text(caloriesText)
                        .font(.fsBodyStrong)
                        .foregroundStyle(Color.fsInk)
                }

                VStack(alignment: .leading, spacing: FSMetrics.space1) {
                    ForEach(model.nutrientBars, id: \.0) { kind, grams in
                        FSNutrientRow(kind, grams: grams, referenceGrams: 100, unit: "g")
                    }
                }
            }
            .padding(FSMetrics.space5)
        }
        .background(Color.fsBackground)
        .navigationTitle("Nutriments")
    }
}

#Preview("Clair") {
    NavigationStack {
        NutrientsScreenView(model: FoodDetailModel(food: .previewFixture))
    }
    .preferredColorScheme(.light)
}

#Preview("Sombre") {
    NavigationStack {
        NutrientsScreenView(model: FoodDetailModel(food: .previewFixture))
    }
    .preferredColorScheme(.dark)
}

#Preview("Accessibilité XL") {
    NavigationStack {
        NutrientsScreenView(model: FoodDetailModel(food: .previewFixture))
    }
    .environment(\.dynamicTypeSize, .accessibility5)
}
