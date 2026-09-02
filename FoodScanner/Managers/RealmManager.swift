//
//  RealmManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 10/11/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation
import RealmSwift

actor RealmManager {

    static let sharedInstance = RealmManager()

    init() {
        autoreleasepool {
            guard let realm = try? Realm() else {
                fatalError("Cannot initialize the default Realm")
            }

            let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path

            // SECURITY: file protection is disabled here so the encrypted Realm directory stays accessible after first unlock (see RealmEncryptionKeyStore's Keychain policy).
            do {
                try FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none], ofItemAtPath: folderPath)
            } catch {
                fatalError("Cannot disable file protection on the Realm directory: \(error.localizedDescription)")
            }

            var config = Realm.Configuration()
            config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("foodScannerUser.realm")
            // SECURITY: Realm file encrypted at rest with a 64-byte AES-256 key kept in the Keychain, never alongside the .realm file itself.
            config.encryptionKey = RealmEncryptionKeyStore.key()
            Realm.Configuration.defaultConfiguration = config
        }
    }

    func food(barcode: String) async -> FoodStruct? {
        autoreleasepool {
            guard let realm = try? Realm(),
                  let food = realm.object(ofType: Food.self, forPrimaryKey: barcode) else {
                return nil
            }
            return Self.foodStruct(from: food)
        }
    }

    func updateFood(_ foodStruct: FoodStruct) async {
        autoreleasepool {
            do {
                let realm = try Realm()
                try realm.write {
                    let food = Food()
                    food.barcode = foodStruct.barcode
                    food.imageURL = foodStruct.imageURL
                    food.lastUpdate = foodStruct.lastUpdate
                    food.name = foodStruct.name
                    food.nutriscoreGrade = foodStruct.nutriscoreGrade
                    foodStruct.nutrients.forEach { nutrient in
                        let nutrientRealm = Nutrient()
                        nutrientRealm.quantity = nutrient.quantity
                        nutrientRealm.type = nutrient.type
                        nutrientRealm.name = nutrient.name
                        food.nutrients.append(nutrientRealm)
                    }
                    realm.add(food, update: .all)
                }
            } catch let error as NSError {
                print("Cannot update Realm failed: \(error.localizedDescription)")
            }
        }
    }

    func allFoodSummaries() async -> [FoodSummary] {
        autoreleasepool {
            guard let realm = try? Realm() else { return [] }
            let foods = realm.objects(Food.self).sorted(byKeyPath: "lastUpdate", ascending: false)
            return foods.map { food in
                FoodSummary(
                    barcode: food.barcode,
                    name: food.name,
                    imageURL: food.imageURL,
                    nutriscoreGrade: food.nutriscoreGrade,
                    lastUpdate: food.lastUpdate
                )
            }
        }
    }

    private static func foodStruct(from food: Food) -> FoodStruct {
        FoodStruct(
            barcode: food.barcode,
            imageURL: food.imageURL,
            name: food.name,
            lastUpdate: food.lastUpdate,
            nutriscoreGrade: food.nutriscoreGrade,
            nutrients: food.nutrients.map { nutrient in
                NutrientStruct(quantity: nutrient.quantity, name: nutrient.name, type: nutrient.type)
            }
        )
    }
}
