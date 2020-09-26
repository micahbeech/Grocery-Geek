//
//  GroceryListManagerTests.swift
//  Grocery GeekTests
//
//  Created by Micah Beech on 2020-09-26.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import XCTest
@testable import Grocery_Geek
import CoreData

class GroceryListManagerTests : XCTestCase {

    var groceryListManager: GroceryListManager!
    var coreDataHelper: CoreDataTestHelper!
    
    override func setUp()  {
        super.setUp()
        coreDataHelper = CoreDataTestHelper()
        
        let context = coreDataHelper.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "List", in: context)
        let list = NSManagedObject(entity: entity!, insertInto: context) as! List
        list.id = UUID()
        list.name = "List"
        list.index = 0
        
        groceryListManager = GroceryListManager(context: context, list: list)
    }

    override func tearDown()  {
        super.tearDown()
        coreDataHelper = nil
        groceryListManager = nil
    }
    
    func testAddListProductNoBarcode() {
        
        let product = groceryListManager.addListProduct(name: "Product", quantity: "Quantity", barcode: nil)
        
        XCTAssertNotNil(product.name)
        XCTAssertNotNil(product.quantity)
        XCTAssert(product.name == "Product")
        XCTAssert(product.quantity == "Quantity")
        XCTAssertNil(product.barcode)
        XCTAssert(groceryListManager.list.currentProducts?.count == 1)
        XCTAssert(groceryListManager.list.removedProducts?.count == 0)
        XCTAssert(groceryListManager.list.currentProducts?.firstObject as! Product == product)
    }
    
    func testAddListProductWithBarcode() {
        
        let context = coreDataHelper.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Barcode", in: context)
        let barcode = NSManagedObject(entity: entity!, insertInto: context) as! Barcode
        
        let product = groceryListManager.addListProduct(name: "Product", quantity: "Quantity", barcode: barcode)
        
        XCTAssertNotNil(product.name)
        XCTAssertNotNil(product.quantity)
        XCTAssertNotNil(product.barcode)
        XCTAssert(product.name == "Product")
        XCTAssert(product.quantity == "Quantity")
        XCTAssert(product.barcode == barcode)
        XCTAssertNotNil(product.barcode?.name)
        XCTAssertNotNil(product.barcode?.quantity)
        XCTAssert(product.barcode?.name == product.name)
        XCTAssert(product.barcode?.quantity == product.quantity)
        XCTAssert(groceryListManager.list.currentProducts?.count == 1)
        XCTAssert(groceryListManager.list.removedProducts?.count == 0)
        XCTAssert(groceryListManager.list.currentProducts?.firstObject as! Product == product)
        
    }
    
    func testEditProduct() {
        
        let product = groceryListManager.addListProduct(name: "Product", quantity: "Quantity", barcode: nil)
        let barcode = product.barcode
        
        groceryListManager.editProduct(product: product, name: "New name", quantity: "New quantity")
        
        XCTAssertNotNil(product.name)
        XCTAssertNotNil(product.quantity)
        XCTAssert(product.name == "New name")
        XCTAssert(product.quantity == "New quantity")
        XCTAssert(product.barcode == barcode)
        
    }
    
    func testRemoveProductFailure() {
        
        let result = groceryListManager.removeProduct(index: 0)
        
        XCTAssertFalse(result)
        
    }
    
    func testRemoveProduct() {
        
        let product = groceryListManager.addListProduct(name: "Product", quantity: nil, barcode: nil)
        
        groceryListManager.removeProduct(index: 0)
        
        XCTAssert(product.removedIndex == 0)
        XCTAssert(groceryListManager.list.currentProducts?.count == 0)
        XCTAssert(groceryListManager.list.removedProducts?.count == 1)
        XCTAssert(groceryListManager.list.removedProducts?.firstObject as! Product == product)
        
    }
    
    func testUndoRemoveProductFailure() {
        
        let result = groceryListManager.undoRemoveProduct()
        
        XCTAssertFalse(result)
        
    }
    
    func testUndoRemoveProduct() {

        let product = groceryListManager.addListProduct(name: "Product", quantity: nil, barcode: nil)
        groceryListManager.removeProduct(index: 0)
        let result = groceryListManager.undoRemoveProduct()
        
        XCTAssertTrue(result)
        XCTAssert(groceryListManager.list.currentProducts?.count == 1)
        XCTAssert(groceryListManager.list.removedProducts?.count == 0)
        XCTAssert(groceryListManager.list.currentProducts?.firstObject as! Product == product)
        
    }
    
    func testUndoRemoveProductCorrectIndex() {
        
        let product1 = groceryListManager.addListProduct(name: "Product 1", quantity: nil, barcode: nil)
        let product2 = groceryListManager.addListProduct(name: "Product 2", quantity: nil, barcode: nil)
        let product3 = groceryListManager.addListProduct(name: "Product 3", quantity: nil, barcode: nil)
        
        groceryListManager.removeProduct(index: 1)
        let result = groceryListManager.undoRemoveProduct()
        
        XCTAssertTrue(result)
        XCTAssert(groceryListManager.list.removedProducts?.count == 0)
        XCTAssert(groceryListManager.list.currentProducts?.array as! [Product] == [product1, product2, product3])
        
    }
    
    func testClearList() {
        
        groceryListManager.addListProduct(name: "Product", quantity: nil, barcode: nil)
        groceryListManager.addListProduct(name: "Product", quantity: nil, barcode: nil)
        groceryListManager.removeProduct(index: 0)
        
        groceryListManager.clearList()
        
        XCTAssert(groceryListManager.list.currentProducts?.count == 0)
        XCTAssert(groceryListManager.list.removedProducts?.count == 0)
        
    }
    
    func testMoveProductFailrue() {
        
        let result = groceryListManager.moveProduct(source: IndexPath(row: 0, section: 0), destination: IndexPath(row: 0, section: 0))
        
        XCTAssertFalse(result)
        
    }
    
    func testMoveProduct() {
        
        let product1 = groceryListManager.addListProduct(name: "Product 1", quantity: nil, barcode: nil)
        let product2 = groceryListManager.addListProduct(name: "Product 2", quantity: nil, barcode: nil)
        let product3 = groceryListManager.addListProduct(name: "Product 3", quantity: nil, barcode: nil)
        
        let original = groceryListManager.list.currentProducts?.array as? [Product]
        
        let result1 = groceryListManager.moveProduct(source: IndexPath(row: 0, section: 0), destination: IndexPath(row: 2, section: 0))
        let result2 = groceryListManager.moveProduct(source: IndexPath(row: 1, section: 0), destination: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(result1)
        XCTAssertTrue(result2)
        XCTAssert(original == [product1, product2, product3])
        XCTAssert(groceryListManager.list.currentProducts?.array as? [Product] == [product3, product2, product1])

    }
    
    func testHasProducts() {
        
        let result1 = groceryListManager.hasProducts()
        groceryListManager.addListProduct(name: "Product", quantity: nil, barcode: nil)
        let result2 = groceryListManager.hasProducts()
        
        XCTAssertFalse(result1)
        XCTAssertTrue(result2)
        
    }
    
    func testSize() {
        
        let empty1 = groceryListManager.size()
        
        groceryListManager.addListProduct(name: "Product", quantity: nil, barcode: nil)
        let one = groceryListManager.size()
        
        groceryListManager.addListProduct(name: "Product", quantity: nil, barcode: nil)
        let two = groceryListManager.size()
        
        groceryListManager.removeProduct(index: 0)
        groceryListManager.removeProduct(index: 0)
        let empty2 = groceryListManager.size()
        
        XCTAssert(empty1 == 0)
        XCTAssert(one == 1)
        XCTAssert(two == 2)
        XCTAssert(empty2 == 0)
        
    }
    
    func testGetProduct() {
        
        let product1 = groceryListManager.getProduct(index: 0)
        let product2 = groceryListManager.addListProduct(name: "Product", quantity: nil, barcode: nil)
        let product3 = groceryListManager.getProduct(index: 0)
        
        XCTAssertNil(product1)
        XCTAssertNotNil(product2)
        XCTAssertNotNil(product3)
        XCTAssert(product2 == product3)
        
    }
    
    func testSave() {
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataHelper.persistentContainer.viewContext) { _ in
            return true
        }
        
        let context = coreDataHelper.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Barcode", in: context)
        let barcode = NSManagedObject(entity: entity!, insertInto: context) as! Barcode
        
        let product1 = groceryListManager.addListProduct(name: "Product 1", quantity: "1", barcode: barcode)
        let product2 = groceryListManager.addListProduct(name: "Product 2", quantity: "2", barcode: nil)
        groceryListManager.moveProduct(source: IndexPath(row: 0, section: 0), destination: IndexPath(row: 1, section: 0))
        groceryListManager.removeProduct(index: 1)
        
        coreDataHelper.saveContext()
        
        waitForExpectations(timeout: 2.0) { error in
            
            XCTAssertNil(error, "Save did not occur")
            
            let newManager = GroceryListManager(context: self.coreDataHelper.persistentContainer.viewContext, list: self.groceryListManager.list)
            
            XCTAssert(newManager.list.currentProducts?.array as? [Product] == [product2])
            XCTAssert(newManager.list.removedProducts?.array as? [Product] == [product1])
            XCTAssert(product1.name == "Product 1")
            XCTAssert(product2.name == "Product 2")
            XCTAssert(product1.quantity == "1")
            XCTAssert(product2.quantity == "2")
            XCTAssert(product1.barcode == barcode)
            XCTAssertNil(product2.barcode)
            
        }
    }

}
