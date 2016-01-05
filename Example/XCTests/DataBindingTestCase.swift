//
//  DataBindingTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 05.01.16.
//  Copyright © 2016 Denys Telezhkin. All rights reserved.
//

import XCTest
@testable import DTTableViewManager
import DTModelStorage
import Nimble

class DataBindingViewController : UIViewController, DTTableViewManageable, UITableViewDelegate {
    var tableView : UITableView! = UITableView()
    var filledInWillDisplayCell = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.startManagingWithDelegate(self)
        manager.dataBindingBehaviour = .BeforeCellIsDisplayed
        manager.registerCellClass(NibCell)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if ((cell as? NibCell)?.model as? Int) == 3 {
            filledInWillDisplayCell = true
        }
    }
}

class DataBindingTestCase: XCTestCase {
    
    var controller : DataBindingViewController!
    
    override func setUp() {
        super.setUp()
        controller = DataBindingViewController()
        _ = controller.view
    }
    
    func testModelIsFilled() {
        controller.manager.memoryStorage.addItem(3)
        
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        
        expect((cell as? NibCell)?.model as? Int).to(beNil())
        controller.manager.tableView(controller.tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath(0,0))
        expect(self.controller.filledInWillDisplayCell).to(beTrue())
    }
    
}
