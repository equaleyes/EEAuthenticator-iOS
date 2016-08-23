//
//  QRTests.swift
//  QRTests
//
//  Created by Žan Skamljič on 17/08/16.
//  Copyright © 2016 Equaleyes. All rights reserved.
//

import XCTest
@testable import QR

class QRTests: XCTestCase {
    let SECRET = "TJVNOJIY72W4PLB2"
    let LABEL = "equaleyes:test@totp.com"
    let ALGORITHM = "SHA1"
    let DIGITS: UInt = 6
    let PERIOD: NSTimeInterval = 30
    
    override func setUp() {
        super.setUp()

    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitGenerator() {
        let generator = TOTPGenerator(secret: SECRET, algorithm: ALGORITHM, digits: DIGITS, period: PERIOD)
        
        XCTAssertNotNil(generator)
    }
    
    func testGeneration() {
        
        let generator = TOTPGenerator(secret: SECRET, algorithm: ALGORITHM, digits: DIGITS, period: PERIOD)
        
        XCTAssertNotNil(generator)
        
        let code = generator!.generateOTP()
        
        XCTAssertNotNil(code)
    }
    
    func testDictInit() {
        let params: [String: AnyObject] = [
            "label": LABEL,
            "secret": SECRET,
            "algorithm": ALGORITHM,
            "digits": DIGITS,
            "period": PERIOD,
        ]
        
        let qrAuth = QRAuth(dict: params)
        
        XCTAssertNotNil(qrAuth)
    }
}
