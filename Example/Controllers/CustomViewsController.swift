//
//  CustomViewsController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 03.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager

class CustomViewsController: UITableViewController, DTTableViewManageable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.register(CustomStringCell.self)
        manager.registerHeader(CustomHeaderFooterView.self, handler:  { header, _,_ in
            header.backgroundPatternView.backgroundColor = UIColor(patternImage: UIImage(named: "textured_paper")!)
        })
        manager.registerFooter(CustomHeaderFooterView.self, handler: { footer,_,_ in
            footer.backgroundPatternView.backgroundColor = UIColor(patternImage: UIImage(named: "mochaGrunge")!)
        })
        
        manager.memoryStorage.setSectionHeaderModels(["Awesome custom header"])
        manager.memoryStorage.setSectionFooterModels(["Not so awesome custom footer"])
        manager.memoryStorage.setItems(["Custom cell", "Custom cell 2"])
    }
}
