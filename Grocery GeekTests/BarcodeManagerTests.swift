//
//  BarcodeManagerTests.swift
//  Grocery GeekTests
//
//  Created by Micah Beech on 2020-09-26.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import XCTest
@testable import Grocery_Geek
import CoreData

class BarcodeManagerTests : XCTestCase, BarcodeManagerDelegate {

    var barcodeManager: BarcodeManager!
    var coreDataHelper: CoreDataTestHelper!
    
    var barcode: Barcode?
    var expectation: XCTestExpectation!
    
    let code = "3614272049529"
    
    override func setUp()  {
        super.setUp()
        coreDataHelper = CoreDataTestHelper()
        barcodeManager = BarcodeManager(context: coreDataHelper.persistentContainer.viewContext)
        barcodeManager.delegate = self
        expectation = XCTestExpectation(description: "Barcode found")
        
    }

    override func tearDown()  {
        super.tearDown()
        coreDataHelper = nil
        barcodeManager = nil
        expectation = nil
        barcode = nil
    }
    
    func barcodeFound(barcode: Barcode) {
        self.barcode = barcode
        expectation.fulfill()
    }
    
    func testFindProductNewBarcode() {
        
        barcodeManager.findProduct(code: code)
        
        wait(for: [expectation], timeout: 12.0)
            
        XCTAssertNotNil(barcode)
        XCTAssertNotNil(barcode!.barcode)
        XCTAssert(barcode!.barcode == code)
        XCTAssert(barcode!.name == "Volupté Tint-in-Balm - Summer Look 2018")
        XCTAssertNil(barcode!.quantity)
        
    }
    
    func testFindProductExistingBarcode() {
        
        barcodeManager.findProduct(code: code)
        
        wait(for: [expectation], timeout: 12.0)
        
        let barcode = self.barcode
        expectation = XCTestExpectation(description: "Barcode found")
        barcodeManager.findProduct(code: code)
        
        wait(for: [expectation], timeout: 12.0)
        
        XCTAssertNotNil(barcode)
        XCTAssertNotNil(self.barcode)
        XCTAssert(barcode == self.barcode)
        
    }
    
    func testSave() {
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataHelper.persistentContainer.viewContext) { _ in
            return true
        }
        
        let code = UUID().uuidString
        barcodeManager.findProduct(code: code)
        
        wait(for: [expectation], timeout: 12.0)
        expectation = XCTestExpectation(description: "Barcode found")
        let barcode = self.barcode
        
        coreDataHelper.saveContext()
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
            
            let newManager = BarcodeManager(context: self.coreDataHelper.persistentContainer.viewContext)
            newManager.findProduct(code: code)
            
            self.wait(for: [self.expectation], timeout: 12.0)
            
            XCTAssertNotNil(self.barcode)
            XCTAssert(barcode == self.barcode)
            
        }
        
    }

}
