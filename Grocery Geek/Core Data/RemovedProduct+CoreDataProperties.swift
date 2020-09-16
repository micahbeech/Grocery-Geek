//
//  RemovedProduct+CoreDataProperties.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-04-26.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData


extension RemovedProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RemovedProduct> {
        return NSFetchRequest<RemovedProduct>(entityName: "RemovedProduct")
    }

    @NSManaged public var name: String?
    @NSManaged public var quantity: String?
    @NSManaged public var index: Int32

}