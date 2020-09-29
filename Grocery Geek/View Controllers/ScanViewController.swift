//
//  ScanViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2019-05-07.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import AVFoundation
import UIKit
import CoreData

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, BarcodeManagerDelegate {
    
    @IBOutlet weak var actionBar: UIToolbar!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var barcodeProduct: Barcode?
    var list: List!
    var barcodeManager: BarcodeManager!
    var section: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        barcodeManager = BarcodeManager(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        barcodeManager.delegate = self
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        let height = view.layer.bounds.height - actionBar.layer.bounds.height
        let width = view.layer.bounds.width
        let originX = view.layer.bounds.origin.x
        let originY = view.layer.bounds.origin.y
        previewLayer.frame = CGRect(x: originX, y: originY, width: width, height: height)
        
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        view.bringSubviewToFront(spinner)

        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(
            title: "Scanning unavailable",
            message: "Looks like your device doesn't support scanning barcodes.",
            preferredStyle: .alert
        )
        
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
        spinner.layer.cornerRadius = 20
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
    }

    func found(code: String) {
        spinner.startAnimating()
        barcodeManager.findProduct(code: code)
    }
    
    func barcodeFound(barcode: Barcode) {
        self.barcodeProduct = barcode
        spinner.stopAnimating()
        performSegue(withIdentifier: "scanAdd", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            
        case "scanAdd":
            let destinationVC = segue.destination as! AddViewController
            destinationVC.barcodeProduct = self.barcodeProduct
            destinationVC.list = self.list
            destinationVC.section = self.section
            
        default:
            break
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func cancelScan(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
