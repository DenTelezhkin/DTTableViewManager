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
        manager.registerCellClass(StringCell.self, whenSelected: { [weak self] (_, model, indexPath)  in
            let alert = UIAlertController(title: "Selected cell",
                message: "with model: \(model) at indexPath: \(indexPath)",
                preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(action)
            self?.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    @IBAction func addItem(sender: AnyObject) {
        manager.memoryStorage.addItem("Row # \(manager.memoryStorage.sectionAtIndex(0).numberOfObjects)")
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        manager.memoryStorage.removeItemsAtIndexPaths([indexPath])
    }
}
