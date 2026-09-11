//
//  ErrorManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import UIKit

final class ErrorManager {

    private let presenter: AlertPresenting

    init(presenter: AlertPresenting? = nil) {
        self.presenter = presenter ?? KeyWindowAlertPresenter()
    }

    func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        presenter.present(title: title, message: message, style: style)
    }
}
