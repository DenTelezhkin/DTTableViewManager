//
//  MappingTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 14.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
@testable import DTTableViewManager

class MappingTestCase: BaseTestCase {

    func testShouldCreateCellFromCode()
    {
        controller.manager.memoryStorage.defersDatasourceUpdates = true
        controller.manager.register(NiblessCell.self)
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        let cell: NiblessCell
        if #available(iOS 11, *) {
            controller.tableView.beginUpdates()
            controller.tableView.endUpdates()
            
            cell = controller.tableView.cellForRow(at: indexPath(0, 0)) as! NiblessCell
        } else {
            cell = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 0)) as! NiblessCell
        }
        
        XCTAssertEqual(cell.model as? Int, 1)
        XCTAssertFalse(cell.awakedFromNib)
        XCTAssert(cell.inittedWithStyle)
    }
    
    func testOptionalUnwrapping()
    {
        controller.manager.memoryStorage.defersDatasourceUpdates = true
        controller.manager.register(NiblessCell.self)
        
        let intOptional : Int? = 3
        controller.manager.memoryStorage.addItem(intOptional, toSection: 0)
        
        XCTAssert(controller.verifyItem(3, atIndexPath: indexPath(0, 0)))
    }
    
    func testSeveralLevelsOfOptionalUnwrapping()
    {
        controller.manager.memoryStorage.defersDatasourceUpdates = true
        controller.manager.register(NiblessCell.self)
        
        let intOptional : Int?? = 3
        controller.manager.memoryStorage.addItem(intOptional, toSection: 0)
        
        XCTAssert(controller.verifyItem(3, atIndexPath: indexPath(0, 0)))
    }
    
    func testCellMappingFromNib()
    {
        controller.manager.memoryStorage.defersDatasourceUpdates = true
        controller.manager.register(NibCell.self)
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        let cell: NibCell
        if #available(iOS 11, *) {
            controller.tableView.beginUpdates()
            controller.tableView.endUpdates()
            
            cell = controller.tableView.cellForRow(at: indexPath(0, 0)) as! NibCell
        } else {
            cell = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 0)) as! NibCell
        }
        
        XCTAssertEqual(cell.model as? Int, 1)
        XCTAssert(cell.awakedFromNib)
        XCTAssertFalse(cell.inittedWithStyle)
    }
    
    func testCellMappingFromNibWithDifferentName()
    {
        controller.manager.memoryStorage.defersDatasourceUpdates = true
        controller.manager.registerNibNamed("RandomNibNameCell", for: BaseTestCell.self)
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        let cell: BaseTestCell
        if #available(iOS 11, tvOS 11, *) {
            controller.tableView.beginUpdates()
            controller.tableView.endUpdates()
            
            cell = controller.tableView.cellForRow(at: indexPath(0, 0)) as! BaseTestCell
        } else {
            cell = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 0)) as! BaseTestCell
        }
        
        XCTAssertEqual(cell.model as? Int, 1)
        XCTAssert(cell.awakedFromNib)
        XCTAssertFalse(cell.inittedWithStyle)
    }

    func testOptionalModelCellMapping()
    {
        controller.manager.register(OptionalIntCell.self)
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        XCTAssert(controller.verifyItem(1, atIndexPath: indexPath(0, 0)))
    }
    
    func testHeaderViewMappingFromUIView()
    {
        controller.manager.registerHeader(NibView.self)
        
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        let view = controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0)
        XCTAssert(view is NibView)
    }
    
    func testHeaderMappingFromHeaderFooterView()
    {
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        let view = controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0)
        XCTAssert(view is NibHeaderFooterView)
    }
    
    func testFooterViewMappingFromUIView()
    {
        controller.manager.registerFooter(NibView.self)
        
        controller.manager.memoryStorage.setSectionFooterModels([1])
        let view = controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0)
        XCTAssert(view is NibView)
    }
    
    func testFooterMappingFromHeaderFooterView()
    {
        controller.manager.registerHeader(ReactingHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        let view = controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0)
        XCTAssert(view is ReactingHeaderFooterView)
    }
    
    func testHeaderViewShouldSupportNSStringModel()
    {
        controller.manager.registerNibNamed("NibHeaderFooterView", forHeader: NibHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        XCTAssert(controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0) is NibHeaderFooterView)
    }
    
    func testNiblessHeaderRegistrationWorks() {
        controller.manager.registerNiblessHeader(NiblessHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        let view = controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0)
        XCTAssert(view is NiblessHeaderFooterView)
    }
    
    func testNiblessFooterRegistrationWorks() {
        controller.manager.registerNiblessFooter(NiblessHeaderFooterView.self)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        let view = controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0)
        XCTAssert(view is NiblessHeaderFooterView)
    }
    
    func testUnregisterCellClass() {
        controller.manager.register(NibCell.self)
        controller.manager.unregister(NibCell.self)
        
        XCTAssertEqual(controller.manager.viewFactory.mappings.count, 0)
    }
    
    func testUnregisterHeaderClass() {
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.unregisterHeader(NibHeaderFooterView.self)
        
        XCTAssertEqual(controller.manager.viewFactory.mappings.count, 0)
    }
    
    func testUnregisterFooterClass() {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.unregisterFooter(NibHeaderFooterView.self)
        
        XCTAssertEqual(controller.manager.viewFactory.mappings.count, 0)
    }
    
    func testUnregisterHeaderClassDoesNotUnregisterCell() {
        controller.manager.register(NibCell.self)
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.unregisterHeader(NibCell.self)
        
        XCTAssertEqual(controller.manager.viewFactory.mappings.count, 2)
    }
    
    func testUnregisteringHeaderDoesNotUnregisterFooter() {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        controller.manager.registerHeader(NibHeaderFooterView.self)
        controller.manager.unregisterHeader(NibHeaderFooterView.self)
        
        XCTAssertEqual(controller.manager.viewFactory.mappings.count, 1)
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
        
        XCTAssertNil(factory.mappings.first?.xibName)
    }
    
    func testCellWithXibHasXibNameInMapping() {
        factory.registerCellClass(NibCell.self, mappingBlock: nil)
        
        XCTAssertEqual(factory.mappings.first?.xibName, "NibCell")
    }
    
    func testHeaderHasXibInMapping() {
        factory.registerHeaderClass(NibHeaderFooterView.self, mappingBlock: nil)
        
        XCTAssertEqual(factory.mappings.first?.xibName, "NibHeaderFooterView")
    }
    
    func testFooterHasXibInMapping() {
        factory.registerFooterClass(NibHeaderFooterView.self, mappingBlock: nil)
        
        XCTAssertEqual(factory.mappings.first?.xibName, "NibHeaderFooterView")
    }
}
