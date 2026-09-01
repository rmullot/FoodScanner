//
//  ScannerScreenModel.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//  Native ObservableObject replacing ScannerViewModel (propertyChanged/PropertyKeys).
//  Calls the async Managers directly; no managed Realm object crosses this
//  boundary, only FoodStruct (Sendable).
//

import Foundation
import Combine
import FoodScannerUI

@MainActor
final class ScannerScreenModel: ObservableObject {

    @Published private(set) var statusMessage: String = ""
    @Published var banner: FSScanStatusBanner.State?
    @Published var lampActivated: Bool = false
    @Published private(set) var scannedFood: FoodStruct?

    private var barcode: String = ""
    private var food: FoodStruct?

    private var reachabilityCancellable: AnyCancellable?

    init() {
        reachabilityCancellable = ReachabilityManager.sharedInstance.$onlineMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] onlineMode in
                guard onlineMode == .offline else { return }
                self?.banner = .offline
            }
    }

    /// Fetches (or re-reads) a product and publishes it via `scannedFood` to drive
    /// the Scanner tab's local navigation.
    func getFoodInformations(barcode: String) {
        guard self.barcode != barcode else {
            if let food {
                scannedFood = food
            }
            return
        }

        self.food = nil
        self.barcode = barcode
        self.statusMessage = barcode
        self.banner = .reading

        Task {
            do {
                let foodStruct = try await WebServiceManager.sharedInstance.getFoodDescription(barcode: barcode)
                self.food = foodStruct
                self.banner = .found(foodStruct.name)
                self.scannedFood = foodStruct
            } catch {
                self.statusMessage = error.localizedDescription
                self.banner = ReachabilityManager.sharedInstance.onlineMode == .offline ? .offline : .notFound
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

    /// Consumed after navigation to allow a new scan of the same barcode.
    func consumeScannedFood() {
        scannedFood = nil
    }
}
