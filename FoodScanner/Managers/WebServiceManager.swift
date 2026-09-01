//
//  WebServiceManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import UIKit

enum WebServiceError: Error {
    case invalidURL
    case notInCache
}

class WebServiceManager {
    static let sharedInstance = WebServiceManager()

    /// Récupère un produit distant, le persiste via `RealmManager` puis relit la version
    /// mise en cache (Sendable) à retourner à l'appelant. En cas d'échec réseau/parsing,
    /// retombe sur le cache Realm existant pour ce code-barres, sinon relance l'erreur.
    func getFoodDescription(barcode: String) async throws -> FoodStruct {
        do {
            let data = try await getData(urlString: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json")
            let foodStruct = try ParserManager.parseFood(from: data)
            await RealmManager.sharedInstance.updateFood(foodStruct)
            if let cachedFood = await RealmManager.sharedInstance.food(barcode: barcode) {
                return cachedFood
            }
            return foodStruct
        } catch {
            // We try at least to check if we have something in cache
            if let cachedFood = await RealmManager.sharedInstance.food(barcode: barcode) {
                return cachedFood
            }
            throw error
        }
    }

    /// Best-effort : l'annulation fine des requêtes en vol se fait désormais côté appelant
    /// via `Task.cancel()`. Cette méthode reste pour couper les tâches URLSession en cours
    /// et réinitialiser l'indicateur d'activité réseau.
    func cancelRequests() {
        URLSession.shared.getTasksWithCompletionHandler { (dataTask, uploadTask, downloadTask) in
            for task in dataTask {
                task.cancel()
            }
            for task in uploadTask {
                task.cancel()
            }
            for task in downloadTask {
                task.cancel()
            }
            Task { @MainActor in
                NetworkActivityManager.sharedInstance.disableActivityIndicator()
            }
        }
    }

    private func getData(urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw WebServiceError.invalidURL
        }

        await NetworkActivityManager.sharedInstance.newRequestStarted()
        defer {
            Task { @MainActor in
                NetworkActivityManager.sharedInstance.requestFinished()
            }
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    private init() {}
}
