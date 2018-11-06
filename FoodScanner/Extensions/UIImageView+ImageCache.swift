//
//  ImageCache.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()
var urlCache = [String:String]()
public enum ImageResult {
    case success(UIImage)
    case failure(String)
}

public typealias ImageCallback = (ImageResult) -> Void

extension UIImageView {
    func loadImageUsingCacheWithURLString(_ URLString: String, placeHolder: UIImage?,completionHandler: ImageCallback? = nil) {
        let imageToDecode: (UIImage?) -> UIImage? = { image in
            guard let image = image else { return nil }
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(at: CGPoint.zero)
            let decodedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return decodedImage
        }
        
        self.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = imageToDecode(cachedImage)
            completionHandler?(.success(cachedImage))
            return
        }
        
        if  Tool.verifyUrl(urlString: URLString) && urlCache[URLString] == nil {
            if let url = URL(string: URLString) {
                urlCache[URLString] = URLString
                NetworkActivityManager.sharedInstance.newRequestStarted()
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    defer {
                        NetworkActivityManager.sharedInstance.requestFinished()
                    }
                    
                    if let errorTmp = error {
                        let errorString = "ERROR LOADING IMAGES FROM URL: \(errorTmp.localizedDescription)"
                        if let decodedPlaceHolder = imageToDecode(placeHolder) {
                            DispatchQueue.main.async {
                                self.image = decodedPlaceHolder
                                completionHandler?(.failure(errorString))
                            }
                        }
                        return
                    }
                    if let data = data, let downloadedImage = UIImage(data: data) {
                        imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                        if let decodedDownloadedImage = imageToDecode(downloadedImage) {
                            urlCache.removeValue(forKey:URLString)
                            DispatchQueue.main.async {
                                self.image = decodedDownloadedImage
                                completionHandler?(.success(downloadedImage))
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            completionHandler?(.failure("Image Data invalid"))
                        }
                    }
                }).resume()
            }
            
        }
    }
}
