//
//  StringCell.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 02.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage
import DTTableViewManager

class StringCell: UITableViewCell, ModelTransfer {
    func update(with model: String) {
        self.textLabel?.text = model
    }

}
