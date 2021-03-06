//
//  ViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2019-05-06.
//  Copyright © 2019 Micah Beech. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ListViewController: UIViewController, UISearchResultsUpdating {

    @IBOutlet weak var groceryList: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    
    var resultSearchController = UISearchController()
    
    var list: List!
    
    var selectedRow: Product?
    var selectedSection: Int?
    var filteredData = [(Int, [Product])]()
    
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
            controller.searchBar.backgroundColor = .systemBackground

            groceryList.tableHeaderView = controller.searchBar
            
            // This fixes the background color changing on pull down with search bar at top
            // Stupid fix, but it works
            groceryList.backgroundView = UIView()

            return controller
        })()
        
        navigationBar.title = list.name
        
        spinner.layer.cornerRadius = 20
        
        groceryList.delegate = self
        groceryList.dataSource = self
        
        // Set up ads
        bannerView.setUp(root: self, adUnitID: testingBannerAdUnitID)
        bannerView.addToViewAtTop(view: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bannerView.load()
        groceryList.reloadData()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        // Turn off the search bar when moving to parent view
        resultSearchController.isActive = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        resultSearchController.isActive = false
        
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
        
        if list.hasProducts() {
        
            // construct alert to be displayed
            let alert = UIAlertController(title: "Clear grocery list?", message: "This will clear current and removed items.", preferredStyle: .alert)
            
            // execute if confirmation received
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { action in
                
                // clear list in database
                self.list.clear()
                
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
        
        resultSearchController.isActive = false
        
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
                self.list.addSection(name: listNameField.text!)
            } else {
                self.list.editSection(section: section!, name: listNameField.text!)
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
        
        let items = [list!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.excludedActivityTypes = [.airDrop]
        present(ac, animated: true)
        
        spinner.stopAnimating()
        
    }
    
    // MARK: Searching
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // Update the current search results
        filteredData = list.searchProducts(text: searchController.searchBar.text!)

        // Update the UI
        groceryList.reloadData()
    }
    
}

