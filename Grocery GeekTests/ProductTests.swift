//
//  ProductTests.swift
//  Grocery GeekTests
//
//  Created by Micah Beech on 2020-10-15.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import XCTest
@testable import Grocery_Geek
import CoreData

class ProductTests : XCTestCase {

    var product: Product!
    var coreDataHelper: CoreDataTestHelper!
    
    override func setUp()  {
        super.setUp()
        
        coreDataHelper = CoreDataTestHelper()
        
        let context = coreDataHelper.persistentContainer.viewContext
        
        product = Product(context: context)
        product.name = "Product"
        product.quantity = "Quantity"
        
    }

    override func tearDown()  {
        super.tearDown()
        product = nil
        coreDataHelper = nil
    }
    
    func testEdit() {
        product.edit(name: "New product", quantity: "New quantity")
        
        XCTAssert(product.name == "New product")
        XCTAssert(product.quantity == "New quantity")
    }

}
