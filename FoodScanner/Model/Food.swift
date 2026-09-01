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
    @objc dynamic var nutriscoreGrade: String?
    var nutrients: List<Nutrient> = List<Nutrient>()
    
    override static func primaryKey() -> String? {
        return "barcode"
    }
    
    static func ==(lhs: Food, rhs: Food) -> Bool {
        return (lhs.barcode == rhs.barcode && lhs.lastUpdate == rhs.lastUpdate)
    }
}

struct ProductRoot: Codable {
    let code: String
    let status_verbose: String
    let status: Int
    let product: FoodStruct
}

struct FoodStruct: Codable {
    var barcode: String = ""
    var imageURL: String = ""
    var name: String = ""
    var lastUpdate: TimeInterval = 0
    var nutriscoreGrade: String?
    var nutrients: [NutrientStruct] = []
    private var nutrientsJSON : NutrientJSONStruct

    enum CodingKeys: String, CodingKey {
        case barcode = "code"
        case imageURL = "image_small_url"
        case name = "product_name"
        case lastUpdate = "last_modified_t"
        case nutriscoreGrade = "nutriscore_grade"
        case nutrientsJSON = "nutriments"
    }

    /// Construction manuelle (previews/fixtures), en plus du décodage JSON ci-dessous.
    init(barcode: String = "", imageURL: String = "", name: String = "", lastUpdate: TimeInterval = 0,
         nutriscoreGrade: String? = nil, nutrients: [NutrientStruct] = []) {
        self.barcode = barcode
        self.imageURL = imageURL
        self.name = name
        self.lastUpdate = lastUpdate
        self.nutriscoreGrade = nutriscoreGrade
        self.nutrients = nutrients
        self.nutrientsJSON = NutrientJSONStruct()
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        barcode = try values.decode(String.self, forKey: .barcode)
        imageURL = try values.decode(String.self, forKey: .imageURL)
        name = try values.decode(String.self, forKey: .name)
        lastUpdate = try values.decode(TimeInterval.self, forKey: .lastUpdate)
        nutriscoreGrade = try values.decodeIfPresent(String.self, forKey: .nutriscoreGrade)
        nutrientsJSON =  try values.decode(NutrientJSONStruct.self, forKey: .nutrientsJSON)
        var nutrientsStructTmp :[NutrientStruct] = []
        nutrientsStructTmp.append(NutrientStruct(quantity: nutrientsJSON.carbohydrates, name: MainNutrientName.carbohydrates.rawValue, type: NutrientType.mainNutrient.rawValue))
        nutrientsStructTmp.append(NutrientStruct(quantity: nutrientsJSON.proteins, name: MainNutrientName.proteins.rawValue, type: NutrientType.mainNutrient.rawValue))
        nutrientsStructTmp.append(NutrientStruct(quantity: nutrientsJSON.energies, name: "Calories", type: NutrientType.calories.rawValue))
        nutrientsStructTmp.append(NutrientStruct(quantity: nutrientsJSON.fats, name: MainNutrientName.fats.rawValue, type: NutrientType.mainNutrient.rawValue))
        nutrientsStructTmp.append(NutrientStruct(quantity: nutrientsJSON.fibers, name: MainNutrientName.fibers.rawValue, type: NutrientType.mainNutrient.rawValue))
        nutrientsStructTmp.append(NutrientStruct(quantity: nutrientsJSON.salt, name: MainNutrientName.salt.rawValue, type: NutrientType.mainNutrient.rawValue))
        nutrientsStructTmp.append(NutrientStruct(quantity: nutrientsJSON.saturatedFats, name: "Lipides Saturées", type: NutrientType.subNutrient.rawValue))
        nutrientsStructTmp.append(NutrientStruct(quantity: nutrientsJSON.sugars, name: "Sucres", type: NutrientType.subNutrient.rawValue))
        nutrients = nutrientsStructTmp.filter({ nutrient in
            return nutrient.quantity > 0
        }).sorted(by: { (nutrient1, nutrient2) in return nutrient1.name < nutrient2.name })
    }
}
