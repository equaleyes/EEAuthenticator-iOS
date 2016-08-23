//
//  TOTPGenerator.swift
//  QR
//
//  Created by Žan Skamljič on 22/08/16.
//  Copyright © 2016 Equaleyes. All rights reserved.
//

import Foundation

class TOTPGenerator: OTPGenerator {
    let period: NSTimeInterval
    
    init?(secret: String, algorithm: String, digits: UInt, period: NSTimeInterval) {
        guard period > 0 && period <= 300 else {
            return nil
        }
        
        self.period = period
        
        super.init(secret: secret, algorithm: algorithm, digits: digits)
    }
    
    override func generateOTP() -> String? {
        return generateOTPForDate(NSDate())
    }
    
    func generateOTPForDate(date: NSDate) -> String? {
        let seconds = date.timeIntervalSince1970
        
        let counter = uint_fast64_t(seconds / period)
        
        return super.generateOTPForCounter(counter)
    }
}