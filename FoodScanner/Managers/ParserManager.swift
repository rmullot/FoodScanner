//
//  ParserManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import CoreData

public enum ParserResult {
    case success(Any?)
    case failure(Error)
}

public enum ParserError: Error {
    case unknownObject
    case foodMultiplePresent
    case foodIdError
}

public typealias ParserCallback = (ParserResult) -> Void

class ParserManager: Any {
    
    private init() { }
    
    //MARK: - Restaurant
    static func parseFoodFromJSON(_ json:[String: Any], completionHandler: ParserCallback? = nil) {
        
        let resultObject: Food = Food()
        
        if let imageURL = json[FoodJSON.imageURL] as? String {
            resultObject.imageURL = imageURL
        }
        
        if let name = json[FoodJSON.name] as? String {
            resultObject.name = name
        }
        
        guard let nutriments = json[FoodJSON.nutrients]  as? [String: Any]  else { completionHandler?(ParserResult.failure(ParserError.unknownObject))
            return
        }
            
        resultObject.nutrients = [];
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
       
        
        if let carbohydrates = nutriments[FoodJSON.carbohydrates] as? String, let quantity = numberFormatter.number(from: carbohydrates)?.doubleValue {
            let nutrient = Nutrient(quantity:quantity,name:"Glucides",type:NutrientType.mainNutrient)
            resultObject.nutrients.append(nutrient)
        }
        
        if let energies = nutriments[FoodJSON.energies] as? String, let quantity = numberFormatter.number(from: energies)?.doubleValue {
            let nutrient = Nutrient(quantity:quantity,name:"Calories",type:NutrientType.calories)
            resultObject.nutrients.append(nutrient)
        }
        
        if let fats = nutriments[FoodJSON.fats] as? String, let quantity = numberFormatter.number(from: fats)?.doubleValue {
            let nutrient = Nutrient(quantity:quantity,name:"Lipides",type:NutrientType.mainNutrient)
            resultObject.nutrients.append(nutrient)
        }
        
        if let quantity = nutriments[FoodJSON.fibers] as? NSNumber {
            let nutrient = Nutrient(quantity:quantity.doubleValue,name:"Fibres",type:NutrientType.mainNutrient)
            resultObject.nutrients.append(nutrient)
        }
        
        if let quantity = nutriments[FoodJSON.proteins]  as? NSNumber {
            let nutrient = Nutrient(quantity:quantity.doubleValue,name:"Protéines",type:NutrientType.mainNutrient)
            resultObject.nutrients.append(nutrient)
        }
        
        if let quantity = nutriments[FoodJSON.salt] as? NSNumber {
            let nutrient = Nutrient(quantity:quantity.doubleValue,name:"Sel",type:NutrientType.mainNutrient)
            resultObject.nutrients.append(nutrient)
        }
        
        if let saturatedFats = nutriments[FoodJSON.saturatedFats] as? String, let quantity = numberFormatter.number(from: saturatedFats)?.doubleValue {
            let nutrient = Nutrient(quantity:quantity,name:"Lipides Saturées",type:NutrientType.subNutrient)
            resultObject.nutrients.append(nutrient)
        }
        
        if let sugars = nutriments[FoodJSON.sugars] as? String, let quantity = numberFormatter.number(from: sugars)?.doubleValue{
            let nutrient = Nutrient(quantity:quantity,name:"Sucres",type:NutrientType.subNutrient)
            resultObject.nutrients.append(nutrient)
        }
        completionHandler?(ParserResult.success(resultObject))
    }
    
}
