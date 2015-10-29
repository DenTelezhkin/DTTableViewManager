//
//  CreationTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 13.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
@testable import DTTableViewManager
import DTModelStorage
import Nimble

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
    
    func testConfigurationAssociation()
    {
        let foo = DTTestTableViewController(nibName: nil, bundle: nil)
        foo.manager.startManagingWithDelegate(foo)
        
        expect(foo.manager) != nil
        expect(foo.manager) == foo.manager // Test if lazily instantiating using associations works correctly
    }
    
    func testLoadFromXibChecksCorrectClassName() {
        let loadedView = StringCell.dt_loadFromXibNamed("NibCell", bundle: NSBundle(forClass: self.dynamicType))
        
        expect(loadedView).to(beNil())
    }
}