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
    private var captureMetadataOutput = AVCaptureMetadataOutput()
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lampButton: UIButton!
    
    var viewModel = ScannerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.propertyChanged = { [weak self] key in self?.viewModelPropertyChanged(key) }
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
                refreshCameraFrame()
                cameraView.layer.addSublayer(videoPreviewLayer)
                
                let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTapEvent(sender:)))
                singleTapGestureRecognizer.numberOfTapsRequired = 1
                singleTapGestureRecognizer.isEnabled = true
                singleTapGestureRecognizer.cancelsTouchesInView = true
                cameraView.addGestureRecognizer(singleTapGestureRecognizer)
                
                cameraView.bringSubviewToFront(lampButton)

            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
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
    
    override func viewDidDisappear(_ animated: Bool) {
        captureMetadataOutput.setMetadataObjectsDelegate(nil, queue: DispatchQueue.main)
        viewModel.forceSwitchOffLamp()
        barCodeFrameView?.frame = CGRect.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        refreshCameraFrame()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshCameraFrame()
       
    }
    
    private func refreshCameraFrame() {
        if let videoPreviewLayer = videoPreviewLayer {
            videoPreviewLayer.frame = cameraView.layer.bounds
            videoPreviewLayer.connection?.videoOrientation = UIDevice.current.orientation == UIDeviceOrientation.landscapeRight || UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ? .landscapeLeft : .portrait
        }
    }
    
    @IBAction func toggleLampEvent() {
        viewModel.toggleLamp()
        lampButton.backgroundColor = viewModel.lampActivated ? UIColor.white : UIColor.black
        lampButton.setTitleColor(viewModel.lampActivated ? UIColor.blue : UIColor.white, for: .normal)
    }
    
    @objc func singleTapEvent(sender: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
        if let barcode = searchBar.text {
            checkBarcode(barcode: barcode)
        }
    }
    
    private func checkBarcode(barcode: String) {
        if barcode.isNumeric {
            searchBar.text = barcode
            viewModel.getFoodInformations(barcode: barcode)
        } else {
            searchBar.text = ""
        }
    }
    
    private func viewModelPropertyChanged(_ key: String) {
        switch key {
        case ScannerViewModel.PropertyKeys.statusMessage.rawValue:
            messageLabel.text = viewModel.statusMessage
        default:
            break
        }
    }

}

extension ScannerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return viewModel.isValidBarcode(text)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.rebootStatusMessage()
        searchBar.resignFirstResponder()
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            barCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject, CameraTool.supportedCodeTypes.contains(metadataObj.type), let videoPreviewLayer = videoPreviewLayer, let barCodeFrameView = barCodeFrameView,  let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadataObj) {
            // If the found metadata is equal to the bar code metadata then update the status label's text and set the bounds
           
            barCodeFrameView.frame = barCodeObject.bounds
            
            if let barcode = metadataObj.stringValue {
                checkBarcode(barcode: barcode)
            }
        }
    }
    
}

