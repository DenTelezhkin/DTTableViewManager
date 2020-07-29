//
//  MappingConditionsTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 16.07.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTTableViewManager

class MappingConditionsTestCase: BaseTestCase {
    
    func testMappingCanBeSwitchedBetweenSections() {
        controller.manager.memoryStorage.defersDatasourceUpdates = true
        controller.manager.register(NibCell.self) { mapping in
            mapping.condition = .section(0)
        }
        controller.manager.register(AnotherIntCell.self) { mapping in
            mapping.condition = .section(1)
        }
        
        controller.manager.memoryStorage.addItem(1)
        controller.manager.memoryStorage.addItem(2, toSection: 1)
        
        let nibCell = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 0))
        XCTAssert(nibCell is NibCell)
        
        let cell = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 1))
        
        XCTAssert(cell is AnotherIntCell)
    }
    
    func testCustomMappingIsRevolvableForTheSameModel() {
        controller.manager.memoryStorage.defersDatasourceUpdates = true
        controller.manager.register(NibCell.self) { mapping in
            mapping.condition = .custom({ indexPath, model in
                guard let model = model as? Int else { return false }
                return model > 2
            })
        }
        controller.manager.register(AnotherIntCell.self) { mapping in
            mapping.condition = .custom({ indexPath, model -> Bool in
                guard let model = model as? Int else { return false }
                return model <= 2
            })
        }
        
        controller.manager.memoryStorage.addItem(3)
        let cell = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 0))
        XCTAssert(cell is NibCell)
        
        controller.manager.memoryStorage.addItem(1)
        let anotherCell = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(1, 0))
        XCTAssert(anotherCell is AnotherIntCell)
    }
    
    func testMappingCanBeSwitchedForNibNames() {
        controller.manager.memoryStorage.defersDatasourceUpdates = true
        controller.manager.register(NibCell.self) { mapping in
            mapping.condition = .section(0)
            mapping.reuseIdentifier = "NibCell One"
        }
        controller.manager.register(NibCell.self) { mapping in
            mapping.condition = .section(1)
            mapping.xibName = "CustomNibCell"
            mapping.reuseIdentifier = "NibCell Two"
        }
        
        controller.manager.memoryStorage.addItem(1)
        controller.manager.memoryStorage.addItem(2, toSection: 1)
        
        let nibCell = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 0)) as? NibCell
        XCTAssertNil(nibCell?.customLabel)
        
        let customNibCell = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 1)) as? NibCell
        
        XCTAssertNotNil(customNibCell?.customLabel)
    }
}
