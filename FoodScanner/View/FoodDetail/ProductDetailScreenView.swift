//
//  ProductDetailScreenView.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//  Merged product detail screen: replaces the former two-step
//  ProductSheetView -> NutrientsScreenView navigation with a single scrollable
//  screen (FSProductCard header + score/calories/nutrient bars). The nav bar
//  title stays a short, generic label (L10n.Nutrients.title) rather than the
//  product name, which can be long enough to truncate in the bar — the full
//  name is still rendered, unclipped, inside FSProductCard in the body.
//

import SwiftUI
import FoodScannerUI

struct ProductDetailScreenView: View {
    @ObservedObject var model: FoodDetailModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FSMetrics.space5) {
                FSProductCard(
                    name: model.name,
                    score: model.nutriScore,
                    thumbnail: model.thumbnail
                )
                .task {
                    await model.loadThumbnail()
                }

                if let score = model.nutriScore {
                    FSScoreScale(score)
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

                FSSceneFooter(.laboratory, caption: L10n.ProductDetail.footerCaption)
            }
            .padding(FSMetrics.space5)
        }
        .background(Color.fsBackground)
        .navigationTitle(L10n.Nutrients.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Clair") {
    NavigationStack {
        ProductDetailScreenView(model: FoodDetailModel(food: .previewFixture))
    }
    .preferredColorScheme(.light)
}

#Preview("Sombre") {
    NavigationStack {
        ProductDetailScreenView(model: FoodDetailModel(food: .previewFixture))
    }
    .preferredColorScheme(.dark)
}

#Preview("Accessibilité XL") {
    NavigationStack {
        ProductDetailScreenView(model: FoodDetailModel(food: .previewFixture))
    }
    .environment(\.dynamicTypeSize, .accessibility5)
}

extension FoodStruct {
    static var previewFixture: FoodStruct {
        FoodStruct(
            barcode: "3017620422003",
            imageURL: "https://images.openfoodfacts.org/images/products/301/762/042/2003/front_fr.jpg",
            name: "Pâte à tartiner noisettes et cacao",
            lastUpdate: Date().timeIntervalSince1970,
            nutriscoreGrade: "e",
            nutrients: [
                NutrientStruct(quantity: 57.5, name: MainNutrientName.carbohydrates.rawValue, type: NutrientType.mainNutrient.rawValue),
                NutrientStruct(quantity: 6.3, name: MainNutrientName.proteins.rawValue, type: NutrientType.mainNutrient.rawValue),
                NutrientStruct(quantity: 30.9, name: MainNutrientName.fats.rawValue, type: NutrientType.mainNutrient.rawValue),
                NutrientStruct(quantity: 0.1, name: MainNutrientName.fibers.rawValue, type: NutrientType.mainNutrient.rawValue),
                NutrientStruct(quantity: 0.107, name: MainNutrientName.salt.rawValue, type: NutrientType.mainNutrient.rawValue),
                NutrientStruct(quantity: 56.3, name: "Sucres", type: NutrientType.subNutrient.rawValue),
                NutrientStruct(quantity: 539, name: "Calories", type: NutrientType.calories.rawValue)
            ]
        )
    }
}
