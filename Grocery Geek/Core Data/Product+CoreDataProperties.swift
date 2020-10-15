//
//  Product+CoreDataProperties.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-10-15.
//  Copyright © 2020 Micah Beech. All rights reserved.
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
    @NSManaged public var removedRow: Int32
    @NSManaged public var removedSection: Section?
    @NSManaged public var section: Section?
    @NSManaged public var recentSection: Section?

}

extension Product : Identifiable {

}
