//
//  TestCoreDataStack.swift
//  Grocery GeekTests
//
//  Created by Micah Beech on 2020-09-25.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import Foundation
import CoreData
import Grocery_Geek

class CoreDataTestHelper {
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        // We need to store the data in memory for testing so that it isn't truly persisted
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: "Model")
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
        
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getLists() -> [List] {
        
        let context = persistentContainer.viewContext
        var lists = [List]()
        
        do {
            lists = try context.fetch(List.fetchRequest())
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return lists
    }
    
    func getSections() -> [Section] {
        
        let context = persistentContainer.viewContext
        var sections = [Section]()
        
        do {
            sections = try context.fetch(Section.fetchRequest())
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return sections
    }
    
}
