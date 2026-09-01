//
//  ImageCache.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018
//  Copyright © 2018 Romain Mullot. All rights reserved.
//
//  Chargement d'image pour UIImageView, adossé à `ImageCacheManager` (actor
//  Swift Concurrency) : plus de completion handler/URLSession.dataTask brut,
//  le cache et la déduplication des téléchargements en vol sont gérés côté
//  actor, partagés avec tout autre consommateur (SwiftUI compris).
//

import UIKit

public enum ImageResult {
    case success(UIImage)
    case failure(String)
}

extension UIImageView {
    @MainActor
    func loadImageUsingCacheWithURLString(_ URLString: String, placeHolder: UIImage?) async -> ImageResult {
        self.image = placeHolder

        guard Tool.verifyUrl(urlString: URLString) else {
            return .failure("Invalid image URL: \(URLString)")
        }

        guard let downloadedImage = await ImageCacheManager.sharedInstance.image(for: URLString) else {
            self.image = placeHolder
            return .failure("ERROR LOADING IMAGE FROM URL: \(URLString)")
        }

        self.image = downloadedImage
        return .success(downloadedImage)
    }
}
