//
//  BarcodeManager.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-24.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import Foundation
import CoreData

class BarcodeManager {
    
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func findProduct(code: String) -> Barcode {
        
        // Get existings barcodes
        var barcodeProducts = [Barcode]()
        
        do {
            barcodeProducts = try context.fetch(Barcode.fetchRequest())
        } catch {
            print("Could not fetch barcodes")
        }
        
        for item in barcodeProducts {
            if item.barcode == code {
                return item
            }
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "Barcode", in: context)
        let barcodeProduct = NSManagedObject(entity: entity!, insertInto: context) as! Barcode
        barcodeProduct.barcode = code
        return barcodeProduct
        
    }
    
}
