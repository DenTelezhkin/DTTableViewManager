//
//  CapitalCell.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 09.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import ModelStorage

class CapitalCell: UITableViewCell, ModelTransfer {
    
    func updateWithModel(model: (String,String)) {
        self.textLabel?.text = model.0
        self.detailTextLabel?.text = model.1
    }
}
