//
//  KeyTableViewController.swift
//  QR
//
//  Created by Žan Skamljič on 23/08/16.
//  Copyright © 2016 Equaleyes. All rights reserved.
//

import UIKit

class KeyTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var authCodes: [QRAuth]!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        authCodes = QRAuth.load()
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        
        self.navigationController?.navigationBar.hidden = true
    }

    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authCodes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("authCell", forIndexPath: indexPath) as! KeyTableViewCell
        cell.setFromQRAuth(authCodes[indexPath.row])
        
        return cell
    }
    
    // MARK: - TableViewDelegate 
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        authCodes[indexPath.row].delete()
        authCodes.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    // MARK: - Additional helpers
    
    func timerTick() {
        NSNotificationCenter.defaultCenter().postNotificationName("timerTick", object: nil)
    }
}
