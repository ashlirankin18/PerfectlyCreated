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
class VideoSessionController: NSObject {
    
    private lazy var session: AVCaptureSession = AVCaptureSession()
    
    private var aVCaptureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var barcodeController = BarCodeScannerController()
    
    /// Subscriber to this publisher to recieve chages related to the barcode.
    var bacodeStringPublisher: AnyPublisher<String, Error> {
        return bacodeStringSubject.eraseToAnyPublisher()
    }
    
    private var bacodeStringSubject = PassthroughSubject<String, Error>()
    
    private var cancellables = Set<AnyCancellable>()
    
    func startRunningSession() {
        session.startRunning()
    }
    
    func stopRunningSession() {
        session.stopRunning()
    }
    
    /// Configures the AvCaptureDevice.
    func configureCaptureDevice(with view: UIView) {
        startRunningSession()
        
        session.sessionPreset = AVCaptureSession.Preset.iFrame1280x720
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video), let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: .global())
        
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        configureOutput(view: view)
        
        session.startRunning()
    }
    
    private func configureOutput(view: UIView) {
        aVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        aVCaptureVideoPreviewLayer?.frame = view.bounds
        aVCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        if let previewLayerUnwrap = aVCaptureVideoPreviewLayer {
            view.layer.addSublayer(previewLayerUnwrap)
        }
    }
}

extension VideoSessionController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        barcodeController.captureOutput(with: .buffer(buffer: sampleBuffer))
            .sink { completion in
                switch completion {
                case .failure: break
                case .finished: break
                }
            } receiveValue: { [weak self] barcodeString in
                self?.bacodeStringSubject.send(barcodeString)
            }
            .store(in: &self.cancellables)
    }
}
