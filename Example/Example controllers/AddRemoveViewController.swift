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
        manager.startManagingWithDelegate(self)
        manager.registerCellClass(StringCell.self)
        manager.didSelect(StringCell.self) { [weak self] (_, model, indexPath)  in
            let alert = UIAlertController(title: "Selected cell",
                message: "with model: \(model) at indexPath: \(indexPath)",
                preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            self?.present(alert, animated: true, completion: nil)
        }
        manager.height(forItemType: String.self) { string, indexPath -> CGFloat in
            return 80
        }
    }
    
    @IBAction func addItem(_ sender: AnyObject) {
        manager.memoryStorage.addItem("Row # \(manager.memoryStorage.sectionAtIndex(0)?.numberOfItems ?? 0)")
    }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath)
    {
        manager.memoryStorage.removeItemsAtIndexPaths([indexPath])
    }
    
}
