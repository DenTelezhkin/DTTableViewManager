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

class FooCell : UITableViewCell, ModelTransfer
{
    func update(with model: Int) {
        
    }
}

class OptionalTableViewController : UIViewController, DTTableViewManageable {
    var optionalTableView: UITableView?
}

class CreationTestCase: XCTestCase {

    func testManagingWithOptionalTableViewWorks() {
        let controller = OptionalTableViewController()
        controller.optionalTableView = UITableView()
        
        XCTAssert(controller.manager.isManagingTableView)
    }
    
    func testCreatingTableControllerFromCode()
    {
        let controller = DTTestTableViewController()
        controller.manager.register(FooCell.self)
    }
    
    func testDelegateIsNotNil() {
        let controller = DTTestTableViewController()
        XCTAssertNotNil((controller.manager.storage as? BaseUpdateDeliveringStorage)?.delegate)
    }
    
    func testDelegateIsNotNilForMemoryStorage() {
        let controller = DTTestTableViewController()
        XCTAssertNotNil(controller.manager.memoryStorage.delegate)
    }
    
    func testSwitchingStorages() {
        let controller = DTTestTableViewController()
        let first = MemoryStorage()
        let second = MemoryStorage()
        controller.manager.storage = first
        XCTAssert(first.delegate === controller.manager.tableViewUpdater)
        
        controller.manager.storage = second
        
        XCTAssertNil(first.delegate)
        XCTAssert(second.delegate === controller.manager.tableViewUpdater)
    }
    
    func testCreatingTableControllerFromXIB()
    {
        let controller = XibTableViewController(nibName: "XibTableViewController", bundle: Bundle(for: type(of: self)))
        let _ = controller.view
        controller.manager.register(FooCell.self)
    }
    
    func testConfigurationAssociation()
    {
        let foo = DTTestTableViewController(nibName: nil, bundle: nil)
        
        XCTAssertNotNil(foo.manager)
        XCTAssert(foo.manager === foo.manager) // Test if lazily instantiating using associations works correctly
    }
    
    func testManagerSetter()
    {
        let manager = DTTableViewManager()
        let foo = DTTestTableViewController(nibName: nil, bundle: nil)
        foo.manager = manager
        
        XCTAssert(foo.manager === manager)
    }
    
    func testCallingStartManagingMethodIsNotRequired() {
        let controller = DTTestTableViewController()
        controller.manager.register(NibCell.self)
        controller.manager.memoryStorage.addItem(3)
    }
}
