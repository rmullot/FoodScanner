//
//  ScannerViewModel.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation

class ScannerViewModel {
    private var food: Food?
    private var barcode: String = ""
    
    var lampActivated : Bool = false
    
    
    func getFoodInformations(barcode: String) {
        if self.barcode != barcode {
            self.barcode = barcode
            
            //TODO: Integrate REALM
            WebServiceManager.sharedInstance.getFoodDescription(barcode: barcode) { result in
                switch result {
                case .Success(let food):
                   self.food = food
                   NavigationManager.sharedInstance.navigateToFoodDescription(food: food)
                   break
                case .Error(_): break
                    //TODO: To rebuild the system of error
                }
                
            }
        } else {
            if let food = food {
                 NavigationManager.sharedInstance.navigateToFoodDescription(food: food)
            }
        }
       
    }
    
    func toggleLamp() {
        lampActivated = !lampActivated
        CameraTool.toggleTorch(on: lampActivated)
    }
}
