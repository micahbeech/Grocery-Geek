//
//  List+CoreDataClass.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-09-28.
//  Copyright © 2020 Micah Beech. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

public class List: NSManagedObject, UIActivityItemSource {
    
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return self.toString()
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return self.toString()
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "My Grocery List"
    }
    
    func toString() -> String {
        
        var message = "Check out my list from Grocery Geek!\n\n"
        
        for section in sections?.array as! [Section] {
            
            message.append(section.name! + "\n")
            
            for product in section.products?.array as! [Product] {
                
                message.append(" \u{2022} ")
                message.append(product.name!)
                message.append(", ")
                message.append(product.quantity!)
                message.append("\n")
                
            }
            
            if section != sections?.lastObject as! Section {
                message.append("\n")
            }
            
        }
        
        return message
    }
}
