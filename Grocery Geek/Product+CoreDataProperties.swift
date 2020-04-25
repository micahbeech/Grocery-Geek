//
//  Product+CoreDataProperties.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2019-05-21.
//  Copyright © 2019 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var name: String?
    @NSManaged public var quantity: String?
    @NSManaged public var index: NSNumber?
    @NSManaged public var barcode: String?

}
