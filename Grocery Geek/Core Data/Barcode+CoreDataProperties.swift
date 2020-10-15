//
//  Barcode+CoreDataProperties.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-28.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData

extension Barcode {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Barcode> {
        return NSFetchRequest<Barcode>(entityName: "Barcode")
    }

    @NSManaged public var barcode: String?
    @NSManaged public var name: String?
    @NSManaged public var quantity: String?

}

extension Barcode : Identifiable {

}
