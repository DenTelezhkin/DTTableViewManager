//
//  ReactingHeaderFooters.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

class ReactingHeaderFooterView : UITableViewHeaderFooterView, ModelTransfer
{
    var sectionIndex: Int?
    var model : String?
    
    func updateWithModel(_ model: String) {
        self.model = model
    }
}
