//
//  FoodSummary.swift
//  FoodScanner
//
//  Lightweight summary of a product, designed to cross async/actor
//  boundaries (history, lists) without ever exposing a managed Realm object.
//

import Foundation

struct FoodSummary: Sendable {
    let barcode: String
    let name: String
    let imageURL: String
    let nutriscoreGrade: String?
    let lastUpdate: TimeInterval
}
