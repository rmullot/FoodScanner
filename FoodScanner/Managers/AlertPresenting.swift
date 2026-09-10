//
//  AlertPresenting.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/04/2026.
//

import UIKit

// MARK: - AlertPresenting

protocol AlertPresenting: AnyObject {
    func present(title: String, message: String, style: UIAlertController.Style)
}

// MARK: - KeyWindowAlertPresenter

final class KeyWindowAlertPresenter: AlertPresenting {

    func present(title: String, message: String, style: UIAlertController.Style) {
        Task { @MainActor in
            guard let rootViewController = UIApplication.keyWindow?.rootViewController else { return }
            let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
            let action = UIAlertAction(title: L10n.Common.okButton, style: .default) { _ in
                rootViewController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(action)
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
}
