//
//  listTests.swift
//  Grocery GeekTests
//
//  Created by Micah Beech on 2020-09-26.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import XCTest
@testable import Grocery_Geek
import CoreData

class ListTests : XCTestCase {

    var list: List!
    var coreDataHelper: CoreDataTestHelper!
    
    override func setUp()  {
        super.setUp()
        
        coreDataHelper = CoreDataTestHelper()
        
        let context = coreDataHelper.persistentContainer.viewContext
        
        list = List(context: context)
        list.name = "List"
        list.index = 0
        
    }

    override func tearDown()  {
        super.tearDown()
        list = nil
        coreDataHelper = nil
    }
    
    func testAddSection() {
        
        let section = list.addSection(name: "Section")
        
        XCTAssertNotNil(section.name)
        XCTAssertNotNil(section.products)
        XCTAssert(section.name == "Section")
        XCTAssert(section.products!.count == 0)
        XCTAssert(list.sections?.count == 1)
        XCTAssert(list.sections?.firstObject as! Section == section)
        
    }
    
    func testEditSection() {
        
        let bad = list.editSection(section: 0, name: "New section")
        
        let section = list.addSection(name: "Section")
        
        let good = list.editSection(section: 0, name: "New section")
        
        XCTAssertFalse(bad)
        XCTAssertTrue(good)
        XCTAssert(section.name == "New section")
    }
    
    func testDeleteSection() {
        
        list.addSection(name: "Section")
        let result1 = list.deleteSection(section: 0)
        let result2 = list.deleteSection(section: 0)
        
        XCTAssertTrue(result1)
        XCTAssertFalse(result2)
        XCTAssert(list.sections?.count == 0)
        
    }
    
    func testAddListProduct() {
        
        let section = list.addSection(name: "Section")
        let product = list.addListProduct(section: 0, name: "Product", quantity: "Quantity")
        
        XCTAssertNotNil(product)
        XCTAssertNotNil(product!.name)
        XCTAssertNotNil(product!.quantity)
        XCTAssert(product!.name == "Product")
        XCTAssert(product!.quantity == "Quantity")
        XCTAssert(section.products?.count == 1)
        XCTAssert(section.removedProducts?.count == 0)
        XCTAssert(section.products?.firstObject as? Product == product)
        
    }
    
    func testAddProductBadSection() {
        
        let product = list.addListProduct(section: 0, name: "Product", quantity: "Quantity")
        
        XCTAssertNil(product)
        
    }
    
    func testRemoveProductFailure() {
        
        let bad = list.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        
        list.addSection(name: "Section")
        
        let badSection = list.removeProduct(indexPath: IndexPath(row: 0, section: 1))
        let badRow = list.removeProduct(indexPath: IndexPath(row: 1, section: 0))
        
        XCTAssertFalse(bad)
        XCTAssertFalse(badSection)
        XCTAssertFalse(badRow)
        
    }
    
    func testRemoveProduct() {
        
        let section = list.addSection(name: "Section")
        let product = list.addListProduct(section: 0, name: "Product", quantity: nil)
        
        list.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        
        XCTAssert(product?.removedRow == 0)
        XCTAssert(section.products?.count == 0)
        XCTAssert(section.removedProducts?.count == 1)
        XCTAssert(section.removedProducts?.firstObject as? Product == product)
        
    }
    
    func testUndoRemoveProductFailure() {
        
        let bad = list.undoRemoveProduct(section: 0)
        
        list.addSection(name: "Section")
        
        let badRow = list.undoRemoveProduct(section: 0)
        let badSection = list.undoRemoveProduct(section: 1)
        
        XCTAssertFalse(bad)
        XCTAssertFalse(badRow)
        XCTAssertFalse(badSection)
        
    }
    
    func testUndoRemoveProduct() {

        let section = list.addSection(name: "Section")
        let product = list.addListProduct(section: 0, name: "Product", quantity: nil)
        list.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        let result = list.undoRemoveProduct(section: 0)
        
        XCTAssertTrue(result)
        XCTAssert(section.products?.count == 1)
        XCTAssert(section.removedProducts?.count == 0)
        XCTAssert(section.products?.firstObject as? Product == product)
        
    }
    
    func testUndoRemoveProductCorrectIndex() {
        
        let section = list.addSection(name: "Section")
        let product1 = list.addListProduct(section: 0, name: "Product 1", quantity: nil)
        let product2 = list.addListProduct(section: 0, name: "Product 2", quantity: nil)
        let product3 = list.addListProduct(section: 0, name: "Product 3", quantity: nil)
        
        list.removeProduct(indexPath: IndexPath(row: 1, section: 0))
        let result = list.undoRemoveProduct(section: 0)
        
        XCTAssertTrue(result)
        XCTAssert(section.removedProducts?.count == 0)
        XCTAssert(section.products?.array as! [Product] == [product1, product2, product3])
        
    }
    
    func testClearList() {
        
        list.addSection(name: "Section")
        list.addListProduct(section: 0, name: "Product", quantity: nil)
        list.addListProduct(section: 0, name: "Product", quantity: nil)
        list.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        
        list.clear()
        
        XCTAssert(list.sections?.count == 0)
        
    }
    
    func testMoveProductFailrue() {
        
        let result = list.moveProduct(source: IndexPath(row: 0, section: 0), destination: IndexPath(row: 0, section: 0))
        
        XCTAssertFalse(result)
        
    }
    
    func testMoveProductSameSection() {
        
        let section = list.addSection(name: "Section")
        let product1 = list.addListProduct(section: 0, name: "Product 1", quantity: nil)
        let product2 = list.addListProduct(section: 0, name: "Product 2", quantity: nil)
        let product3 = list.addListProduct(section: 0, name: "Product 3", quantity: nil)
        
        let original = section.products?.array as? [Product]
        
        let result1 = list.moveProduct(source: IndexPath(row: 0, section: 0), destination: IndexPath(row: 2, section: 0))
        let result2 = list.moveProduct(source: IndexPath(row: 1, section: 0), destination: IndexPath(row: 0, section: 0))
        
        XCTAssertNotNil(product1)
        XCTAssertNotNil(product2)
        XCTAssertNotNil(product3)
        XCTAssertTrue(result1)
        XCTAssertTrue(result2)
        XCTAssert(original == [product1!, product2!, product3!])
        XCTAssert(section.products?.array as? [Product] == [product3!, product2!, product1!])

    }
    
    func testMoveProductDifferentSection() {
        
        let section1 = list.addSection(name: "Section 1")
        let section2 = list.addSection(name: "Section 2")
        let product1 = list.addListProduct(section: 0, name: "Product 1", quantity: nil)
        let product2 = list.addListProduct(section: 0, name: "Product 2", quantity: nil)
        let product3 = list.addListProduct(section: 1, name: "Product 3", quantity: nil)
        
        let original1 = section1.products?.array as? [Product]
        let original2 = section2.products?.array as? [Product]
        
        let result1 = list.moveProduct(source: IndexPath(row: 0, section: 0), destination: IndexPath(row: 1, section: 1))
        let result2 = list.moveProduct(source: IndexPath(row: 0, section: 1), destination: IndexPath(row: 0, section: 0))
        
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
        
        let result1 = list.hasProducts()
        list.addSection(name: "Section")
        let result2 = list.hasProducts()
        list.addListProduct(section: 0, name: "Product", quantity: nil)
        let result3 = list.hasProducts()
        
        XCTAssertFalse(result1)
        XCTAssertFalse(result2)
        XCTAssertTrue(result3)
        
    }
    
    func testSize() {
        
        let noSections = list.sectionCount()
        let badProducts = list.sectionSize(sectionIndex: 0)
        
        list.addSection(name: "Section")
        let oneSection = list.sectionCount()
        let noProducts = list.sectionSize(sectionIndex: 0)
        
        list.addListProduct(section: 0, name: "Product", quantity: nil)
        let oneProduct = list.sectionSize(sectionIndex: 0)
        
        list.addListProduct(section: 0, name: "Product", quantity: nil)
        let twoProducts = list.sectionSize(sectionIndex: 0)
        
        list.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        list.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        let empty = list.sectionSize(sectionIndex: 0)
        
        list.deleteSection(section: 0)
        let noSectionsAgain = list.sectionCount()
        
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
        
        let section1 = list.getSection(index: 0)
        let section2 = list.addSection(name: "Section")
        let section3 = list.getSection(index: 0)
        
        XCTAssertNil(section1)
        XCTAssertNotNil(section2)
        XCTAssertNotNil(section3)
        XCTAssert(section2 == section3)
        
    }
    
    func testGetProduct() {
        
        list.addSection(name: "Section 1")
        list.addSection(name: "Section 2")
        
        let product1 = list.getProduct(indexPath: IndexPath(row: 0, section: 0))
        let product2 = list.addListProduct(section: 0, name: "Product", quantity: nil)
        let product3 = list.getProduct(indexPath: IndexPath(row: 0, section: 0))
        
        let product4 = list.getProduct(indexPath: IndexPath(row: 0, section: 1))
        let product5 = list.addListProduct(section: 1, name: "Product", quantity: nil)
        let product6 = list.getProduct(indexPath: IndexPath(row: 0, section: 1))
        
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
        
        let section = list.addSection(name: "Section")
        
        let product1 = list.addListProduct(section: 0, name: "Product 1", quantity: "1")
        let product2 = list.addListProduct(section: 0, name: "Product 2", quantity: "2")
        list.moveProduct(source: IndexPath(row: 0, section: 0), destination: IndexPath(row: 1, section: 0))
        list.removeProduct(indexPath: IndexPath(row: 0, section: 0))
        
        coreDataHelper.saveContext()
        
        waitForExpectations(timeout: 2.0) { error in
            
            XCTAssertNil(error, "Save did not occur")
            
            let newList = self.coreDataHelper.getLists().first
            let newSection = newList?.sections?.firstObject as! Section
            
            XCTAssertNotNil(newList)
            XCTAssertNotNil(newSection)
            XCTAssert(newList?.sections?.array as? [Section] == [newSection])
            XCTAssert(newSection.name == section.name)
            XCTAssert(newSection.products?.array as? [Product] == [product1!])
            XCTAssert(newSection.removedProducts?.array as? [Product] == [product2!])
            XCTAssert(newSection.name == "Section")
            XCTAssert(product1!.name == "Product 1")
            XCTAssert(product2!.name == "Product 2")
            XCTAssert(product1!.quantity == "1")
            XCTAssert(product2!.quantity == "2")
            
        }
    }
    
    func testStringConversion() {
        
        list.addSection(name: "Section 1")
        list.addSection(name: "Section 2")
        
        list.addListProduct(section: 0, name: "Product 1", quantity: "1")
        list.addListProduct(section: 0, name: "Product 2", quantity: "2")
        list.addListProduct(section: 1, name: "Product 3", quantity: "3")
        list.addListProduct(section: 1, name: "Product 4", quantity: "4")
        list.addListProduct(section: 1, name: "Product 5", quantity: "5")
        
        let result = list.toString()
        
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
        
        list.addSection(name: "Section 1")
        list.addSection(name: "Section 2")
        
        let product1 = list.addListProduct(section: 0, name: "Product 1", quantity: "1")
        let product2 = list.addListProduct(section: 0, name: "Product 2", quantity: "2")
        let product3 = list.addListProduct(section: 1, name: "Product 3", quantity: "3")
        let product4 = list.addListProduct(section: 1, name: "Product 4", quantity: "4")
        let product5 = list.addListProduct(section: 1, name: "Product 5", quantity: "5")
        
        let allReturned = list.searchProducts(text: "Product")
        let noneReturned = list.searchProducts(text: "Apples")
        let empty = list.searchProducts(text: "")
        let oneReturned = list.searchProducts(text: "Product 4")
        
        func isEqual(lhs: (Int, [Product]), rhs: (Int, [Product?])) -> Bool {
            return lhs.0 == rhs.0 && lhs.1 == rhs.1
        }
        
        XCTAssert(allReturned.elementsEqual([(0, [product1, product2]), (1, [product3, product4, product5])], by: isEqual(lhs:rhs:)))
        XCTAssertTrue(noneReturned.isEmpty)
        XCTAssert(empty.elementsEqual([(0, [product1, product2]), (1, [product3, product4, product5])], by: isEqual(lhs:rhs:)))
        XCTAssert(oneReturned.elementsEqual([(1, [product4])], by: isEqual(lhs:rhs:)))
        
    }

}
