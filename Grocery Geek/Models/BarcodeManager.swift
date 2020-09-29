//
//  BarcodeManager.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-24.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import Foundation
import CoreData

protocol BarcodeManagerDelegate {
    func barcodeFound(barcode: Barcode)
}

class BarcodeManager {
    
    var context: NSManagedObjectContext
    var delegate: BarcodeManagerDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func findProduct(code: String) {
        
        // Get existings barcodes
        var barcodeProducts = [Barcode]()
        
        do {
            barcodeProducts = try context.fetch(Barcode.fetchRequest())
        } catch {
            print("Could not fetch barcodes")
        }
        
        for item in barcodeProducts {
            if item.barcode == code {
                delegate?.barcodeFound(barcode: item)
                return
            }
        }
        
        searchProduct(code: code)
        
    }
    
    private func searchProduct(code: String) {
        
        guard let fileURL = Bundle.main.url(forResource: "apikeys", withExtension: "txt") else {
            delegate?.barcodeFound(barcode: createBarcode(code: code))
            return
        }

        var key = ""
        
        do {
            key = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print("Could not read from \(fileURL.absoluteString)")
            delegate?.barcodeFound(barcode: createBarcode(code: code))
            return
        }
        
        key = String(key.dropLast())
        
        let queryItems = [
            URLQueryItem(name: "barcode", value: code),
            URLQueryItem(name: "formatted", value: "y"),
            URLQueryItem(name: "key", value: key)
        ]
        var urlComponents = URLComponents(string: "https://api.barcodelookup.com/v2/products")!
        urlComponents.queryItems = queryItems

        let request = NSMutableURLRequest(url: urlComponents.url! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                
            } else if data != nil {
                
                do {
                    var name: String?
                    
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        if let products = json["products"] as? [[String: Any]] {
                            if let product = products.first {
                                name = product["product_name"] as? String
                            }
                        }
                    }
                    
                    let barcode = self.createBarcode(code: code, name: name)
                    
                    DispatchQueue.main.async {
                        self.delegate?.barcodeFound(barcode: barcode)
                    }
                    
                } catch {
                    print("Could not parse barcode search response")
                }
                
            } else {
                print("No data received for request \(String(describing: response as? HTTPURLResponse))")
                
            }
        })

        dataTask.resume()
    }
    
    private func createBarcode(code: String, name: String? = nil) -> Barcode {
        let entity = NSEntityDescription.entity(forEntityName: "Barcode", in: context)
        let barcodeProduct = NSManagedObject(entity: entity!, insertInto: context) as! Barcode
        barcodeProduct.barcode = code
        barcodeProduct.name = name
        return barcodeProduct
    }
    
}
