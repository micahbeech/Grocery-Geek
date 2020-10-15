//
//  Product+CoreDataClass.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-28.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData

public class Product: NSManagedObject {
    
    func edit(name: String, quantity: String?) {
        
        // update product properties
        self.name = name
        self.quantity = quantity
        
    }

}
