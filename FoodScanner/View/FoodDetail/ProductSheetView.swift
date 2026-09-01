//
//  ProductSheetView.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//  Product sheet: replaces FoodCollectionReusableView. Passive view, purely
//  fed by FoodDetailModel.
//

import SwiftUI
import FoodScannerUI

struct ProductSheetView: View {
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

                NavigationLink("Voir les nutriments") {
                    NutrientsScreenView(model: model)
                }
                .font(.fsBodyStrong)
                .foregroundStyle(Color.fsAccent)
                .frame(minHeight: FSMetrics.minTouchTarget)
            }
            .padding(FSMetrics.space5)
        }
        .background(Color.fsBackground)
        .navigationTitle(model.name)
    }
}

#Preview("Clair") {
    ProductSheetView(model: FoodDetailModel(food: .previewFixture))
        .preferredColorScheme(.light)
}

#Preview("Sombre") {
    ProductSheetView(model: FoodDetailModel(food: .previewFixture))
        .preferredColorScheme(.dark)
}

#Preview("Accessibilité XL") {
    ProductSheetView(model: FoodDetailModel(food: .previewFixture))
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
