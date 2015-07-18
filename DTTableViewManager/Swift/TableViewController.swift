//
//  TableViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

public enum SupplementarySectionStyle
{
    case Title
    case View
}

public class DTTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet public var tableView : UITableView!

    private lazy var cellFactory: TableViewFactory = {
        precondition(self.tableView != nil, "Please call registration methods only when view is loaded")
        
        let factory = TableViewFactory(tableView: self.tableView)
        return factory
        }()
    
    public var sectionHeaderStyle = SupplementarySectionStyle.Title
    public var sectionFooterStyle = SupplementarySectionStyle.Title
    
    public var displayHeaderOnEmptySection = true
    public var displayFooterOnEmptySection = true
    
    public var insertSectionAnimation = UITableViewRowAnimation.None
    public var deleteSectionAnimation = UITableViewRowAnimation.Automatic
    public var reloadSectionAnimation = UITableViewRowAnimation.Automatic

    public var insertRowAnimation = UITableViewRowAnimation.Automatic
    public var deleteRowAnimation = UITableViewRowAnimation.Automatic
    public var reloadRowAnimation = UITableViewRowAnimation.Automatic
    
    public var memoryStorage : MemoryStorage!
    {
        precondition(storage is MemoryStorage, "DTTableViewController memoryStorage method should be called only if you are using MemoryStorage")
        
        return storage as! MemoryStorage
    }
    
    public var storage : StorageProtocol = {
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
    public func registerCellClass<T:ModelTransfer where T: UITableViewCell>(cellType:T.Type)
    {
        self.cellFactory.registerCellClass(cellType)
    }
    
    public func registerNibNamed<T:ModelTransfer where T: UITableViewCell>(nibName: String, forCellType cellType: T.Type)
    {
        self.cellFactory.registerNibNamed(nibName, forCellType: cellType)
    }
    
    public func registerHeaderClass<T:ModelTransfer where T: UIView>(headerType : T.Type)
    {
        self.sectionHeaderStyle = .View
        self.cellFactory.registerHeaderClass(headerType)
    }
    
    public func registerFooterClass<T:ModelTransfer where T:UIView>(footerType: T.Type)
    {
        self.sectionFooterStyle = .View
        self.cellFactory.registerFooterClass(footerType)
    }
    
    public func registerNibNamed<T:ModelTransfer where T:UIView>(nibName: String, forHeaderType headerType: T.Type)
    {
        self.sectionHeaderStyle = .View
        self.cellFactory.registerNibNamed(nibName, forHeaderType: headerType)
    }
    
    public func registerNibNamed<T:ModelTransfer where T:UIView>(nibName: String, forFooterType footerType: T.Type)
    {
        self.sectionFooterStyle = .View
        self.cellFactory.registerNibNamed(nibName, forFooterType: footerType)
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
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.sectionHeaderStyle == .Title { return nil }
        
        var model : Any?
        if self.storage is HeaderFooterStorageProtocol {
            model = (self.storage as! HeaderFooterStorageProtocol).headerModelForSectionIndex(section)
        }
        if self.storage.sections[section].numberOfObjects == 0 && !self.displayHeaderOnEmptySection {
            model = nil
        }
        return self.cellFactory.headerViewForModel(model)
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.sectionFooterStyle == .Title { return nil }
        
        var model : Any?
        if self.storage is HeaderFooterStorageProtocol {
            model = (self.storage as! HeaderFooterStorageProtocol).footerModelForSectionIndex(section)
        }
        if self.storage.sections[section].numberOfObjects == 0 && !self.displayFooterOnEmptySection {
            model = nil
        }
        return self.cellFactory.footerViewForModel(model)
    }
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