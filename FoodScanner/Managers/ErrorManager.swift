//
//  ErrorManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import UIKit

class ErrorManager {
    static func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        DispatchQueue.main.async {
            if let rootViewController = UIApplication.keyWindow?.rootViewController {
                let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
                let action = UIAlertAction(title: L10n.Common.okButton, style: .default) { _ in
                    rootViewController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(action)
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    private init() {
        
    }
}
