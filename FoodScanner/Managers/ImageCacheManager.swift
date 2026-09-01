//
//  ImageCacheManager.swift
//  FoodScanner
//
//  Cache d'images basé sur Swift Concurrency : un `actor` mémorise les
//  images déjà téléchargées (NSCache) et déduplique les téléchargements
//  concurrents d'une même URL (une seule requête réseau en vol par URL,
//  les appelants suivants attendent la même Task). Remplace le
//  téléchargement à la volée par écran (ex. `AsyncImage`) qui ne partage
//  aucun cache entre deux apparitions du même produit.
//

import UIKit

actor ImageCacheManager {
    static let sharedInstance = ImageCacheManager()

    private let cache = NSCache<NSString, UIImage>()
    private var inFlightTasks: [String: Task<UIImage?, Never>] = [:]

    private init() {}

    func image(for urlString: String) async -> UIImage? {
        let key = NSString(string: urlString)

        if let cached = cache.object(forKey: key) {
            return cached
        }

        if let existingTask = inFlightTasks[urlString] {
            return await existingTask.value
        }

        guard let url = URL(string: urlString) else { return nil }

        let cache = self.cache
        let task = Task<UIImage?, Never> {
            await NetworkActivityManager.sharedInstance.newRequestStarted()
            defer {
                Task { await NetworkActivityManager.sharedInstance.requestFinished() }
            }
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let downloadedImage = UIImage(data: data) else { return nil }
            let decodedImage = Self.decoded(downloadedImage)
            cache.setObject(decodedImage, forKey: key)
            return decodedImage
        }

        inFlightTasks[urlString] = task
        let result = await task.value
        inFlightTasks[urlString] = nil
        return result
    }

    /// Pré-décode l'image hors de l'écran (évite le coût de décodage JPEG/PNG au premier affichage).
    private static func decoded(_ image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size, format: .init(for: .init(displayScale: image.scale)))
        return renderer.image { _ in image.draw(at: .zero) }
    }
}
