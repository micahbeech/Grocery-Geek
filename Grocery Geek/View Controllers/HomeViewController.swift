//
//  HomeViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-16.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var listData = [String]()
    @IBOutlet weak var listTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listData.append("My Grocery List")
        
        listTable.delegate = self
        listTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the data for this row
        let list = listData[indexPath.row]
        
        // Get a cell to display
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListItem", for: indexPath) as! ListItem
        cell.listName?.text = list
        
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showList", sender: self)
        listTable.deselectRow(at: indexPath, animated: true)
    }
    
    
}
