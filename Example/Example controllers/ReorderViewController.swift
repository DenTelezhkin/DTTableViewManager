//
//  ReorderViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 02.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager
import DTModelStorage

class ReorderViewController: UIViewController, DTTableViewManageable, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.startManaging(withDelegate: self)
        manager.register(StringCell.self)
        
        manager.memoryStorage.addItems(["Section 1 cell", "Section 1 cell"], toSection: 0)
        manager.memoryStorage.addItems(["Section 2 cell"], toSection: 1)
        manager.memoryStorage.addItems(["Section 3 cell", "Section 3 cell", "Section 3 cell"], toSection: 2)
        manager.canMove(StringCell.self, { _,_,_ in return true })
        manager.editingStyle(for: StringCell.self, { _,_,_ in return .none })
        
        manager.memoryStorage.setSectionHeaderModels(["Section 1", "Section 2", "Section 3"])
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
}
