//
//  DelegateForwardingTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 29.10.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage
@testable import DTTableViewManager
import Nimble

class DelegateTableViewController: DTTestTableViewController {
    var headerHeightRequested = false
    var footerHeightRequested = false
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerHeightRequested = true
        return 44
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        footerHeightRequested = true
        return 44
    }
}

class DelegateForwardingTestCase: XCTestCase {
    
    var controller : DelegateTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = DelegateTableViewController()
        controller.manager.startManagingWithDelegate(controller)
    }
    
    func testHeaderHeightIsRequested() {
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        let _ = controller.manager.tableView(controller.tableView, heightForHeaderInSection:  0)
        expect(self.controller.headerHeightRequested).to(beTrue())
    }
    
    func testFooterHeightIsRequested() {
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        let _ = controller.manager.tableView(controller.tableView, heightForFooterInSection:  0)
        expect(self.controller.footerHeightRequested).to(beTrue())
    }
}
