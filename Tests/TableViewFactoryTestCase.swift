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

fileprivate class UpdatableModel {
    var value: Bool = false
}

fileprivate class UpdatableCell : UITableViewCell, ModelTransfer {
    var model : UpdatableModel?

    func update(with model: UpdatableModel) {
        self.model = model
    }
    
    fileprivate override func prepareForReuse() {
        super.prepareForReuse()
        XCTFail()
    }
}

class TableViewFactoryTestCase: XCTestCase {
    
    var controller : DTTestTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = DTTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        controller.manager.startManaging(withDelegate: controller)
        controller.manager.storage = MemoryStorage()
    }
    
    func testCellForModelNilModelError() {
        let model: Int? = nil
        do {
            try _ = controller.manager.viewFactory.cellForModel(model as Any, atIndexPath: indexPath(0, 0))
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
            try _ = controller.manager.viewFactory.headerFooterView(of: .supplementaryView(kind: "Foo"), model: model as Any, atIndexPath: IndexPath(index: 0))
        } catch DTTableViewFactoryError.nilHeaderFooterModel(let section) {
            expect(section) == 0
        } catch {
            XCTFail()
        }
    }
    
    func testUpdateCellAtIndexPath() {
        controller.manager.register(UpdatableCell.self)
        let model = UpdatableModel()
        controller.manager.memoryStorage.addItem(model)
        
        controller.manager.tableViewUpdater = controller.manager.coreDataUpdater()
        model.value = true
        controller.manager.updateCellClosure()(indexPath(0, 0),model)
        expect((self.controller.tableView.cellForRow(at: indexPath(0, 0)) as? UpdatableCell)?.model?.value).to(beTrue())
    }
    
}
