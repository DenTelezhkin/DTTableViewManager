//
//  FixtureViews.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 18.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import ModelStorage

class NibView : UIView, ModelTransfer
{
    func updateWithModel(model: Int) {
    }
}

class NibHeaderFooterView : UITableViewHeaderFooterView, ModelTransfer
{
    func updateWithModel(model: Int) {
    }
}
