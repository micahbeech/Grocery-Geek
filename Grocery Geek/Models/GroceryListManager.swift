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
    
    func addListProduct(name: String, quantity: String?, barcode: Barcode?) {
        
        // add product to core data
        let entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
        let newProduct = NSManagedObject(entity: entity!, insertInto: context) as! Product
         
        // set the product's properties
        newProduct.name = name
        newProduct.quantity = quantity
        newProduct.barcode = barcode
        
        // update info for the barcode
        newProduct.barcode?.name = newProduct.name
        newProduct.barcode?.quantity = newProduct.quantity
        
        // add product to the list
        list.addToCurrentProducts(newProduct)
    }
    
    func editProduct(product: Product, name: String, quantity: String?) {
        
        // update product properties
        product.name = name
        product.quantity = quantity
        
        // update info for the barcode
        product.barcode?.name = name
        product.barcode?.quantity = quantity
        
    }
    
    func removeProduct(index: Int) {
        
        // get product to remove
        let removedProduct = list.currentProducts?.array[index] as! Product
        removedProduct.removedIndex = Int32(index)
        
        // move product
        list.addToRemovedProducts(removedProduct)
        list.removeFromCurrentProducts(removedProduct)
        
    }
    
    func undoRemoveProduct() -> Bool {
        
        // Get place of item to remove
        let itemIndex = list.removedProducts!.count - 1
        
        // do nothing if nothing to remove
        if itemIndex < 0 {
            return false
        }
        
        // get removed product
        let product = list.removedProducts?.array[itemIndex] as! Product
        
        // move product
        list.insertIntoCurrentProducts(product, at: Int(product.removedIndex))
        list.removeFromRemovedProducts(product)
        
        return true
    }
    
    func clearList() {
        
        // delete removed products
        for product in list.removedProducts?.array as! [Product] {
            context.delete(product)
        }
        
        // delete from list
        for product in list.currentProducts?.array as! [Product] {
            context.delete(product)
        }
        
    }
    
    func moveProduct(source: IndexPath, destination: IndexPath) {
        let product = list.currentProducts?.array[source.row] as! Product
        list.removeFromCurrentProducts(at: source.row)
        list.insertIntoCurrentProducts(product, at: destination.row)
    }
    
    func hasProducts() -> Bool {
        return list.currentProducts!.count > 0 || list.removedProducts!.count > 0
    }
    
    func size() -> Int {
        return list.currentProducts!.count
    }
    
    func getProduct(index: Int) -> Product {
        return list.currentProducts?.array[index] as! Product
    }
    
}
