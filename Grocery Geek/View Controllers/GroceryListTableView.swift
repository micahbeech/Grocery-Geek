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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        // Use filtered data if searching
        if resultSearchController.isActive {
            return filteredData.count
            
        // Use regular data otherwise
        } else {
            return listManager.sectionCount()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // User filtered data if searching
        if resultSearchController.isActive {
            return filteredData[section].1.count
            
        // Return regular data otherwise
        } else {
            return listManager.sectionSize(sectionIndex: section)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerSize
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Get the correct section index
        var sectionIndex = section
        if resultSearchController.isActive {
            sectionIndex = filteredData[section].0
        }
        
        let sectionObject = listManager.getSection(index: sectionIndex)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.rowHeight))
        view.backgroundColor = UIColor.systemBackground
        
        let itemHeight = CGFloat(44)
        let inset = CGFloat(15)
        let offset = (headerSize - itemHeight) / 2
        
        let title = UILabel(frame: CGRect(x: inset, y: offset, width: view.frame.width - (itemHeight + inset) * 3 - inset, height: itemHeight))
        title.text = sectionObject?.name
        title.font = UIFont(descriptor: title.font.fontDescriptor, size: 30)
        
        view.addSubview(title)
        
        // When in editing mode, the section shows a button to delete it and edit its name
        if tableView.isEditing {
            
            let deleteButton = UIButton(frame: CGRect(x: view.frame.maxX - inset - itemHeight, y: offset, width: itemHeight, height: itemHeight))
            deleteButton.setImage(UIImage(systemName: "minus.circle"), for: .normal)
            deleteButton.addTarget(self, action: #selector(deleteSection), for: .touchUpInside)
            deleteButton.tag = section
            
            let editButton = UIButton(frame: CGRect(x: deleteButton.frame.minX - inset - itemHeight, y: offset, width: itemHeight, height: itemHeight))
            editButton.setImage(UIImage(systemName: "rectangle.and.pencil.and.ellipsis"), for: .normal)
            editButton.addTarget(self, action: #selector(editHeader), for: .touchUpInside)
            editButton.tag = section
            
            view.addSubview(deleteButton)
            view.addSubview(editButton)
        
        // Otherwise, the section has buttons to add, scan and undo removing products
        } else {
            
            let addButton = UIButton(frame: CGRect(x: view.frame.maxX - inset - itemHeight, y: offset, width: itemHeight, height: itemHeight))
            addButton.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
            addButton.addTarget(self, action: #selector(addProduct), for: .touchUpInside)
            addButton.tag = section
            
            let scanButton = UIButton(frame: CGRect(x: addButton.frame.minX - inset - itemHeight, y: offset, width: itemHeight, height: itemHeight))
            scanButton.setImage(UIImage(systemName: "barcode.viewfinder"), for: .normal)
            scanButton.addTarget(self, action: #selector(scanProduct), for: .touchUpInside)
            scanButton.tag = section
            
            let undoButton = UIButton(frame: CGRect(x: scanButton.frame.minX - inset - itemHeight, y: offset, width: itemHeight, height: itemHeight))
            undoButton.setImage(UIImage(systemName: "arrow.uturn.left"), for: .normal)
            undoButton.addTarget(self, action: #selector(undoRemove), for: .touchUpInside)
            undoButton.tag = section
            
            view.addSubview(addButton)
            view.addSubview(scanButton)
            view.addSubview(undoButton)
            
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a cell to display
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductItem", for: indexPath) as! GroceryItem
        
        var product: Product? = nil
        
        // Use the filtered data if searching
        if resultSearchController.isActive {
            product = filteredData[indexPath.section].1[indexPath.row]
            
        // Use the regular data otherwise
        } else {
            product = listManager.getProduct(indexPath: indexPath)
        }
        
        cell.productName?.text = product?.name
        cell.productQuantity?.text = product?.quantity
        
        // Return the cell
        return cell
    }
    
    // Go into product editing mode when a row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = listManager.getProduct(indexPath: indexPath)
        performSegue(withIdentifier: "addProduct", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            listManager.removeProduct(indexPath: indexPath)
            groceryList.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        listManager.moveProduct(source: sourceIndexPath, destination: destinationIndexPath)
    }
    
    // Selector function for adding a product
    @objc func addProduct(sender: UIButton!) {
        selectedSection = sender.tag
        performSegue(withIdentifier: "addProduct", sender: self)
    }
    
    // Selector function for scanning a product
    @objc func scanProduct(sender: UIButton!) {
        selectedSection = sender.tag
        performSegue(withIdentifier: "scanProduct", sender: self)
    }
    
    // Selector function for editing a section name
    @objc func editHeader(sender: UIButton!) {
        let section = listManager.getSection(index: sender.tag)
        changeSectionName(title: "Edit section", message: nil, name: section?.name, section: sender.tag)
    }
    
    // Selector function for deleting a section
    @objc func deleteSection(sender: UIButton!) {
        
        // construct alert to be displayed
        let alert = UIAlertController(title: "Delete section?", message: "This cannot be undone", preferredStyle: .alert)
        
        // execute if confirmation received
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
            self.listManager.deleteSection(section: sender.tag)
            self.groceryList.reloadData()
        }))
        
        // execute if event cancelled
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // Selector function for undoing the removal of a product
    @objc func undoRemove(sender: UIButton!) {
        
        if listManager.undoRemoveProduct(section: sender.tag) {
            groceryList.reloadData()
            return
        }
        
        // construct alert to be displayed
        let alert = UIAlertController(title: "No items have been removed", message: "Swipe left to remove an item", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
}
