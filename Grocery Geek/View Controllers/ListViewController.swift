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
    
    var list: List!
    var listManager: GroceryListManager!
    
    var selectedRow: Product?
    
    // MARK: setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listManager = GroceryListManager(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext, list: list)
        
        navigationBar.title = list.name
        
        groceryList.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            
        case "addProduct":
            let destinationVC = segue.destination as! AddViewController
            destinationVC.list = list
            destinationVC.itemToEdit = selectedRow
            selectedRow = nil
            
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
        
    @IBAction func undoRemove(_ sender: Any) {
        
        if listManager.undoRemoveProduct() {
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
        
        if listManager.hasProducts() {
        
            // construct alert to be displayed
            let alert = UIAlertController(title: "Clear grocery list?", message: "This will clear current and removed items.", preferredStyle: .alert)
            
            // execute if confirmation received
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
                
                // clear list in database
                self.listManager.clearList()
                
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

