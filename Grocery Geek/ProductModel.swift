//
//  ProductModel.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2019-05-07.
//  Copyright © 2019 Micah Beech. All rights reserved.
//

import UIKit

class ProductModel {
    
    static var groceryListData = [Product]()
    static var removedList = [RemovedProduct]()
    
    static func productIndexSort(first: Product, second: Product) -> Bool {
        if let firstIndex = first.index, let secondIndex = second.index {
            return firstIndex.intValue < secondIndex.intValue
        }
        print("Error. Not all grocery list items have indices.")
        return false
    }
    
}
