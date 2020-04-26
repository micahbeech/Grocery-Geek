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
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var productModel: ProductModel! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productModel = ProductModel(context: context)
        groceryList.delegate = self
        groceryList.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        productModel.loadCoreData()
        groceryList.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segue.identifier! {
//        case "addProduct":
//            let destinationVC = segue.destination as! AddViewController
//            destinationVC.context = self.context
//        case "scanProduct":
//            let destinationVC = segue.destination as! ScannerViewController
//            destinationVC.context = self.context
//        default:
//            break
//        }
//    }
    
}

