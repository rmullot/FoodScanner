//
//  CameraTool.swift
//  FoodScanner
//
//  Created by Romain Mullot on 29/10/2018.
//  Copyright © 2018 Romain Mullot. All rights reserved.
//

import Foundation
import AVFoundation

class CameraTool {
    
    //MARK: - Attributes
    
    static let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                                 AVMetadataObject.ObjectType.code39,
                                                 AVMetadataObject.ObjectType.code39Mod43,
                                                 AVMetadataObject.ObjectType.code93,
                                                 AVMetadataObject.ObjectType.code128,
                                                 AVMetadataObject.ObjectType.ean8,
                                                 AVMetadataObject.ObjectType.ean13,
                                                 AVMetadataObject.ObjectType.aztec,
                                                 AVMetadataObject.ObjectType.pdf417,
                                                 AVMetadataObject.ObjectType.itf14,
                                                 AVMetadataObject.ObjectType.dataMatrix,
                                                 AVMetadataObject.ObjectType.interleaved2of5,
                                                 AVMetadataObject.ObjectType.qr]
    
    //MARK: - Methods
    
    static func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        #if targetEnvironment(simulator)
            print("Missing capture devices.")
            return nil
        #else
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
                [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
                                                                    mediaType: .video, position: .unspecified)
            let devices = discoverySession.devices
        
            return devices.first(where: { device in device.position == position })!
        #endif
    }
    
    static func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = on ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
}
