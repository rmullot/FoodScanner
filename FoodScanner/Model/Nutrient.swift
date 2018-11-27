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

struct NutrientStruct: Codable {
    var quantity: Double = 0
    var name: String = ""
    var type: Int = NutrientType.mainNutrient.rawValue
}

struct NutrientJSONStruct: Codable {
    
    var carbohydrates: Double = 0
    var energies: Double = 0
    var fats: Double = 0
    var fibers: Double = 0
    var proteins: Double = 0
    var salt: Double = 0
    var saturatedFats: Double = 0
    var sugars: Double = 0
    
    enum CodingKeys: String, CodingKey {
        case carbohydrates = "carbohydrates_100g"
        case energies = "energy_100g"
        case fibers = "fiber_100g"
        case proteins = "proteins_100g"
        case salt = "salt_100g"
        case fats = "fat_100g"
        case saturatedFats = "saturated-fat_100g"
        case sugars = "sugars_100g"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        //OpenFoodFact return sometimes a Double or a String ...
        func decode(key: CodingKeys) throws -> Double {
            do {
                return try values.decodeIfPresent(StringCodableMap<Double>.self, forKey: key)?.decoded ?? 0
            } catch {
                return try values.decodeIfPresent(Double.self, forKey: key) ?? 0
            }
        }
        
        saturatedFats = try decode(key: .saturatedFats)
        carbohydrates = try decode(key: .carbohydrates)
        energies = try decode(key: .energies)
        fibers = try decode(key: .fibers)
        proteins = try decode(key: .proteins)
        salt = try decode(key: .salt)
        fats = try decode(key: .fats)
        sugars = try decode(key: .sugars)
    }

}

struct StringCodableMap<Decoded: LosslessStringConvertible> : Codable {
    
    var decoded: Decoded
    
    init(_ decoded: Decoded) {
        self.decoded = decoded
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        let decodedString = try container.decode(String.self)
        
        guard let decoded = Decoded(decodedString) else {
            throw DecodingError.dataCorruptedError(
                in: container, debugDescription: """
                The string \(decodedString) is not representable as a \(Decoded.self)
                """
            )
        }
        
        self.decoded = decoded
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(decoded.description)
    }
}
