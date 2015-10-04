//
//  DTTestTableViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 22.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager

class DTTestTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DTTableViewManageable {

    var tableView : UITableView! = UITableView()
    
    var beforeContentUpdateValue = false
    var afterContentUpdateValue = false
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.manager.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.manager.tableView(tableView, numberOfRowsInSection: section)
    }
}

extension DTTestTableViewController : DTTableViewContentUpdatable {
    func beforeContentUpdate() {
        beforeContentUpdateValue = true
    }
    
    func afterContentUpdate() {
        afterContentUpdateValue = true
    }
}
