//
//  NumberCell.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 27.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

class NumberCell: UITableViewCell, DTModelTransfer {

    @IBOutlet weak var label: UILabel!
    func updateWithModel(model: AnyObject)
    {
        let number = model as! Int
        label.text = number.description
    }
}
