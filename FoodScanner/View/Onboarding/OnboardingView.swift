//
//  OnboardingView.swift
//  FoodScanner
//
//  Écran d'accueil/permissions : bienvenue + autorisation caméra.
//  Présenté en .fullScreenCover depuis la racine au premier lancement.
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

            Text("Bienvenue sur FoodScanner")
                .font(.fsHeadline)
                .foregroundStyle(Color.fsInk)
                .multilineTextAlignment(.center)

            Text("Scannez un code-barres pour découvrir le Nutri-Score et les nutriments d'un produit.")
                .font(.fsBody)
                .foregroundStyle(Color.fsInkSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if authorizationDenied {
                Text("La caméra est nécessaire pour scanner un produit. Vous pouvez l'autoriser dans les "
                     + "réglages iOS, ou saisir le code-barres manuellement dans l'app.")
                    .font(.fsCaption)
                    .foregroundStyle(Color.fsAccent)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            FSButton("Autoriser la caméra", systemImage: "camera") {
                requestCameraAuthorization()
            }

            FSButton("Continuer sans la caméra", role: .quiet) {
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
