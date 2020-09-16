//
//  ViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2019-05-06.
//  Copyright © 2019 Micah Beech. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var groceryList: UITableView!
    @IBOutlet weak var editButton: UIButton!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var groceryListData = [ListProduct]()
    var removedListData = [RemovedProduct]()
    
    var selectedRow: ListProduct? = nil
    
    // MARK: setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            // fetch grocery list items
            groceryListData = try context.fetch(ListProduct.fetchRequest())
            
            // sort data into original order
            groceryListData.sort(by: { (first: ListProduct, second: ListProduct) -> Bool in return first.index < second.index })
            
            // fetch removed products
            removedListData = try context.fetch(RemovedProduct.fetchRequest())
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        groceryList.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            
        case "addProduct":
            if selectedRow != nil {
                let destinationVC = segue.destination as! AddViewController
                destinationVC.itemToEdit = selectedRow
                selectedRow = nil
            }
            
        default:
            break
        }
    }
    
    // MARK: remove data
    
    @IBAction func editToggle(_ sender: Any) {
        groceryList.isEditing = !groceryList.isEditing
        
        if groceryList.isEditing {
            editButton.setTitle("Done", for: .normal)
            editButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        } else {
            editButton.setTitle("Edit", for: .normal)
            editButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        }
    }
    
    func removeProduct(index: Int) {
        // get cell to remove
        let removedCell = groceryListData.remove(at: index)
        // create new cell
        let entity = NSEntityDescription.entity(forEntityName: "RemovedProduct", in: context)
        let removedProduct = NSManagedObject(entity: entity!, insertInto: context) as! RemovedProduct
        
        // add name to removed product
        if removedCell.name != nil {
            removedProduct.name = removedCell.name!
        } else {
            print("Attempted to remove a product with no name")
            return
        }
        
        removedProduct.quantity = removedCell.quantity!
        removedProduct.index = Int32(index)
        
        removedListData.append(removedProduct)
        
        // Update grocery list
        context.delete(removedCell)
    }
    
    func undoRemoveProduct() -> Bool {
        // Get place of item to remove
        let itemIndex = removedListData.count - 1
        
        // do nothing if nothing to remove
        if itemIndex < 0 {
            return false
        }
        
        // create new cell
        let entity = NSEntityDescription.entity(forEntityName: "ListProduct", in: context)
        let cellToAdd = NSManagedObject(entity: entity!, insertInto: context) as! ListProduct
        
        // Get removed cell
        let productToAdd = removedListData[itemIndex]
        
        // Update new cell
        cellToAdd.name = productToAdd.name
        cellToAdd.quantity = productToAdd.quantity
        cellToAdd.index = productToAdd.index <= groceryListData.count ? productToAdd.index : Int32(groceryListData.endIndex)
        
        // Add cell to list
        groceryListData.insert(cellToAdd, at: Int(cellToAdd.index))
        
        // remove item from removed list
        removedListData.remove(at: itemIndex)
        context.delete(productToAdd)
        
        return true
    }
    
    @IBAction func undoRemove(_ sender: Any) {
        
        if undoRemoveProduct() {
            groceryList.reloadData()
            return
        }
        
        // construct alert to be displayed
        let alert = UIAlertController(title: "No items have been removed", message: "Swipe left to remove an item", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Clear data
    
    @IBAction func clear(_ sender: Any) {
        
        if groceryListData.count > 0 || removedListData.count > 0 {
        
            // construct alert to be displayed
            let alert = UIAlertController(title: "Clear grocery list?", message: "This will clear current and removed items.", preferredStyle: .alert)
            
            // execute if confirmation received
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
                for item in self.groceryListData {
                    self.context.delete(item)
                }
                for item in self.removedListData {
                    self.context.delete(item)
                }
                
                // delete cells from table and present to view
                self.groceryListData.removeAll()
                self.removedListData.removeAll()
                self.groceryList.reloadData()
            }))
            
            // execute if event cancelled
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        } else {
            
            // construct alert to be displayed
            let alert = UIAlertController(title: "Your list is empty!", message: "Scan or add items from the toolbar below.", preferredStyle: .alert)
            
            // add action
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
}

