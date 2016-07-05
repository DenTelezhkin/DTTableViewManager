//
//  SwiftViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 27.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit

@objc(SwiftViewController)
class SwiftViewController: DTTableViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var refreshControl : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerCellClass(NumberCell.self, forModelClass:NSNumber.self)

        self.refreshControl = UIRefreshControl()
        self.tableView.addSubview(self.refreshControl)
        self.refreshControl.addTarget(self, action: #selector(SwiftViewController.refreshShouldStart(_:)),
            forControlEvents: .ValueChanged)
        
        executeAfter(1, block: { () -> Void in
            self.memoryStorage().setItems(self.randomNumbers(), forSectionIndex: 0)
        })
    }
    
    func refreshShouldStart(sender: UIRefreshControl) {
        executeAfter(1, block: { () -> Void in
            self.refreshControl.endRefreshing()
            self.memoryStorage().setItems(self.randomNumbers(), forSectionIndex: 0)
        })
    }
    
    func randomNumbers() -> [Int] {
        var items = [Int]()
        
        for _ in 0 ..< 5
        {
            items.append(Int(arc4random_uniform(10)))
        }
        
        return items
    }
}

extension SwiftViewController {
    override func tableControllerDidUpdateContent() {
        if self.tableView.numberOfRowsInSection(0) > 0
        {
            self.tableView.hidden = false
            self.spinner.stopAnimating()
        }
        else {
            self.tableView.hidden = true
            self.spinner.startAnimating()
        }
    }
}