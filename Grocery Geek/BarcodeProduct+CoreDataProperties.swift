//
//  BarcodeProduct+CoreDataProperties.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-04-26.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData


extension BarcodeProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BarcodeProduct> {
        return NSFetchRequest<BarcodeProduct>(entityName: "BarcodeProduct")
    }

    @NSManaged public var name: String?
    @NSManaged public var quantity: String?
    @NSManaged public var barcode: String?

}
