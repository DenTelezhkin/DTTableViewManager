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
        
        manager.startManaging(withDelegate: self)
        
        manager.configureEvents(for: StringCell.self) { [weak self] cellType, modelType in
            manager.register(cellType)
            manager.didSelect(cellType) { _, model, indexPath  in
                let alert = UIAlertController(title: "Selected cell",
                                              message: "with model: \(model) at indexPath: \(indexPath)",
                    preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                self?.present(alert, animated: true, completion: nil)
            }
            manager.commitEditingStyle(for: cellType) { _, _, _, indexPath in
                self?.manager.memoryStorage.removeItems(at: [indexPath])
            }
            manager.heightForCell(withItem: modelType) { string, indexPath -> CGFloat in
                return 80
            }
        }
    }
    
    @IBAction func addItem(_ sender: AnyObject) {
        manager.memoryStorage.addItem("Row # \(manager.memoryStorage.section(atIndex: 0)?.numberOfItems ?? 0)")
    }
}
