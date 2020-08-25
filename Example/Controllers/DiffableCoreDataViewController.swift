//
//  DiffableCoreDataViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 7/28/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager
import CoreData

class DiffableCoreDataViewController: UITableViewController, DTTableViewManageable, NSFetchedResultsControllerDelegate {

    let fetchController = CoreDataManager.sharedInstance.banksFetchController()
    var dataSource: UITableViewDiffableDataSource<String, Bank>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.register(BankCell.self) { mapping in
            mapping.trailingSwipeActionsConfiguration { _, model, _ in
                UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "Delete", handler: { _, _, _ in
                    CoreDataManager.sharedInstance.managedObjectContext.delete(model)
                    try? CoreDataManager.sharedInstance.managedObjectContext.save()
                })])
            }
        }
        dataSource = manager.configureDiffableDataSource(modelProvider: { [weak self] indexPath, identifier in
            self?.fetchController.object(at: indexPath) as Any
        })
        manager.supplementaryStorage?.headerModelProvider = { [weak self] in
            if let sections = self?.fetchController.sections {
                if $0 >= sections.count { return nil }
                return sections[$0].name
            }
            return nil
        }
        updateSnapshot(animatingDifferences: false)
        fetchController.delegate = self
        navigationItem.rightBarButtonItems = [
            barButton(title: "Add", action: { vc in vc.addRecordButtonTapped()} ),
            barButton(title: "Reset", action: { vc in vc.resetDataButtonTapped() })
        ]
    }
    
    func updateSnapshot(animatingDifferences: Bool) {
        guard let sections = fetchController.sections else { return }
        var snapshot = NSDiffableDataSourceSnapshot<String,Bank>()
        for section in sections {
            snapshot.appendSections([section.name])
            snapshot.appendItems((section.objects ?? []).compactMap { $0 as? Bank }, toSection: section.name)
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func resetDataButtonTapped() {
        // This functionality is currently bugged as NSFetchedResultsController returns duplicated records each time
        // Which leads to displaying wrong data, even though database was cleared.
        // So we just pop to rootViewController.
        CoreDataManager.sharedInstance.resetData()
        navigationController?.popViewController(animated: true)
    }
    
    func addRecordButtonTapped() {
        let context = CoreDataManager.sharedInstance.managedObjectContext
        _ = Bank(info: [
            "name": "Random bank name",
            "city": "Random city",
            "zip": ["111","222","333","4444"].randomElement() ?? "",
            "state": manager.supplementaryStorage?.headerModelProvider?((0..<(manager.storage.numberOfSections())).randomElement() ?? 0) as Any
        ], inContext: context)
        try? context.save()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot(animatingDifferences: true)
    }
}
