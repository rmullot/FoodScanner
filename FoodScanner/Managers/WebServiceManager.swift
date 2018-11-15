//
//  WebServiceManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import UIKit

enum Result<T>{
    case Success(T)
    case Error(String)
}

class WebServiceManager {
    public var onlineMode: OnlineMode = .online
    static let sharedInstance = WebServiceManager()
    
    func getFoodDescription(barcode:String,completionHandler: @escaping (Result<Food>) -> Void){

        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        self.getDataWith(urlString: urlString, completion: { (result) in
            switch result {
            case .Success(let data):
                ParserManager.parseFoodFromJSON(data, completionHandler: { result in
                    switch(result)
                    {
                    case .success(let food):
                        guard var food  = food as? FoodStruct else {
                            completionHandler(.Error("Returned object is not FoodStruct type"))
                            return
                        }
                        food.barcode = barcode
                        RealmManager.sharedInstance.updateFood(foodStruct: food) {
                            RealmManager.sharedInstance.getFood(withBarcode:barcode, completionHandler: { cachedFood in
                                guard let cachedFood = cachedFood else {
                                    completionHandler(.Error("food is not in Realm"))
                                    return
                                }
                                completionHandler(.Success(cachedFood))
                                
                            })
                        }
                        
                    case .failure(_):
                        // We try at least to check if we have something in cache
                        RealmManager.sharedInstance.getFood(withBarcode:barcode, completionHandler: { cachedFood in
                            if let cachedFood = cachedFood {
                                completionHandler(.Success(cachedFood))
                                return
                            }
                            completionHandler(.Error("food doesn't have nutrients"))
                        })
                    }
                })
                
            case .Error(let message):
                RealmManager.sharedInstance.getFood(withBarcode:barcode, completionHandler: { cachedFood in
                    if let cachedFood = cachedFood {
                        completionHandler(.Success(cachedFood))
                        return
                    }
                    ErrorManager.showAlertWith(title: "Error canceled data", message: message)
                    return completionHandler(.Error(message))
                })
            }
        })
    }
    
    func cancelRequests(){
        URLSession.shared.getTasksWithCompletionHandler { (dataTask, uploadTask, downloadTask) in
            for task in dataTask{
                task.cancel()
            }
            for task in uploadTask{
                task.cancel()
            }
            for task in downloadTask{
                task.cancel()
            }
            NetworkActivityManager.sharedInstance.disableActivityIndicator()
        }
    }
    
    
    private func getDataWith(urlString:String,completion: @escaping (Result<[String: Any]>) -> Void) {
        guard let url = URL(string: urlString) else {
            return completion(.Error("Invalid URL, we can't update your feed")) }
        
        NetworkActivityManager.sharedInstance.newRequestStarted()
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                NetworkActivityManager.sharedInstance.requestFinished()
                guard error == nil else {
                    return completion(.Error(error!.localizedDescription)) }
                guard let data = data else {
                    return completion(.Error(error?.localizedDescription ?? "There are no new Items to show")) }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                        guard let itemsJsonArray = json[FoodJSON.product] as? [String: AnyObject] else {
                            if let status = json[FoodJSON.status] as? UInt, status == 0 {
                                return completion(.Error("product not found"))
                            }
                            return completion(.Error("JSON invalid from \(urlString)"))
                            
                        }
                        return completion(.Success(itemsJsonArray))
                        
                    }
                } catch let error {
                    return completion(.Error(error.localizedDescription))
                }
            }
           
            }.resume()
    }
     private init() {
        ReachabilityManager.sharedInstance.delegates.add(self)
    }
    
    deinit {
        ReachabilityManager.sharedInstance.delegates.remove(self)
    }
}

// MARK: - ReachabilityManagerDelegate
extension WebServiceManager: ReachabilityManagerDelegate {

    public func onlineModeChanged(_ newMode: OnlineMode) {
        if self.onlineMode != newMode {
            onlineMode = newMode
            switch newMode {
                case .offline:
                        ErrorManager.showAlertWith(title: "Error", message: "Network not detected or lost")
                case .onlineSlow:
                    print("bad Network")
                case .online:
                    print("Network OK")
            }
        }
    }
}
