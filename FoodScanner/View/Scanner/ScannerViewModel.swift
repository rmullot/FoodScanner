//
//  ScannerViewModel.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//

import Foundation
import Combine
import FoodScannerUI

@MainActor
final class ScannerViewModel: ObservableObject {

    @Published private(set) var statusMessage: String = ""
    @Published var banner: FSScanStatusBanner.State?
    @Published var lampActivated: Bool = false
    @Published private(set) var scannedFood: FoodStruct?
    @Published private(set) var isNetworkActive: Bool = false

    private var barcode: String = ""
    private var food: FoodStruct?

    private let webService: WebServiceProviding
    private let reachability: ReachabilityProviding
    private let networkActivity: NetworkActivityTracking
    private var reachabilityCancellable: AnyCancellable?
    private var networkActivityCancellable: AnyCancellable?

    init(webService: WebServiceProviding? = nil,
         reachability: ReachabilityProviding? = nil,
         networkActivity: NetworkActivityTracking? = nil) {
        self.webService = webService ?? InjectionManager.shared.webService
        self.reachability = reachability ?? InjectionManager.shared.reachability
        self.networkActivity = networkActivity ?? InjectionManager.shared.networkActivity
        let reachability = self.reachability
        reachabilityCancellable = reachability.onlineModePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] onlineMode in
                guard onlineMode == .offline else { return }
                self?.banner = .offline
            }
        networkActivityCancellable = self.networkActivity.isActivePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isActive in
                self?.isNetworkActive = isActive
            }
    }

    func getFoodInformations(barcode: String) {
        guard self.barcode != barcode else {
            return
        }

        self.food = nil
        self.barcode = barcode
        self.statusMessage = barcode
        self.banner = .reading

        Task {
            do {
                let foodStruct = try await webService.getFoodDescription(barcode: barcode)
                self.food = foodStruct
                self.banner = .found(foodStruct.name)
                self.scannedFood = foodStruct
            } catch {
                self.statusMessage = error.localizedDescription
                self.banner = reachability.onlineMode == .offline ? .offline : .notFound
            }
        }
    }

    func toggleLamp() {
        lampActivated.toggle()
        CameraTool.toggleTorch(on: lampActivated)
    }

    func forceSwitchOffLamp() {
        lampActivated = false
        CameraTool.toggleTorch(on: lampActivated)
    }

    func rebootStatusMessage() {
        statusMessage = "No bar code is detected"
    }

    func isValidBarcode(_ text: String) -> Bool {
        if text.isEmpty {
            return true
        } else {
            return text.isNumeric
        }
    }

    func consumeScannedFood() {
        scannedFood = nil
    }

    func resetForNewScan() {
        barcode = ""
        food = nil
        banner = nil
    }
}
