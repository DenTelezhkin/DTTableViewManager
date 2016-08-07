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
        controller.manager.didSelect(SelectionReactingTableCell.self) { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            reactingCell = cell
        }
        
        controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        controller.manager.tableView(controller.tableView, didSelectRowAt: indexPath(1, 0))
        
        expect(reactingCell?.indexPath) == indexPath(1, 0)
        expect(reactingCell?.model) == 2
    }
    
    func testCellSelectionPerfomance() {
        controller.manager.registerCellClass(SelectionReactingTableCell.self)
        self.controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: true) {
            self.controller.manager.didSelect(SelectionReactingTableCell.self) { (_, _, _) in
                self.stopMeasuring()
            }
            self.controller.manager.tableView(self.controller.tableView, didSelectRowAt: indexPath(1, 0))
        }
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
    
    func testMovingTableViewItems() {
        controller.manager.memoryStorage.addItems([1,2,3])
        controller.manager.memoryStorage.addItems([4,5,6], toSection: 1)
        
        controller.manager.tableView(controller.tableView, moveRowAt: indexPath(0, 0), to: indexPath(3, 1))
        
        expect(self.controller.manager.memoryStorage.sectionAtIndex(0)?.itemsOfType(Int.self)) == [2,3]
        expect(self.controller.manager.memoryStorage.sectionAtIndex(1)?.itemsOfType(Int.self)) == [4,5,6,1]
    }
}

class ReactingToEventsFastTestCase : XCTestCase {
    var controller : ReactingTestTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = ReactingTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.storage = MemoryStorage()
        controller.manager.registerFooterClass(ReactingHeaderFooterView.self)
        controller.manager.registerCellClass(NibCell.self)
    }
    
    func testFooterConfigurationClosure()
    {
        let exp = expectation(description: "Configure footer")
        controller.manager.configureFooter(ReactingHeaderFooterView.self) { _ in
            exp.fulfill()
        }
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        _ = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHeightForRowAtIndexPathClosure()
    {
        let exp = expectation(description: "heightForRowAtIndexPath")
        controller.manager.height(forItemType: Int.self, closure: { int, indexPath in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, heightForRowAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEstimatedHeightForRowAtIndexPathClosure()
    {
        let exp = expectation(description: "estimatedHeightForRowAtIndexPath")
        controller.manager.estimatedHeight(forItemType: Int.self, closure: { int, indexPath in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, estimatedHeightForRowAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testIndentationLevelForRowAtIndexPathClosure()
    {
        let exp = expectation(description: "indentationLevelForRowAtIndexPath")
        controller.manager.indentationLevel(forItemType: Int.self, closure: { int, indexPath in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, indentationLevelForRowAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillSelectRowAtIndexPathClosure() {
        let exp = expectation(description: "willSelect")
        controller.manager.willSelect(NibCell.self, { (cell, model, indexPath) -> IndexPath? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, willSelectRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDeselectRowAtIndexPathClosure() {
        let exp = expectation(description: "willDeselect")
        controller.manager.willDeselect(NibCell.self, { (cell, model, indexPath) -> IndexPath? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, willDeselectRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidDeselectRowAtIndexPathClosure() {
        let exp = expectation(description: "didDeselect")
        controller.manager.didDeselect(NibCell.self, { (cell, model, indexPath) -> IndexPath? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, didDeselectRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayRowAtIndexPathClosure() {
        let exp = expectation(description: "willDisplay")
        controller.manager.willDisplay(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, willDisplay: NibCell(), forRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEditActionsForRowAtIndexPathClosure() {
        let exp = expectation(description: "editActions")
        controller.manager.editActions(for: NibCell.self, { (cell, model, indexPath) -> [UITableViewRowAction]? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, editActionsForRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAccessoryButtonTappedForRowAtIndexPathClosure() {
        let exp = expectation(description: "accessoryButtonTapped")
        controller.manager.accessoryButtonTapped(in: NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, accessoryButtonTappedForRowWith: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCommitEditingStyleForRowAtIndexPathClosure() {
        let exp = expectation(description: "commitEditingStyle")
        controller.manager.commitEditingStyle(for: NibCell.self, { style, cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, commit: .delete, forRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanEditRowAtIndexPathClosure() {
        let exp = expectation(description: "canEditRow")
        controller.manager.canEdit(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return false
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, canEditRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanMoveRowAtIndexPathClosure() {
        let exp = expectation(description: "canMoveRow")
        controller.manager.canMove(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return false
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, canMoveRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
}

