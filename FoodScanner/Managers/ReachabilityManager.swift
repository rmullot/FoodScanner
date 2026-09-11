//
//  ReachabilityManager.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation
import Combine
import CoreTelephony

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

@MainActor
public final class ReachabilityManager: ObservableObject, ReachabilityProviding {

    // MARK: Properties

    @Published public private(set) var onlineMode: OnlineMode = .online

    public var onlineModePublisher: AnyPublisher<OnlineMode, Never> {
        $onlineMode.eraseToAnyPublisher()
    }

    private let source: ReachabilitySource

    private let changeOperatingModeDelay: Double

    private var changeOperatingModeTask: Task<Void, Never>?

    init(source: ReachabilitySource? = nil, changeOperatingModeDelay: Double = 2.0) {
        self.source = source ?? SystemReachabilitySource()
        self.changeOperatingModeDelay = changeOperatingModeDelay
        self.source.reachabilityDidChange = { [weak self] in
            if Thread.isMainThread {
                MainActor.assumeIsolated {
                    self?.reachabilityChanged()
                }
            } else {
                Task { @MainActor in
                    self?.reachabilityChanged()
                }
            }
        }
        self.source.start()
    }

    // MARK: Reachability changed

    func reachabilityChanged() {
        if source.isReachable {

            if let radioAccessTechnologies = source.currentRadioAccessTechnologies, !radioAccessTechnologies.isEmpty {
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
        changeOperatingModeTask?.cancel()
        changeOperatingModeTask = nil

        guard newMode == .offline else {
            onlineMode = newMode
            return
        }

        let delay = changeOperatingModeDelay
        changeOperatingModeTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.onlineMode = newMode
        }
    }

}
