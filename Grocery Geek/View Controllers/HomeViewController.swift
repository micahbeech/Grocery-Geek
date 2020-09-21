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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedList: List?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            // fetch grocery list items
            listData = try context.fetch(List.fetchRequest())
            
            listData.sort(by: { $0.index < $1.index } )
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        listTable.delegate = self
        listTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the data for this row
        let list = listData[indexPath.row]
        
        // Get a cell to display
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListItem", for: indexPath) as! ListItem
        cell.listName?.text = list.name
        
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get reference to list that was selected
        selectedList = listData[indexPath.row]
        
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
                let list = self.listData.remove(at: indexPath.row)
                self.context.delete(list)
                self.listTable.reloadData()
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(add)
            alert.addAction(cancel)
            
            present(alert, animated: true)
            
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Get list to be moved
        let list = listData[sourceIndexPath.row]
        
        // Update indices
        listData[destinationIndexPath.row].index = list.index
        list.index = Int32(destinationIndexPath.row)
        
        // Update table
        listData.remove(at: sourceIndexPath.row)
        listData.insert(list, at: destinationIndexPath.row)
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
                let entity = NSEntityDescription.entity(forEntityName: "List", in: self.context)
                let list = NSManagedObject(entity: entity!, insertInto: self.context) as! List
                
                // Set fields
                list.name = listNameField.text
                list.id = UUID()
                list.index = Int32(self.listData.count)
                
                // Add to list of lists
                self.listData.append(list)
                
            } else {
                // Updated existing list
                self.selectedList?.name = listNameField.text
                
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
