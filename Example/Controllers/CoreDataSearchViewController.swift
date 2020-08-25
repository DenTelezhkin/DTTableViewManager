//
//  CoreDataSearchViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 20.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager
import CoreData

class CoreDataSearchViewController: UIViewController, DTTableViewManageable {

    var tableView: UITableView!
    var noContentLabel: UILabel!
    let searchController = UISearchController(searchResultsController: nil)
    let fetchResultsController = CoreDataManager.sharedInstance.banksFetchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureSubviews()
        
        manager = DTTableViewManager(storage: CoreDataStorage(fetchedResultsController: fetchResultsController))
        manager.register(BankCell.self)
        manager.tableViewUpdater?.didUpdateContent = { [weak self] _ in
            // In some cases it makes sense to show no content view underneath tableView
            self?.tableView.isHidden = self?.tableView.numberOfSections == 0
            self?.noContentLabel.isHidden = self?.tableView.numberOfSections != 0
        }

        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func configureSubviews() {
        noContentLabel = UILabel()
        noContentLabel.translatesAutoresizingMaskIntoConstraints = false
        noContentLabel.text = "No banks found"
        noContentLabel.isHidden = true
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        view.addSubview(noContentLabel)
        noContentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noContentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension CoreDataSearchViewController : UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text ?? ""
        if searchString == "" {
            self.fetchResultsController.fetchRequest.predicate = nil
        } else {
            let predicate = NSPredicate(format: "name contains[c] %@ OR city contains[c] %@ OR state contains[c] %@",searchString,searchString,searchString)
            self.fetchResultsController.fetchRequest.predicate = predicate
        }
        try! fetchResultsController.performFetch()
        manager.tableViewUpdater?.storageNeedsReloading()
    }
}
