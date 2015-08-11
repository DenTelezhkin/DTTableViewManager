//
//  LocalSearchViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 03.08.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager
import ModelStorage

class LocalSearchViewController: DTTableViewController {

    let searchController = UISearchController(searchResultsController: nil)
    lazy var searchBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchButtonTapped:")
    let capitals = ["Europe": [("Ukraine","Kyiv"), ("England","London"), ("Portugal","Lissabon")],
                    "Asia": [("Thailand","Bangkok"), ("Oman","Maskat"), ("Lebanon","Beihrut")],
                    "Australia and Oceania":[("Fiji","Kanberra"), ("Australia","Kanberra")],
                    "Northern America":[("USA","Washington D.C."),("Mexico", "Mexico city")],
                    "Southern America":[("Chile","Santiago"),("Peru","Lima"),("Columbia","Bogota")],
                    "Africa":[("Mali","Bamako"),("Gana","Akkra"),("Togo","Lome")]
    ]
    
    lazy var fullStorage : MemoryStorage = self.memoryStorage
    var filteredStorage : MemoryStorage = MemoryStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerCellClass(CapitalCell)
//        fullStorage.setSectionHeaderModels([Any](capitals.keys) )
//        filteredStorage.setSectionHeaderModels(capitals.keys.array)
        
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
    }

    @IBAction func searchButtonTapped(sender: AnyObject) {
        searchController.active = true
    }
}

extension LocalSearchViewController : UISearchControllerDelegate
{
    func presentSearchController(searchController: UISearchController) {
        navigationItem.titleView = searchController.searchBar
        searchController.searchBar.becomeFirstResponder()
        navigationItem.rightBarButtonItem = nil
        navigationItem.hidesBackButton = true
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        navigationItem.rightBarButtonItem = searchBarButtonItem
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
    }
}

extension LocalSearchViewController : UISearchResultsUpdating
{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
}
