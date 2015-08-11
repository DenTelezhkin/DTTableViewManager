//
//  CustomViewsController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 03.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager

class CustomViewsController: DTTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerCellClass(CustomStringCell)
        self.registerHeaderClass(CustomHeaderFooterView)
        self.registerFooterClass(CustomHeaderFooterView)
        
        self.memoryStorage.setSectionHeaderModel(("Awesome custom header", UIImage(named: "textured_paper.png")!), forSectionIndex: 0)
        self.memoryStorage.setSectionFooterModel(("Not so awesome custom footer", UIImage(named: "mochaGrunge.png")!), forSectionIndex: 0)
        
        let foo = ["Custom cell", "Custom cell 2"]
        self.memoryStorage.addItems(foo)
    }

}
