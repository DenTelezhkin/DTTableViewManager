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
    
    func testDelegateIsNotNil() {
        let controller = DTTestTableViewController()
        controller.manager.startManagingWithDelegate(controller)
        expect(controller.manager.storage.delegate != nil).to(beTrue())
    }
    
    func testDelegateIsNotNilForMemoryStorage() {
        let controller = DTTestTableViewController()
        controller.manager.startManagingWithDelegate(controller)
        expect(controller.manager.memoryStorage.delegate != nil).to(beTrue())
    }
    
    func testSwitchingStorages() {
        let controller = DTTestTableViewController()
        let first = MemoryStorage()
        let second = MemoryStorage()
        controller.manager.storage = first
        expect(first.delegate === controller.manager).to(beTrue())
        
        controller.manager.storage = second
        
        expect(first.delegate == nil).to(beTrue())
        expect(second.delegate === controller.manager).to(beTrue())
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
    
    func testManagerSetter()
    {
        let manager = DTTableViewManager()
        let foo = DTTestTableViewController(nibName: nil, bundle: nil)
        foo.manager = manager
        foo.manager.startManagingWithDelegate(foo)
        
        expect(foo.manager === manager)
    }
    
    func testLoadFromXibChecksCorrectClassName() {
        let loadedView = StringCell.dt_loadFromXibNamed("NibCell", bundle: NSBundle(forClass: self.dynamicType))
        
        expect(loadedView).to(beNil())
    }
}