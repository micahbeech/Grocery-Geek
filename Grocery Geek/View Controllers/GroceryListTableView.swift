//
//  TableView.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-15.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import Foundation
import UIKit

extension ListViewController : UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groceryList.delegate = self
        groceryList.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list!.listProducts!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the data for this row
        let product = list?.listProducts?.array[indexPath.row] as! ListProduct
        
        // Get a cell to display
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductItem", for: indexPath) as! GroceryItem
        cell.productName?.text = product.name
        cell.productQuantity?.text = product.quantity
        
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = list?.listProducts?.array[indexPath.row] as? ListProduct
        performSegue(withIdentifier: "addProduct", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeProduct(index: indexPath.row)
            groceryList.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let product = list?.listProducts?.array[sourceIndexPath.row] as! ListProduct
        list?.removeFromListProducts(at: sourceIndexPath.row)
        product.index = Int32(destinationIndexPath.row)
        list?.insertIntoListProducts(product, at: destinationIndexPath.row)
    }
    
}