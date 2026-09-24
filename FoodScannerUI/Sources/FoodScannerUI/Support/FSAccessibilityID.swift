//
//  FSAccessibilityID.swift
//  FoodScannerUI
//
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/24/2026.
//

import SwiftUI

public enum FSAccessibilityID: Equatable {
    case keypadValidate
    case keypadKeyDelete
    case keypadKey(String)
    case statusRowTextSizeStatus
    case statusRowTextSizeOpenSettings

    public var identifier: String {
        switch self {
        case .keypadValidate: return "keypad.validate"
        case .keypadKeyDelete: return "keypad.key.delete"
        case .keypadKey(let key): return "keypad.key.\(key)"
        case .statusRowTextSizeStatus: return "statusRow.textSize.status"
        case .statusRowTextSizeOpenSettings: return "statusRow.textSize.openSettings"
        }
    }
}

extension View {
    func fsAccessibilityIdentifier(_ id: FSAccessibilityID) -> some View {
        accessibilityIdentifier(id.identifier)
    }
}
