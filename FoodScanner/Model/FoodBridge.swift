//
//  FoodBridge.swift
//  FoodScanner
//
//  Bridge between the app's Codable structs (FoodStruct/NutrientStruct) and
//  the FoodScannerUI design system types. Lives on the app side (not in the
//  package) so that FoodScannerUI stays independent of FoodScanner's domain model.
//

import Foundation
import FoodScannerUI

extension NutrientStruct {
    /// Maps the French `MainNutrientName` name to the design system nutrient.
    /// "Sucres" (sugars) intentionally has no `FSNutrient` equivalent (confirmed
    /// in `FSPattern.swift`): it stays displayed as plain text, never as a bar.
    var fsKind: FSNutrient? {
        guard type == NutrientType.mainNutrient.rawValue else { return nil }
        switch name {
        case MainNutrientName.proteins.rawValue: return .protein
        case MainNutrientName.carbohydrates.rawValue: return .carbs
        case MainNutrientName.fats.rawValue: return .fat
        case MainNutrientName.fibers.rawValue: return .fiber
        case MainNutrientName.salt.rawValue: return .salt
        default: return nil
        }
    }
}

extension FoodStruct {
    /// List of main nutrient bars ("Score then bars"), excluding calories,
    /// sub-nutrients, and any nutrient without an `FSNutrient` equivalent.
    var nutrientBars: [(FSNutrient, Double)] {
        nutrients.compactMap { nutrient in
            guard let kind = nutrient.fsKind else { return nil }
            return (kind, nutrient.quantity)
        }
    }

    /// The design system Nutri-Score, from the letter decoded from the API.
    var fsNutriScore: FSNutriScore? {
        nutriscoreGrade.flatMap { FSNutriScore(letter: $0) }
    }

    /// The "Calories" nutrient, displayed as plain text (no bar).
    var caloriesNutrient: NutrientStruct? {
        nutrients.first { $0.type == NutrientType.calories.rawValue }
    }
}
