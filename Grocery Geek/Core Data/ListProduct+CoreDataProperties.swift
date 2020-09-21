//
//  ListProduct+CoreDataProperties.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-18.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData


extension ListProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListProduct> {
        return NSFetchRequest<ListProduct>(entityName: "ListProduct")
    }

    @NSManaged public var index: Int32
    @NSManaged public var name: String?
    @NSManaged public var quantity: String?
    @NSManaged public var barcode: BarcodeProduct?
    @NSManaged public var list: List?

}
