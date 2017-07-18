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
@testable import DTTableViewManager

class MappingTestCase: XCTestCase {

    var controller : DTTestTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = DTTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        controller.manager.startManaging(withDelegate: controller)
        controller.manager.storage = MemoryStorage()
    }

    func testShouldCreateCellFromCode()
    {
        controller.manager.register(NiblessCell.self)
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        let cell: NiblessCell
        if #available(iOS 11, *) {
            controller.tableView.beginUpdates()
            controller.tableView.endUpdates()
            
            cell = controller.tableView.cellForRow(at: indexPath(0, 0)) as! NiblessCell
        } else {
            cell = controller.manager.tableView(controller.tableView, cellForRowAt: indexPath(0, 0)) as! NiblessCell
        }
        
        expect(cell.model as? Int) == 1
        expect(cell.awakedFromNib) == false
        expect(cell.inittedWithStyle) == true
    }
    
    func testOptionalUnwrapping()
    {
        controller.manager.register(NiblessCell.self)
        
        let intOptional : Int? = 3
        controller.manager.memoryStorage.addItem(intOptional, toSection: 0)
        
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testSeveralLevelsOfOptionalUnwrapping()
    {
        controller.manager.register(NiblessCell.self)
        
        let intOptional : Int?? = 3
        controller.manager.memoryStorage.addItem(intOptional, toSection: 0)
        
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testCellMappingFromNib()
    {
        controller.manager.register(NibCell.self)
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        let cell: NibCell
        if #available(iOS 11, *) {
            controller.tableView.beginUpdates()
            controller.tableView.endUpdates()
            
            cell = controller.tableView.cellForRow(at: indexPath(0, 0)) as! NibCell
        } else {
            cell = controller.manager.tableView(controller.tableView, cellForRowAt: indexPath(0, 0)) as! NibCell
        }
        
        expect(cell.model as? Int) == 1
        expect(cell.awakedFromNib) == true
        expect(cell.inittedWithStyle) == false
    }
    
    func testCellMappingFromNibWithDifferentName()
    {
        controller.manager.registerNibNamed("RandomNibNameCell", for: BaseTestCell.self)
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        let cell: BaseTestCell
        if #available(iOS 11, tvOS 11, *) {
            controller.tableView.beginUpdates()
            controller.tableView.endUpdates()
            
            cell = controller.tableView.cellForRow(at: indexPath(0, 0)) as! BaseTestCell
        } else {
            cell = controller.manager.tableView(controller.tableView, cellForRowAt: indexPath(0, 0)) as! BaseTestCell
        }
        
        expect(cell.model as? Int) == 1
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
        controller.manager.registerHeader(NibView.self)
        
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        let view = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0)
        expect(view).to(beAKindOf(NibView.self))
    }
    
    func testHeaderMappingFromHeaderFooterView()
    {
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        let view = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0)
        expect(view).to(beAKindOf(NibHeaderFooterView.self))
    }
    
    func testFooterViewMappingFromUIView()
    {
        controller.manager.registerFooter(NibView.self)
        
        controller.manager.memoryStorage.setSectionFooterModels([1])
        let view = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0)
        expect(view).to(beAKindOf(NibView.self))
    }
    
    func testFooterMappingFromHeaderFooterView()
    {
        controller.manager.registerHeader(ReactingHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        let view = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0)
        expect(view).to(beAKindOf(ReactingHeaderFooterView.self))
    }
    
    func testHeaderViewShouldSupportNSStringModel()
    {
        controller.manager.registerNibNamed("NibHeaderFooterView", forHeader: NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        expect(self.controller.manager.tableView(self.controller.tableView, viewForHeaderInSection: 0)).to(beAKindOf(NibHeaderFooterView.self))
    }
    
    func testNiblessHeaderRegistrationWorks() {
        controller.manager.registerNiblessHeader(NiblessHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        let view = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0)
        expect(view).to(beAKindOf(NiblessHeaderFooterView.self))
    }
    
    func testNiblessFooterRegistrationWorks() {
        controller.manager.registerNiblessFooter(NiblessHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        let view = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0)
        expect(view).to(beAKindOf(NiblessHeaderFooterView.self))
    }
    
    func testUnregisterCellClass() {
        controller.manager.register(NibCell.self)
        controller.manager.unregister(NibCell.self)
        
        expect(self.controller.manager.viewFactory.mappings.count) == 0
    }
    
    func testUnregisterHeaderClass() {
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.unregisterHeader(NibHeaderFooterView.self)
        
        expect(self.controller.manager.viewFactory.mappings.count) == 0
    }
    
    func testUnregisterFooterClass() {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.unregisterFooter(NibHeaderFooterView.self)
        
        expect(self.controller.manager.viewFactory.mappings.count) == 0
    }
    
    func testUnregisterHeaderClassDoesNotUnregisterCell() {
        controller.manager.register(NibCell.self)
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.unregisterHeader(NibCell.self)
        
        expect(self.controller.manager.viewFactory.mappings.count) == 2
    }
    
    func testUnregisteringHeaderDoesNotUnregisterFooter() {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.unregisterHeader(NibHeaderFooterView.self)
        
        expect(self.controller.manager.viewFactory.mappings.count) == 1
    }
}

class NibNameViewModelMappingTestCase : XCTestCase {
    var factory : TableViewFactory!
    
    override func setUp() {
        super.setUp()
        factory = TableViewFactory(tableView: UITableView())
    }
    
    func testRegisterCellWithoutNibYieldsNoXibName() {
        factory.registerCellClass(NiblessCell.self, mappingBlock: nil)
        
        expect(self.factory.mappings.first?.xibName).to(beNil())
    }
    
    func testCellWithXibHasXibNameInMapping() {
        factory.registerCellClass(NibCell.self, mappingBlock: nil)
        
        expect(self.factory.mappings.first?.xibName) == "NibCell"
    }
    
    func testHeaderHasXibInMapping() {
        factory.registerHeaderClass(NibHeaderFooterView.self, mappingBlock: nil)
        
        expect(self.factory.mappings.first?.xibName) == "NibHeaderFooterView"
    }
    
    func testFooterHasXibInMapping() {
        factory.registerFooterClass(NibHeaderFooterView.self, mappingBlock: nil)
        
        expect(self.factory.mappings.first?.xibName) == "NibHeaderFooterView"
    }
}
