//
//  OnboardingView.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//

import SwiftUI
import AVFoundation
import FoodScannerUI

struct OnboardingView: View {
    let onFinished: () -> Void

    @State private var authorizationDenied = false

    var body: some View {
        VStack(spacing: FSMetrics.space6) {
            Spacer()

            FSMascot(.strawberry, size: 96)

            Text(L10n.Onboarding.welcomeTitle)
                .font(.fsHeadline)
                .foregroundStyle(Color.fsInk)
                .multilineTextAlignment(.center)

            Text(L10n.Onboarding.welcomeMessage)
                .font(.fsBody)
                .foregroundStyle(Color.fsInkSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if authorizationDenied {
                Text(L10n.Onboarding.cameraDeniedMessage)
                    .font(.fsCaption)
                    .foregroundStyle(Color.fsAccent)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            FSButton(L10n.Onboarding.allowCameraButton, systemImage: "camera") {
                requestCameraAuthorization()
            }

            FSButton(L10n.Onboarding.continueWithoutCameraButton, role: .quiet) {
                onFinished()
            }
        }
        .padding(FSMetrics.space6)
        .background(Color.fsBackground)
    }

    private func requestCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            onFinished()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        onFinished()
                    } else {
                        authorizationDenied = true
                    }
                }
            }
        default:
            authorizationDenied = true
        }
    }
}

#Preview("Clair") {
    OnboardingView(onFinished: {})
        .preferredColorScheme(.light)
}

#Preview("Sombre") {
    OnboardingView(onFinished: {})
        .preferredColorScheme(.dark)
}

#Preview("Accessibilité XL") {
    OnboardingView(onFinished: {})
        .environment(\.dynamicTypeSize, .accessibility5)
}
