//
//  BankCell.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 20.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

class BankCell : UITableViewCell, ModelTransfer
{
    func updateWithModel(_ model: Bank) {
        self.textLabel?.text = model.name
        self.detailTextLabel?.text = model.city
    }
}
