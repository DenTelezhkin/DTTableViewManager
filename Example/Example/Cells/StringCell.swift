//
//  StringCell.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 02.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import ModelStorage
import DTTableViewManager

class StringCell: UITableViewCell, ModelTransfer {
    func updateWithModel(model: String) {
        self.textLabel?.text = model
    }

}
