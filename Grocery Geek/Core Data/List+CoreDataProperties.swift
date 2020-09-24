//
//  List+CoreDataProperties.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-23.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData


extension List {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var index: Int32
    @NSManaged public var name: String?
    @NSManaged public var currentProducts: NSOrderedSet?
    @NSManaged public var removedProducts: NSOrderedSet?

}

// MARK: Generated accessors for currentProducts
extension List {

    @objc(insertObject:inCurrentProductsAtIndex:)
    @NSManaged public func insertIntoCurrentProducts(_ value: Product, at idx: Int)

    @objc(removeObjectFromCurrentProductsAtIndex:)
    @NSManaged public func removeFromCurrentProducts(at idx: Int)

    @objc(insertCurrentProducts:atIndexes:)
    @NSManaged public func insertIntoCurrentProducts(_ values: [Product], at indexes: NSIndexSet)

    @objc(removeCurrentProductsAtIndexes:)
    @NSManaged public func removeFromCurrentProducts(at indexes: NSIndexSet)

    @objc(replaceObjectInCurrentProductsAtIndex:withObject:)
    @NSManaged public func replaceCurrentProducts(at idx: Int, with value: Product)

    @objc(replaceCurrentProductsAtIndexes:withCurrentProducts:)
    @NSManaged public func replaceCurrentProducts(at indexes: NSIndexSet, with values: [Product])

    @objc(addCurrentProductsObject:)
    @NSManaged public func addToCurrentProducts(_ value: Product)

    @objc(removeCurrentProductsObject:)
    @NSManaged public func removeFromCurrentProducts(_ value: Product)

    @objc(addCurrentProducts:)
    @NSManaged public func addToCurrentProducts(_ values: NSOrderedSet)

    @objc(removeCurrentProducts:)
    @NSManaged public func removeFromCurrentProducts(_ values: NSOrderedSet)

}

// MARK: Generated accessors for removedProducts
extension List {

    @objc(insertObject:inRemovedProductsAtIndex:)
    @NSManaged public func insertIntoRemovedProducts(_ value: Product, at idx: Int)

    @objc(removeObjectFromRemovedProductsAtIndex:)
    @NSManaged public func removeFromRemovedProducts(at idx: Int)

    @objc(insertRemovedProducts:atIndexes:)
    @NSManaged public func insertIntoRemovedProducts(_ values: [Product], at indexes: NSIndexSet)

    @objc(removeRemovedProductsAtIndexes:)
    @NSManaged public func removeFromRemovedProducts(at indexes: NSIndexSet)

    @objc(replaceObjectInRemovedProductsAtIndex:withObject:)
    @NSManaged public func replaceRemovedProducts(at idx: Int, with value: Product)

    @objc(replaceRemovedProductsAtIndexes:withRemovedProducts:)
    @NSManaged public func replaceRemovedProducts(at indexes: NSIndexSet, with values: [Product])

    @objc(addRemovedProductsObject:)
    @NSManaged public func addToRemovedProducts(_ value: Product)

    @objc(removeRemovedProductsObject:)
    @NSManaged public func removeFromRemovedProducts(_ value: Product)

    @objc(addRemovedProducts:)
    @NSManaged public func addToRemovedProducts(_ values: NSOrderedSet)

    @objc(removeRemovedProducts:)
    @NSManaged public func removeFromRemovedProducts(_ values: NSOrderedSet)

}

extension List : Identifiable {

}
