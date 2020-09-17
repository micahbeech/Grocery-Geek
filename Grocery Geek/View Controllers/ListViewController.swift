//
//  ViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2019-05-06.
//  Copyright © 2019 Micah Beech. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController {

    @IBOutlet weak var groceryList: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var list: List?
    
    var selectedRow: ListProduct? = nil
    
    // MARK: setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBar.title = list?.name
        
        groceryList.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            
        case "addProduct":
            let destinationVC = segue.destination as! AddViewController
            destinationVC.list = list
            
            if selectedRow != nil {
                destinationVC.itemToEdit = selectedRow
                selectedRow = nil
            }
            
        case "scanProduct":
            let destinationVC = segue.destination as! ScannerViewController
            destinationVC.list = list
            
        default:
            break
        }
    }
    
    // MARK: remove data
    
    @IBAction func editToggle(_ sender: Any) {
        groceryList.isEditing = !groceryList.isEditing
        
        if groceryList.isEditing {
            editButton.title = "Done"
            editButton.style = .done
        } else {
            editButton.title = "Edit"
            editButton.style = .plain
        }
    }
    
    func removeProduct(index: Int) {
        
        // get cell to remove
        let removedCell = list?.listProducts?.array[index] as! ListProduct
        
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
        
        list?.addToRemovedProducts(removedProduct)
        list?.removeFromListProducts(removedCell)
    }
    
    func undoRemoveProduct() -> Bool {
        // Get place of item to remove
        let itemIndex = list!.removedProducts!.count - 1
        
        // do nothing if nothing to remove
        if itemIndex < 0 {
            return false
        }
        
        // create new cell
        let entity = NSEntityDescription.entity(forEntityName: "ListProduct", in: context)
        let cellToAdd = NSManagedObject(entity: entity!, insertInto: context) as! ListProduct
        
        // Get removed cell
        let productToAdd = list?.removedProducts?.array[itemIndex] as! RemovedProduct
        
        // Update new cell
        cellToAdd.name = productToAdd.name
        cellToAdd.quantity = productToAdd.quantity
        cellToAdd.index = productToAdd.index <= Int32(list!.listProducts!.count) ? productToAdd.index : Int32(list!.listProducts!.count)
        
        // Add cell to list
        list?.insertIntoListProducts(cellToAdd, at: Int(cellToAdd.index))
        
        // remove item from removed list
        list?.removeFromRemovedProducts(at: itemIndex)
        
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
        
        if list!.listProducts!.count > 0 || list!.removedProducts!.count > 0 {
        
            // construct alert to be displayed
            let alert = UIAlertController(title: "Clear grocery list?", message: "This will clear current and removed items.", preferredStyle: .alert)
            
            // execute if confirmation received
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
                self.list?.removeFromListProducts(at: NSIndexSet(indexesIn: NSRange(location: 0, length: self.list!.listProducts!.count)))
                self.list?.removeFromRemovedProducts(at: NSIndexSet(indexesIn: NSRange(location: 0, length: self.list!.removedProducts!.count)))
                
                // delete cells from table and present to view
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

