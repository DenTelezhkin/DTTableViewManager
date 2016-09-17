//
//  ReactingTableCell.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 19.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

class ReactingTableCell: UITableViewCell, ModelTransfer {

    func update(with model: Int) {
        
    }

}

class SelectionReactingTableCell: ReactingTableCell
{
    var indexPath: IndexPath?
    var cell: SelectionReactingTableCell?
    var model : Int?
}
