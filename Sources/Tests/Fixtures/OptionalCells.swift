//
//  OptionalCells.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 17.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

class OptionalIntCell : UITableViewCell, ModelTransfer, ModelRetrievable
{
    var model: Any!
    func update(with model: Int?) {
        self.model = model
    }
}
