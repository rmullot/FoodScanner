//
//  ScannerViewModel.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation

class ScannerViewModel {
    
    var propertyChanged:((_ key: String) -> Void)?
    
    enum PropertyKeys: String {
        case statusMessage = "statusMessage"
    }
    
    private var food: Food?
    private var barcode: String = ""
    
    
    private(set)var statusMessage: String = "" {
        didSet {
            propertyChanged?(PropertyKeys.statusMessage.rawValue)
        }
    }
    
    var lampActivated : Bool = false
    
    
    func getFoodInformations(barcode: String) {
        if self.barcode != barcode {
            self.barcode = barcode
            self.food = nil
            self.statusMessage = barcode
            //TODO: Integrate REALM
            WebServiceManager.sharedInstance.getFoodDescription(barcode: barcode) { result in
                switch result {
                case .Success(let food):
                   self.food = food
                   NavigationManager.sharedInstance.navigateToFoodDescription(food: food)
                case .Error(let message):
                    self.statusMessage = message
                }
            }
        } else if let food = food {
            NavigationManager.sharedInstance.navigateToFoodDescription(food: food)
        }
       
    }
    
    func toggleLamp() {
        lampActivated = !lampActivated
        CameraTool.toggleTorch(on: lampActivated)
    }
    
    func forceSwitchOffLamp() {
        lampActivated = false
        CameraTool.toggleTorch(on: lampActivated)
    }
    
    func rebootStatusMessage() {
        statusMessage = "No bar code is detected"
    }
    
    func isValidBarcode(_ text : String) -> Bool {
        if text.isEmpty {
            return true
        } else {
            return text.isNumeric
        }
    }
}
