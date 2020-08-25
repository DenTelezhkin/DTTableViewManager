//
//  AddRemoveViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 02.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager

class AddRemoveViewController: UITableViewController, DTTableViewManageable {

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.register(UITableViewCell.self, for: String.self) { [weak self] mapping in
            mapping.didSelect { _, model, indexPath in
                let alert = UIAlertController(title: "Selected cell",
                                              message: "with model: \(model) at indexPath: \(indexPath)",
                    preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                self?.present(alert, animated: true, completion: nil)
            }
            mapping.commitEditingStyle { _, _, _, indexPath in
                self?.manager.memoryStorage.removeItems(at: [indexPath])
            }
            mapping.heightForCell { _, _ in 80 }
        } handler: { cell, model, _ in
            cell.textLabel?.text = model
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: UIAction { [weak manager] _ in
            manager?.memoryStorage.addItem("Row # \(manager?.memoryStorage.section(atIndex: 0)?.numberOfItems ?? 0)")
        }, menu: nil)
    }
}
