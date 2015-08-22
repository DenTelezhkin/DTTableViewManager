//
//  CreationTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 13.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTTableViewManager
import ModelStorage

class FooCell : UITableViewCell, ModelTransfer
{
    func updateWithModel(model: Int) {
        
    }
}

class CreationTestCase: XCTestCase {

    func testCreatingTableControllerFromCode()
    {
        let controller = DTTestTableViewController()
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.registerCellClass(FooCell)
    }
    
    func testCreatingTableControllerFromXIB()
    {
        let controller = XibTableViewController(nibName: "XibTableViewController", bundle: NSBundle(forClass: self.dynamicType))
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.registerCellClass(FooCell)
    }
}