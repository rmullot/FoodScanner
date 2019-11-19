//
//  NetworkActivityManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation
import UIKit

open class NetworkActivityManager {
    static let sharedInstance = NetworkActivityManager()
    
    var countRequest: MutexCounter = MutexCounter()
    
    fileprivate let maxActivityDuration: Double = 120 //in seconds
    
    fileprivate var disableActivityIndicatorClosure: DispatchQueue.CancellableClosure = nil
    
    private init() {}
    
    @discardableResult
    open func newRequestStarted() -> Int
    {
        guard Thread.isMainThread == true else {
            DispatchQueue.main.async {
                self.newRequestStarted()
            }
            let count = countRequest.getValue()
            return count
        }
        let count = countRequest.incrementAndGet()
        if(!UIApplication.shared.isNetworkActivityIndicatorVisible)
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        if let closure = disableActivityIndicatorClosure
        {
            closure()
        }
 
        
        disableActivityIndicatorClosure = DispatchQueue.main.cancellableAsyncAfter(secondsDeadline: maxActivityDuration) {
            self.disableActivityIndicator()
        }
        
        return count
    }
    
    @discardableResult
    open func requestFinished() -> Int
    {
        guard Thread.isMainThread == true else {
            DispatchQueue.main.async {
                self.requestFinished()
            }
            let count = countRequest.getValue()
            return count

        }
        let count = countRequest.decrementAndGet()
//        if(count < 0)
//        {
//            print("Network Activity Indicator was asked to hide more often than shown")
//        }
  
        if(count <= 0)
        {
            if let closure = disableActivityIndicatorClosure
            {
                closure()
            }
            countRequest.setValue(0)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
        return count
    }
    
    open func disableActivityIndicator() {
        guard Thread.isMainThread == true else {
            DispatchQueue.main.async {
                self.disableActivityIndicator()
            }
            return
        }
        if let closure = disableActivityIndicatorClosure
        {
            closure()
        }
        countRequest.setValue(0)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
  
}
