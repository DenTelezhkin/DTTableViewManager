//
//  TableViewFactoryTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 29.11.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
@testable import DTTableViewManager

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

class TableViewFactoryTestCase: BaseTestCase {
    
    func testUpdateCellAtIndexPath() {
        if #available(tvOS 11, *) {
            controller.tableView = UITableView()
            controller.manager.memoryStorage.defersDatasourceUpdates = true
        } 
        
        controller.manager.register(UpdatableCell.self)
        let model = UpdatableModel()
        controller.manager.memoryStorage.addItem(model)
        
        controller.manager.tableViewUpdater = controller.manager.coreDataUpdater()
        model.value = true
        controller.manager.updateCellClosure()(indexPath(0, 0),model)
        if #available(tvOS 11, *) {
            XCTAssertTrue((controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 0)) as? UpdatableCell)?.model?.value ?? false)
        } else {
            XCTAssertTrue((controller.tableView.cellForRow(at: indexPath(0, 0)) as? UpdatableCell)?.model?.value ?? false)
        }
    }
    
}
