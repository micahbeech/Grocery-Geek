//
//  Grocery_GeekTests.swift
//  Grocery GeekTests
//
//  Created by Micah Beech on 2020-09-25.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import XCTest
@testable import Grocery_Geek
import CoreData

class ListTableManagerTests : XCTestCase {

    var listManager: ListTableManager!
    var coreDataHelper: CoreDataTestHelper!
    
    override func setUp()  {
        super.setUp()
        coreDataHelper = CoreDataTestHelper()
        listManager = ListTableManager(context: coreDataHelper.persistentContainer.viewContext)
        
    }

    override func tearDown()  {
        super.tearDown()
        coreDataHelper = nil
        listManager = nil
    }
    
    func testAddList() {
        
        let list = listManager.addList(name: "Test list")
        
        XCTAssertNotNil(list, "list should not be nil")
        XCTAssertNotNil(list.name, "list name should not be nil")
        XCTAssertNotNil(list.id, "id should not be nil")
        XCTAssertNotNil(list.sections, "current products should not be nil")
        XCTAssert(list.name == "Test list")
        XCTAssert(list.index == 0)
        XCTAssert(list.sections!.count == 1)
        XCTAssert((list.sections!.firstObject as! Section).name == "Items")
        
    }
    
    func testRemoveListFailure() {
        
        let result = listManager.removeList(index: 0)
        
        XCTAssertFalse(result)
        
    }
    
    func testRemoveList() {
        
        listManager.addList(name: "Test list")
        let result = listManager.removeList(index: 0)
        
        XCTAssertTrue(result)
        XCTAssert(listManager.lists.isEmpty)
        
    }
    
    func testEditList() {
        
        let list = listManager.addList(name: "Test list")
        let index = list.index
        let sections = list.sections
        
        listManager.updateList(list: list, name: "Test")
        
        XCTAssert(list.name == "Test")
        XCTAssert(list.index == index)
        XCTAssert(list.sections == sections)
        
    }
    
    func testGetList() {
        
        let list1 = listManager.getList(index: 0)
        let list2 = listManager.addList(name: "Test list")
        let list3 = listManager.getList(index: 0)
        
        XCTAssertNil(list1)
        XCTAssertNotNil(list2)
        XCTAssertNotNil(list3)
        XCTAssert(list2 == list3)
    }
    
    func testSize() {
        
        let empty1 = listManager.size()
        
        listManager.addList(name: "Test list")
        let one = listManager.size()
        
        listManager.addList(name: "Test list")
        let two = listManager.size()
        
        listManager.removeList(index: 0)
        listManager.removeList(index: 0)
        let empty2 = listManager.size()
        
        XCTAssert(empty1 == 0)
        XCTAssert(one == 1)
        XCTAssert(two == 2)
        XCTAssert(empty2 == 0)
        
    }
    
    func testMoveListFailure() {
        
        let result = listManager.moveList(start: 0, end: 1)
        
        XCTAssertFalse(result)
        
    }
    
    func testMoveList() {
        
        let list1 = listManager.addList(name: "List 1")
        let list2 = listManager.addList(name: "List 2")
        let list3 = listManager.addList(name: "List 3")
        
        let original = listManager.lists
        
        let result1 = listManager.moveList(start: 0, end: 2)
        let result2 = listManager.moveList(start: 1, end: 0)
        
        XCTAssertTrue(result1)
        XCTAssertTrue(result2)
        XCTAssert(original == [list1, list2, list3])
        XCTAssert(listManager.lists == [list3, list2, list1])
        XCTAssert(list1.index == 2)
        XCTAssert(list2.index == 1)
        XCTAssert(list3.index == 0)
        
    }
    
    func testInit() {
        
        listManager.addList(name: "List 1")
        listManager.addList(name: "List 2")
        listManager.addList(name: "List 3")
        listManager.moveList(start: 0, end: 2)
        listManager.addList(name: "List 4")
        listManager.removeList(index: 1)
        
        coreDataHelper.saveContext()
    
        let newManager = ListTableManager(context: coreDataHelper.persistentContainer.viewContext)
        
        XCTAssert(newManager.lists == self.listManager.lists)
        
    }
    
    func testInitEmpty() {
        
        XCTAssert(listManager.lists.isEmpty)
        
    }
    
    func testSave() {
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataHelper.persistentContainer.viewContext) { _ in
            return true
        }
        
        listManager.addList(name: "Test list")
        coreDataHelper.saveContext()
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }

}
