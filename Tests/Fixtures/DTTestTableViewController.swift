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

    @IBOutlet var tableView : UITableView! = UITableView()
    
    var beforeContentUpdateValue = false
    var afterContentUpdateValue = false
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.manager.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
