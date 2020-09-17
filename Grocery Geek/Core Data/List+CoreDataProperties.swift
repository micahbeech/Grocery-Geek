//
//  List+CoreDataProperties.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-16.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData


extension List {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: UUID?
    @NSManaged public var index: Int32
    @NSManaged public var listProducts: NSOrderedSet?
    @NSManaged public var barcodeProducts: NSSet?
    @NSManaged public var removedProducts: NSOrderedSet?

}

// MARK: Generated accessors for listProducts
extension List {

    @objc(insertObject:inListProductsAtIndex:)
    @NSManaged public func insertIntoListProducts(_ value: ListProduct, at idx: Int)

    @objc(removeObjectFromListProductsAtIndex:)
    @NSManaged public func removeFromListProducts(at idx: Int)

    @objc(insertListProducts:atIndexes:)
    @NSManaged public func insertIntoListProducts(_ values: [ListProduct], at indexes: NSIndexSet)

    @objc(removeListProductsAtIndexes:)
    @NSManaged public func removeFromListProducts(at indexes: NSIndexSet)

    @objc(replaceObjectInListProductsAtIndex:withObject:)
    @NSManaged public func replaceListProducts(at idx: Int, with value: ListProduct)

    @objc(replaceListProductsAtIndexes:withListProducts:)
    @NSManaged public func replaceListProducts(at indexes: NSIndexSet, with values: [ListProduct])

    @objc(addListProductsObject:)
    @NSManaged public func addToListProducts(_ value: ListProduct)

    @objc(removeListProductsObject:)
    @NSManaged public func removeFromListProducts(_ value: ListProduct)

    @objc(addListProducts:)
    @NSManaged public func addToListProducts(_ values: NSOrderedSet)

    @objc(removeListProducts:)
    @NSManaged public func removeFromListProducts(_ values: NSOrderedSet)

}

// MARK: Generated accessors for barcodeProducts
extension List {

    @objc(addBarcodeProductsObject:)
    @NSManaged public func addToBarcodeProducts(_ value: BarcodeProduct)

    @objc(removeBarcodeProductsObject:)
    @NSManaged public func removeFromBarcodeProducts(_ value: BarcodeProduct)

    @objc(addBarcodeProducts:)
    @NSManaged public func addToBarcodeProducts(_ values: NSSet)

    @objc(removeBarcodeProducts:)
    @NSManaged public func removeFromBarcodeProducts(_ values: NSSet)

}

// MARK: Generated accessors for removedProducts
extension List {

    @objc(insertObject:inRemovedProductsAtIndex:)
    @NSManaged public func insertIntoRemovedProducts(_ value: RemovedProduct, at idx: Int)

    @objc(removeObjectFromRemovedProductsAtIndex:)
    @NSManaged public func removeFromRemovedProducts(at idx: Int)

    @objc(insertRemovedProducts:atIndexes:)
    @NSManaged public func insertIntoRemovedProducts(_ values: [RemovedProduct], at indexes: NSIndexSet)

    @objc(removeRemovedProductsAtIndexes:)
    @NSManaged public func removeFromRemovedProducts(at indexes: NSIndexSet)

    @objc(replaceObjectInRemovedProductsAtIndex:withObject:)
    @NSManaged public func replaceRemovedProducts(at idx: Int, with value: RemovedProduct)

    @objc(replaceRemovedProductsAtIndexes:withRemovedProducts:)
    @NSManaged public func replaceRemovedProducts(at indexes: NSIndexSet, with values: [RemovedProduct])

    @objc(addRemovedProductsObject:)
    @NSManaged public func addToRemovedProducts(_ value: RemovedProduct)

    @objc(removeRemovedProductsObject:)
    @NSManaged public func removeFromRemovedProducts(_ value: RemovedProduct)

    @objc(addRemovedProducts:)
    @NSManaged public func addToRemovedProducts(_ values: NSOrderedSet)

    @objc(removeRemovedProducts:)
    @NSManaged public func removeFromRemovedProducts(_ values: NSOrderedSet)

}
