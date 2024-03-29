//
//  VideoSessionController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 10/31/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Combine

/// Controls the logic related to reading the barcodes.
final class VideoSessionController: NSObject {
    
    private lazy var session: AVCaptureSession = AVCaptureSession()
    
    private var aVCaptureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let shapeLayer = CAShapeLayer()
    
    /// Subscriber to this publisher to receive changes related to the barcode.
    var barcodeStringPublisher: AnyPublisher<String, Error> {
        return barcodeStringSubject.eraseToAnyPublisher()
    }
    
    private let view: UIView
    
    init(view: UIView) {
        self.view = view
        super.init()
    }
    
    private var barcodeStringSubject = PassthroughSubject<String, Error>()
    
    private var cancellables = Set<AnyCancellable>()
    
    func startRunningSession() {
        session.startRunning()
    }
    
    func stopRunningSession() {
        session.stopRunning()
    }
    
    /// Configures the AvCaptureDevice.
    func configureCaptureDevice() {
        startRunningSession()
    
        let metadataOutput = AVCaptureMetadataOutput()
        
        session.sessionPreset = AVCaptureSession.Preset.iFrame1280x720
        
        guard let captureDevice = AVCaptureDevice.default(for: .video), let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        session.addInput(deviceInput)
        session.addOutput(metadataOutput)
        
        configureOutput()
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        metadataOutput.rectOfInterest = aVCaptureVideoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: CGRect(x: view.frame.width * 0.065, y: view.center.y - 48, width: view.frame.width * 0.85, height: view.frame.width * 0.5)) ?? .zero
    }
    
    private func configureOutput() {
        aVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        aVCaptureVideoPreviewLayer?.frame = view.frame
        aVCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        if let previewLayerUnwrap = aVCaptureVideoPreviewLayer {
            view.layer.addSublayer(previewLayerUnwrap)
            configureRoundRectPath()
        }
    }
    
    private func configureRoundRectPath() {
        let path = UIBezierPath(roundedRect: CGRect(x: view.frame.width * 0.068, y: view.center.y - 48, width: view.frame.width * 0.85, height: view.frame.width * 0.5), cornerRadius: 20.0)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 5.0
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.path = path.cgPath
        view.layer.addSublayer(shapeLayer)
    }
}

extension VideoSessionController: AVCaptureMetadataOutputObjectsDelegate {
   
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first else {
            return
        }
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
            return
        }
        guard let stringValue = readableObject.stringValue else {
            return
        }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.barcodeStringSubject.send(stringValue)
    }
}
