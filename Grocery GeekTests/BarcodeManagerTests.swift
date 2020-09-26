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

class BarcodeManagerTests : XCTestCase {

    var barcodeManager: BarcodeManager!
    var coreDataHelper: CoreDataTestHelper!
    
    override func setUp()  {
        super.setUp()
        coreDataHelper = CoreDataTestHelper()
        barcodeManager = BarcodeManager(context: coreDataHelper.persistentContainer.viewContext)
        
    }

    override func tearDown()  {
        super.tearDown()
        coreDataHelper = nil
        barcodeManager = nil
    }
    
    func testFindProductNewBarcode() {
        
        let code = UUID().uuidString
        
        let barcode = barcodeManager.findProduct(code: code)
        
        XCTAssertNotNil(barcode)
        XCTAssertNotNil(barcode.barcode)
        XCTAssert(barcode.barcode == code)
        XCTAssertNil(barcode.name)
        XCTAssertNil(barcode.quantity)
        
    }
    
    func testFindProductExistingBarcode() {
        
        let code = UUID().uuidString
        
        let barcode1 = barcodeManager.findProduct(code: code)
        let barcode2 = barcodeManager.findProduct(code: code)
        
        XCTAssertNotNil(barcode1)
        XCTAssertNotNil(barcode2)
        XCTAssert(barcode1 == barcode2)
        
    }

}
