//
//  CustomStringCell.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 03.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

class CustomStringCell: UITableViewCell, ModelTransfer {

    @IBOutlet weak var label: UILabel!
    
    func update(with model: String) {
        self.label.text = model
    }
}
