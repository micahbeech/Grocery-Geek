//
//  ListItem.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-16.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import UIKit

class ListItem : UITableViewCell {

    @IBOutlet weak var listName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
