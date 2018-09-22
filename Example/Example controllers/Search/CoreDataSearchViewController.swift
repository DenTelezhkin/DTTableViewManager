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
import DTModelStorage

class CoreDataSearchViewController: UIViewController, DTTableViewManageable {

    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    let fetchResultsController: NSFetchedResultsController<Bank> = {
    
        let context = CoreDataManager.sharedInstance.managedObjectContext
        let request = NSFetchRequest<Bank>()
        request.entity = NSEntityDescription.entity(forEntityName: "Bank", in: context)
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: "zip", ascending: true)]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "state", cacheName: nil)
        try! fetchResultsController.performFetch()
        return fetchResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.register(BankCell.self)
        manager.storage = CoreDataStorage(fetchedResultsController: fetchResultsController)
        manager.tableViewUpdater?.didUpdateContent = { [weak self] _ in
            self?.tableView.isHidden = self?.tableView.numberOfSections == 0
        }

        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
    }
}

extension CoreDataSearchViewController : UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text ?? ""
        if searchString == "" {
            self.fetchResultsController.fetchRequest.predicate = nil
        } else {
            let predicate = NSPredicate(format: "name contains %@ OR city contains %@ OR state contains %@",searchString,searchString,searchString)
            self.fetchResultsController.fetchRequest.predicate = predicate
        }
        try! fetchResultsController.performFetch()
        tableView.reloadData()
    }
}
