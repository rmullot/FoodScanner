//
//  ReachabilityManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation
import CoreTelephony
import UIKit

// MARK: - OnlineMode
@objc public enum OnlineMode: Int {
    case offline = 0
    case onlineSlow = 1
    case online = 2
}

extension OnlineMode: RawRepresentable {
    public init?(rawValue: Int) {
        switch rawValue {
        case 2: self = .online
        case 1: self = .onlineSlow
        case 0: self = .offline
        default: return nil
        }
    }
    
    public var rawValue: Int {
        switch self {
        case .online: return 2
        case .onlineSlow: return 1
        case .offline: return 0
        }
    }
    
    public var description: String {
        switch self {
        case .online: return "online"
        case .onlineSlow: return "onlineSlow"
        case .offline: return "offline"
        }
    }
}

// MARK: - Reachability Manager Delegate

@objc public protocol ReachabilityManagerDelegate {
    var onlineMode: OnlineMode {get}
    func onlineModeChanged(_ onlineMode: OnlineMode)
}

// MARK: - Reachability Manager

public final class ReachabilityManager {
    
    // MARK: Properties
    static let sharedInstance = ReachabilityManager()
    
    private(set) var delegates = MulticastDelegate<ReachabilityManagerDelegate>()
    
    private var reachability: Reachability? = nil
    
    private let telephonyInfo = CTTelephonyNetworkInfo()
    
    private var _onlineMode: OnlineMode = .online
    
    private(set) var onlineMode: OnlineMode {
        set {
            _onlineMode = newValue
            self.delegates.invoke { (delegate) in
                delegate.onlineModeChanged(_onlineMode)
            }
        }
        
        get {
            return _onlineMode
        }
    }
    
    private let changeOperatingModeDelay: Double = 2.0 //in seconds
    
    private var changeOperatinModeClosure: DispatchQueue.CancellableClosure? = nil

    
    private init()
    {
        self.delegates = MulticastDelegate<ReachabilityManagerDelegate>.init(addClosure: {delegate in
            delegate.onlineModeChanged(self.onlineMode)
        })
        self.onlineMode = .online
        reachability = Reachability()
        if reachability != nil {
            do {
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(ReachabilityManager.reachabilityChanged(_:)),
                                                       name: ReachabilityChangedNotification,
                                                       object: reachability)
                
                try reachability?.startNotifier()
            } catch(let error) {
                print("Unable to start Reachability! Error: \(error)")
            }
        } else {
            print("Unable to create Reachability!")
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ReachabilityManager.refreshReachability),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Reachability changed
    
    @objc public dynamic func refreshReachability() {
        if let reachability = self.reachability {
            NotificationCenter.default.post(name: ReachabilityChangedNotification, object:reachability)
        }
    }
    
    @objc dynamic func reachabilityChanged(_ note: Notification) {
        guard let noteReachability = note.object as? Reachability, let reachability = self.reachability, reachability === noteReachability else {
            return
        }

        if reachability.isReachable {
            
            let oldRadioAccess = {
                if let currentRadioAccessTechnology = self.telephonyInfo.currentRadioAccessTechnology  {
                    switch(currentRadioAccessTechnology){
                    case CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x,
                         CTRadioAccessTechnologyGPRS:
                        //slow mode
                        self.changeOnlineMode(.onlineSlow)
                    default:
                        //fast mode
                        self.changeOnlineMode(.online)
                    }
                }
                else { self.changeOnlineMode(.online) }
            }
            
            //handle slow / fast mode here
            if #available(iOS 12, *) {
                //TODO: Why serviceCurrentRadioAccessTechnology is always nil ?
                if let currentRadioAccessTechnology = telephonyInfo.serviceCurrentRadioAccessTechnology  {
                    currentRadioAccessTechnology.keys.forEach { (key) in
                        print("\(key)\n")
                    }
                } else {
                    oldRadioAccess()
                }
            }
            else {
               oldRadioAccess()
            }
            
        } else {
            changeOnlineMode(.offline)
        }
    }
    
    public func changeOnlineMode(_ onlineMode: OnlineMode) {
        if let closure = changeOperatinModeClosure {
            closure!()
        }
        if(onlineMode == .online || onlineMode == .onlineSlow) {
            self.onlineMode = onlineMode
        } else {
            changeOperatinModeClosure = DispatchQueue.main.cancellableAsyncAfter(secondsDeadline: changeOperatingModeDelay) {
                self.onlineMode = onlineMode
            }
        }
    }

}
