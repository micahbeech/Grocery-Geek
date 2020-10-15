//
//  Section+CoreDataProperties.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-10-15.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData


extension Section {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Section> {
        return NSFetchRequest<Section>(entityName: "Section")
    }

    @NSManaged public var name: String?
    @NSManaged public var list: List?
    @NSManaged public var products: NSOrderedSet?
    @NSManaged public var removedProducts: NSOrderedSet?
    @NSManaged public var recentProducts: NSOrderedSet?

}

// MARK: Generated accessors for products
extension Section {

    @objc(insertObject:inProductsAtIndex:)
    @NSManaged public func insertIntoProducts(_ value: Product, at idx: Int)

    @objc(removeObjectFromProductsAtIndex:)
    @NSManaged public func removeFromProducts(at idx: Int)

    @objc(insertProducts:atIndexes:)
    @NSManaged public func insertIntoProducts(_ values: [Product], at indexes: NSIndexSet)

    @objc(removeProductsAtIndexes:)
    @NSManaged public func removeFromProducts(at indexes: NSIndexSet)

    @objc(replaceObjectInProductsAtIndex:withObject:)
    @NSManaged public func replaceProducts(at idx: Int, with value: Product)

    @objc(replaceProductsAtIndexes:withProducts:)
    @NSManaged public func replaceProducts(at indexes: NSIndexSet, with values: [Product])

    @objc(addProductsObject:)
    @NSManaged public func addToProducts(_ value: Product)

    @objc(removeProductsObject:)
    @NSManaged public func removeFromProducts(_ value: Product)

    @objc(addProducts:)
    @NSManaged public func addToProducts(_ values: NSOrderedSet)

    @objc(removeProducts:)
    @NSManaged public func removeFromProducts(_ values: NSOrderedSet)

}

// MARK: Generated accessors for removedProducts
extension Section {

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

// MARK: Generated accessors for recentProducts
extension Section {

    @objc(insertObject:inRecentProductsAtIndex:)
    @NSManaged public func insertIntoRecentProducts(_ value: Product, at idx: Int)

    @objc(removeObjectFromRecentProductsAtIndex:)
    @NSManaged public func removeFromRecentProducts(at idx: Int)

    @objc(insertRecentProducts:atIndexes:)
    @NSManaged public func insertIntoRecentProducts(_ values: [Product], at indexes: NSIndexSet)

    @objc(removeRecentProductsAtIndexes:)
    @NSManaged public func removeFromRecentProducts(at indexes: NSIndexSet)

    @objc(replaceObjectInRecentProductsAtIndex:withObject:)
    @NSManaged public func replaceRecentProducts(at idx: Int, with value: Product)

    @objc(replaceRecentProductsAtIndexes:withRecentProducts:)
    @NSManaged public func replaceRecentProducts(at indexes: NSIndexSet, with values: [Product])

    @objc(addRecentProductsObject:)
    @NSManaged public func addToRecentProducts(_ value: Product)

    @objc(removeRecentProductsObject:)
    @NSManaged public func removeFromRecentProducts(_ value: Product)

    @objc(addRecentProducts:)
    @NSManaged public func addToRecentProducts(_ values: NSOrderedSet)

    @objc(removeRecentProducts:)
    @NSManaged public func removeFromRecentProducts(_ values: NSOrderedSet)

}

extension Section : Identifiable {

}
