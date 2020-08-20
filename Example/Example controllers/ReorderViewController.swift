//
//  ReorderViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 02.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager

class ReorderViewController: UIViewController, DTTableViewManageable, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.register(StringCell.self) { [weak self] in
            $0.canMove { _,_,_ in true }
            $0.editingStyle { _,_ in .none }
            $0.moveRowTo { destination, _, _, source in
                self?.manager.memoryStorage.moveItemWithoutAnimation(from: source, to: destination)
            }
        }
        manager.memoryStorage.addItems(["Section 1 cell", "Section 1 cell"], toSection: 0)
        manager.memoryStorage.addItems(["Section 2 cell"], toSection: 1)
        manager.memoryStorage.addItems(["Section 3 cell", "Section 3 cell", "Section 3 cell"], toSection: 2)
        manager.memoryStorage.setSectionHeaderModels(["Section 1", "Section 2", "Section 3"])
        navigationItem.rightBarButtonItem = editButtonItem
    }
}
