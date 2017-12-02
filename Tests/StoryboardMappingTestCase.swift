//
//  StoryboardMappingTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 10.01.16.
//  Copyright © 2016 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import Nimble
import DTModelStorage
@testable import DTTableViewManager

class StoryboardMappingTestCase: XCTestCase {
    
    var controller : StoryboardViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "FixtureStoryboard", bundle: Bundle(for: type(of: self)))
        controller = storyboard.instantiateInitialViewController() as! StoryboardViewController
        _ = controller.view
        controller.manager.startManaging(withDelegate: controller)
    }
    
    func testCellIsMappedAndOutletsAreCreated() {
        controller.manager.memoryStorage.defersDatasourceUpdates = true
        controller.manager.register(StoryboardCell.self)
        controller.manager.memoryStorage.addItem(1)
        
        let cell = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 0)) as! StoryboardCell
        
        expect(cell.storyboardLabel).toNot(beNil())
    }
}
