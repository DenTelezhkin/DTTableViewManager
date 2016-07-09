//
//  ReactingToEventsTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 19.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage
@testable import DTTableViewManager
import Nimble

class AlwaysVisibleTableView: UITableView
{
    override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        return self.dataSource?.tableView(self, cellForRowAt: indexPath)
    }
    
    
    override func headerView(forSection section: Int) -> UITableViewHeaderFooterView? {
        return self.delegate?.tableView!(self, viewForHeaderInSection: section) as? UITableViewHeaderFooterView
    }
}

class ReactingTestTableViewController: DTTestTableViewController
{
    var indexPath : IndexPath?
    var model: Int?
    var text : String?
    
    func cellConfiguration(_ cell: SelectionReactingTableCell, model: Int, indexPath: IndexPath) {
        cell.indexPath = indexPath
        cell.model = model
        cell.textLabel?.text = "Foo"
    }
    
    func headerConfiguration(_ header: ReactingHeaderFooterView, model: String, sectionIndex: Int) {
        header.model = "Bar"
        header.sectionIndex = sectionIndex
    }
    
    func cellSelection(_ cell: SelectionReactingTableCell, model: Int, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.model = model
        self.text = "Bar"
    }
}

class ReactingToEventsTestCase: XCTestCase {

    var controller : ReactingTestTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = ReactingTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.storage = MemoryStorage()
    }
    
    func testCellSelectionClosure()
    {
        controller.manager.registerCellClass(SelectionReactingTableCell.self)
        var reactingCell : SelectionReactingTableCell?
        controller.manager.whenSelected(SelectionReactingTableCell.self) { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            reactingCell = cell
        }
        
        controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        controller.manager.tableView(controller.tableView, didSelectRowAt: indexPath(1, 0))
        
        expect(reactingCell?.indexPath) == indexPath(1, 0)
        expect(reactingCell?.model) == 2
    }
    
    func testCellConfigurationClosure()
    {
        controller.manager.registerCellClass(SelectionReactingTableCell.self)
        
        var reactingCell : SelectionReactingTableCell?
        
        controller.manager.configureCell(SelectionReactingTableCell.self, { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            cell.textLabel?.text = "Foo"
            reactingCell = cell
        })
        
        controller.manager.memoryStorage.addItem(2, toSection: 0)
        _ = controller.manager.tableView(controller.tableView, cellForRowAt: indexPath(0, 0))
        
        expect(reactingCell?.indexPath) == indexPath(0, 0)
        expect(reactingCell?.model) == 2
        expect(reactingCell?.textLabel?.text) == "Foo"
    }
    
    func testHeaderConfigurationClosure()
    {
        controller.manager.registerHeaderClass(ReactingHeaderFooterView.self)
        
        var reactingHeader : ReactingHeaderFooterView?
        
        controller.manager.configureHeader(ReactingHeaderFooterView.self) { (header, model, sectionIndex) in
            header.model = "Bar"
            header.sectionIndex = sectionIndex
        }
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        reactingHeader = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0) as? ReactingHeaderFooterView
        
        expect(reactingHeader?.sectionIndex) == 0
        expect(reactingHeader?.model) == "Bar"
    }
    
    func testFooterConfigurationClosure()
    {
        controller.manager.registerFooterClass(ReactingHeaderFooterView.self)
        
        var reactingFooter : ReactingHeaderFooterView?
        
        controller.manager.configureFooter(ReactingHeaderFooterView.self) { (footer, model, sectionIndex) in
            footer.model = "Bar"
            footer.sectionIndex = sectionIndex
        }
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        reactingFooter = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0) as? ReactingHeaderFooterView
        
        expect(reactingFooter?.sectionIndex) == 0
        expect(reactingFooter?.model) == "Bar"
    }
    
    func testShouldReactAfterContentUpdate()
    {
        controller.manager.registerCellClass(NibCell.self)
        
        expect(self.controller.afterContentUpdateValue) == false
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        expect(self.controller.afterContentUpdateValue) == true
    }
    
    func testShouldReactBeforeContentUpdate()
    {
        controller.manager.registerCellClass(NibCell.self)
        
        expect(self.controller.beforeContentUpdateValue) == false
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        expect(self.controller.beforeContentUpdateValue) == true
    }
    
    func testCellRegisterSelectionClosure()
    {
        var reactingCell : SelectionReactingTableCell?
        
        controller.manager.registerCellClass(SelectionReactingTableCell.self, whenSelected: { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            reactingCell = cell
        })

        controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        controller.manager.tableView(controller.tableView, didSelectRowAt: indexPath(1, 0))
        
        expect(reactingCell?.indexPath) == indexPath(1, 0)
        expect(reactingCell?.model) == 2
    }
    
    func testMovingTableViewItems() {
        controller.manager.memoryStorage.addItems([1,2,3])
        controller.manager.memoryStorage.addItems([4,5,6], toSection: 1)
        
        controller.manager.tableView(controller.tableView, moveRowAt: indexPath(0, 0), to: indexPath(3, 1))
        
        expect(self.controller.manager.memoryStorage.sectionAtIndex(0)?.itemsOfType(Int.self)) == [2,3]
        expect(self.controller.manager.memoryStorage.sectionAtIndex(1)?.itemsOfType(Int.self)) == [4,5,6,1]
    }
    
//    func testTableViewFactoryErrorHandler() {
//        var errorHandlerCalled = false
//        
//        controller.manager.tableViewFactoryErrorHandler = { error in
//            errorHandlerCalled = true
//        }
//    }
}

// Method pointers tests
extension ReactingToEventsTestCase
{
    func testCellConfigurationMethodPointer() {
        controller.manager.registerCellClass(SelectionReactingTableCell.self)
        controller.manager.cellConfiguration(ReactingTestTableViewController.self.cellConfiguration)
        
        controller.manager.memoryStorage.addItem(2, toSection: 0)
        let reactingCell = controller.manager.tableView(controller.tableView, cellForRowAt: indexPath(0, 0)) as? SelectionReactingTableCell
        
        expect(reactingCell?.indexPath) == indexPath(0, 0)
        expect(reactingCell?.model) == 2
        expect(reactingCell?.textLabel?.text) == "Foo"
    }
    
    func testCellSelectionMethodPointer() {
        controller.manager.registerCellClass(SelectionReactingTableCell.self)
        controller.manager.cellSelection(ReactingTestTableViewController.self.cellSelection)
        
        controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        controller.manager.tableView(controller.tableView, didSelectRowAt: indexPath(1, 0))
        
        expect(self.controller.indexPath) == indexPath(1, 0)
        expect(self.controller.model) == 2
        expect(self.controller.text) == "Bar"
    }
    
    func testHeaderConfigurationMethodPointer() {
        controller.manager.registerHeaderClass(ReactingHeaderFooterView.self)
        
        var reactingHeader : ReactingHeaderFooterView?
        
        controller.manager.headerConfiguration(ReactingTestTableViewController.self.headerConfiguration)
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        reactingHeader = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0) as? ReactingHeaderFooterView
        
        expect(reactingHeader?.sectionIndex) == 0
        expect(reactingHeader?.model) == "Bar"
    }
    
    func testFooterConfigurationMethodPointer() {
        controller.manager.registerFooterClass(ReactingHeaderFooterView.self)
        
        var reactingFooter : ReactingHeaderFooterView?
        
        controller.manager.footerConfiguration(ReactingTestTableViewController.self.headerConfiguration)
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        reactingFooter = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0) as? ReactingHeaderFooterView
        
        expect(reactingFooter?.sectionIndex) == 0
        expect(reactingFooter?.model) == "Bar"
    }
}
