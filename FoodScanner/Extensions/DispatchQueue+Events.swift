//
//  DispatchQueue+FoodScanner.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import UIKit

extension DispatchQueue {
    public typealias CancellableClosure = (() -> ())?
    
    public func asyncAfter(secondsDeadline: TimeInterval, qos: DispatchQoS = .default, flags: DispatchWorkItemFlags = [], execute work: @escaping @convention(block) () -> Swift.Void) {
        self.asyncAfter(deadline: DispatchTime.now() + secondsDeadline, qos: qos, flags: flags, execute: work)
    }
    
    public func cancellableAsyncAfter(secondsDeadline: TimeInterval, execute work: @escaping @convention(block) () -> Swift.Void) ->CancellableClosure {
        var cancelled = false
        let cancelClosure:CancellableClosure = {
            cancelled = true
        }
        
        self.asyncAfter(secondsDeadline: secondsDeadline) {
            if !cancelled {
                work()
            }
        }
        
        return cancelClosure
    }
}

