//
//  ScannerScreenModel.swift
//  FoodScanner
//
//  ObservableObject natif remplaçant ScannerViewModel (propertyChanged/PropertyKeys).
//  Appelle directement les Managers async ; aucun objet Realm managé ne traverse
//  cette frontière, uniquement des FoodStruct (Sendable).
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

    /// Récupère (ou relit) un produit et le publie via `scannedFood` pour piloter
    /// la navigation locale de l'onglet Scanner.
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

    /// Consommé après navigation pour permettre un nouveau scan du même code-barres.
    func consumeScannedFood() {
        scannedFood = nil
    }
}
