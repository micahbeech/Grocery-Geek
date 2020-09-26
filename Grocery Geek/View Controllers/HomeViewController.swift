//
//  HomeViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-16.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var listData = [List]()
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var listManager: ListTableManager!
    var selectedList: List?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listManager = ListTableManager(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        
        listTable.delegate = self
        listTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listManager.size()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the data for this row
        let list = listManager.getList(index: indexPath.row)
        
        // Get a cell to display
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListItem", for: indexPath) as! ListItem
        cell.listName?.text = list?.name
        
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get reference to list that was selected
        selectedList = listManager.getList(index: indexPath.row)
        
        if listTable.isEditing {
            // Editing mode, change the name of the list
            changeListName(title: "Change name", message: "", newList: false)
            
        } else {
            // Regular mode, show list
            performSegue(withIdentifier: "showList", sender: self)
            selectedList = nil
            
        }
        
        // Reset selection
        listTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Are you sure?", message: "This cannot be undone", preferredStyle: .alert)
            
            let add = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                self.listManager.removeList(index: indexPath.row)
                self.listTable.reloadData()
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(add)
            alert.addAction(cancel)
            
            present(alert, animated: true)
            
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        listManager.moveList(start: sourceIndexPath.row, end: destinationIndexPath.row)
        listTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        
        case "showList":
            let destinationVC = segue.destination as! ListViewController
            destinationVC.list = selectedList
            
        default:
            break
            
        }
    }
    
    func changeListName(title: String, message: String, newList: Bool) {
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        var listNameField = UITextField()
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .sentences
            if self.selectedList != nil {
                textField.text = self.selectedList!.name
            }
            listNameField = textField
        }
        
        let add = UIAlertAction(title: "OK", style: .default) { (action) in
            if listNameField.text == nil || listNameField.text == "" {
                return
            }
            
            if newList {
                // Create new list
                self.listManager.addList(name: listNameField.text!)
                
            } else {
                // Updated existing list
                self.listManager.updateList(list: self.selectedList!, name: listNameField.text!)
                
            }
            
            self.listTable.reloadData()
            self.selectedList = nil
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.selectedList = nil
        }
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        present(alert, animated: true)
        
    }
    
    @IBAction func addList(_ sender: Any) {
        
        changeListName(
            title: "Add List",
            message: "Make a list for a store, a product type, or anything else you can think of!",
            newList: true
        )
        
    }
    
    @IBAction func editToggle(_ sender: Any) {
        listTable.isEditing = !listTable.isEditing
        
        if listTable.isEditing {
            editButton.title = "Done"
            editButton.style = .done
        } else {
            editButton.title = "Edit"
            editButton.style = .plain
        }
        
    }
    
    
}
