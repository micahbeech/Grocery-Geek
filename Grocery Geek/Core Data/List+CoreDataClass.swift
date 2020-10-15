//
//  List+CoreDataClass.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-28.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

public class List: NSManagedObject {
    
    @discardableResult
    func addListProduct(section: Int, name: String, quantity: String?) -> Product? {
        
        // Get the section to be added to
        guard let section = getSection(index: section) else { return nil }
        
        // Add the product to the section and return it
        return section.addProduct(name: name, quantity: quantity)
    }
    
    
    @discardableResult
    func removeProduct(indexPath: IndexPath) -> Bool {
        
        // get section to remove from
        guard let section = getSection(index: indexPath.section) else { return false }
        
        // remove the product
        return section.removeProduct(index: indexPath.row)
        
    }
    
    func undoRemoveProduct(section: Int) -> Bool {
        
        // Get section to undo from
        guard let section = getSection(index: section) else { return false }
        
        // Undo the action
        return section.undoRemoveProduct()
    }
    
    func clear() {

        // delete from list
        for section in sections?.array as! [Section] {
            removeFromSections(section)
            managedObjectContext?.delete(section)
        }
        
    }
    
    @discardableResult
    func moveProduct(source: IndexPath, destination: IndexPath) -> Bool {
        
        guard let startSection = getSection(index: source.section) else { return false }
        guard let endSection = getSection(index: destination.section) else { return false }
        
        guard let product = getProduct(indexPath: source) else { return false }

        if destination.row > endSection.products!.count { return false }
        
        startSection.removeFromProducts(at: source.row)
        endSection.insertIntoProducts(product, at: destination.row)
        
        return true
        
    }
    
    func hasProducts() -> Bool {
        
        for section in sections!.array as! [Section] {
            if section.hasProducts() {
                return true
            }
        }
        
        return false
    }
    
    func sectionCount() -> Int {
        return sections!.count
    }
    
    func sectionSize(sectionIndex: Int) -> Int {
        guard let section = getSection(index: sectionIndex) else { return 0 }
        return section.productCount()
    }
    
    func getSection(index: Int) -> Section? {
        
        if 0 > index || index >= sections!.count { return nil }
        
        return sections?.array[index] as? Section
    }
    
    func getProduct(indexPath: IndexPath) -> Product? {
        
        guard let section = getSection(index: indexPath.section) else { return nil }
        
        return section.getProduct(index: indexPath.row)
        
    }
    
    @discardableResult
    func addSection(name: String) -> Section {
        // add product to core data
        let newSection = Section(context: managedObjectContext!)
         
        // set the product's properties
        newSection.edit(name: name)
        
        addToSections(newSection)
        
        return newSection
    }
    
    @discardableResult
    func editSection(section: Int, name: String) -> Bool {
        
        guard let section = getSection(index: section) else { return false }
        
        section.edit(name: name)
        
        return true
        
    }
    
    @discardableResult
    func deleteSection(section: Int) -> Bool {
        
        guard let section = getSection(index: section) else { return false }
        
        removeFromSections(section)
        managedObjectContext?.delete(section)
        
        return true
        
    }
    
    func searchProducts(text: String) -> [(Int, [Product])] {
        
        // Get a predicate to filter by
        var searchPredicate = NSPredicate()
        
        if text.isEmpty {
            // If the text is empty, continue to display all results
            searchPredicate = NSPredicate(value: true)
            
        } else {
            // Otherwise, return all items whose name begins with the text
            searchPredicate = NSPredicate(format: "SELF.name BEGINSWITH[c] %@", text)
        }
        
        var results = [(Int, [Product])]()
        
        for (index, section) in (sections!.array as! [Section]).enumerated() {
            
            // Get the products for this section that meet the criteria of the predicate
            let products = section.search(predicate: searchPredicate)
            
            // Add the section to the list with the filtered products, if any
            if !products.isEmpty {
                results.append((index, products))
            }
        }
        
        return results
    }
    

}

extension List : UIActivityItemSource {
    
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return self.toString()
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return self.toString()
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "My Grocery List"
    }
    
    func toString() -> String {
        
        var message = "Check out my list from Grocery Geek!\n\n"
        
        for section in sections?.array as! [Section] {
            
            message.append(section.name! + "\n")
            
            for product in section.products?.array as! [Product] {
                
                message.append(" \u{2022} ")
                message.append(product.name!)
                message.append(", ")
                message.append(product.quantity!)
                message.append("\n")
                
            }
            
            if section != sections?.lastObject as! Section {
                message.append("\n")
            }
            
        }
        
        return message
    }
}
