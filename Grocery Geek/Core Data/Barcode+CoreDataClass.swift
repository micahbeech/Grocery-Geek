//
//  Barcode+CoreDataClass.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-28.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData


public class Barcode: NSManagedObject {
    
    func edit(code: String? = nil, name: String? = nil, quantity: String? = nil) {
        
        if let barcode = code {
            self.barcode = barcode
        }
        
        self.name = name
        self.quantity = quantity
    }
    
}
