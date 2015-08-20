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
import ModelStorage

class CoreDataSearchViewController: DTTableViewController {

    let searchController = UISearchController(searchResultsController: nil)
    let fetchResultsController: NSFetchedResultsController = {
    
        let context = CoreDataManager.sharedInstance.managedObjectContext
        let request = NSFetchRequest(entityName: "Bank")
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: "zip", ascending: true)]
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "state", cacheName: nil)
        fetchResultsController.performFetch(nil)
        return fetchResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerCellClass(BankCell)
        self.storage = CoreDataStorage(fetchedResultsController: fetchResultsController)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
    }
}

extension CoreDataSearchViewController : UISearchResultsUpdating
{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        if searchString == "" {
            self.fetchResultsController.fetchRequest.predicate = nil
        } else {
            let predicate = NSPredicate(format: "name contains %@ OR city contains %@ OR state contains %@",searchString,searchString,searchString)
            self.fetchResultsController.fetchRequest.predicate = predicate
        }
        self.fetchResultsController.performFetch(nil)
        tableView.reloadData()
        self.tableView.hidden = self.tableView.numberOfSections() == 0
    }
}
