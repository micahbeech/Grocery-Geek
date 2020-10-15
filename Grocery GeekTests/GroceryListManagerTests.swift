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
        
        let list = List(context: context)
        list.name = "List"
        list.index = 0
        
        groceryListManager = GroceryListManager(context: context, list: list)
    }

    override func tearDown()  {
        super.tearDown()
        coreDataHelper = nil
        groceryListManager = nil
    }
    
    func testAddSection() {
        
        let section = groceryListManager.addSection(name: "Section")
        
        XCTAssertNotNil(section.name)
        XCTAssertNotNil(section.products)
        XCTAssert(section.name == "Section")
        XCTAssert(section.products!.count == 0)
        XCTAssert(groceryListManager.list.sections?.count == 1)
        XCTAssert(groceryListManager.list.sections?.firstObject as! Section == section)
        
    }
    
    func testDeleteSection() {
        
        groceryListManager.addSection(name: "Section")
        let result1 = groceryListManager.deleteSection(section: 0)
        let result2 = groceryListManager.deleteSection(section: 0)
        
        XCTAssertTrue(result1)
        XCTAssertFalse(result2)
        XCTAssert(groceryListManager.list.sections?.count == 0)
        
    }
    
    func testAddListProductNoBarcode() {
        
        let section = groceryListManager.addSection(name: "Section")
        let product = groceryListManager.addListProduct(section: 0, name: "Product", quantity: "Quantity", barcode: nil)
        
        XCTAssertNotNil(product)
        XCTAssertNotNil(product!.name)
        XCTAssertNotNil(product!.quantity)
        XCTAssert(product!.name == "Product")
        XCTAssert(product!.quantity == "Quantity")
        XCTAssertNil(product!.barcode)
        XCTAssert(section.products?.count == 1)
        XCTAssert(section.removedProducts?.count == 0)
        XCTAssert(section.products?.firstObject as? Product == product)
        
    }
    
    func testAddListProductWithBarcode() {
        
        let context = coreDataHelper.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Barcode", in: context)
        let barcode = NSManagedObject(entity: entity!, insertInto: context) as! Barcode
        
        let section = groceryListManager.addSection(name: "Section")
        let product = groceryListManager.addListProduct(section: 0, name: "Product", quantity: "Quantity", barcode: barcode)
        
        XCTAssertNotNil(product)
        XCTAssertNotNil(product!.name)
        XCTAssertNotNil(product!.quantity)
        XCTAssertNotNil(product!.barcode)
        XCTAssert(product!.name == "Product")
        XCTAssert(product!.quantity == "Quantity")
        XCTAssert(product!.barcode == barcode)
        XCTAssertNotNil(product!.barcode?.name)
        XCTAssertNotNil(product!.barcode?.quantity)
        XCTAssert(product!.barcode?.name == product!.name)
        XCTAssert(product!.barcode?.quantity == product!.quantity)
        XCTAssert(section.products?.count == 1)
        XCTAssert(section.removedProducts?.count == 0)
        XCTAssert(section.products?.firstObject as? Product == product)
        
    }
    
    func testAddProductBadSection() {
        
        let product = groceryListManager.addListProduct(section: 0, name: "Product", quantity: "Quantity", barcode: nil)
        
        XCTAssertNil(product)
        
    }
    
    func testEditProduct() {
        
        groceryListManager.addSection(name: "Section")
        let product = groceryListManager.addListProduct(section: 0, name: "Product", quantity: "Quantity", barcode: nil)
        
        XCTAssertNotNil(product)
        
        let barcode = product!.barcode
        
        groceryListManager.editProduct(product: product!, name: "New name", quantity: "New quantity")
        
        XCTAssertNotNil(product!.name)
        XCTAssertNotNil(product!.quantity)
        XCTAssert(product!.name == "New name")
        XCTAssert(product!.quantity == "New quantity")
        XCTAssert(product!.barcode == barcode)
        
    }
    
    func testRemoveProductFailure() {
        
        let bad = groceryListManager.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        
        groceryListManager.addSection(name: "Section")
        
        let badSection = groceryListManager.removeProduct(indexPath: IndexPath(row: 0, section: 1))
        let badRow = groceryListManager.removeProduct(indexPath: IndexPath(row: 1, section: 0))
        
        XCTAssertFalse(bad)
        XCTAssertFalse(badSection)
        XCTAssertFalse(badRow)
        
    }
    
    func testRemoveProduct() {
        
        let section = groceryListManager.addSection(name: "Section")
        let product = groceryListManager.addListProduct(section: 0, name: "Product", quantity: nil, barcode: nil)
        
        groceryListManager.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        
        XCTAssert(product?.removedRow == 0)
        XCTAssert(section.products?.count == 0)
        XCTAssert(section.removedProducts?.count == 1)
        XCTAssert(section.removedProducts?.firstObject as? Product == product)
        
    }
    
    func testUndoRemoveProductFailure() {
        
        let bad = groceryListManager.undoRemoveProduct(section: 0)
        
        groceryListManager.addSection(name: "Section")
        
        let badRow = groceryListManager.undoRemoveProduct(section: 0)
        let badSection = groceryListManager.undoRemoveProduct(section: 1)
        
        XCTAssertFalse(bad)
        XCTAssertFalse(badRow)
        XCTAssertFalse(badSection)
        
    }
    
    func testUndoRemoveProduct() {

        let section = groceryListManager.addSection(name: "Section")
        let product = groceryListManager.addListProduct(section: 0, name: "Product", quantity: nil, barcode: nil)
        groceryListManager.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        let result = groceryListManager.undoRemoveProduct(section: 0)
        
        XCTAssertTrue(result)
        XCTAssert(section.products?.count == 1)
        XCTAssert(section.removedProducts?.count == 0)
        XCTAssert(section.products?.firstObject as? Product == product)
        
    }
    
    func testUndoRemoveProductCorrectIndex() {
        
        let section = groceryListManager.addSection(name: "Section")
        let product1 = groceryListManager.addListProduct(section: 0, name: "Product 1", quantity: nil, barcode: nil)
        let product2 = groceryListManager.addListProduct(section: 0, name: "Product 2", quantity: nil, barcode: nil)
        let product3 = groceryListManager.addListProduct(section: 0, name: "Product 3", quantity: nil, barcode: nil)
        
        groceryListManager.removeProduct(indexPath: IndexPath(row: 1, section: 0))
        let result = groceryListManager.undoRemoveProduct(section: 0)
        
        XCTAssertTrue(result)
        XCTAssert(section.removedProducts?.count == 0)
        XCTAssert(section.products?.array as! [Product] == [product1, product2, product3])
        
    }
    
    func testClearList() {
        
        groceryListManager.addSection(name: "Section")
        groceryListManager.addListProduct(section: 0, name: "Product", quantity: nil, barcode: nil)
        groceryListManager.addListProduct(section: 0, name: "Product", quantity: nil, barcode: nil)
        groceryListManager.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        
        groceryListManager.clearList()
        
        XCTAssert(groceryListManager.list.sections?.count == 0)
        
    }
    
    func testMoveProductFailrue() {
        
        let result = groceryListManager.moveProduct(source: IndexPath(row: 0, section: 0), destination: IndexPath(row: 0, section: 0))
        
        XCTAssertFalse(result)
        
    }
    
    func testMoveProductSameSection() {
        
        let section = groceryListManager.addSection(name: "Section")
        let product1 = groceryListManager.addListProduct(section: 0, name: "Product 1", quantity: nil, barcode: nil)
        let product2 = groceryListManager.addListProduct(section: 0, name: "Product 2", quantity: nil, barcode: nil)
        let product3 = groceryListManager.addListProduct(section: 0, name: "Product 3", quantity: nil, barcode: nil)
        
        let original = section.products?.array as? [Product]
        
        let result1 = groceryListManager.moveProduct(source: IndexPath(row: 0, section: 0), destination: IndexPath(row: 2, section: 0))
        let result2 = groceryListManager.moveProduct(source: IndexPath(row: 1, section: 0), destination: IndexPath(row: 0, section: 0))
        
        XCTAssertNotNil(product1)
        XCTAssertNotNil(product2)
        XCTAssertNotNil(product3)
        XCTAssertTrue(result1)
        XCTAssertTrue(result2)
        XCTAssert(original == [product1!, product2!, product3!])
        XCTAssert(section.products?.array as? [Product] == [product3!, product2!, product1!])

    }
    
    func testMoveProductDifferentSection() {
        
        let section1 = groceryListManager.addSection(name: "Section 1")
        let section2 = groceryListManager.addSection(name: "Section 2")
        let product1 = groceryListManager.addListProduct(section: 0, name: "Product 1", quantity: nil, barcode: nil)
        let product2 = groceryListManager.addListProduct(section: 0, name: "Product 2", quantity: nil, barcode: nil)
        let product3 = groceryListManager.addListProduct(section: 1, name: "Product 3", quantity: nil, barcode: nil)
        
        let original1 = section1.products?.array as? [Product]
        let original2 = section2.products?.array as? [Product]
        
        let result1 = groceryListManager.moveProduct(source: IndexPath(row: 0, section: 0), destination: IndexPath(row: 1, section: 1))
        let result2 = groceryListManager.moveProduct(source: IndexPath(row: 0, section: 1), destination: IndexPath(row: 0, section: 0))
        
        XCTAssertNotNil(product1)
        XCTAssertNotNil(product2)
        XCTAssertNotNil(product3)
        XCTAssertTrue(result1)
        XCTAssertTrue(result2)
        XCTAssert(original1 == [product1!, product2!])
        XCTAssert(original2 == [product3!])
        XCTAssert(section1.products?.array as? [Product] == [product3!, product2!])
        XCTAssert(section2.products?.array as? [Product] == [product1!])

    }
    
    func testHasProducts() {
        
        let result1 = groceryListManager.hasProducts()
        groceryListManager.addSection(name: "Section")
        let result2 = groceryListManager.hasProducts()
        groceryListManager.addListProduct(section: 0, name: "Product", quantity: nil, barcode: nil)
        let result3 = groceryListManager.hasProducts()
        
        XCTAssertFalse(result1)
        XCTAssertFalse(result2)
        XCTAssertTrue(result3)
        
    }
    
    func testSize() {
        
        let noSections = groceryListManager.sectionCount()
        let badProducts = groceryListManager.sectionSize(sectionIndex: 0)
        
        groceryListManager.addSection(name: "Section")
        let oneSection = groceryListManager.sectionCount()
        let noProducts = groceryListManager.sectionSize(sectionIndex: 0)
        
        groceryListManager.addListProduct(section: 0, name: "Product", quantity: nil, barcode: nil)
        let oneProduct = groceryListManager.sectionSize(sectionIndex: 0)
        
        groceryListManager.addListProduct(section: 0, name: "Product", quantity: nil, barcode: nil)
        let twoProducts = groceryListManager.sectionSize(sectionIndex: 0)
        
        groceryListManager.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        groceryListManager.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        let empty = groceryListManager.sectionSize(sectionIndex: 0)
        
        groceryListManager.deleteSection(section: 0)
        let noSectionsAgain = groceryListManager.sectionCount()
        
        XCTAssert(noSections == 0)
        XCTAssert(badProducts == 0)
        XCTAssert(oneSection == 1)
        XCTAssert(noProducts == 0)
        XCTAssert(oneProduct == 1)
        XCTAssert(twoProducts == 2)
        XCTAssert(empty == 0)
        XCTAssert(noSectionsAgain == 0)
        
    }
    
    func testGetSection() {
        
        let section1 = groceryListManager.getSection(index: 0)
        let section2 = groceryListManager.addSection(name: "Section")
        let section3 = groceryListManager.getSection(index: 0)
        
        XCTAssertNil(section1)
        XCTAssertNotNil(section2)
        XCTAssertNotNil(section3)
        XCTAssert(section2 == section3)
        
    }
    
    func testGetProduct() {
        
        groceryListManager.addSection(name: "Section 1")
        groceryListManager.addSection(name: "Section 2")
        
        let product1 = groceryListManager.getProduct(indexPath: IndexPath(row: 0, section: 0))
        let product2 = groceryListManager.addListProduct(section: 0, name: "Product", quantity: nil, barcode: nil)
        let product3 = groceryListManager.getProduct(indexPath: IndexPath(row: 0, section: 0))
        
        let product4 = groceryListManager.getProduct(indexPath: IndexPath(row: 0, section: 1))
        let product5 = groceryListManager.addListProduct(section: 1, name: "Product", quantity: nil, barcode: nil)
        let product6 = groceryListManager.getProduct(indexPath: IndexPath(row: 0, section: 1))
        
        XCTAssertNil(product1)
        XCTAssertNotNil(product2)
        XCTAssertNotNil(product3)
        XCTAssert(product2 == product3)
        XCTAssertNil(product4)
        XCTAssertNotNil(product5)
        XCTAssertNotNil(product6)
        XCTAssert(product5 == product6)
        
    }
    
    func testSave() {
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataHelper.persistentContainer.viewContext) { _ in
            return true
        }
        
        let context = coreDataHelper.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Barcode", in: context)
        let barcode = NSManagedObject(entity: entity!, insertInto: context) as! Barcode
        
        let section = groceryListManager.addSection(name: "Section")
        
        let product1 = groceryListManager.addListProduct(section: 0, name: "Product 1", quantity: "1", barcode: barcode)
        let product2 = groceryListManager.addListProduct(section: 0, name: "Product 2", quantity: "2", barcode: nil)
        groceryListManager.moveProduct(source: IndexPath(row: 0, section: 0), destination: IndexPath(row: 1, section: 0))
        groceryListManager.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        
        coreDataHelper.saveContext()
        
        waitForExpectations(timeout: 2.0) { error in
            
            XCTAssertNil(error, "Save did not occur")
            
            let newManager = GroceryListManager(context: self.coreDataHelper.persistentContainer.viewContext, list: self.groceryListManager.list)
            let newSection = newManager.list.sections?.firstObject as! Section
            
            XCTAssertNotNil(newSection)
            XCTAssert(newManager.list.sections?.array as? [Section] == [newSection])
            XCTAssert(newSection.name == section.name)
            XCTAssert(newSection.products?.array as? [Product] == [product1!])
            XCTAssert(newSection.removedProducts?.array as? [Product] == [product2!])
            XCTAssert(newSection.name == "Section")
            XCTAssert(product1!.name == "Product 1")
            XCTAssert(product2!.name == "Product 2")
            XCTAssert(product1!.quantity == "1")
            XCTAssert(product2!.quantity == "2")
            XCTAssert(product1!.barcode == barcode)
            XCTAssertNil(product2!.barcode)
            
        }
    }
    
    func testStringConversion() {
        
        groceryListManager.addSection(name: "Section 1")
        groceryListManager.addSection(name: "Section 2")
        
        groceryListManager.addListProduct(section: 0, name: "Product 1", quantity: "1", barcode: nil)
        groceryListManager.addListProduct(section: 0, name: "Product 2", quantity: "2", barcode: nil)
        groceryListManager.addListProduct(section: 1, name: "Product 3", quantity: "3", barcode: nil)
        groceryListManager.addListProduct(section: 1, name: "Product 4", quantity: "4", barcode: nil)
        groceryListManager.addListProduct(section: 1, name: "Product 5", quantity: "5", barcode: nil)
        
        let result = groceryListManager.list.toString()
        
        let expectedResult = """
        Check out my list from Grocery Geek!

        Section 1
         • Product 1, 1
         • Product 2, 2

        Section 2
         • Product 3, 3
         • Product 4, 4
         • Product 5, 5

        """
        
        XCTAssert(result == expectedResult)
        
    }
    
    func testSearch() {
        
        groceryListManager.addSection(name: "Section 1")
        groceryListManager.addSection(name: "Section 2")
        
        let product1 = groceryListManager.addListProduct(section: 0, name: "Product 1", quantity: "1", barcode: nil)
        let product2 = groceryListManager.addListProduct(section: 0, name: "Product 2", quantity: "2", barcode: nil)
        let product3 = groceryListManager.addListProduct(section: 1, name: "Product 3", quantity: "3", barcode: nil)
        let product4 = groceryListManager.addListProduct(section: 1, name: "Product 4", quantity: "4", barcode: nil)
        let product5 = groceryListManager.addListProduct(section: 1, name: "Product 5", quantity: "5", barcode: nil)
        
        let allReturned = groceryListManager.searchProducts(text: "Product")
        let noneReturned = groceryListManager.searchProducts(text: "Apples")
        let empty = groceryListManager.searchProducts(text: "")
        let oneReturned = groceryListManager.searchProducts(text: "Product 4")
        
        func isEqual(lhs: (Int, [Product]), rhs: (Int, [Product?])) -> Bool {
            return lhs.0 == rhs.0 && lhs.1 == rhs.1
        }
        
        XCTAssert(allReturned.elementsEqual([(0, [product1, product2]), (1, [product3, product4, product5])], by: isEqual(lhs:rhs:)))
        XCTAssertTrue(noneReturned.isEmpty)
        XCTAssert(empty.elementsEqual([(0, [product1, product2]), (1, [product3, product4, product5])], by: isEqual(lhs:rhs:)))
        XCTAssert(oneReturned.elementsEqual([(1, [product4])], by: isEqual(lhs:rhs:)))
        
    }

}
