//
//  Product+CoreDataProperties.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-23.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var index: Int32
    @NSManaged public var name: String?
    @NSManaged public var quantity: String?
    @NSManaged public var barcode: Barcode?
    @NSManaged public var list: List?
    @NSManaged public var removedList: List?

}

extension Product : Identifiable {

}
