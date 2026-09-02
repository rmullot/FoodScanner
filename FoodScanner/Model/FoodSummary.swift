//
//  FoodSummary.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//

import Foundation

struct FoodSummary: Sendable {
    let barcode: String
    let name: String
    let imageURL: String
    let nutriscoreGrade: String?
    let lastUpdate: TimeInterval
}
