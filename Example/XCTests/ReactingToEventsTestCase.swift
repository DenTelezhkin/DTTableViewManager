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

    var controller : DTTestTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = DTTestTableViewController()
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
        
        var updated : Int?
        controller.manager.afterContentUpdate { () -> Void in
            updated = 42
        }
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        expect(updated) == 42
    }
    
    func testShouldReactBeforeContentUpdate()
    {
        controller.manager.registerCellClass(NibCell)
        
        var updated : Int?
        controller.manager.beforeContentUpdate { () -> Void in
            updated = 42
        }
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        expect(updated) == 42
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
}
