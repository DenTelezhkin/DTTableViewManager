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
        controller.manager.viewBundle = NSBundle(forClass: self.dynamicType)
        controller.manager.storage = MemoryStorage()
    }
    
    func testCellForModelNilModelError() {
        let model: Int? = nil
        do {
            try controller.manager.viewFactory.cellForModel(model, atIndexPath: indexPath(0, 0))
        } catch DTTableViewFactoryError.NilCellModel(let indexPath) {
            expect(indexPath) == NSIndexPath(forItem: 0, inSection: 0)
        } catch {
            XCTFail()
        }
    }
    
    func testNoMappingsFound() {
        do {
            try controller.manager.viewFactory.cellForModel(1, atIndexPath: indexPath(0, 0))
        } catch DTTableViewFactoryError.NoCellMappings(let model) {
            expect(model as? Int) == 1
        } catch {
            XCTFail()
        }
    }
    
    func testNilHeaderFooterModel() {
        let model: Int? = nil
        do {
            try controller.manager.viewFactory.headerFooterViewOfType(.SupplementaryView(kind: "Foo"), model: model, atIndexPath: NSIndexPath(index: 0))
        } catch DTTableViewFactoryError.NilHeaderFooterModel(let section) {
            expect(section) == 0
        } catch {
            XCTFail()
        }
    }
    
}
