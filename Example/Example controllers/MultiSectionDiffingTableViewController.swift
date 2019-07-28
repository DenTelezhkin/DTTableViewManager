//
//  MultiSectionDiffingTableViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 7/20/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager
import DTModelStorage

@available(iOS 13.0, *)
class MultiSectionDiffingTableViewController: UITableViewController, DTTableViewManageable {

    lazy var students: [String: [String]] = {
        Bundle.main.path(forResource: "students", ofType: "json")
                    .flatMap { URL(fileURLWithPath: $0) }
                    .flatMap { try? Data(contentsOf: $0) }
                    .flatMap { try? JSONDecoder().decode([String:[String]].self, from: $0) } ?? [:]
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
        manager.register(StringCell.self)
        guard #available(iOS 13, *) else {
            let alert = UIAlertController(title: "Unavailable", message: "Multi-section diffing is supported on iOS 13 and higher", preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .default, handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
            return
        }
        diffableDataSource = manager.configureDiffableDataSource { indexPath, item in
            item
        }
        manager.supplementaryStorage?.setSectionHeaderModels(Section.allCases.map { $0.rawValue.capitalized })
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        updateUI(searchTerm: "", animated: false)
    }
    
    func updateUI(searchTerm: String, animated: Bool) {
        let snapshot : NSDiffableDataSourceSnapshot<Section, String> = .init()
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
