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
        manager.register(CustomStringCell.self)
        manager.registerHeader(CustomHeaderFooterView.self)
        manager.registerFooter(CustomHeaderFooterView.self)
        
        manager.memoryStorage.setSectionHeaderModels([("Awesome custom header", UIImage(named: "textured_paper.png")!)])
        manager.memoryStorage.setSectionFooterModels([("Not so awesome custom footer", UIImage(named: "mochaGrunge.png")!)])
        
        let foo = ["Custom cell", "Custom cell 2"]
        manager.memoryStorage.addItems(foo)
    }

}
