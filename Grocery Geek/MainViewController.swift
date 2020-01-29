//
//  ViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2019-05-06.
//  Copyright © 2019 Micah Beech. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var groceryList: UITableView!
    
    @IBOutlet weak var undoButton: UIBarButtonItem!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groceryList.delegate = self
        groceryList.dataSource = self
        
        groceryList.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groceryList.reloadData()
        groceryList.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProductModel.groceryListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the data for this row
        let product = ProductModel.groceryListData[indexPath.row]
        
        // Get a cell to display
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductItem", for: indexPath) as! GroceryItem
        cell.productName?.text = product.name
        cell.productQuantity?.text = product.quantity
        
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // get cell to remove
        let removedCell = ProductModel.groceryListData.remove(at: indexPath.row)
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
        
        removedProduct.spot = indexPath.row
        
        ProductModel.removedList.append(removedProduct)
        
        // Update grocery list
        context.delete(removedCell)
        groceryList.reloadData()
    }
    
    @IBAction func undoRemove(_ sender: Any) {
        // Get place of item to remove
        let itemIndex = ProductModel.removedList.count - 1
        
        // do nothing if no items to remove
        if itemIndex == 0 {
            undoButton.tintColor = .lightText
        } else if itemIndex < 0 {
            return
        }
        
        // create new cell
        let entity = NSEntityDescription.entity(forEntityName: "Product", in: context)
        let cellToAdd = NSManagedObject(entity: entity!, insertInto: context) as! Product
        
        // Get removed cell
        let productToAdd = ProductModel.removedList[itemIndex]
        
        // Update new cell
        cellToAdd.name = productToAdd.name
        cellToAdd.quantity = productToAdd.quantity
        cellToAdd.index = productToAdd.spot as NSNumber
        
        // Add cell to list
        ProductModel.groceryListData.insert(cellToAdd, at: productToAdd.spot)
        groceryList.reloadData()
        
        // remove item from removed list
        ProductModel.removedList.remove(at: itemIndex)
    }
    
    @IBAction func clear(_ sender: Any) {
        
        if ProductModel.groceryListData.count > 0 {
        
            // construct alert to be displayed
            let alert = UIAlertController(title: "Clear grocery list?", message: "This action cannot be undone", preferredStyle: .alert)
            
            // execute if confirmation received
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
                // delete cells from database
                for item in ProductModel.groceryListData {
                    self.context.delete(item)
                }
                
                // delete cells from table and present to view
                ProductModel.groceryListData.removeAll()
                ProductModel.removedList.removeAll()
                self.groceryList.reloadData()
            }))
            
            // execute if event cancelled
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        } else {
            
            // construct alert to be displayed
            let alert = UIAlertController(title: "Grocery list empty", message: "Add items from the toolbar below.", preferredStyle: .alert)
            
            // add action
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func addProduct(_ sender: Any) {
        
        // construct alert to be displayed
        let alert = UIAlertController(title: "Add Product", message: "This action cannot be undone", preferredStyle: .alert)
        
       
        
        alert.addTextField(configurationHandler: { (productName) in
            productName.placeholder = "Cheese"
        })
        
        alert.addTextField(configurationHandler: { (productQuantity) in
            productQuantity.placeholder = "1 block"
        })
        
        // execute if confirmation received
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            
            let productName = alert.textFields![0]
            let productQuantity = alert.textFields![1]
            
            // Guard against bad input
            if productName.text == "" {
                let warning = UIAlertController(title: "Cannot add item", message: "Please fill in all fields", preferredStyle: .alert)
                warning.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(warning, animated: true, completion: nil)
                return
            }
             
            // add product for core data
            let newProduct = Product.init(entity: NSEntityDescription.entity(forEntityName: "Product", in: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)!, insertInto: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
             
            // set the product's properties
            if let name = productName.text {
                newProduct.name = name
            } else {
                print("No text available for name")
                return
            }
            if let quantity = productQuantity.text {
                newProduct.quantity = quantity
            } else {
                print("No text available for quantity")
            }
            newProduct.index = ProductModel.groceryListData.count as NSNumber
             
            ProductModel.groceryListData.append(newProduct)
            self.groceryList.reloadData()
        }))
        
        // execute if event cancelled
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
}

