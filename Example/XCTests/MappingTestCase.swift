//
//  MappingTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 14.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import Nimble
import DTModelStorage
import DTTableViewManager

class MappingTestCase: XCTestCase {

    var controller : DTTestTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = DTTestTableViewController()
        controller.tableView = UITableView()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.viewBundle = NSBundle(forClass: self.dynamicType)
        controller.manager.storage = MemoryStorage()
    }

    func testShouldCreateCellFromCode()
    {
        controller.manager.registerCellClass(NiblessCell)
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        expect(self.controller.verifyItem(1, atIndexPath: indexPath(0, 0))) == true
        expect(self.controller.verifyItem(2, atIndexPath: indexPath(0, 0))) == false // Sanity check
        
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0)) as! NiblessCell
        
        expect(cell.awakedFromNib) == false
        expect(cell.inittedWithStyle) == true
    }
    
    func testOptionalUnwrapping()
    {
        controller.manager.registerCellClass(NiblessCell)
        
        let intOptional : Int? = 3
        controller.manager.memoryStorage.addItem(intOptional, toSection: 0)
        
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testSeveralLevelsOfOptionalUnwrapping()
    {
        controller.manager.registerCellClass(NiblessCell)
        
        let intOptional : Int?? = 3
        controller.manager.memoryStorage.addItem(intOptional, toSection: 0)
        
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testCellMappingFromNib()
    {
        controller.manager.registerCellClass(NibCell)
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        expect(self.controller.verifyItem(1, atIndexPath: indexPath(0, 0))) == true
        expect(self.controller.verifyItem(2, atIndexPath: indexPath(0, 0))) == false // Sanity check
        
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0)) as! NibCell
        
        expect(cell.awakedFromNib) == true
        expect(cell.inittedWithStyle) == false
    }
    
    func testCellMappingFromNibWithDifferentName()
    {
        controller.manager.registerNibNamed("RandomNibNameCell", forCellClass: BaseTestCell.self)
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        expect(self.controller.verifyItem(1, atIndexPath: indexPath(0, 0))) == true
        expect(self.controller.verifyItem(2, atIndexPath: indexPath(0, 0))) == false // Sanity check
        
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0)) as! BaseTestCell
        
        expect(cell.awakedFromNib) == true
        expect(cell.inittedWithStyle) == false
    }

    // MARK: TODO - Reevaluate this functionality in the future
    // Is there a reason to have optional cell mapping or not?
//    func testOptionalModelCellMapping()
//    {
//        controller.registerCellClass(OptionalIntCell)
//        
//        controller.memoryStorage.addItem(Optional(1), toSection: 0)
//        
//        expect(self.controller.verifyItem(1, atIndexPath: indexPath(0, 0))) == true
//    }
    
    func testHeaderViewMappingFromUIView()
    {
        controller.manager.registerHeaderClass(NibView)
        
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        let view = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0)
        expect(view).to(beAKindOf(NibView.self))
    }
    
    func testHeaderMappingFromHeaderFooterView()
    {
        controller.manager.registerHeaderClass(NibHeaderFooterView)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        let view = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0)
        expect(view).to(beAKindOf(NibHeaderFooterView.self))
    }
    
    func testFooterViewMappingFromUIView()
    {
        controller.manager.registerFooterClass(NibView)
        
        controller.manager.memoryStorage.setSectionFooterModels([1])
        let view = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0)
        expect(view).to(beAKindOf(NibView.self))
    }
    
    func testFooterMappingFromHeaderFooterView()
    {
        controller.manager.registerHeaderClass(ReactingHeaderFooterView)
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        let view = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0)
        expect(view).to(beAKindOf(ReactingHeaderFooterView.self))
    }
    
    func testHeaderViewShouldSupportNSStringModel()
    {
        controller.manager.registerNibNamed("NibHeaderFooterView", forHeaderClass: NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        expect(self.controller.manager.tableView(self.controller.tableView, viewForHeaderInSection: 0)).to(beAKindOf(NibHeaderFooterView))
    }
    
    func testNiblessHeaderRegistrationWorks() {
        controller.manager.registerNiblessHeaderClass(NiblessHeaderFooterView)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        let view = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0)
        expect(view).to(beAKindOf(NiblessHeaderFooterView.self))
    }
    
    func testNiblessFooterRegistrationWorks() {
        controller.manager.registerNiblessFooterClass(NiblessHeaderFooterView)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        let view = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0)
        expect(view).to(beAKindOf(NiblessHeaderFooterView.self))
    }
}
