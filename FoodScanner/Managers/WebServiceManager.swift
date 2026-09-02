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

final class WebServiceManager: WebServiceProviding {

    private let foodStore: FoodStoring
    private let networkActivity: NetworkActivityTracking

    init(foodStore: FoodStoring, networkActivity: NetworkActivityTracking) {
        self.foodStore = foodStore
        self.networkActivity = networkActivity
    }

    func getFoodDescription(barcode: String) async throws -> FoodStruct {
        do {
            let data = try await getData(urlString: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json")
            let foodStruct = try ParserManager.parseFood(from: data)
            await foodStore.updateFood(foodStruct)
            if let cachedFood = await foodStore.food(barcode: barcode) {
                return cachedFood
            }
            return foodStruct
        } catch {
            if let cachedFood = await foodStore.food(barcode: barcode) {
                return cachedFood
            }
            throw error
        }
    }

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
                self.networkActivity.disableActivityIndicator()
            }
        }
    }

    private func getData(urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw WebServiceError.invalidURL
        }

        await networkActivity.newRequestStarted()
        defer {
            Task { @MainActor in
                self.networkActivity.requestFinished()
            }
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
