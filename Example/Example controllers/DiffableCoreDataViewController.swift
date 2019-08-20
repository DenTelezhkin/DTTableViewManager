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
    var dataSource: UITableViewDiffableDataSource<String, Bank>!
    
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
        let snapshot = NSDiffableDataSourceSnapshot<String,Bank>()
        for section in sections {
            snapshot.appendSections([section.name])
            snapshot.appendItems((section.objects ?? []).compactMap { $0 as? Bank }, toSection: section.name)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    @IBAction func resetDataButtonTapped(_ sender: Any) {
        // This functionality is currently bugged as NSFetchedResultsController returns duplicated records each time
        // Which leads to displaying wrong data, even though database was cleared.
        // So we just pop to rootViewController.
        CoreDataManager.sharedInstance.resetData()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addRecordButtonTapped(_ sender: Any) {
        let context = CoreDataManager.sharedInstance.managedObjectContext
        _ = Bank(info: [
            "name": "Random bank name",
            "city": "Random city",
            "zip": ["111","222","333","4444"].randomElement() ?? "",
            "state": manager.supplementaryStorage?.headerModelProvider?((0..<(manager.storage.numberOfSections())).randomElement() ?? 0) as Any
        ], inContext: context)
        _ = try? context.save()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let genericSnapshot = NSDiffableDataSourceSnapshot<String,Bank>()
        for section in snapshot.sectionIdentifiers.compactMap({ $0 as? String}) {
            genericSnapshot.appendSections([section])
            genericSnapshot.appendItems(snapshot.itemIdentifiersInSection(withIdentifier: section)
                .compactMap { $0 as? NSManagedObjectID }
                .compactMap { CoreDataManager.sharedInstance.managedObjectContext.object(with: $0) }
                .compactMap { $0 as? Bank },
                                        toSection: section)
        }
        dataSource.apply(genericSnapshot, animatingDifferences: true)
    }}
