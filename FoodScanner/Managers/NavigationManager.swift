//
//  NavigationManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation
import UIKit

protocol NavigationManagerProtocol {
    func navigateToFoodDescription(food: Food)
    func closeFoodDescription()
}

class NavigationManager: NavigationManagerProtocol {
    
    //MARK: - Attributs
    
    static let sharedInstance = NavigationManager()
    
    private var navigationController: UINavigationController {
        guard let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else {
            fatalError()
        }
        return navigationController
    }
    
    //MARK: - Methods
    
    func navigateToFoodDescription(food: Food) {
        guard navigationController.visibleViewController is ScannerViewController  else { return }
        if let foodViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FoodViewController") as? FoodViewController {
            foodViewController.viewModel = FoodViewModel(food: food)
            navigationController.pushViewController(foodViewController, animated: true)
        }
       
    }
    
    func closeFoodDescription() {
        navigationController.popViewController(animated: true)
    }
    
    private init() {
        
    }
}
