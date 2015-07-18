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

    var controller : DTTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = DTTableViewController()
        controller.tableView = UITableView()
        let _ = controller.view
        controller.storage = MemoryStorage()
    }

    func testShouldCreateCellFromCode()
    {
        controller.registerCellClass(NiblessCell)
        
        controller.memoryStorage.addItem(1, toSection: 0)
        
        expect(self.controller.verifyItem(1, atIndexPath: indexPath(0, 0))) == true
        expect(self.controller.verifyItem(2, atIndexPath: indexPath(0, 0))) == false // Sanity check
        
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0)) as! NiblessCell
        
        expect(cell.awakedFromNib) == false
        expect(cell.inittedWithStyle) == true
    }
    
    func testOptionalUnwrapping()
    {
        controller.registerCellClass(NiblessCell)
        
        let intOptional : Int? = 3
        controller.memoryStorage.addItem(intOptional, toSection: 0)
        
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testSeveralLevelsOfOptionalUnwrapping()
    {
        controller.registerCellClass(NiblessCell)
        
        let intOptional : Int?? = 3
        controller.memoryStorage.addItem(intOptional, toSection: 0)
        
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testCellMappingFromNib()
    {
        controller.registerCellClass(NibCell)
        
        controller.memoryStorage.addItem(1, toSection: 0)
        
        expect(self.controller.verifyItem(1, atIndexPath: indexPath(0, 0))) == true
        expect(self.controller.verifyItem(2, atIndexPath: indexPath(0, 0))) == false // Sanity check
        
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0)) as! NibCell
        
        expect(cell.awakedFromNib) == true
        expect(cell.inittedWithStyle) == false
    }
    
    func testCellMappingFromNibWithDifferentName()
    {
        controller.registerNibName("RandomNibNameCell", cellType: BaseTestCell.self)
        
        controller.memoryStorage.addItem(1, toSection: 0)
        
        expect(self.controller.verifyItem(1, atIndexPath: indexPath(0, 0))) == true
        expect(self.controller.verifyItem(2, atIndexPath: indexPath(0, 0))) == false // Sanity check
        
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0)) as! BaseTestCell
        
        expect(cell.awakedFromNib) == true
        expect(cell.inittedWithStyle) == false
    }

    // MARK: TODO - Reealuate this functionality in the future
    // Is there a reason to have optional cell mapping or not?
//    func testOptionalModelCellMapping()
//    {
//        controller.registerCellClass(OptionalIntCell)
//        
//        controller.memoryStorage.addItem(Optional(1), toSection: 0)
//        
//        expect(self.controller.verifyItem(1, atIndexPath: indexPath(0, 0))) == true
//    }
    
    // MARK: TODO in Swift 2, with testables, check that mapping cannot be added twice
}
