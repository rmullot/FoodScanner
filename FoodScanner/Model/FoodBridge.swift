//
//  FoodBridge.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//

import Foundation
import FoodScannerUI

extension NutrientStruct {
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
    var nutrientBars: [(FSNutrient, Double)] {
        nutrients.compactMap { nutrient in
            guard let kind = nutrient.fsKind else { return nil }
            return (kind, nutrient.quantity)
        }
    }

    var fsNutriScore: FSNutriScore? {
        nutriscoreGrade.flatMap { FSNutriScore(letter: $0) }
    }

    var caloriesNutrient: NutrientStruct? {
        nutrients.first { $0.type == NutrientType.calories.rawValue }
    }
}
