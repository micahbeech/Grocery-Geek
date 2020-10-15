//
//  SectionTests.swift
//  Grocery GeekTests
//
//  Created by Micah Beech on 2020-10-15.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import XCTest
@testable import Grocery_Geek
import CoreData

class SectionTests : XCTestCase {

    var section: Section!
    var coreDataHelper: CoreDataTestHelper!
    
    override func setUp()  {
        super.setUp()
        
        coreDataHelper = CoreDataTestHelper()
        
        let context = coreDataHelper.persistentContainer.viewContext
        
        section = Section(context: context)
        section.name = "Section"
        
    }

    override func tearDown()  {
        super.tearDown()
        section = nil
        coreDataHelper = nil
    }
    
    func testGetProduct() {
        
        let bad = section.getProduct(index: 0)
        
        let product = section.addProduct(name: "Product", quantity: "1")
        
        let good = section.getProduct(index: 0)
        
        XCTAssertNil(bad)
        XCTAssertNotNil(good)
        XCTAssert(product == good)
        XCTAssert(good!.name == "Product")
        XCTAssert(good!.quantity == "1")
    }
    
    func testAddProduct() {
        
        let product = section.addProduct(name: "Product", quantity: "1")
        
        XCTAssertNotNil(product)
        XCTAssert(product!.name == "Product")
        XCTAssert(product!.quantity == "1")
    }
    
    
    func testRemoveProduct() {
        
        section.addProduct(name: "Product", quantity: "1")
        let good = section.removeProduct(index: 0)
        let bad = section.removeProduct(index: 0)
        
        XCTAssertFalse(bad)
        XCTAssertTrue(good)
        XCTAssert(section.products?.count == 0)
        
    }
    
    func testUndoRemoveProduct() {
        
        let product = section.addProduct(name: "Product", quantity: "1")
        section.removeProduct(index: 0)
        let good = section.undoRemoveProduct()
        let bad = section.undoRemoveProduct()
        
        XCTAssertFalse(bad)
        XCTAssertTrue(good)
        XCTAssert(section.products?.count == 1)
        XCTAssert(section.products?.firstObject as? Product == product)
    }
    
    func testHasProducts() {
        let no = section.hasProducts()
        section.addProduct(name: "Product", quantity: nil)
        let yes = section.hasProducts()
        section.removeProduct(index: 0)
        let yesRemoved = section.hasProducts()
        
        XCTAssertFalse(no)
        XCTAssertTrue(yes)
        XCTAssertTrue(yesRemoved)
    }
    
    func testProductCount() {
        let empty = section.productCount()
        section.addProduct(name: "", quantity: "")
        let one = section.productCount()
        
        XCTAssert(empty == 0)
        XCTAssert(one == 1)
    }
    
    func testEdit() {
        section.edit(name: "New section")
        
        XCTAssert(section.name == "New section")
    }
    
    func testSearch() {
        let predicate = NSPredicate(format: "SELF.name BEGINSWITH[c] %@", "Product")
        
        let product1 = section.addProduct(name: "Test", quantity: nil)
        let product2 = section.addProduct(name: "Product", quantity: "1")
        let product3 = section.addProduct(name: "Product 2", quantity: "2")
        let product4 = section.addProduct(name: "Hello", quantity: nil)
        
        let products = section.search(predicate: predicate)
        let all = section.search(predicate: NSPredicate(value: true))
        
        XCTAssert(products == [product2, product3])
        XCTAssert(all == [product1, product2, product3, product4])
    }
    
    func testSave() {
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataHelper.persistentContainer.viewContext) { _ in
            return true
        }
        
        let product1 = section.addProduct(name: "Product 1", quantity: "1")
        let product2 = section.addProduct(name: "Product 2", quantity: "2")
        section.removeProduct(index: 0)
        
        coreDataHelper.saveContext()
        
        waitForExpectations(timeout: 2.0) { error in
            
            XCTAssertNil(error, "Save did not occur")
            
            let newSection = self.coreDataHelper.getSections().first
            
            XCTAssertNotNil(newSection)
            XCTAssert(newSection!.name == self.section.name)
            XCTAssert(newSection!.products?.array as? [Product] == [product2!])
            XCTAssert(newSection!.removedProducts?.array as? [Product] == [product1!])
            XCTAssert(newSection!.name == "Section")
            XCTAssert(product1!.name == "Product 1")
            XCTAssert(product2!.name == "Product 2")
            XCTAssert(product1!.quantity == "1")
            XCTAssert(product2!.quantity == "2")
            
        }
    }
    
    func testSearchRecent() {
        
        let product1 = section.addProduct(name: "Product 1", quantity: "1")
        let product2 = section.addProduct(name: "Product 2", quantity: "2")
        let product3 = section.addProduct(name: "Item", quantity: "3")
        
        let empty = section.searchRecent(text: "")
        let case1 = section.searchRecent(text: "Product")
        let case2 = section.searchRecent(text: "It")
        let case3 = section.searchRecent(text: "t")
        let case4 = section.searchRecent(text: "Hello")
        
        XCTAssert(section.recentProducts?.count == 3)
        XCTAssert(empty == [product3, product2, product1])
        XCTAssert(case1 == [product2, product1])
        XCTAssert(case2 == [product3])
        XCTAssert(case3 == [product3, product2, product1])
        XCTAssertTrue(case4.isEmpty)
        
    }

}
