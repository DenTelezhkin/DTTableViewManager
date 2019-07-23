//
//  BaseTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 7/23/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
//

import XCTest

class BaseTestCase: XCTestCase {
    
    var controller : DTTestTableViewController!

    override func setUp() {
        super.setUp()
        
        controller = DTTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
    }
}
