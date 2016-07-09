//
//  TableViewFactoryTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 29.11.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
@testable import DTTableViewManager
import DTModelStorage
import Nimble

class TableViewFactoryTestCase: XCTestCase {
    
    var controller : DTTestTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = DTTestTableViewController()
        controller.tableView = UITableView()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.storage = MemoryStorage()
    }
    
    func testCellForModelNilModelError() {
        let model: Int? = nil
        do {
            try _ = controller.manager.viewFactory.cellForModel(model, atIndexPath: indexPath(0, 0))
        } catch DTTableViewFactoryError.nilCellModel(let indexPath) {
            expect(indexPath) == IndexPath(item: 0, section: 0)
        } catch {
            XCTFail()
        }
    }
    
    func testNoMappingsFound() {
        do {
            try _ = controller.manager.viewFactory.cellForModel(1, atIndexPath: indexPath(0, 0))
        } catch DTTableViewFactoryError.noCellMappings(let model) {
            expect(model as? Int) == 1
        } catch {
            XCTFail()
        }
    }
    
    func testNilHeaderFooterModel() {
        let model: Int? = nil
        do {
            try _ = controller.manager.viewFactory.headerFooterViewOfType(.supplementaryView(kind: "Foo"), model: model, atIndexPath: IndexPath(index: 0))
        } catch DTTableViewFactoryError.nilHeaderFooterModel(let section) {
            expect(section) == 0
        } catch {
            XCTFail()
        }
    }
    
}
