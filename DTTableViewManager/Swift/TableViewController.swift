//
//  TableViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

enum SupplementarySectionStyle
{
    case Title
    case View
}

public class DTTableViewController: UIViewController {
    @IBOutlet var tableView : UITableView!

    private lazy var cellFactory: TableViewFactory = {
        precondition(self.tableView != nil, "Please call registration methods only when view is loaded")
        
        let factory = TableViewFactory(tableView: self.tableView)
        return factory
        }()
    
    var sectionHeaderStyle = SupplementarySectionStyle.Title
    var sectionFooterStyle = SupplementarySectionStyle.Title
    
    var displayHeaderOnEmptySection = true
    var displayFooterOnEmptySection = true
    
    var insertSectionAnimation = UITableViewRowAnimation.None
    var deleteSectionAnimation = UITableViewRowAnimation.Automatic
    var reloadSectionAnimation = UITableViewRowAnimation.Automatic

    var insertRowAnimation = UITableViewRowAnimation.Automatic
    var deleteRowAnimation = UITableViewRowAnimation.Automatic
    var reloadRowAnimation = UITableViewRowAnimation.Automatic
    
    var memoryStorage : MemoryStorage!
    {
        precondition(storage is MemoryStorage, "DTTableViewController memoryStorage method should be called only if you are using MemoryStorage")
        
        return storage as! MemoryStorage
    }
    
    var storage : StorageProtocol = {
        let storage = MemoryStorage()
        storage.supplementaryHeaderKind = DTTableViewElementSectionHeader
        storage.supplementaryFooterKind = DTTableViewElementSectionFooter
        return storage
    }()
    {
        didSet {
            if let headerFooterCompatibleStorage = storage as? BaseStorage {
                headerFooterCompatibleStorage.supplementaryHeaderKind = DTTableViewElementSectionHeader
                headerFooterCompatibleStorage.supplementaryFooterKind = DTTableViewElementSectionFooter
            }
            storage.delegate = self
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(tableView != nil, "Wire up UITableView outlet before creating \(self.dynamicType) controller")
        
        tableView.delegate = self
        tableView.dataSource = self
        // MARK: TODO use latest DTModelStorage for updates
        storage.delegate = self
    }
}

// MARK: Cell registration
extension DTTableViewController
{
    func registerCellClass<T:ModelTransfer>(cellType:T.Type)
    {
        self.cellFactory.registerCellClass(cellType)
    }
    
    func registerNibName<T:ModelTransfer>(nibName: String, cellType: T.Type)
    {
        self.cellFactory.registerNibName(nibName, cellType: cellType)
    }
}

extension DTTableViewController: UITableViewDataSource
{
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storage.sections[section].numberOfObjects
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.storage.sections.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.cellFactory.cellForModel(self.storage.objectAtIndexPath(indexPath)!, atIndexPath: indexPath)
    }
}

extension DTTableViewController: UITableViewDelegate
{
    
}

extension DTTableViewController : StorageUpdating
{
    public func storageDidPerformUpdate(update : StorageUpdate)
    {
        tableView.beginUpdates()
        
        tableView.deleteSections(update.deletedSectionIndexes, withRowAnimation: deleteSectionAnimation)
        tableView.insertSections(update.insertedSectionIndexes, withRowAnimation: insertSectionAnimation)
        tableView.reloadSections(update.updatedSectionIndexes, withRowAnimation: reloadSectionAnimation)
        
        tableView.deleteRowsAtIndexPaths(update.deletedRowIndexPaths, withRowAnimation: deleteRowAnimation)
        tableView.insertRowsAtIndexPaths(update.insertedRowIndexPaths, withRowAnimation: insertRowAnimation)
        tableView.reloadRowsAtIndexPaths(update.updatedRowIndexPaths, withRowAnimation: reloadRowAnimation)
        
        tableView.endUpdates()
    }
    
    public func storageNeedsReloading()
    {
        tableView.reloadData()
    }
}