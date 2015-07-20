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
import ModelStorage
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
        controller.registerNibNamed("RandomNibNameCell", forCellType: BaseTestCell.self)
        
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
    
    
    func testHeaderViewMappingFromUIView()
    {
        controller.registerHeaderClass(NibView)
        
        controller.memoryStorage.setSectionHeaderModels([1])
        let view = controller.tableView(controller.tableView, viewForHeaderInSection: 0)
        expect(view).to(beAKindOf(NibView.self))
    }
    
    func testHeaderMappingFromHeaderFooterView()
    {
        controller.registerHeaderClass(NibHeaderFooterView)
        controller.memoryStorage.setSectionHeaderModels([1])
        let view = controller.tableView(controller.tableView, viewForHeaderInSection: 0)
        expect(view).to(beAKindOf(NibHeaderFooterView.self))
    }
    
    func testFooterViewMappingFromUIView()
    {
        controller.registerFooterClass(NibView)
        
        controller.memoryStorage.setSectionFooterModels([1])
        let view = controller.tableView(controller.tableView, viewForFooterInSection: 0)
        expect(view).to(beAKindOf(NibView.self))
    }
    
    func testFooterMappingFromHeaderFooterView()
    {
        controller.registerFooterClass(NibHeaderFooterView)
        controller.memoryStorage.setSectionFooterModels([1])
        let view = controller.tableView(controller.tableView, viewForFooterInSection: 0)
        expect(view).to(beAKindOf(NibHeaderFooterView.self))
    }
    
    class NSNumberCell : UITableViewCell, ModelTransfer {
        func updateWithModel(model: NSNumber) {}
    }
    
    func testShouldSupportFoundationNSNumber()
    {
        controller.registerCellClass(NSNumberCell)
        
        controller.memoryStorage.addItem(NSNumber(double: 1), toSection: 0)
        
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSNumberCell.self))
    }
    
    func testShouldSupportFoundationNSNumberBool()
    {
        controller.registerCellClass(NSNumberCell)
        controller.memoryStorage.addItem(NSNumber(bool: true), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSNumberCell.self))
    }
    
    class NSStringCell: UITableViewCell, ModelTransfer{
        func updateWithModel(model: NSString) {}
    }
    
    func testShouldSupportFoundationNSStringEmpty()
    {
        controller.registerCellClass(NSStringCell)
        controller.memoryStorage.addItem(NSString(), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSStringCell.self))
    }
    
    func testShouldSupportFoundationNSString()
    {
        controller.registerCellClass(NSStringCell)
        controller.memoryStorage.addItem(NSString(string: "dsf"), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSStringCell.self))
    }
    
    func testShouldSupportFoundationNSStringWithSwiftString()
    {
        controller.registerCellClass(NSStringCell)
        controller.memoryStorage.addItem("sdf", toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSStringCell.self))
    }
    
    func testShouldSupportFoundationNSStringWithNSMutableString()
    {
        controller.registerCellClass(NSStringCell)
        controller.memoryStorage.addItem(NSMutableString(string: "dsfdssf"), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSStringCell.self))
    }
    
    class NSAttributedStringCell: UITableViewCell, ModelTransfer{
        func updateWithModel(model: NSAttributedString) {}
    }
    
    func testShouldSupportFoundationNSStringWithNSAttributedString()
    {
        controller.registerCellClass(NSAttributedStringCell)
        controller.memoryStorage.addItem(NSAttributedString(string: "dsfdssf"), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSAttributedStringCell.self))
    }
    
    func testShouldSupportFoundationNSStringWithNSMutableAttributedString()
    {
        controller.registerCellClass(NSAttributedStringCell)
        controller.memoryStorage.addItem(NSMutableAttributedString(string: "dsfdssf"), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSAttributedStringCell.self))
    }
    
    class NSDictionaryCell: UITableViewCell, ModelTransfer{
        func updateWithModel(model: NSDictionary) {}
    }
    
    func testShouldSupportFoundationNSDictionary()
    {
        controller.registerCellClass(NSDictionaryCell)
        controller.memoryStorage.addItem(NSDictionary(), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSDictionaryCell.self))
    }
    
    func testShouldSupportFoundationNSDictionaryWithMutableDicationary()
    {
        controller.registerCellClass(NSDictionaryCell)
        controller.memoryStorage.addItem(NSMutableDictionary(), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSDictionaryCell.self))
    }
    
    class NSArrayCell: UITableViewCell, ModelTransfer{
        func updateWithModel(model: NSArray) {}
    }
    
    func testShouldSupportFoundationNSArray()
    {
        controller.registerCellClass(NSArrayCell)
        controller.memoryStorage.addItem(NSArray(), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSArrayCell.self))
    }
    
    func testShouldSupportFoundationNSArrayWithMutableNSArray()
    {
        controller.registerCellClass(NSArrayCell)
        controller.memoryStorage.addItem(NSMutableArray(), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSArrayCell.self))
    }
    
    class NSDateCell: UITableViewCell, ModelTransfer{
        func updateWithModel(model: NSDate) {}
    }
    
    func testShouldSupportFoundationNSDate()
    {
        controller.registerCellClass(NSDateCell)
        controller.memoryStorage.addItem(NSDate(), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSDateCell.self))
    }
    
    class NSSetCell : UITableViewCell, ModelTransfer {
        func updateWithModel(model: NSSet) {}
    }
    
    func testShouldSupportFoundationNSSet()
    {
        controller.registerCellClass(NSSetCell)
        controller.memoryStorage.addItem(NSSet(), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSSetCell.self))
    }
    
    func testShouldSupportFoundationNSSetWithMutableSet()
    {
        controller.registerCellClass(NSSetCell)
        controller.memoryStorage.addItem(NSMutableSet(), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSSetCell.self))
    }
    
    class NSOrderedSetCell : UITableViewCell, ModelTransfer {
        func updateWithModel(model: NSOrderedSet) {}
    }
    
    func testShouldSupportFoundationNSOrderedSet()
    {
        controller.registerCellClass(NSOrderedSetCell)
        controller.memoryStorage.addItem(NSOrderedSet(), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSOrderedSetCell.self))
    }
    
    func testShouldSupportFoundationNSOrderedSetWithMutableSet()
    {
        controller.registerCellClass(NSOrderedSetCell)
        controller.memoryStorage.addItem(NSMutableOrderedSet(), toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSOrderedSetCell.self))
    }
}
