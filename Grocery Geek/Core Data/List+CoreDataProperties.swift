//
//  List+CoreDataProperties.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-28.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData

extension List {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }

    @NSManaged public var index: Int32
    @NSManaged public var name: String?
    @NSManaged public var sections: NSOrderedSet?

}

// MARK: Generated accessors for sections
extension List {

    @objc(insertObject:inSectionsAtIndex:)
    @NSManaged public func insertIntoSections(_ value: Section, at idx: Int)

    @objc(removeObjectFromSectionsAtIndex:)
    @NSManaged public func removeFromSections(at idx: Int)

    @objc(insertSections:atIndexes:)
    @NSManaged public func insertIntoSections(_ values: [Section], at indexes: NSIndexSet)

    @objc(removeSectionsAtIndexes:)
    @NSManaged public func removeFromSections(at indexes: NSIndexSet)

    @objc(replaceObjectInSectionsAtIndex:withObject:)
    @NSManaged public func replaceSections(at idx: Int, with value: Section)

    @objc(replaceSectionsAtIndexes:withSections:)
    @NSManaged public func replaceSections(at indexes: NSIndexSet, with values: [Section])

    @objc(addSectionsObject:)
    @NSManaged public func addToSections(_ value: Section)

    @objc(removeSectionsObject:)
    @NSManaged public func removeFromSections(_ value: Section)

    @objc(addSections:)
    @NSManaged public func addToSections(_ values: NSOrderedSet)

    @objc(removeSections:)
    @NSManaged public func removeFromSections(_ values: NSOrderedSet)

}

extension List : Identifiable {

}
