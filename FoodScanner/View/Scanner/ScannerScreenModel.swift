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

    /// Fetches (or re-reads) a product and publishes it via `banner`/`scannedFood`.
    /// Navigation is no longer automatic: `scannedFood` is only the payload a
    /// user tap on the `.found` banner (in `ScannerScreenView`) pushes onto the
    /// NavigationStack — resolving a product never pushes anything by itself.
    ///
    /// While the same barcode stays in frame, `CameraPreviewView` keeps calling
    /// this method multiple times per second. Once a barcode has already been
    /// resolved (`self.barcode` still set to it), repeated calls for that same
    /// barcode must be no-ops: republishing `banner`/`scannedFood` here would
    /// re-render the "found" banner (and reset its tap target) for a barcode
    /// the user hasn't moved the camera away from, or hasn't tapped yet.
    /// `resetForNewScan()` (called once the NavigationStack path is back at
    /// root) is what re-arms detection of that same barcode.
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

    /// Consumed right after the user taps the "found" banner to navigate.
    /// `scannedFood` itself is cleared, but
    /// `barcode` is intentionally left set: this is what keeps
    /// `getFoodInformations(barcode:)` from re-pushing the fiche while the
    /// same barcode is still in frame and the user hasn't left the scanner's
    /// root screen yet. See `resetForNewScan()`.
    func consumeScannedFood() {
        scannedFood = nil
    }

    /// Re-arms barcode detection once the Scanner tab's `NavigationStack` is
    /// back at its root (the user popped back from the fiche, or dismissed
    /// it). Without this, scanning the very same barcode again after coming
    /// back to the scanner would silently do nothing, since `getFoodInformations`
    /// still treats it as already resolved.
    func resetForNewScan() {
        barcode = ""
        food = nil
        banner = nil
    }
}
