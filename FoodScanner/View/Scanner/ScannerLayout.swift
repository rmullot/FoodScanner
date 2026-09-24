//
//  ScannerLayout.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/24/2026.
//

import SwiftUI
import FoodScannerUI

struct ScannerLayout: Equatable {
    let isSideBySide: Bool

    init(horizontalSizeClass: UserInterfaceSizeClass?, verticalSizeClass: UserInterfaceSizeClass?) {
        isSideBySide = horizontalSizeClass == .regular || verticalSizeClass == .compact
    }

    func keypadHeight(containerHeight: CGFloat) -> CGFloat {
        let available = isSideBySide
            ? containerHeight - FSMetrics.space10 * 2 - FSMetrics.controlHeight * 2
            : containerHeight * 0.45
        return max(FSMetrics.keypadMinRegionHeight, available)
    }

    func panelMaxHeight(containerHeight: CGFloat) -> CGFloat {
        isSideBySide ? containerHeight : containerHeight * 0.75
    }
}
