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
        controller.manager.registerNibNamed("RandomNibNameCell", forCellType: BaseTestCell.self)
        
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
        controller.manager.registerNibNamed("NibHeaderFooterView", forHeaderType: NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        expect(self.controller.manager.tableView(self.controller.tableView, viewForHeaderInSection: 0)).to(beAKindOf(NibHeaderFooterView))
    }
    
    class NSNumberCell : UITableViewCell, ModelTransfer {
        func updateWithModel(model: NSNumber) {}
    }
    
    func testShouldSupportFoundationNSNumber()
    {
        controller.manager.registerCellClass(NSNumberCell)
        
        controller.manager.memoryStorage.addItem(NSNumber(double: 1), toSection: 0)
        
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSNumberCell.self))
    }
    
    func testShouldSupportFoundationNSNumberBool()
    {
        controller.manager.registerCellClass(NSNumberCell)
        controller.manager.memoryStorage.addItem(NSNumber(bool: true), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSNumberCell.self))
    }
    
    class NSStringCell: UITableViewCell, ModelTransfer{
        func updateWithModel(model: NSString) {}
    }
    
    func testShouldSupportFoundationNSStringEmpty()
    {
        controller.manager.registerCellClass(NSStringCell)
        controller.manager.memoryStorage.addItem(NSString(), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSStringCell.self))
    }
    
    func testShouldSupportFoundationNSString()
    {
        controller.manager.registerCellClass(NSStringCell)
        controller.manager.memoryStorage.addItem(NSString(string: "dsf"), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSStringCell.self))
    }
    
    func testShouldSupportFoundationNSStringWithSwiftString()
    {
        controller.manager.registerCellClass(NSStringCell)
        controller.manager.memoryStorage.addItem("sdf" as NSString, toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSStringCell.self))
    }
    
    func testShouldSupportFoundationNSStringWithNSMutableString()
    {
        controller.manager.registerCellClass(NSStringCell)
        controller.manager.memoryStorage.addItem(NSMutableString(string: "dsfdssf"), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSStringCell.self))
    }
    
    class NSAttributedStringCell: UITableViewCell, ModelTransfer{
        func updateWithModel(model: NSAttributedString) {}
    }
    
    func testShouldSupportFoundationNSStringWithNSAttributedString()
    {
        controller.manager.registerCellClass(NSAttributedStringCell)
        controller.manager.memoryStorage.addItem(NSAttributedString(string: "dsfdssf"), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSAttributedStringCell.self))
    }
    
    func testShouldSupportFoundationNSStringWithNSMutableAttributedString()
    {
        controller.manager.registerCellClass(NSAttributedStringCell)
        controller.manager.memoryStorage.addItem(NSMutableAttributedString(string: "dsfdssf"), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSAttributedStringCell.self))
    }
    
    class NSDictionaryCell: UITableViewCell, ModelTransfer{
        func updateWithModel(model: NSDictionary) {}
    }
    
    func testShouldSupportFoundationNSDictionary()
    {
        controller.manager.registerCellClass(NSDictionaryCell)
        controller.manager.memoryStorage.addItem(NSDictionary(), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSDictionaryCell.self))
    }
    
    func testShouldSupportFoundationNSDictionaryWithMutableDicationary()
    {
        controller.manager.registerCellClass(NSDictionaryCell)
        controller.manager.memoryStorage.addItem(NSMutableDictionary(), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSDictionaryCell.self))
    }
    
    class NSArrayCell: UITableViewCell, ModelTransfer{
        func updateWithModel(model: NSArray) {}
    }
    
    func testShouldSupportFoundationNSArray()
    {
        controller.manager.registerCellClass(NSArrayCell)
        controller.manager.memoryStorage.addItem(NSArray(), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSArrayCell.self))
    }
    
    func testShouldSupportFoundationNSArrayWithMutableNSArray()
    {
        controller.manager.registerCellClass(NSArrayCell)
        controller.manager.memoryStorage.addItem(NSMutableArray(), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSArrayCell.self))
    }
    
    class NSDateCell: UITableViewCell, ModelTransfer{
        func updateWithModel(model: NSDate) {}
    }
    
    func testShouldSupportFoundationNSDate()
    {
        controller.manager.registerCellClass(NSDateCell)
        controller.manager.memoryStorage.addItem(NSDate(), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSDateCell.self))
    }
    
    class NSSetCell : UITableViewCell, ModelTransfer {
        func updateWithModel(model: NSSet) {}
    }
    
    func testShouldSupportFoundationNSSet()
    {
        controller.manager.registerCellClass(NSSetCell)
        controller.manager.memoryStorage.addItem(NSSet(), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSSetCell.self))
    }
    
    func testShouldSupportFoundationNSSetWithMutableSet()
    {
        controller.manager.registerCellClass(NSSetCell)
        controller.manager.memoryStorage.addItem(NSMutableSet(), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSSetCell.self))
    }
    
    class NSOrderedSetCell : UITableViewCell, ModelTransfer {
        func updateWithModel(model: NSOrderedSet) {}
    }
    
    func testShouldSupportFoundationNSOrderedSet()
    {
        controller.manager.registerCellClass(NSOrderedSetCell)
        controller.manager.memoryStorage.addItem(NSOrderedSet(), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSOrderedSetCell.self))
    }
    
    func testShouldSupportFoundationNSOrderedSetWithMutableSet()
    {
        controller.manager.registerCellClass(NSOrderedSetCell)
        controller.manager.memoryStorage.addItem(NSMutableOrderedSet(), toSection: 0)
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        expect(cell).to(beAKindOf(NSOrderedSetCell.self))
    }
}
