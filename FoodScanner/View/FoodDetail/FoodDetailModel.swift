//
//  FoodDetailModel.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//

import Foundation
import SwiftUI
import FoodScannerUI

@MainActor
final class FoodDetailModel: ObservableObject {
    @Published var food: FoodStruct?
    @Published private(set) var thumbnail: Image?

    init(food: FoodStruct?) {
        self.food = food
    }

    var name: String { food?.name ?? "" }

    var imageURL: String? { food?.imageURL }

    var nutriScore: FSNutriScore? { food?.fsNutriScore }

    var nutrientBars: [(FSNutrient, Double)] { food?.nutrientBars ?? [] }

    var caloriesText: String? {
        guard let calories = food?.caloriesNutrient else { return nil }
        return L10n.Nutrients.caloriesFormat(Int(calories.quantity))
    }

    func loadThumbnail() async {
        guard thumbnail == nil, let imageURL else { return }
        guard let uiImage = await ImageCacheManager.sharedInstance.image(for: imageURL) else { return }
        thumbnail = Image(uiImage: uiImage)
    }
}
