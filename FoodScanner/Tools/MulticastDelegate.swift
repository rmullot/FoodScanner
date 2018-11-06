//
//  MulticastDelegate.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation

public class MulticastDelegate <T> {
    
    private let lock: PThreadMutex = PThreadMutex()
    
    fileprivate let addClosure: ((T) -> ())?
    
    public init(addClosure: ((T) -> ())? = nil) {
        self.addClosure = addClosure
    }
    
    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    public func add(_ delegate: T) {
        self.lock.sync {
            delegates.add(delegate as AnyObject)
            self.addClosure?(delegate)
        }
    }
    
    public func remove(_ delegate: T) {
        self.lock.sync {
            for oneDelegate in delegates.allObjects.reversed() {
                if oneDelegate === delegate as AnyObject {
                    delegates.remove(oneDelegate)
                }
            }
        }
    }
    
    public func invoke(_ invocation: (T) -> ()) {
        self.lock.sync {
            for delegate in delegates.allObjects.reversed() {
                if let delegate = delegate as? T {
                    invocation(delegate)
                }
            }
        }
    }
}
