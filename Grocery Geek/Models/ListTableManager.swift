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
    
    func getList(index: Int) -> List? {
        if index >= lists.count {
            return nil
        }
        return lists[index]
    }
    
    @discardableResult
    func removeList(index: Int) -> Bool {
        
        if 0 > index || index >= lists.count {
            return false
        }
        
        let list = lists.remove(at: index)
        context.delete(list)
        
        return true
    }
    
    @discardableResult
    func moveList(start: Int, end: Int) -> Bool {
        
        if 0 > start || start >= lists.count || 0 > end || end >= lists.count {
            return false
        }
        
        // move list
        let list = lists[start]
        lists.remove(at: start)
        lists.insert(list, at: end)
        
        // Update indices
        var count = Int32(min(start, end))
        for list in lists[min(start, end)...max(start, end)] {
            list.index = count
            count += 1
        }
        
        return true

    }
    
    @discardableResult
    func addList(name: String) -> List {
        
        // Create new list
        let entity = NSEntityDescription.entity(forEntityName: "List", in: self.context)
        let list = NSManagedObject(entity: entity!, insertInto: self.context) as! List
        
        // Set fields
        list.name = name
        list.id = UUID()
        list.index = Int32(lists.count)
        
        // Add to list of lists
        lists.append(list)
        
        return list
        
    }
    
    func updateList(list: List, name: String) {
        list.name = name
    }
    
}
