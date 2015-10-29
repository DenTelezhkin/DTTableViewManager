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
    override func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        return self.dataSource?.tableView(self, cellForRowAtIndexPath: indexPath)
    }
    
    
    override func headerViewForSection(section: Int) -> UITableViewHeaderFooterView? {
        return self.delegate?.tableView!(self, viewForHeaderInSection: section) as? UITableViewHeaderFooterView
    }
}

class ReactingTestTableViewController: DTTestTableViewController
{
    var indexPath : NSIndexPath?
    var model: Int?
    var text : String?
    
    func cellConfiguration(cell: SelectionReactingTableCell, model: Int, indexPath: NSIndexPath) {
        cell.indexPath = indexPath
        cell.model = model
        cell.textLabel?.text = "Foo"
    }
    
    func headerConfiguration(header: ReactingHeaderFooterView, model: String, sectionIndex: Int) {
        header.model = "Bar"
        header.sectionIndex = sectionIndex
    }
    
    func cellSelection(cell: SelectionReactingTableCell, model: Int, indexPath: NSIndexPath) {
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
        controller.manager.viewBundle = NSBundle(forClass: self.dynamicType)
        controller.manager.storage = MemoryStorage()
    }
    
    func testCellSelectionClosure()
    {
        controller.manager.registerCellClass(SelectionReactingTableCell)
        var reactingCell : SelectionReactingTableCell?
        controller.manager.whenSelected(SelectionReactingTableCell.self) { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            reactingCell = cell
        }
        
        controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        controller.manager.tableView(controller.tableView, didSelectRowAtIndexPath: indexPath(1, 0))
        
        expect(reactingCell?.indexPath) == indexPath(1, 0)
        expect(reactingCell?.model) == 2
    }
    
    func testCellConfigurationClosure()
    {
        controller.manager.registerCellClass(SelectionReactingTableCell)
        
        var reactingCell : SelectionReactingTableCell?
        
        controller.manager.configureCell(SelectionReactingTableCell.self, { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            cell.textLabel?.text = "Foo"
            reactingCell = cell
        })
        
        controller.manager.memoryStorage.addItem(2, toSection: 0)
        controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        
        expect(reactingCell?.indexPath) == indexPath(0, 0)
        expect(reactingCell?.model) == 2
        expect(reactingCell?.textLabel?.text) == "Foo"
    }
    
    func testHeaderConfigurationClosure()
    {
        controller.manager.registerHeaderClass(ReactingHeaderFooterView)
        
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
        controller.manager.registerFooterClass(ReactingHeaderFooterView)
        
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
        controller.manager.registerCellClass(NibCell)
        
        expect(self.controller.afterContentUpdateValue) == false
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        expect(self.controller.afterContentUpdateValue) == true
    }
    
    func testShouldReactBeforeContentUpdate()
    {
        controller.manager.registerCellClass(NibCell)
        
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
        controller.manager.tableView(controller.tableView, didSelectRowAtIndexPath: indexPath(1, 0))
        
        expect(reactingCell?.indexPath) == indexPath(1, 0)
        expect(reactingCell?.model) == 2
    }
    
    func testViewModelMappingDescription() {
        let viewModelMapping = ViewModelMapping(viewType: .Cell, viewTypeMirror: _reflect(UITableViewCell.self), modelTypeMirror: _reflect(String.self)) { (_, _) -> () in
        }
        
        expect(viewModelMapping.debugDescription) != ""
    }
    
    func testMovingTableViewItems() {
        controller.manager.memoryStorage.addItems([1,2,3])
        controller.manager.memoryStorage.addItems([4,5,6], toSection: 1)
        
        controller.manager.tableView(controller.tableView, moveRowAtIndexPath: indexPath(0, 0), toIndexPath: indexPath(3, 1))
        
        expect(self.controller.manager.memoryStorage.sectionAtIndex(0)?.itemsOfType(Int)) == [2,3]
        expect(self.controller.manager.memoryStorage.sectionAtIndex(1)?.itemsOfType(Int)) == [4,5,6,1]
    }
}

// Method pointers tests
extension ReactingToEventsTestCase
{
    func testCellConfigurationMethodPointer() {
        controller.manager.registerCellClass(SelectionReactingTableCell)
        controller.manager.cellConfiguration(ReactingTestTableViewController.self.cellConfiguration)
        
        controller.manager.memoryStorage.addItem(2, toSection: 0)
        let reactingCell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0)) as? SelectionReactingTableCell
        
        expect(reactingCell?.indexPath) == indexPath(0, 0)
        expect(reactingCell?.model) == 2
        expect(reactingCell?.textLabel?.text) == "Foo"
    }
    
    func testCellSelectionMethodPointer() {
        controller.manager.registerCellClass(SelectionReactingTableCell)
        controller.manager.cellSelection(ReactingTestTableViewController.self.cellSelection)
        
        controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        controller.manager.tableView(controller.tableView, didSelectRowAtIndexPath: indexPath(1, 0))
        
        expect(self.controller.indexPath) == indexPath(1, 0)
        expect(self.controller.model) == 2
        expect(self.controller.text) == "Bar"
    }
    
    func testHeaderConfigurationMethodPointer() {
        controller.manager.registerHeaderClass(ReactingHeaderFooterView)
        
        var reactingHeader : ReactingHeaderFooterView?
        
        controller.manager.headerConfiguration(ReactingTestTableViewController.self.headerConfiguration)
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        reactingHeader = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0) as? ReactingHeaderFooterView
        
        expect(reactingHeader?.sectionIndex) == 0
        expect(reactingHeader?.model) == "Bar"
    }
    
    func testFooterConfigurationMethodPointer() {
        controller.manager.registerFooterClass(ReactingHeaderFooterView)
        
        var reactingFooter : ReactingHeaderFooterView?
        
        controller.manager.footerConfiguration(ReactingTestTableViewController.self.headerConfiguration)
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        reactingFooter = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0) as? ReactingHeaderFooterView
        
        expect(reactingFooter?.sectionIndex) == 0
        expect(reactingFooter?.model) == "Bar"
    }
}
