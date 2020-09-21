//
//  BarcodeProduct+CoreDataProperties.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-18.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData


extension BarcodeProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BarcodeProduct> {
        return NSFetchRequest<BarcodeProduct>(entityName: "BarcodeProduct")
    }

    @NSManaged public var barcode: String?
    @NSManaged public var name: String?
    @NSManaged public var quantity: String?
    @NSManaged public var product: ListProduct?

}
