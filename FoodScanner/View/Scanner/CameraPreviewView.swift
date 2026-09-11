//
//  CameraPreviewView.swift
//  FoodScanner
//  Copyright © MULLOT Romain EI. All rights reserved.
//  Created on 09/01/2026.
//
//

import SwiftUI
import AVFoundation
import UIKit
import FoodScannerUI

struct CameraPreviewView: UIViewRepresentable {

    let onBarcodeDetected: (String) -> Void

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.onBarcodeDetected = onBarcodeDetected
        view.start()
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.onBarcodeDetected = onBarcodeDetected
    }

    static func dismantleUIView(_ uiView: CameraPreviewUIView, coordinator: ()) {
        uiView.stop()
    }
}

final class CameraPreviewUIView: UIView {

    var onBarcodeDetected: ((String) -> Void)?

    private let captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var captureMetadataOutput = AVCaptureMetadataOutput()
    private var barCodeFrameView: UIView?
    private let sessionQueue = DispatchQueue(label: "com.foodscanner.cameraSession")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSession()
        setupTapToFocus()
        setupOrientationObserver()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSession()
        setupTapToFocus()
        setupOrientationObserver()
    }

    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer?.frame = layer.bounds
        updateVideoRotationAngle()
    }

    private func setupOrientationObserver() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateVideoRotationAngle),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc private func updateVideoRotationAngle() {
        let angle: CGFloat
        switch UIDevice.current.orientation {
        case .landscapeLeft: angle = 0
        case .landscapeRight: angle = 180
        case .portraitUpsideDown: angle = 270
        default: angle = 90
        }
        if let connection = videoPreviewLayer?.connection, connection.isVideoRotationAngleSupported(angle) {
            connection.videoRotationAngle = angle
        }
    }

    private func setupSession() {
        guard let captureDevice = CameraTool.bestDevice(in: .back) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)

            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            layer.addSublayer(previewLayer)
            videoPreviewLayer = previewLayer
        } catch {
            print(error)
            return
        }

        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = CameraTool.supportedCodeTypes

        let frameView = UIView()
        frameView.layer.borderColor = UIColor(Color.fsLeaf).cgColor
        frameView.layer.borderWidth = FSMetrics.borderWidthStrong
        addSubview(frameView)
        barCodeFrameView = frameView
    }

    private func setupTapToFocus() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = true
        addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        endEditing(true)
    }

    func start() {
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        sessionQueue.async { [captureSession] in
            guard !captureSession.isRunning else { return }
            captureSession.startRunning()
        }
    }

    func stop() {
        captureMetadataOutput.setMetadataObjectsDelegate(nil, queue: DispatchQueue.main)
        barCodeFrameView?.frame = .zero
        sessionQueue.async { [captureSession] in
            guard captureSession.isRunning else { return }
            captureSession.stopRunning()
        }
    }
}

extension CameraPreviewUIView: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !metadataObjects.isEmpty else {
            barCodeFrameView?.frame = .zero
            return
        }

        if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
           CameraTool.supportedCodeTypes.contains(metadataObj.type),
           let videoPreviewLayer,
           let barCodeFrameView,
           let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadataObj) {
            barCodeFrameView.frame = barCodeObject.bounds

            if let barcode = metadataObj.stringValue {
                onBarcodeDetected?(barcode)
            }
        }
    }
}
