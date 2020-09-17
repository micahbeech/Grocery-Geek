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
        selectedList = listData[indexPath.row]
        performSegue(withIdentifier: "showList", sender: self)
        listTable.deselectRow(at: indexPath, animated: true)
        selectedList = nil
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
        let list = listData[sourceIndexPath.row]
        listData.remove(at: sourceIndexPath.row)
        list.index = Int32(destinationIndexPath.row)
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
    
    @IBAction func addList(_ sender: Any) {
        
        let alert = UIAlertController(
            title: "Add List",
            message: "Make a list for a store, a product type, or anything else you can think of!",
            preferredStyle: .alert
        )
        
        var listNameField = UITextField()
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            listNameField = textField
        }
        
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            if listNameField.text == nil || listNameField.text == "" {
                return
            }
            
            let entity = NSEntityDescription.entity(forEntityName: "List", in: self.context)
            let list = NSManagedObject(entity: entity!, insertInto: self.context) as! List
            list.name = listNameField.text
            list.id = UUID()
            list.index = Int32(self.listData.count)
            self.listData.append(list)
            self.listTable.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        present(alert, animated: true)
        
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
