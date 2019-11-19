//
//  RealmManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 10/11/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation
import RealmSwift

//TODO: To upgrade class to manage : mutlithread, managed and unmanaged object differences, etc.
class RealmManager {

    static let sharedInstance = RealmManager()
    private let backgroundQueue = DispatchQueue(label: "realm", qos: .background)
    
    private init() {
        autoreleasepool {
            let realm = try! Realm()
            
            // Get our Realm file's parent directory
            let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
            
            // Disable file protection for this directory
            try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none], ofItemAtPath: folderPath)
            setDefaultRealmForUser(username: "foodScannerUser")
        }
    }
    
    func setDefaultRealmForUser(username: String) {
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(username).realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    func getFood(withBarcode barcode:String, completionHandler: @escaping ((Food?) -> Void)) {
        DispatchQueue.main.async {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        let food = realm.object(ofType: Food.self, forPrimaryKey: barcode)
                        completionHandler(food)
                    }
                } catch let error as NSError {
                    print("Cannot update Realm failed: \(error.localizedDescription)")
                    completionHandler(nil)
                }

            }
        }
    }
        
    func updateFood(foodStruct:FoodStruct, completionHandler: @escaping (() -> Void)) {
        backgroundQueue.async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    try realm.write {
                        let food = Food()
                        food.barcode = foodStruct.barcode
                        food.imageURL = foodStruct.imageURL
                        food.lastUpdate = foodStruct.lastUpdate
                        food.name = foodStruct.name
                        foodStruct.nutrients.forEach({ nutrient in
                            let nutrientRealm = Nutrient()
                            nutrientRealm.quantity = nutrient.quantity
                            nutrientRealm.type = nutrient.type
                            nutrientRealm.name = nutrient.name
                            food.nutrients.append(nutrientRealm)
                        })
                        realm.add(food,update: .all)
                        
                        DispatchQueue.main.async {
                            completionHandler()
                        }
                    }
                } catch let error as NSError {
                    print("Cannot update Realm failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completionHandler()
                    }
                }
            }
        }
    }
    
}
 extension Realm {
     func writeAsync<T : ThreadConfined>(obj: T, errorHandler: @escaping ((_ error : Swift.Error) -> Void) = { _ in return }, block: @escaping ((Realm, T?) -> Void)) {
        let wrappedObj = ThreadSafeReference(to: obj)
        let config = self.configuration
        DispatchQueue(label: "background").async {
            autoreleasepool {
                do {
                    let realm = try Realm(configuration: config)
                    let obj = realm.resolve(wrappedObj)
                    try realm.write { block(realm, obj) }
                } catch {
                    errorHandler(error)
                }
            }
        }
    }
}
