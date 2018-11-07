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
                guard nutrient.type == .mainNutrient, nutrient.quantity > 0 else { return }
                let dataEntry = PieChartDataEntry(value: nutrient.quantity, label: nutrient.name)
                tmp.append(dataEntry)
            }
            return tmp
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
        return nutrient.type == .calories ? "\(Int(nutrient.quantity))kCal" : "\(nutrient.quantity)g pour 100g"
    }
    
    func getNameNutrient(index: Int) -> String  {
        guard let nutrients = food?.nutrients, index < nutrients.count else { return "" }
        let nutrient = nutrients[index]
        return nutrient.name
    }
}
