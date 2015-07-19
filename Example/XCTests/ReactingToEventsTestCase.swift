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
}

class ReactingToEventsTestCase: XCTestCase {

    var controller : DTTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = DTTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
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
}
