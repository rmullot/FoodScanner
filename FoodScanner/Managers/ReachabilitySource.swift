//
//  ReachabilitySource.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/04/2026.
//

import CoreTelephony
import Foundation
import UIKit

// MARK: - ReachabilitySource

protocol ReachabilitySource: AnyObject {
    var isReachable: Bool { get }
    var currentRadioAccessTechnologies: [String: String]? { get }
    var reachabilityDidChange: (() -> Void)? { get set }
    func start()
}

// MARK: - SystemReachabilitySource

final class SystemReachabilitySource: ReachabilitySource {

    var reachabilityDidChange: (() -> Void)?

    private var reachability: Reachability?

    private let telephonyInfo = CTTelephonyNetworkInfo()

    init() {
        reachability = Reachability()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    var isReachable: Bool {
        reachability?.isReachable ?? false
    }

    var currentRadioAccessTechnologies: [String: String]? {
        telephonyInfo.serviceCurrentRadioAccessTechnology
    }

    func start() {
        guard let reachability else {
            print("Unable to create Reachability!")
            return
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notifyChange),
                                               name: ReachabilityChangedNotification,
                                               object: reachability)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refresh),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)

        do {
            try reachability.startNotifier()
        } catch let error {
            print("Unable to start Reachability! Error: \(error)")
        }
    }

    @objc private func notifyChange() {
        reachabilityDidChange?()
    }

    @objc private func refresh() {
        guard let reachability else { return }
        NotificationCenter.default.post(name: ReachabilityChangedNotification, object: reachability)
    }
}
