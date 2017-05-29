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
    func update(with model: Int) {
        
    }
}

class OptionalTableViewController : UIViewController, DTTableViewOptionalManageable {
    var tableView: UITableView?
}

class CreationTestCase: XCTestCase {

    func testManagingWithOptionalTableViewWorks() {
        let controller = OptionalTableViewController()
        controller.tableView = UITableView()
        controller.manager.startManaging(withDelegate: controller)
        
        expect(controller.manager.isManagingTableView).to(beTrue())
    }
    
    func testCreatingTableControllerFromCode()
    {
        let controller = DTTestTableViewController()
        controller.manager.startManaging(withDelegate: controller)
        controller.manager.register(FooCell.self)
    }
    
    func testDelegateIsNotNil() {
        let controller = DTTestTableViewController()
        controller.manager.startManaging(withDelegate: controller)
        expect(controller.manager.storage.delegate != nil).to(beTrue())
    }
    
    func testDelegateIsNotNilForMemoryStorage() {
        let controller = DTTestTableViewController()
        controller.manager.startManaging(withDelegate: controller)
        expect(controller.manager.memoryStorage.delegate != nil).to(beTrue())
    }
    
    func testSwitchingStorages() {
        let controller = DTTestTableViewController()
        let first = MemoryStorage()
        let second = MemoryStorage()
        controller.manager.storage = first
        expect(first.delegate === controller.manager.tableViewUpdater).to(beTrue())
        
        controller.manager.storage = second
        
        expect(first.delegate == nil).to(beTrue())
        expect(second.delegate === controller.manager.tableViewUpdater).to(beTrue())
    }
    
    func testCreatingTableControllerFromXIB()
    {
        let controller = XibTableViewController(nibName: "XibTableViewController", bundle: Bundle(for: type(of: self)))
        let _ = controller.view
        controller.manager.startManaging(withDelegate: controller)
        controller.manager.register(FooCell.self)
    }
    
    func testConfigurationAssociation()
    {
        let foo = DTTestTableViewController(nibName: nil, bundle: nil)
        foo.manager.startManaging(withDelegate: foo)
        
        expect(foo.manager).toNot(beNil())
        expect(foo.manager) == foo.manager // Test if lazily instantiating using associations works correctly
    }
    
    func testManagerSetter()
    {
        let manager = DTTableViewManager()
        let foo = DTTestTableViewController(nibName: nil, bundle: nil)
        foo.manager = manager
        foo.manager.startManaging(withDelegate: foo)
        
        expect(foo.manager === manager).to(beTruthy())
    }
    
    func testLoadFromXibChecksCorrectClassName() {
        let loadedView = StringCell.dt_loadFromXibNamed("NibCell")
        
        expect(loadedView).to(beNil())
    }
}
