//
//  SystemAccessibilityProviding.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/10/2026.
//

import Combine
import UIKit

/// Read-only seam over the live iOS system accessibility state that the app
/// mirrors in Settings. iOS exposes no API to mutate these settings, so the
/// protocol is deliberately get-only; `changesPublisher` fires whenever one of
/// the mirrored values changes while the app is foregrounded.
@MainActor
protocol SystemAccessibilityProviding: AnyObject {
    var isReduceMotionEnabled: Bool { get }
    var isIncreasedContrastEnabled: Bool { get }
    var preferredContentSizeCategory: UIContentSizeCategory { get }
    var changesPublisher: AnyPublisher<Void, Never> { get }
}

@MainActor
final class SystemAccessibilityManager: SystemAccessibilityProviding {
    private let subject = PassthroughSubject<Void, Never>()
    private let notificationCenter: NotificationCenter
    private var observers: [NSObjectProtocol] = []

    var changesPublisher: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    var isReduceMotionEnabled: Bool { UIAccessibility.isReduceMotionEnabled }

    var isIncreasedContrastEnabled: Bool { UIAccessibility.isDarkerSystemColorsEnabled }

    var preferredContentSizeCategory: UIContentSizeCategory {
        UIApplication.shared.preferredContentSizeCategory
    }

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter

        let names: [Notification.Name] = [
            UIAccessibility.reduceMotionStatusDidChangeNotification,
            UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
            UIContentSizeCategory.didChangeNotification
        ]

        observers = names.map { name in
            notificationCenter.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.subject.send(())
                }
            }
        }
    }

    deinit {
        observers.forEach { notificationCenter.removeObserver($0) }
    }
}
