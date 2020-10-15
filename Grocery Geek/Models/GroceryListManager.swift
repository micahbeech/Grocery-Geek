//
//  ProductManager.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-23.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import Foundation
import CoreData

class GroceryListManager {
    
    var list: List
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext, list: List) {
        self.context = context
        self.list = list
    }
    
    @discardableResult
    func addListProduct(section: Int, name: String, quantity: String?, barcode: Barcode?) -> Product? {
        
        // add product to core data
        let entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
        let newProduct = NSManagedObject(entity: entity!, insertInto: context) as! Product
         
        // set the product's properties
        newProduct.name = name
        newProduct.quantity = quantity
        
        // add product to the list
        guard let section = getSection(index: section) else { return nil }
        section.addToProducts(newProduct)
        
        return newProduct
    }
    
    func editProduct(product: Product, name: String, quantity: String?) {
        
        // update product properties
        product.name = name
        product.quantity = quantity
        
    }
    
    @discardableResult
    func removeProduct(indexPath: IndexPath) -> Bool {
        
        // get product to remove
        guard let section = getSection(index: indexPath.section) else { return false }
        guard let removedProduct = getProduct(indexPath: indexPath) else { return false }
        removedProduct.removedSection = section
        removedProduct.removedRow = Int32(indexPath.row)

        // move product
        section.removeFromProducts(removedProduct)
        section.addToRemovedProducts(removedProduct)
        
        return true
        
    }
    
    func undoRemoveProduct(section: Int) -> Bool {
        
        // Get place of item to remove
        guard let section = getSection(index: section) else { return false }
        let itemIndex = section.removedProducts!.count - 1

        // do nothing if nothing to remove
        if itemIndex < 0 {
            return false
        }

        // get removed product
        let product = section.removedProducts?.array[itemIndex] as! Product

        // move product
        section.insertIntoProducts(product, at: Int(product.removedRow))
        section.removeFromRemovedProducts(product)
        
        return true
    }
    
    func clearList() {

        // delete from list
        for section in list.sections?.array as! [Section] {
            
            for product in section.products?.array as! [Product] {
                section.removeFromProducts(product)
                context.delete(product)
            }
            
            for product in section.removedProducts?.array as! [Product] {
                section.removeFromRemovedProducts(product)
                context.delete(product)
            }
            
            list.removeFromSections(section)
            context.delete(section)
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
        
        for section in list.sections!.array as! [Section] {
            if section.products!.count > 0 || section.removedProducts!.count > 0 {
                return true
            }
        }
        
        return false
    }
    
    func sectionCount() -> Int {
        return list.sections!.count
    }
    
    func sectionSize(sectionIndex: Int) -> Int {
        guard let section = getSection(index: sectionIndex) else { return 0 }
        return section.products!.count
    }
    
    func getSection(index: Int) -> Section? {
        
        if 0 > index || index >= list.sections!.count {
            return nil
        }
        
        return list.sections?.array[index] as? Section
    }
    
    func getProduct(indexPath: IndexPath) -> Product? {
        
        guard let section = getSection(index: indexPath.section) else { return nil }
        
        if 0 > indexPath.row || indexPath.row >= section.products!.count {
            return nil
        }
        
        return section.products?.array[indexPath.row] as? Product
        
    }
    
    @discardableResult
    func addSection(name: String) -> Section {
        // add product to core data
        let entity = NSEntityDescription.entity(forEntityName: "Section", in: context)
        let newSection = NSManagedObject(entity: entity!, insertInto: context) as! Section
         
        // set the product's properties
        newSection.name = name
        
        list.addToSections(newSection)
        
        return newSection
    }
    
    @discardableResult
    func editSection(section: Int, name: String) -> Bool {
        
        guard let section = getSection(index: section) else { return false }
        
        section.name = name
        
        return true
        
    }
    
    @discardableResult
    func deleteSection(section: Int) -> Bool {
        
        guard let section = getSection(index: section) else { return false }
        
        list.removeFromSections(section)
        context.delete(section)
        
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
        
        for (index, section) in (list.sections!.array as! [Section]).enumerated() {
            
            // Get the products for this section that meet the criteria of the predicate
            let products = section.products?.filtered(using: searchPredicate).array as! [Product]
            
            // Add the section to the list with the filtered products, if any
            if !products.isEmpty {
                results.append((index, products))
            }
        }
        
        return results
    }
    
}
