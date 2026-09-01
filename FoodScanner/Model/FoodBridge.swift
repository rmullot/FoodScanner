//
//  FoodBridge.swift
//  FoodScanner
//
//  Pont entre les structs Codable de l'app (FoodStruct/NutrientStruct) et les
//  types du design system FoodScannerUI. Vit côté app (pas dans le package)
//  pour que FoodScannerUI reste indépendant du modèle métier de FoodScanner.
//

import Foundation
import FoodScannerUI

extension NutrientStruct {
    /// Mappe le nom français `MainNutrientName` vers le nutriment de la charte.
    /// "Sucres" n'a volontairement pas d'équivalent `FSNutrient` (confirmé dans
    /// `FSPattern.swift`) : il reste affiché en texte simple, jamais en barre.
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
    /// Liste des barres de nutriments principaux ("Score puis barres"), en
    /// excluant les calories, les sous-nutriments et tout nutriment sans
    /// équivalent `FSNutrient`.
    var nutrientBars: [(FSNutrient, Double)] {
        nutrients.compactMap { nutrient in
            guard let kind = nutrient.fsKind else { return nil }
            return (kind, nutrient.quantity)
        }
    }

    /// Le Nutri-Score de la charte, à partir de la lettre décodée depuis l'API.
    var fsNutriScore: FSNutriScore? {
        nutriscoreGrade.flatMap { FSNutriScore(letter: $0) }
    }

    /// Le nutriment "Calories", affiché en texte simple (pas de barre).
    var caloriesNutrient: NutrientStruct? {
        nutrients.first { $0.type == NutrientType.calories.rawValue }
    }
}
