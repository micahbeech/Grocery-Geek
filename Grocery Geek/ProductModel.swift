//
//  ProductModel.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2019-05-07.
//  Copyright © 2019 Micah Beech. All rights reserved.
//

import UIKit
import CoreData

class ProductModel {
    
    private var groceryListData = [Product]()
    private var removedList = [RemovedProduct]()
    
    private let context: NSManagedObjectContext!
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadCoreData()
    }
    
    func loadCoreData() {
         do {
            // fetch core data
            groceryListData = try context.fetch(Product.fetchRequest())
            
            // sort data into original order
            groceryListData.sort(by: productIndexSort(first:second:))
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getGroceryListData() -> [Product] {
        return groceryListData
    }
    
    func productIndexSort(first: Product, second: Product) -> Bool {
        if let firstIndex = first.index, let secondIndex = second.index {
            return firstIndex.intValue < secondIndex.intValue
        }
        print("Error. Not all grocery list items have indices.")
        return false
    }
    
    func addToList(productName: String?, productQuantity: String?, barcode: String? = nil) {
        // add product for core data
        let entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
        let newProduct = NSManagedObject(entity: entity!, insertInto: context) as! Product
         
        // set the product's properties
        if let name = productName {
            newProduct.name = name
        } else {
            print("No text available for name")
            return
        }
        if let quantity = productQuantity {
            newProduct.quantity = quantity
        } else {
            print("No text available for quantity")
        }
        newProduct.barcode = barcode
        newProduct.index = groceryListData.count as NSNumber
         
        groceryListData.append(newProduct)
    }
    
    func getFromBarcode(barcode: String?) -> Product? {
        if barcode == nil { return nil }
        for item in groceryListData.reversed() {
            print(item.name!)
            if (item.barcode == barcode) {
                return item
            }
        }
        return nil
    }
    
    func clearData() {
        // delete cells from database
        for item in groceryListData {
            context.delete(item)
        }
        
        // delete cells from table and present to view
        groceryListData.removeAll()
        removedList.removeAll()
    }
    
    func undoRemoveProduct() -> Bool {
        // Get place of item to remove
        let itemIndex = removedList.count - 1
        
        // do nothing if nothing to remove
        if itemIndex < 0 {
            return false
        }
        
        // create new cell
        let entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
        let cellToAdd = NSManagedObject(entity: entity!, insertInto: context) as! Product
        
        // Get removed cell
        let productToAdd = removedList[itemIndex]
        
        // Update new cell
        cellToAdd.name = productToAdd.name
        cellToAdd.quantity = productToAdd.quantity
        cellToAdd.index = productToAdd.spot as NSNumber
        
        // Add cell to list
        groceryListData.insert(cellToAdd, at: productToAdd.spot)
        
        // remove item from removed list
        removedList.remove(at: itemIndex)
        
        return true
    }
    
    func removeProduct(index: Int) {
        // get cell to remove
        let removedCell = groceryListData.remove(at: index)
        let removedProduct = RemovedProduct()
        
        // add name to removed product
        if removedCell.name != nil {
            removedProduct.name = removedCell.name!
        } else {
            print("Attempted to remove a product with no name")
            return
        }
        
        // add quantity to remove product
        if removedCell.quantity != nil {
            removedProduct.quantity = removedCell.quantity!
        } else {
            removedProduct.quantity = ""
        }
        
        removedProduct.spot = index
        
        removedList.append(removedProduct)
        
        // Update grocery list
        context.delete(removedCell)
    }
    
}
