//
//  Section+CoreDataClass.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-28.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Section)
public class Section: NSManagedObject {

    func getProduct(index: Int) -> Product? {
        
        if 0 > index || index >= products!.count {
            return nil
        }
        
        return products?.array[index] as? Product
    }
    
    func addProduct(name: String, quantity: String?) -> Product? {
        
        // add product to core data
        let newProduct = Product(context: managedObjectContext!)
         
        // set the product's properties
        newProduct.edit(name: name, quantity: quantity)
        
        // add product to the section
        addToProducts(newProduct)
        
        return newProduct
    }
    
    @discardableResult
    func removeProduct(index: Int) -> Bool {
        
        // get product to remove
        guard let removedProduct = getProduct(index: index) else { return false }
        
        // update product's properties
        removedProduct.removedSection = self
        removedProduct.removedRow = Int32(index)

        // move product
        removeFromProducts(removedProduct)
        addToRemovedProducts(removedProduct)
        
        return true
        
    }
    
    func undoRemoveProduct() -> Bool {
        
        // Get place of item to remove
        let itemIndex = removedProducts!.count - 1

        // do nothing if nothing to remove
        if itemIndex < 0 { return false }

        // get removed product
        let product = removedProducts?.array[itemIndex] as! Product

        // move product
        insertIntoProducts(product, at: Int(product.removedRow))
        removeFromRemovedProducts(product)
        
        return true
    }
    
    func hasProducts() -> Bool {
        return products!.count > 0 || removedProducts!.count > 0
    }
    
    func productCount() -> Int {
        return products!.count
    }
    
    func edit(name: String) {
        self.name = name
    }
    
    func search(predicate: NSPredicate) -> [Product] {
        return products?.filtered(using: predicate).array as! [Product]
    }
    
}
