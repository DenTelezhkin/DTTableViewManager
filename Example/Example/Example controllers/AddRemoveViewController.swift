//
//  AddRemoveViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 02.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager

class AddRemoveViewController: DTTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerCellClass(StringCell.self, selectionClosure: { [weak self] (_, model, indexPath)  in
            let alert = UIAlertController(title: "Selected cell",
                message: "with model: \(model) at indexPath: \(indexPath)",
                preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(action)
            self?.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    @IBAction func addItem(sender: AnyObject) {
        self.memoryStorage.addItem("Row # \(self.memoryStorage.sectionAtIndex(0).numberOfObjects)")
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        self.memoryStorage.removeItemsAtIndexPaths([indexPath])
    }
}
