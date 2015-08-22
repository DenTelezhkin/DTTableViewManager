//
//  CustomViewsController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 03.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager

class CustomViewsController: UIViewController, DTTableViewManageable {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.startManagingWithDelegate(self)
        manager.registerCellClass(CustomStringCell)
        manager.registerHeaderClass(CustomHeaderFooterView)
        manager.registerFooterClass(CustomHeaderFooterView)
        
        manager.memoryStorage.setSectionHeaderModel(("Awesome custom header", UIImage(named: "textured_paper.png")!), forSectionIndex: 0)
        manager.memoryStorage.setSectionFooterModel(("Not so awesome custom footer", UIImage(named: "mochaGrunge.png")!), forSectionIndex: 0)
        
        let foo = ["Custom cell", "Custom cell 2"]
        manager.memoryStorage.addItems(foo)
    }

}
