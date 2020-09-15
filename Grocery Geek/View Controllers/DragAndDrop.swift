//
//  DragAndDrop.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-15.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import Foundation
import UIKit

extension ViewController {
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let product = groceryListData[sourceIndexPath.row]
        groceryListData.remove(at: sourceIndexPath.row)
        product.index = Int32(destinationIndexPath.row)
        groceryListData.insert(product, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
