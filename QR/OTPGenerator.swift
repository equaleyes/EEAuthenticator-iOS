//
//  OTPGenerator.swift
//  QR
//
//  Created by Žan Skamljič on 22/08/16.
//  Copyright © 2016 Equaleyes. All rights reserved.
//

import Foundation

enum OTPGeneratorAlgorithm: String {
    case SHA1   = "SHA1"
    case SHA256 = "SHA256"
    case SHA512 = "SHA512"
    case SHAMD5 = "SHAMD5"
    
    var algorithm: CCHmacAlgorithm {
        switch(self) {
        case .SHA1:
            return CCHmacAlgorithm(kCCHmacAlgSHA1)
        case .SHA256:
            return CCHmacAlgorithm(kCCHmacAlgSHA256)
        case .SHA512:
            return CCHmacAlgorithm(kCCHmacAlgSHA512)
        case .SHAMD5:
            return CCHmacAlgorithm(kCCHmacAlgMD5)
        }
    }
    
    var hashLength: Int {
        switch(self) {
        case .SHA1:
            return Int(CC_SHA1_DIGEST_LENGTH)
        case .SHA256:
            return Int(CC_SHA256_DIGEST_LENGTH)
        case .SHA512:
            return Int(CC_SHA512_DIGEST_LENGTH)
        case .SHAMD5:
            return Int(CC_MD5_DIGEST_LENGTH)
        }
    }
}

class OTPGenerator {
    let pinModTable: [UInt32] = [
        0,
        10,
        100,
        1000,
        10000,
        100000,
        1000000,
        10000000,
        100000000,
    ]
    
    private let algorithm:  OTPGeneratorAlgorithm
    private let digits:     UInt
    private let secret:     String
    
    init?(secret: String, algorithm: String, digits: UInt) {
        self.secret = secret
        self.digits = digits
        
        guard let validAlgorithm = OTPGeneratorAlgorithm(rawValue: algorithm)
            where digits >= 6 && digits <= 8 && secret.characters.count > 0 else {
            return nil
        }
        
        self.algorithm = validAlgorithm
    }
    
    func generateOTPForCounter(counter: UInt64) -> String? {
        var counter = counter
        
        let algorithm = self.algorithm.algorithm
        let hashLength = self.algorithm.hashLength
        
        let hash = NSMutableData(length: hashLength)!
        
        counter = NSSwapHostLongLongToBig(counter)
        let counterData = NSData(bytes: &counter, length: sizeof(uint_fast64_t))
        
        let secretBytes = base32Decode(secret)! //[UInt8](secret.utf8)
        
        var ctx = CCHmacContext()        
        CCHmacInit(&ctx, algorithm, secretBytes, secretBytes.count)
        CCHmacUpdate(&ctx, counterData.bytes, counterData.length)
        CCHmacFinal(&ctx, hash.mutableBytes)
        
        var ptr = [Int8](count: hash.length, repeatedValue: 0)
        hash.getBytes(&ptr, length: hash.length)
        
        let offset: Int8 = ptr[hashLength - 1] & 0x0F
        
        ptr = Array(ptr[Int(offset)..<ptr.count])
        let truncData = NSData(bytes: ptr, length: 4)
        var truncInt: UInt32 = 0
        truncData.getBytes(&truncInt, length: sizeof(UInt32))
        
        let truncatedHash = NSSwapBigIntToHost(truncInt) & 0x7FFFFFFF
        
        let pinValue = truncatedHash % pinModTable[Int(digits)]
        
        return String(format: "%0*u", digits, pinValue)
    }
    
    func generateOTP() -> String? {
        return nil
    }
}