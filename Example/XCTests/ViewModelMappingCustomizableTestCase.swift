//
//  ViewModelMappingCustomizableTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 29.11.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTTableViewManager
import DTModelStorage
import Nimble

class CustomizableViewController: DTTestTableViewController, DTViewModelMappingCustomizable {
    
    var mappingSelectableBlock : (([ViewModelMapping], Any) -> ViewModelMapping?)?
    
    func viewModelMappingFromCandidates(candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
        return mappingSelectableBlock?(candidates, model)
    }
}

class IntCell : UITableViewCell, ModelTransfer {
    func updateWithModel(model: Int) {
        
    }
}

class AnotherIntCell : UITableViewCell, ModelTransfer {
    func updateWithModel(model: Int) {
        
    }
}

class IntHeader: UITableViewHeaderFooterView, ModelTransfer {
    func updateWithModel(model: Int) {
        
    }
}

class AnotherIntHeader: UITableViewHeaderFooterView, ModelTransfer {
    func updateWithModel(model: Int) {
        
    }
}

class ViewModelMappingCustomizableTestCase: XCTestCase {
    
    var controller : CustomizableViewController!
    
    override func setUp() {
        super.setUp()
        controller = CustomizableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.viewBundle = NSBundle(forClass: self.dynamicType)
        controller.manager.storage = MemoryStorage()
    }
    
    func testMappingCustomizableAllowsSelectingAnotherCellMapping() {
        controller.manager.registerCellClass(IntCell)
        controller.manager.registerCellClass(AnotherIntCell)
        controller.mappingSelectableBlock = { mappings, model in
            return mappings.last
        }
        
        controller.manager.memoryStorage.addItem(3)
        
        let cell = controller.manager.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        
        expect(cell is AnotherIntCell).to(beTrue())
    }
    
    func testMappingCustomizableAllowsSelectingAnotherHeaderMapping() {
        controller.manager.registerNiblessHeaderClass(IntHeader)
        controller.manager.registerNiblessHeaderClass(AnotherIntHeader)
        controller.mappingSelectableBlock = { mappings, model in
            return mappings.last
        }
        
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        expect(self.controller.manager.tableView(self.controller.tableView, viewForHeaderInSection: 0)).to(beAKindOf(AnotherIntHeader))
    }
    
    func testMappingCustomizableAllowsSelectingAnotherFooterMapping() {
        controller.manager.registerNiblessFooterClass(IntHeader)
        controller.manager.registerNiblessFooterClass(AnotherIntHeader)
        controller.mappingSelectableBlock = { mappings, model in
            return mappings.last
        }
        
        controller.manager.memoryStorage.setSectionFooterModels([1])
        expect(self.controller.manager.tableView(self.controller.tableView, viewForFooterInSection: 0)).to(beAKindOf(AnotherIntHeader))
    }
}
