//
//  ListTableManager.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-24.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import Foundation
import CoreData

class ListTableManager {
    
    var context: NSManagedObjectContext
    var lists: [List]
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.lists = []
        
        do {
            // fetch grocery list items
            lists = try context.fetch(List.fetchRequest())
            
            lists.sort(by: { $0.index < $1.index } )
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func size() -> Int {
        return lists.count
    }
    
    func getList(index: Int) -> List {
        return lists[index]
    }
    
    func removeList(index: Int) {
        let list = lists.remove(at: index)
        context.delete(list)
    }
    
    func moveList(start: Int, end: Int) {
        
        // move list
        let list = lists[start]
        lists.remove(at: start)
        lists.insert(list, at: end)
        
        // Update indices
        var count = Int32(start)
        for list in lists[start...end] {
            list.index = count
            count += 1
        }

    }
    
    func addList(name: String) {
        
        // Create new list
        let entity = NSEntityDescription.entity(forEntityName: "List", in: self.context)
        let list = NSManagedObject(entity: entity!, insertInto: self.context) as! List
        
        // Set fields
        list.name = name
        list.id = UUID()
        list.index = Int32(lists.count)
        
        // Add to list of lists
        lists.append(list)
        
    }
    
    func updateList(list: List, name: String) {
        list.name = name
    }
    
}
