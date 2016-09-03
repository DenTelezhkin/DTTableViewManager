//
//  FixtureViews.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 18.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

class NibView : UIView, ModelTransfer
{
    func update(with model: Int) {
    }
}

class NibHeaderFooterView : UITableViewHeaderFooterView, ModelTransfer
{
    func update(with model: Int) {
    }
}

class NiblessHeaderFooterView : UITableViewHeaderFooterView, ModelTransfer
{
    func update(with model: Int) {
        
    }
}
