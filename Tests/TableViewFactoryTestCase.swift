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
    
    func testUpdateCellAtIndexPath() {
        if #available(iOS 11, tvOS 11, *) {
            controller.tableView = UITableView()
            controller.manager.startManaging(withDelegate: controller)
            controller.manager.storage = MemoryStorage()
            controller.manager.memoryStorage.defersDatasourceUpdates = true
        } 
        
        controller.manager.register(UpdatableCell.self)
        let model = UpdatableModel()
        controller.manager.memoryStorage.addItem(model)
        
        controller.manager.tableViewUpdater = controller.manager.coreDataUpdater()
        model.value = true
        controller.manager.updateCellClosure()(indexPath(0, 0),model)
        if #available(iOS 11, tvOS 11, *) {
            expect((self.controller.manager.tableDataSource?.tableView(self.controller.tableView, cellForRowAt: indexPath(0, 0)) as? UpdatableCell)?.model?.value).to(beTrue())
        } else {
            expect((self.controller.tableView.cellForRow(at: indexPath(0, 0)) as? UpdatableCell)?.model?.value).to(beTrue())
        }
    }
    
}
