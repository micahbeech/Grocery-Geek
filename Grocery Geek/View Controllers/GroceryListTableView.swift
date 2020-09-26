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
        return listManager.size()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the data for this row
        let product = listManager.getProduct(index: indexPath.row)
        
        // Get a cell to display
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductItem", for: indexPath) as! GroceryItem
        cell.productName?.text = product?.name
        cell.productQuantity?.text = product?.quantity
        
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = listManager.getProduct(index: indexPath.row)
        performSegue(withIdentifier: "addProduct", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            listManager.removeProduct(index: indexPath.row)
            groceryList.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        listManager.moveProduct(source: sourceIndexPath, destination: destinationIndexPath)
    }
    
}
