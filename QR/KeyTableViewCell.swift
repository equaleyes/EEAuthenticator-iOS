//
//  KeyTableViewCell.swift
//  QR
//
//  Created by Žan Skamljič on 23/08/16.
//  Copyright © 2016 Equaleyes. All rights reserved.
//

import UIKit

class KeyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
    var generator: TOTPGenerator?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(timerTick), name: "timerTick", object: nil)
    }
    
    func setFromQRAuth(qrAuth: QRAuth) {
        generator = qrAuth.generator as? TOTPGenerator
        
        nameLabel.text = qrAuth.label
        codeLabel.text = generator?.generateOTP()
        timerTick()
    }
    
    func timerTick() {
        let timeNow = NSDate().timeIntervalSince1970
        
        guard let period = generator?.period else {
            return
        }
        
        let counter = 30 - Int(timeNow % period)
        
        timeLabel.text = "\(counter)"
        
        if counter == 30 {
            codeLabel.text = generator?.generateOTP()
        }
    }
}
