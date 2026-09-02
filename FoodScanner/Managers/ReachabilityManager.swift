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

// MARK: - Reachability Manager

public final class ReachabilityManager: ObservableObject {

    // MARK: Properties

    static let sharedInstance = ReachabilityManager()

    @Published public private(set) var onlineMode: OnlineMode = .online

    private var reachability: Reachability?

    private let telephonyInfo = CTTelephonyNetworkInfo()

    private let changeOperatingModeDelay: Double = 2.0

    private var changeOperatinModeClosure: DispatchQueue.CancellableClosure = nil

    private init() {
        reachability = Reachability()
        if let reachability {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(ReachabilityManager.reachabilityChanged(_:)),
                                                   name: ReachabilityChangedNotification,
                                                   object: reachability)
            do {
                try reachability.startNotifier()
            } catch let error {
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
            NotificationCenter.default.post(name: ReachabilityChangedNotification, object: reachability)
        }
    }

    @objc dynamic func reachabilityChanged(_ note: Notification) {
        guard let noteReachability = note.object as? Reachability, let reachability = self.reachability, reachability === noteReachability else {
            return
        }

        if reachability.isReachable {

            if let radioAccessTechnologies = telephonyInfo.serviceCurrentRadioAccessTechnology, !radioAccessTechnologies.isEmpty {
                let isSlow = radioAccessTechnologies.values.contains { technology in
                    technology == CTRadioAccessTechnologyEdge ||
                    technology == CTRadioAccessTechnologyCDMA1x ||
                    technology == CTRadioAccessTechnologyGPRS
                }
                changeOnlineMode(isSlow ? .onlineSlow : .online)
            } else {
                changeOnlineMode(.online)
            }

        } else {
            changeOnlineMode(.offline)
        }
    }

    public func changeOnlineMode(_ newMode: OnlineMode) {
        changeOperatinModeClosure?()
        if newMode == .online || newMode == .onlineSlow {
            publish(newMode)
        } else {
            changeOperatinModeClosure = DispatchQueue.main.cancellableAsyncAfter(secondsDeadline: changeOperatingModeDelay) { [weak self] in
                self?.publish(newMode)
            }
        }
    }

    private func publish(_ newMode: OnlineMode) {
        if Thread.isMainThread {
            onlineMode = newMode
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.onlineMode = newMode
            }
        }
    }

}
