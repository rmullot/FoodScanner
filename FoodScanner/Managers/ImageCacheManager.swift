//
//  ImageCacheManager.swift
//  FoodScanner
//
//  Image cache based on Swift Concurrency: an `actor` memorizes already
//  downloaded images (NSCache) and deduplicates concurrent downloads of
//  the same URL (a single in-flight network request per URL, subsequent
//  callers await the same Task). Replaces per-screen on-the-fly
//  downloading (e.g. `AsyncImage`) which shares no cache between two
//  appearances of the same product.
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

    /// Pre-decodes the image off-screen (avoids the JPEG/PNG decoding cost on first display).
    private static func decoded(_ image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size, format: .init(for: .init(displayScale: image.scale)))
        return renderer.image { _ in image.draw(at: .zero) }
    }
}
