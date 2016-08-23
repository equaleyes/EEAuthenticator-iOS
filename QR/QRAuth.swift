//
//  QRUtils.swift
//  QR
//
//  Created by Žan Skamljič on 17/08/16.
//  Copyright © 2016 Equaleyes. All rights reserved.
//

import Foundation

class QRAuth {
    private static let SAVE_KEY = "qr_auth.list"
    
    internal let label:     String
    private let secret:     String
    private let algorithm:  String
    private let digits:     UInt
    private let period:     NSTimeInterval
    
    var generator: OTPGenerator? {
        get {
            return TOTPGenerator(secret: secret, algorithm: algorithm, digits: digits, period: period)
        }
    }
    
    init?(string: String) {
        let url = NSURL(string: string)
        
        guard let scheme = url?.scheme,
            let host = url?.host,
            let label = url?.path,
            let query = url?.query
            where scheme == "otpauth" && host == "totp" else {
            return nil
        }
        
        self.label = label.substringFromIndex(label.startIndex.advancedBy(1))
        
        let parameters = QRAuth.parseParameters(query)
        
        guard let secret = parameters["secret"] else {
            return nil
        }
        
        self.secret = secret
        
        algorithm = parameters["algorithm"] ?? "SHA1"
        digits = UInt(parameters["digits"] ?? "") ?? 6
        period = NSTimeInterval(parameters["period"] ?? "") ?? 30
    }
    
    convenience init?(dict: [String: AnyObject]) {
        var dict = dict
        
        guard let label = dict["label"] as? String else {
                return nil
        }
        
        dict.removeValueForKey("label")
        
        let url = NSURL(string: "otpauth://totp/\(label)\(QRAuth.queryWith(dict))")
        
        self.init(string: url!.absoluteString)
    }
    
    func save() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var qrList = defaults.objectForKey(QRAuth.SAVE_KEY) as? [[String: AnyObject]] ?? [[String: AnyObject]]()
        
        var modified = false
        
        for i in 0..<qrList.count {
            if qrList[i]["secret"] as? String == secret {
                qrList[i]["label"] = label
                qrList[i]["algorithm"] = algorithm
                qrList[i]["digits"] = digits
                qrList[i]["period"] = period
                
                modified = true
                break
            }
        }
        
        if !modified {
            let newElement: [String: AnyObject] = [
                "label": label,
                "secret": secret,
                "algorithm": algorithm,
                "digits": digits,
                "period": period,
            ]
            
            qrList.append(newElement)
        }
        
        defaults.setObject(qrList, forKey: QRAuth.SAVE_KEY)
        defaults.synchronize()
    }
    
    func delete() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var qrList = defaults.objectForKey("qr_auth.list") as? [[String: AnyObject]] ?? [[String: AnyObject]]()
        
        var modified = -1
        
        for i in 0..<qrList.count {
            if qrList[i]["secret"] as? String == secret {
                modified = i
                break
            }
        }
        
        if modified != -1 {
            qrList.removeAtIndex(modified)
            defaults.setObject(qrList, forKey: QRAuth.SAVE_KEY)
            defaults.synchronize()
        }
    }
    
    static func load() -> [QRAuth] {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let qrList = defaults.objectForKey("qr_auth.list") as? [[String: AnyObject]] ?? [[String: AnyObject]]()
        
        var authArray = [QRAuth]()
        
        for qrItem in qrList {
            if let qrAuth = QRAuth(dict: qrItem) {
                authArray.append(qrAuth)
            }
        }
        
        return authArray
    }
    
    private static func parseParameters(query: String) -> [String: String] {
        let parts = query.characters.split { $0 == "&" }.map(String.init)
        
        var parameters = [String: String]()
        
        for part in parts {
            let keyValue = part.characters.split { $0 == "=" }.map(String.init)
            
            parameters[keyValue[0]] = keyValue[1]
        }
        
        return parameters
    }
    
    private static func queryWith(parameters: [String: AnyObject]) -> String {
        var string = ""
        
        for (key, value) in parameters {
            if string.characters.count == 0 {
                string += "?"
            } else {
                string += "&"
            }
            string += "\(key)=\(value)"
        }
        
        return string
    }
}