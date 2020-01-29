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
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getGroceryListData() -> [Product] {
        return groceryListData
    }
    
    func setGroceryListData(data: [Product]) {
        groceryListData = data
    }
    
    func productIndexSort(first: Product, second: Product) -> Bool {
        if let firstIndex = first.index, let secondIndex = second.index {
            return firstIndex.intValue < secondIndex.intValue
        }
        print("Error. Not all grocery list items have indices.")
        return false
    }
    
    func addToList(productName: String?, productQuantity: String?) {
        // add product for core data
        let newProduct = Product.init(entity: NSEntityDescription.entity(forEntityName: "Product", in: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)!, insertInto: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
         
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
        newProduct.index = groceryListData.count as NSNumber
         
        groceryListData.append(newProduct)
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
    
    func undoRemoveProduct() {
        // Get place of item to remove
        let itemIndex = removedList.count - 1
        
        // do nothing if nothing to remove
        if itemIndex < 0 {
            return
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
