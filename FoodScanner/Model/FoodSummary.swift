//
//  FoodSummary.swift
//  FoodScanner
//
//  Résumé léger d'un produit, pensé pour traverser les frontières async/actor
//  (historique, listes) sans jamais exposer un objet Realm managé.
//

import Foundation

struct FoodSummary: Sendable {
    let barcode: String
    let name: String
    let imageURL: String
    let nutriscoreGrade: String?
    let lastUpdate: TimeInterval
}
