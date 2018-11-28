//
//  FoodViewModel.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation
import Charts

class FoodViewModel {
    private var food: Food? = nil
    
    init(food: Food) {
        self.food = food
    }
    
    var nutrientsCount: Int {
        get {
            guard let food = food else { return 0 }
            return food.nutrients.count
        }
    }
    
    var imageUrl: String {
        get {
            guard let food = food else { return "" }
            return food.imageURL
        }
    }
    
    var name: String {
        get {
            guard let food = food else { return "" }
            return food.name
        }
    }
    
    var nutrientsData: [PieChartDataEntry] {
        get {
            guard let food = food, food.nutrients.count > 0 else { return [] }

            var tmp: [PieChartDataEntry] = []
            food.nutrients.forEach { nutrient in
                guard nutrient.type == NutrientType.mainNutrient.rawValue, nutrient.quantity > 0 else { return }
                let dataEntry = PieChartDataEntry(value: nutrient.quantity, label: nutrient.name)
                tmp.append(dataEntry)
            }
            return tmp
        }
    }
    
    var nutrientsColorIndex: [Int] {
        get {
            guard let food = food, food.nutrients.count > 0 else { return [] }
            
            var colorIndex: [Int] = []
            food.nutrients.forEach { nutrient in
                guard nutrient.type == NutrientType.mainNutrient.rawValue, nutrient.quantity > 0 else { return }
                switch nutrient.name {
                case MainNutrientName.carbohydrates.rawValue: colorIndex.append(0)
                case MainNutrientName.fats.rawValue: colorIndex.append(1)
                case MainNutrientName.fibers.rawValue: colorIndex.append(2)
                case MainNutrientName.proteins.rawValue: colorIndex.append(3)
                case MainNutrientName.salt.rawValue: colorIndex.append(4)
                default:
                    break
                }
                
            }
            return colorIndex
        }
    }
    
    var descriptionChart: String {
        get {
            return "Ratio nutriments pour 100g"
        }
    }
    
    func getQuantityNutrient(index: Int) -> String {
        guard let nutrients = food?.nutrients, index < nutrients.count else { return "" }
        let nutrient = nutrients[index]
        return nutrient.type == NutrientType.calories.rawValue ? "\(Int(nutrient.quantity))kCal" : "\(nutrient.quantity)g pour 100g"
    }
    
    func getNameNutrient(index: Int) -> String  {
        guard let nutrients = food?.nutrients, index < nutrients.count else { return "" }
        let nutrient = nutrients[index]
        return nutrient.name
    }
}
