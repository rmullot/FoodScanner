//
//  FoodDetailModel.swift
//  FoodScanner
//
//  Adaptateur ObservableObject exposant un FoodStruct aux vues SwiftUI de la
//  fiche produit. Ne crée/mute jamais d'objet Realm : reçoit uniquement des
//  structs Codable déjà converties (par RealmManager ou le parsing réseau).
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
        return "\(Int(calories.quantity)) kCal pour 100 g"
    }

    /// Résout la miniature via le cache image partagé. Ne fait rien si déjà
    /// chargée ou si le produit n'a pas d'URL d'image — l'écran (`.task`)
    /// pilote quand cet appel a lieu, `FoodDetailModel` ne se relance pas
    /// silencieusement tout seul.
    func loadThumbnail() async {
        guard thumbnail == nil, let imageURL else { return }
        guard let uiImage = await ImageCacheManager.sharedInstance.image(for: imageURL) else { return }
        thumbnail = Image(uiImage: uiImage)
    }
}
