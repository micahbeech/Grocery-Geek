//
//  ViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2019-05-06.
//  Copyright © 2019 Micah Beech. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UISearchResultsUpdating {

    @IBOutlet weak var groceryList: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var resultSearchController = UISearchController()
    
    var list: List!
    var listManager: GroceryListManager!
    
    var selectedRow: Product?
    var selectedSection: Int?
    var filteredData = [[Product]]()
    
    let headerSize = CGFloat(60)
    
    // MARK: setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.sizeToFit()

            groceryList.tableHeaderView = controller.searchBar

            return controller
        })()
        
        groceryList.delegate = self
        groceryList.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listManager = GroceryListManager(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext, list: list)
        
        navigationBar.title = list.name
        
        spinner.layer.cornerRadius = 20
        
        groceryList.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            
        case "addProduct":
            let destinationVC = segue.destination as! AddViewController
            destinationVC.list = list
            destinationVC.itemToEdit = selectedRow
            destinationVC.section = selectedSection
            selectedRow = nil
            selectedSection = nil
            
        case "scanProduct":
            let destinationVC = segue.destination as! ScannerViewController
            destinationVC.loadViewIfNeeded()
            destinationVC.list = list
            destinationVC.section = selectedSection
            
        default:
            break
            
        }
    }
    
    // MARK: remove data
    
    @IBAction func editToggle(_ sender: Any) {
        groceryList.isEditing = !groceryList.isEditing
        
        groceryList.reloadData()
        
        if groceryList.isEditing {
            editButton.title = "Done"
            editButton.style = .done
        } else {
            editButton.title = "Edit"
            editButton.style = .plain
        }
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
            let alert = UIAlertController(title: "Your list is empty!", message: "Scan or add items to build your list.", preferredStyle: .alert)
            
            // add action
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    // MARK: Section Management
    
    func changeSectionName(title: String, message: String? = nil, name: String? = nil, section: Int? = nil) {
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        var listNameField = UITextField()
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .sentences
            textField.text = name
            listNameField = textField
        }
        
        let add = UIAlertAction(title: "OK", style: .default) { (action) in
            if listNameField.text == nil || listNameField.text == "" {
                return
            }
            
            if name == nil {
                self.listManager.addSection(name: listNameField.text!)
            } else {
                self.listManager.editSection(section: section!, name: listNameField.text!)
            }
            
            self.groceryList.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        present(alert, animated: true)
        
    }
    
    @IBAction func addSection(_ sender: Any) {
        
        changeSectionName(title: "Add section", message: "Use sections to group your lists into product types!")
        
    }
    
    // MARK: Sharing
    
    @IBAction func share(_ sender: Any) {
        
        spinner.startAnimating()
        
        let items = [listManager.list]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.excludedActivityTypes = [.airDrop]
        present(ac, animated: true)
        
        spinner.stopAnimating()
        
    }
    
    // MARK: Searching
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // Clear the current search results
        filteredData.removeAll(keepingCapacity: false)

        // Get a predicate to filter by
        var searchPredicate = NSPredicate()
        
        if searchController.searchBar.text!.isEmpty {
            // If nothing has been typed, continue to display all results
            searchPredicate = NSPredicate(value: true)
            
        } else {
            // Otherwise, return all items whose name begins with the text
            searchPredicate = NSPredicate(format: "SELF.name BEGINSWITH[c] %@", searchController.searchBar.text!)
        }
        
        for section in list.sections!.array as! [Section] {
            
            // Get the products for this section that meet the criteria of the predicate
            let products = section.products?.filtered(using: searchPredicate).array as! [Product]
            
            // Add the section to the list with the filtered products, if any
            if !products.isEmpty {
                filteredData.append(products)
            }
        }

        // Update the UI
        groceryList.reloadData()
    }
    
}

