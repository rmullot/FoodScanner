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

    /// Fetches a remote product, persists it via `RealmManager`, then reads back the
    /// cached (Sendable) version to return to the caller. On network/parsing failure,
    /// falls back to the existing Realm cache for this barcode, otherwise rethrows the error.
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

    /// Best-effort: fine-grained cancellation of in-flight requests is now done by the caller
    /// via `Task.cancel()`. This method remains to cut off ongoing URLSession tasks
    /// and reset the network activity indicator.
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
