//
//  Nutrient.swift
//  FoodScanner
//
//  Created by Romain Mullot on 13/11/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation
import RealmSwift

enum NutrientType : Int {
    case calories = 0
    case mainNutrient = 1
    case subNutrient = 2
}

final class Nutrient: Object {
    
    @objc dynamic var quantity: Double = 0
    @objc dynamic var name: String = ""
    @objc dynamic var type: Int = NutrientType.mainNutrient.rawValue
    
}

struct NutrientStruct {
    var quantity: Double = 0
    var name: String = ""
    var type: Int = NutrientType.mainNutrient.rawValue
}
