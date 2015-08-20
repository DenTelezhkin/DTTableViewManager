//
//  ReactingToEventsTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 19.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import ModelStorage
import DTTableViewManager
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

class ReactingToEventsTestCase: XCTestCase {

    var controller : DTTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = DTTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        controller.viewBundle = NSBundle(forClass: self.dynamicType)
        controller.storage = MemoryStorage()
    }
    
    func testCellSelectionClosure()
    {
        controller.registerCellClass(SelectionReactingTableCell)
        var reactingCell : SelectionReactingTableCell?
        controller.whenSelected(SelectionReactingTableCell.self) { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            reactingCell = cell
        }
        
        controller.memoryStorage.addItems([1,2], toSection: 0)
        controller.tableView(controller.tableView, didSelectRowAtIndexPath: indexPath(1, 0))
        
        expect(reactingCell?.indexPath) == indexPath(1, 0)
        expect(reactingCell?.model) == 2
    }
    
    func testCellConfigurationClosure()
    {
        controller.registerCellClass(SelectionReactingTableCell)
        
        var reactingCell : SelectionReactingTableCell?
        
        controller.configureCell(SelectionReactingTableCell.self, { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            cell.textLabel?.text = "Foo"
            reactingCell = cell
        })
        
        controller.memoryStorage.addItem(2, toSection: 0)
        controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        
        expect(reactingCell?.indexPath) == indexPath(0, 0)
        expect(reactingCell?.model) == 2
        expect(reactingCell?.textLabel?.text) == "Foo"
    }
    
    func testHeaderConfigurationClosure()
    {
        controller.registerHeaderClass(ReactingHeaderFooterView)
        
        var reactingHeader : ReactingHeaderFooterView?
        
        controller.configureHeader(ReactingHeaderFooterView.self) { (header, model, sectionIndex) in
            header.model = "Bar"
            header.sectionIndex = sectionIndex
        }
        controller.memoryStorage.setSectionHeaderModels(["Foo"])
        reactingHeader = controller.tableView(controller.tableView, viewForHeaderInSection: 0) as? ReactingHeaderFooterView
        
        expect(reactingHeader?.sectionIndex) == 0
        expect(reactingHeader?.model) == "Bar"
    }
    
    func testFooterConfigurationClosure()
    {
        controller.registerFooterClass(ReactingHeaderFooterView)
        
        var reactingFooter : ReactingHeaderFooterView?
        
        controller.configureFooter(ReactingHeaderFooterView.self) { (footer, model, sectionIndex) in
            footer.model = "Bar"
            footer.sectionIndex = sectionIndex
        }
        controller.memoryStorage.setSectionFooterModels(["Foo"])
        reactingFooter = controller.tableView(controller.tableView, viewForFooterInSection: 0) as? ReactingHeaderFooterView
        
        expect(reactingFooter?.sectionIndex) == 0
        expect(reactingFooter?.model) == "Bar"
    }
    
    func testShouldReactAfterContentUpdate()
    {
        controller.registerCellClass(NibCell)
        
        var updated : Int?
        controller.afterContentUpdate { () -> Void in
            updated = 42
        }
        
        controller.memoryStorage.addItem(1, toSection: 0)
        
        expect(updated) == 42
    }
    
    func testShouldReactBeforeContentUpdate()
    {
        controller.registerCellClass(NibCell)
        
        var updated : Int?
        controller.beforeContentUpdate { () -> Void in
            updated = 42
        }
        
        controller.memoryStorage.addItem(1, toSection: 0)
        
        expect(updated) == 42
    }
    
    func testCellRegisterSelectionClosure()
    {
        var reactingCell : SelectionReactingTableCell?
        
        controller.registerCellClass(SelectionReactingTableCell.self, selectionClosure: { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            reactingCell = cell
        })

        controller.memoryStorage.addItems([1,2], toSection: 0)
        controller.tableView(controller.tableView, didSelectRowAtIndexPath: indexPath(1, 0))
        
        expect(reactingCell?.indexPath) == indexPath(1, 0)
        expect(reactingCell?.model) == 2
    }
}
