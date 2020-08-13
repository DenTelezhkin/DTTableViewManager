//
//  AddRemoveViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 02.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager

class AddRemoveViewController: UIViewController, DTTableViewManageable {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.register(StringCell.self) { [weak self] in
            $0.didSelect { _, model, indexPath  in
                let alert = UIAlertController(title: "Selected cell",
                                              message: "with model: \(model) at indexPath: \(indexPath)",
                    preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                self?.present(alert, animated: true, completion: nil)
            }
            $0.commitEditingStyle { _, _, _, indexPath in
                self?.manager.memoryStorage.removeItems(at: [indexPath])
            }
            $0.heightForCell { _, _ in 80 }
        }
    }
    
    @IBAction func addItem(_ sender: AnyObject) {
        manager.memoryStorage.addItem("Row # \(manager.memoryStorage.section(atIndex: 0)?.numberOfItems ?? 0)")
    }
}
