//
//  ParserManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation

enum ParserError: Error {
    case decodeObject
    case foodMultiplePresent
    case foodNotFoundError
    case unknownObject
}

class ParserManager {

    private init() { }

    // MARK: - Food
    static func parseFood(from data: Data) throws -> FoodStruct {
        do {
            let productRoot: ProductRoot = try JSONDecoder().decode(ProductRoot.self, from: data)
            guard productRoot.status == 1 else {
                throw ParserError.foodNotFoundError
            }
            return productRoot.product
        } catch let error as ParserError {
            throw error
        } catch DecodingError.dataCorrupted(let context) {
            print(context)
            throw ParserError.decodeObject
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            throw ParserError.decodeObject
        } catch DecodingError.valueNotFound(let value, let context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            throw ParserError.decodeObject
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            throw ParserError.decodeObject
        } catch {
            print("error: ", error)
            throw ParserError.unknownObject
        }
    }

}
