//
//  ScannerViewController.swift
//  FoodScanner
//
//  Created by Romain Mullot on 22/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController {
    
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var barCodeFrameView: UIView?
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lampButton: UIButton!
    
    var viewModel: ScannerViewModel! {
        didSet {
            // TODO
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ScannerViewModel()
        messageLabel.layer.shadowColor = UIColor.black.cgColor
        messageLabel.layer.shadowRadius = 1.0
        messageLabel.layer.shadowOpacity = 1.0
        messageLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        messageLabel.layer.masksToBounds = false
        
        
        guard let captureDevice = CameraTool.bestDevice(in: .back) else { return }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            if let videoPreviewLayer = videoPreviewLayer {
                videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer.frame = cameraView.layer.bounds
                videoPreviewLayer.connection?.videoOrientation = .portrait
                cameraView.layer.addSublayer(videoPreviewLayer)
                cameraView.bringSubviewToFront(lampButton)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = CameraTool.supportedCodeTypes
        
        // Start video capture.
        captureSession.startRunning()
        
        barCodeFrameView = UIView()
        
        if let barCodeFrameView = barCodeFrameView {
            barCodeFrameView.layer.borderColor = UIColor.green.cgColor
            barCodeFrameView.layer.borderWidth = 2
            cameraView.addSubview(barCodeFrameView)
            cameraView.bringSubviewToFront(barCodeFrameView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = self.cameraView.bounds
    }
    
    @IBAction func toggleLampEvent() {
        viewModel.toggleLamp()
        lampButton.backgroundColor = viewModel.lampActivated ? UIColor.white : UIColor.black
        lampButton.setTitleColor(viewModel.lampActivated ? UIColor.blue : UIColor.white, for: .normal)
    }

}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            barCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No bar code is detected"
            return
        }
        
        // Get the metadata object.
        if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject, CameraTool.supportedCodeTypes.contains(metadataObj.type), let videoPreviewLayer = videoPreviewLayer, let barCodeFrameView = barCodeFrameView,  let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadataObj) {
            // If the found metadata is equal to the bar code metadata then update the status label's text and set the bounds
           
            barCodeFrameView.frame = barCodeObject.bounds
            
            if let barcode = metadataObj.stringValue {
                if barcode.isNumeric {
                    messageLabel.text = barcode
                    searchBar.text = barcode
                    viewModel.getFoodInformations(barcode: barcode)
                } else {
                    messageLabel.text = "data received but not a valid digital barcode"
                    searchBar.text = ""
                }
            }
        }
    }
    
}

