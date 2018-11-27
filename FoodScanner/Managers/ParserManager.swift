//
//  ParserManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import RealmSwift

public enum ParserResult {
    case success(Any?)
    case failure(Swift.Error,String)
}

public enum ParserError: Error {
    case decodeObject
    case foodMultiplePresent
    case foodNotFoundError
    case unknownObject
}

public typealias ParserCallback = (ParserResult) -> Void

class ParserManager {
    
    private init() { }
    
    //MARK: - Food
    static func parseFoodFromJSON(_ json: Data, completionHandler: ParserCallback? = nil) {
        do {
            let productRoot: ProductRoot = try JSONDecoder().decode(ProductRoot.self, from: json)
            guard productRoot.status == 1 else {
                completionHandler?(ParserResult.failure(ParserError.foodNotFoundError, productRoot.status_verbose))
                return
            }
            completionHandler?(ParserResult.success(productRoot.product))
        } catch DecodingError.dataCorrupted(let context) {
            print(context)
            completionHandler?(ParserResult.failure(ParserError.decodeObject, context.debugDescription))
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completionHandler?(ParserResult.failure(ParserError.decodeObject, context.debugDescription))
        } catch DecodingError.valueNotFound(let value, let context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completionHandler?(ParserResult.failure(ParserError.decodeObject, context.debugDescription))
        } catch DecodingError.typeMismatch(let type, let context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completionHandler?(ParserResult.failure(ParserError.decodeObject, context.debugDescription))
        } catch {
            print("error: ", error)
            completionHandler?(ParserResult.failure(ParserError.unknownObject,error.localizedDescription))
        }
    }
    
}
