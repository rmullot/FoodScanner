//
//  Food.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation

enum NutrientType : Int {
    case calories = 0
    case mainNutrient = 1
    case subNutrient = 2
}

struct Nutrient {
    var quantity: Double = 0
    var name: String = ""
    var type: NutrientType = NutrientType.mainNutrient
}

class Food {
    
    var barcode: String = ""
    var imageURL: String = ""
    var name: String = ""
    var nutrients: [Nutrient] = []
    
}

