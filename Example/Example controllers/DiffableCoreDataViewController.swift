//
//  DiffableCoreDataViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 7/28/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager
import DTModelStorage
import CoreData

@available(iOS 13, *)
class DiffableCoreDataViewController: UITableViewController, DTTableViewManageable, NSFetchedResultsControllerDelegate {

    let fetchController = CoreDataManager.sharedInstance.banksFetchController()
    var dataSource: UITableViewDiffableDataSourceReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.register(BankCell.self)
        
        guard #available(iOS 13, *) else {
            showiOS13RequiredAlert()
            return 
        }
        dataSource = manager.configureDiffableDataSource(modelProvider: { [weak self] indexPath, identifier in
            return self?.fetchController.object(at: indexPath) as Any
        })
        manager.supplementaryStorage?.headerModelProvider = { [weak self] in
            if let sections = self?.fetchController.sections {
                if $0 >= sections.count { return nil }
                return sections[$0].name
            }
            return nil
        }
        updateInitialSnapshot()
        fetchController.delegate = self
    }
    
    func updateInitialSnapshot() {
        guard let sections = fetchController.sections else { return }
        let snapshot = NSDiffableDataSourceSnapshotReference()
        for (index, section) in sections.enumerated() {
            snapshot.appendSections(withIdentifiers: [index])
            snapshot.appendItems(withIdentifiers: section.objects ?? [], intoSectionWithIdentifier: index)
        }
        dataSource.applySnapshot(snapshot, animatingDifferences: false)
    }
    
    @IBAction func resetDataButtonTapped(_ sender: Any) {
        CoreDataManager.sharedInstance.resetData()
    }
    
    @IBAction func addRecordButtonTapped(_ sender: Any) {
        let context = CoreDataManager.sharedInstance.managedObjectContext
        _ = Bank(info: [
            "name": "Random bank name",
            "city": "Random city",
            "zip": ["111","222","333","4444"].randomElement() ?? "",
            "state": manager.supplementaryStorage?.headerModelProvider?((0...(manager.storage?.numberOfSections() ?? 0)).randomElement() ?? 0) as Any
        ], inContext: context)
        _ = try? context.save()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        dataSource.applySnapshot(snapshot, animatingDifferences: true)
    }
}
