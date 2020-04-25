//
//  ViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2019-05-06.
//  Copyright © 2019 Micah Beech. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var groceryList: UITableView!
    let productModel = ProductModel()
    var incomingBarcode: UIAlertController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groceryList.delegate = self
        groceryList.dataSource = self
        
        groceryList.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groceryList.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (incomingBarcode != nil) {
            present(incomingBarcode!, animated: true, completion: nil)
            incomingBarcode = nil
            groceryList.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productModel.getGroceryListData().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the data for this row
        let product = productModel.getGroceryListData()[indexPath.row]
        
        // Get a cell to display
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductItem", for: indexPath) as! GroceryItem
        cell.productName?.text = product.name
        cell.productQuantity?.text = product.quantity
        
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        productModel.removeProduct(index: indexPath.row)
        groceryList.reloadData()
    }
    
    @IBAction func undoRemove(_ sender: Any) {
        
        if productModel.undoRemoveProduct() {
            groceryList.reloadData()
            return
        }
        
        // construct alert to be displayed
        let alert = UIAlertController(title: "No items have been removed", message: "Tap on an item to remove it", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func clear(_ sender: Any) {
        
        if productModel.getGroceryListData().count > 0 {
        
            // construct alert to be displayed
            let alert = UIAlertController(title: "Clear grocery list?", message: "This action cannot be undone", preferredStyle: .alert)
            
            // execute if confirmation received
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
                self.productModel.clearData()
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
    
    func addFromScanner(barcode: String) {
        let product = productModel.getFromBarcode(barcode: barcode)
        if (product == nil) {
            incomingBarcode = getAddAlert(message: "Sorry, we don't recognize this barcode", barcode: barcode)
        } else {
            incomingBarcode = getAddAlert(message: "Confirm details", name: product!.name, quantity: product!.quantity, barcode: barcode)
        }
    }
    
    func getAddAlert(message: String? = nil, name: String? = nil, quantity: String? = nil, barcode: String? = nil) -> UIAlertController {
        // construct alert to be displayed
        let alert = UIAlertController(title: "Add Product", message: message, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (productName) in
            if (name != nil && name != "") {
                productName.text = name
            } else {
                productName.placeholder = "Product"
            }
        })
        
        alert.addTextField(configurationHandler: { (productQuantity) in
            if (quantity != nil && quantity != "") {
                productQuantity.text = quantity
            } else {
                productQuantity.placeholder = "Quantity"
            }
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
             
            self.productModel.addToList(productName: productName.text, productQuantity: productQuantity.text, barcode: barcode)
            
            self.groceryList.reloadData()
        }))
        
        // execute if event cancelled
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alert
    }
    
    @IBAction func addProduct(_ sender: Any) {

        let alert = getAddAlert()
        present(alert, animated: true, completion: nil)
        
        groceryList.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: false)
        
    }
    
    
}

