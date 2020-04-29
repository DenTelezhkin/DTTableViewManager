//
//  ViewModelMappingCustomizableTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 29.11.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTTableViewManager

class IntCell : UITableViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class AnotherIntCell : UITableViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class IntHeader: UITableViewHeaderFooterView, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class AnotherIntHeader: UITableViewHeaderFooterView, ModelTransfer {
    func update(with model: Int) {
        
    }
}
