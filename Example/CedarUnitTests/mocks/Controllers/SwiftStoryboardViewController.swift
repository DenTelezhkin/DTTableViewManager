//
//  SwiftStoryboardViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 01.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit

class SwiftStoryboardViewController: DTTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCellClass(SwiftTableViewCell.self, forModelClass: NSString.self)
    }
}
