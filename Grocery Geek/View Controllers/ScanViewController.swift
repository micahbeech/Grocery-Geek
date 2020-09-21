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

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var actionBar: UIToolbar!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var barcodeProduct: BarcodeProduct?
    var list: List?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        let bounds = CGRect(x: originX, y: originY, width: width, height: height)
        previewLayer.frame = bounds
        
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

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
        
        // Get existings barcodes
        var barcodeProducts = [BarcodeProduct]()
        
        do {
            barcodeProducts = try context.fetch(BarcodeProduct.fetchRequest())
        } catch {
            print("Could not fetch barcodes")
        }
        
        for item in barcodeProducts {
            if item.barcode == code {
                barcodeProduct = item
                break
            }
        }
        
        if barcodeProduct == nil {
            let barcodeEntity = NSEntityDescription.entity(forEntityName: "BarcodeProduct", in: context)
            barcodeProduct = NSManagedObject(entity: barcodeEntity!, insertInto: context) as? BarcodeProduct
            barcodeProduct?.barcode = code
        }
        
        performSegue(withIdentifier: "scanAdd", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            
        case "scanAdd":
            let destinationVC = segue.destination as! AddViewController
            destinationVC.barcodeProduct = self.barcodeProduct
            destinationVC.list = self.list
            
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
