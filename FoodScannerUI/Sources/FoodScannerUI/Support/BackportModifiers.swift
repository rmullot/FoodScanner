//
//  BackportModifiers.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/10/2026.
//

import SwiftUI

extension View {
    @ViewBuilder
    func scrollBounceBasedOnSize() -> some View {
        if #available(iOS 16.4, *) {
            scrollBounceBehavior(.basedOnSize)
        } else {
            self
        }
    }
}
