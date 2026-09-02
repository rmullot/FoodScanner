//
//  FoodDetailViewModel.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//

import Foundation
import SwiftUI
import FoodScannerUI

@MainActor
final class FoodDetailViewModel: ObservableObject {
    @Published var food: FoodStruct?
    @Published private(set) var thumbnail: Image?

    private let imageCache: ImageCaching

    init(food: FoodStruct?, imageCache: ImageCaching? = nil) {
        self.food = food
        self.imageCache = imageCache ?? InjectionManager.shared.imageCache
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
        guard let uiImage = await imageCache.image(for: imageURL) else { return }
        thumbnail = Image(uiImage: uiImage)
    }
}
