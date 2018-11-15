//
//  Food.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation
import RealmSwift

final class Food: Object {
    
    @objc dynamic var barcode: String = ""
    @objc dynamic var imageURL: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var lastUpdate: TimeInterval = 0
    var nutrients: List<Nutrient> = List<Nutrient>()
    
    override static func primaryKey() -> String? {
        return "barcode"
    }
    
    static func ==(lhs: Food, rhs: Food) -> Bool {
        return (lhs.barcode == rhs.barcode && lhs.lastUpdate == rhs.lastUpdate)
    }
}

struct FoodStruct {
    var barcode: String = ""
    var imageURL: String = ""
    var name: String = ""
    var lastUpdate: TimeInterval = 0
    var nutrients: [NutrientStruct] = []
}
