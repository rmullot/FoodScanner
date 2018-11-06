//
//  String+Regex.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation

extension String {
    var isNumeric: Bool {
        return range(of: "[^0-9]", options: .regularExpression) == nil
    }
}
