//
//  MultiSectionDiffingTableViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 7/20/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager

class MultiSectionDiffingTableViewController: UITableViewController, DTTableViewManageable {

    lazy var students: [String: [String]] = {
        (try? JSONDecoder().decode([String:[String]].self,
                                   from: NSDataAsset(name: "students")?.data ?? .init())) ?? [:]
    }()
    
    enum Section: String, CaseIterable {
        case gryffindor
        case ravenclaw
        case hufflepuff
        case slytherin
    }
    let searchController = UISearchController(searchResultsController: nil)
    var diffableDataSource : UITableViewDiffableDataSource<Section, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.register(UITableViewCell.self, for: String.self) { cell, model, _ in
            cell.textLabel?.text = model
        }
        diffableDataSource = manager.configureDiffableDataSource { indexPath, item in
            item
        }
        manager.supplementaryStorage?.setSectionHeaderModels(Section.allCases.map { $0.rawValue.capitalized })
        manager.tableViewUpdater?.deleteRowAnimation = .fade
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        updateUI(searchTerm: "", animated: false)
    }
    
    func updateUI(searchTerm: String, animated: Bool) {
        var snapshot : NSDiffableDataSourceSnapshot<Section, String> = .init()
        for section in Section.allCases {
            let studentsInClass = students[section.rawValue.capitalized]?.filter { $0.lowercased().contains(searchTerm.lowercased()) || searchTerm.isEmpty } ?? []
            if !studentsInClass.isEmpty {
                snapshot.appendSections([section])
                snapshot.appendItems(studentsInClass)
            }
        }
        diffableDataSource?.apply(snapshot, animatingDifferences: animated)
    }
}

// MARK: - UISearchResultsUpdating
@available(iOS 13, *)
extension MultiSectionDiffingTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateUI(searchTerm: searchController.searchBar.text ?? "", animated: true)
    }
}
