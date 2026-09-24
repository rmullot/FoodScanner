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
    let isCompactHeight: Bool

    init(horizontalSizeClass: UserInterfaceSizeClass?, verticalSizeClass: UserInterfaceSizeClass?) {
        isCompactHeight = verticalSizeClass == .compact
        isSideBySide = horizontalSizeClass == .regular && !isCompactHeight
    }

    func keypadHeight(containerHeight: CGFloat) -> CGFloat {
        let available = isSideBySide
            ? containerHeight - FSMetrics.space10 * 2 - FSMetrics.controlHeight * 2
            : containerHeight * 0.45
        return max(FSMetrics.keypadMinRegionHeight, available)
    }

    var panelTopPadding: CGFloat {
        isCompactHeight ? FSMetrics.space2 : 0
    }

    var panelBottomPadding: CGFloat {
        isCompactHeight ? FSMetrics.space2 : FSMetrics.space4
    }

    func panelMaxWidth(showsKeypad: Bool) -> CGFloat {
        let columns: CGFloat = isCompactHeight && showsKeypad ? 2 : 1
        return FSMetrics.keypadMaxWidth * columns + FSMetrics.space10 * 2
    }

    func panelMaxHeight(containerHeight: CGFloat) -> CGFloat {
        isSideBySide || isCompactHeight ? containerHeight : containerHeight * 0.85
    }
}
