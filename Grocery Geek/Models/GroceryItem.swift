//
//  GroceryItem.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2019-05-13.
//  Copyright © 2019 Micah Beech. All rights reserved.
//

import UIKit

class GroceryItem: UITableViewCell {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productQuantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
