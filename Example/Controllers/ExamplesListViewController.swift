//
//  ExamplesListViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 24.08.2020.
//  Copyright © 2020 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager

class ExamplesListViewController: UITableViewController, DTTableViewManageable {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Examples"
        manager.register(UITableViewCell.self, for: Example.self) { [weak self] mapping in
            mapping.didSelect { _, model, _ in
                self?.navigationController?.pushViewController(model.controller, animated: true)
            }
        } handler: { cell, model, _ in
            cell.textLabel?.text = model.title
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        }
        manager.memoryStorage.setItems(Example.allCases)
    }
}
