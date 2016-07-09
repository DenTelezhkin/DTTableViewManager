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
        manager.dataBindingBehaviour = .beforeCellIsDisplayed
        manager.registerCellClass(NibCell.self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
        
        let cell = controller.manager.tableView(controller.tableView, cellForRowAt: indexPath(0, 0))
        
        expect((cell as? NibCell)?.model as? Int).to(beNil())
        controller.manager.tableView(controller.tableView, willDisplay: cell, forRowAt: indexPath(0,0))
        expect(self.controller.filledInWillDisplayCell).to(beTrue())
    }
    
}
