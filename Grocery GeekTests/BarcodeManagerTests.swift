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
    var found: XCTestExpectation!
    
    let code = "3614272049529"
    
    override func setUp()  {
        super.setUp()
        coreDataHelper = CoreDataTestHelper()
        barcodeManager = BarcodeManager(context: coreDataHelper.persistentContainer.viewContext)
        barcodeManager.delegate = self
        found = XCTestExpectation(description: "Barcode found")
        
    }

    override func tearDown()  {
        super.tearDown()
        coreDataHelper = nil
        barcodeManager = nil
        found = nil
        barcode = nil
    }
    
    func barcodeFound(barcode: Barcode) {
        self.barcode = barcode
        found.fulfill()
    }
    
    func testFindProductNewBarcode()  {
        
        barcodeManager.findProduct(code: code)
        
        wait(for: [found], timeout: 12.0)
            
        XCTAssertNotNil(barcode)
        XCTAssertNotNil(barcode!.barcode)
        XCTAssert(barcode!.barcode == code)
        XCTAssertNil(barcode!.name)
        XCTAssertNil(barcode!.quantity)
        
    }
    
    func testFindProductExistingBarcode() {
        
        barcodeManager.findProduct(code: code)
        
        wait(for: [found], timeout: 12.0)
        
        let barcode = self.barcode
        found = XCTestExpectation(description: "Barcode found")
        barcodeManager.findProduct(code: code)
        
        wait(for: [found], timeout: 12.0)
        
        XCTAssertNotNil(barcode)
        XCTAssertNotNil(self.barcode)
        XCTAssert(barcode == self.barcode)
        
    }
    
    func testSave() {
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataHelper.persistentContainer.viewContext) { _ in
            return true
        }
        
        barcodeManager.findProduct(code: code)
        
        wait(for: [found], timeout: 12.0)
        found = XCTestExpectation(description: "Barcode found")
        
        coreDataHelper.saveContext()
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
            
            var barcodeProducts = [Barcode]()
            
            do {
                barcodeProducts = try self.coreDataHelper.persistentContainer.viewContext.fetch(Barcode.fetchRequest())
            } catch {
                print("Could not fetch barcodes")
            }
            
            XCTAssertNotNil(barcodeProducts.first)
            XCTAssert(barcodeProducts.first == self.barcode)
            
        }
        
    }

}
