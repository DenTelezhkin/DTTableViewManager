//
//  TableViewController.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import ModelStorage

public protocol DTTableViewManageable : NSObjectProtocol
{
    var tableView : UITableView! { get }
}

private var DTTableViewManagerAssociatedKey = "Manager Associated Key"
extension DTTableViewManageable
{
    public var manager : DTTableViewManager
    {
        get {
            var object = objc_getAssociatedObject(self, &DTTableViewManagerAssociatedKey)
            if object == nil {
                object = DTTableViewManager()
                objc_setAssociatedObject(self, &DTTableViewManagerAssociatedKey, object, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return object as! DTTableViewManager
        }
        set {
            objc_setAssociatedObject(self, &DTTableViewManagerAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public class DTTableViewManager : NSObject {
    
    var tableView : UITableView!
    {
        return self.delegate?.tableView
    }
    
    weak var delegate : DTTableViewManageable?

    private lazy var cellFactory: TableViewFactory = {
        precondition(self.tableView != nil, "Please call manager.startManagingWithDelegate(self) before calling any other DTTableViewManager methods")
        return TableViewFactory(tableView: self.tableView)
    }()
    
    public var viewBundle = NSBundle.mainBundle()
    {
        didSet {
            cellFactory.bundle = viewBundle
        }
    }
    
    public var configuration = TableViewConfiguration()
    
    var tableViewReactions = [TableViewReaction]()
    
    func reactionOfReactionType(type: TableViewReactionType, forCellType cellType: _MirrorType?) -> TableViewReaction?
    {
        return self.tableViewReactions.filter({ (reaction) -> Bool in
            return reaction.reactionType == type && reaction.cellType?.summary == cellType?.summary
        }).first
    }
    
    public var memoryStorage : MemoryStorage!
    {
        precondition(storage is MemoryStorage, "DTTableViewController memoryStorage method should be called only if you are using MemoryStorage")
        
        return storage as! MemoryStorage
    }
    
    public var storage : StorageProtocol = {
        let storage = MemoryStorage()
        storage.configureForTableViewUsage()
        return storage
    }()
    {
        willSet {
            // explicit self is required due to known bug in Swift compiler - https://devforums.apple.com/message/1065306#1065306
            self.storage.delegate = nil
        }
        didSet {
            if let headerFooterCompatibleStorage = storage as? BaseStorage {
                headerFooterCompatibleStorage.configureForTableViewUsage()
            }
            storage.delegate = self
        }
    }
    
    public func startManagingWithDelegate(delegate : DTTableViewManageable)
    {
        precondition(delegate.tableView != nil,"Call startManagingWithDelegate: method only when UITableView has been created")
        
        self.delegate = delegate
        delegate.tableView.delegate = self
        delegate.tableView.dataSource = self
    }
    
    func headerModelForSectionIndex(index: Int) -> Any?
    {
        if self.storage.sections[index].numberOfObjects == 0 && !configuration.displayHeaderOnEmptySection
        {
            return nil
        }
        return (self.storage as? HeaderFooterStorageProtocol)?.headerModelForSectionIndex(index)
    }
    
    func footerModelForSectionIndex(index: Int) -> Any?
    {
        if self.storage.sections[index].numberOfObjects == 0 && !configuration.displayFooterOnEmptySection
        {
            return nil
        }
        return (self.storage as? HeaderFooterStorageProtocol)?.footerModelForSectionIndex(index)
    }
}

// MARK: Runtime forwarding
extension DTTableViewManager
{
    public override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        return delegate
    }
    
    public override func respondsToSelector(aSelector: Selector) -> Bool {
        if self.delegate?.respondsToSelector(aSelector) ?? false {
            return true
        }
        return super.respondsToSelector(aSelector)
    }
}

// MARK: Cell registration
extension DTTableViewManager
{
    public func registerCellClass<T:ModelTransfer where T: UITableViewCell>(cellType:T.Type)
    {
        self.cellFactory.registerCellClass(cellType)
    }
    
    public func registerCellClass<T:ModelTransfer where T:UITableViewCell>(cellType: T.Type,
        selectionClosure: (T,T.CellModel, NSIndexPath) -> Void)
    {
        self.cellFactory.registerCellClass(cellType)
        self.whenSelected(cellType, selectionClosure)
    }

    public func registerNibNamed<T:ModelTransfer where T: UITableViewCell>(nibName: String, forCellType cellType: T.Type)
    {
        self.cellFactory.registerNibNamed(nibName, forCellType: cellType)
    }
    
    public func registerHeaderClass<T:ModelTransfer where T: UIView>(headerType : T.Type)
    {
        configuration.sectionHeaderStyle = .View
        self.cellFactory.registerHeaderClass(headerType)
    }
    
    public func registerFooterClass<T:ModelTransfer where T:UIView>(footerType: T.Type)
    {
        configuration.sectionFooterStyle = .View
        cellFactory.registerFooterClass(footerType)
    }
    
    public func registerNibNamed<T:ModelTransfer where T:UIView>(nibName: String, forHeaderType headerType: T.Type)
    {
        configuration.sectionHeaderStyle = .View
        cellFactory.registerNibNamed(nibName, forHeaderType: headerType)
    }
    
    public func registerNibNamed<T:ModelTransfer where T:UIView>(nibName: String, forFooterType footerType: T.Type)
    {
        configuration.sectionFooterStyle = .View
        cellFactory.registerNibNamed(nibName, forFooterType: footerType)
    }
    
}

// MARK: Table view reactions
extension DTTableViewManager
{
    public func whenSelected<T:ModelTransfer where T:UITableViewCell>(cellClass:  T.Type, _ closure: (T,T.CellModel, NSIndexPath) -> Void)
    {
        let reaction = TableViewReaction(reactionType: .Selection)
        reaction.cellType = _reflect(T)
        reaction.reactionBlock = { [weak self, reaction] in
            if let indexPath = reaction.reactionData as? NSIndexPath,
                let cell = self?.tableView.cellForRowAtIndexPath(indexPath),
                let model = self?.storage.objectAtIndexPath(indexPath)
            {
                closure(cell as! T, model as! T.CellModel, indexPath)
            }
        }
        self.tableViewReactions.append(reaction)
    }
    
    public func configureCell<T:ModelTransfer where T: UITableViewCell>(cellClass:T.Type, _ closure: (T, T.CellModel, NSIndexPath) -> Void)
    {
        let reaction = TableViewReaction(reactionType: .CellConfiguration)
        reaction.cellType = _reflect(T)
        reaction.reactionBlock = { [weak self, reaction] in
            if let configuration = reaction.reactionData as? CellConfiguration,
                let model = self?.storage.objectAtIndexPath(configuration.indexPath)
            {
                closure(configuration.cell as! T, model as! T.CellModel, configuration.indexPath)
            }
        }
        self.tableViewReactions.append(reaction)
    }
    
    public func configureHeader<T:ModelTransfer where T: UIView>(headerClass: T.Type, _ closure: (T, T.CellModel, NSInteger) -> Void)
    {
        let reaction = TableViewReaction(reactionType: .HeaderConfiguration)
        reaction.cellType = _reflect(T)
        reaction.reactionBlock = { [weak self, reaction] in
            if let configuration = reaction.reactionData as? ViewConfiguration,
                let headerStorage = self?.storage as? HeaderFooterStorageProtocol,
                let model = headerStorage.headerModelForSectionIndex(configuration.sectionIndex)
            {
                closure(configuration.view as! T, model as! T.CellModel, configuration.sectionIndex)
            }
        }
        self.tableViewReactions.append(reaction)
    }
    
    public func configureFooter<T:ModelTransfer where T: UIView>(footerClass: T.Type, _ closure: (T, T.CellModel, NSInteger) -> Void)
    {
        let reaction = TableViewReaction(reactionType: .FooterConfiguration)
        reaction.cellType = _reflect(T)
        reaction.reactionBlock = { [weak self, reaction] in
            if let configuration = reaction.reactionData as? ViewConfiguration,
                let footerStorage = self?.storage as? HeaderFooterStorageProtocol,
                let model = footerStorage.footerModelForSectionIndex(configuration.sectionIndex)
            {
                closure(configuration.view as! T, model as! T.CellModel, configuration.sectionIndex)
            }
        }
        self.tableViewReactions.append(reaction)
    }
    
    public func beforeContentUpdate(block: () -> Void )
    {
        let reaction = TableViewReaction(reactionType: .ControllerWillUpdateContent)
        reaction.reactionBlock = block
        self.tableViewReactions.append(reaction)
    }
    
    public func afterContentUpdate(block : () -> Void )
    {
        let reaction = TableViewReaction(reactionType: .ControllerDidUpdateContent)
        reaction.reactionBlock = block
        self.tableViewReactions.append(reaction)
    }
}

extension DTTableViewManager: UITableViewDataSource
{
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storage.sections[section].numberOfObjects
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.storage.sections.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = self.storage.objectAtIndexPath(indexPath)!
        let cell = self.cellFactory.cellForModel(model, atIndexPath: indexPath)
        
        if let reaction = self.reactionOfReactionType(.CellConfiguration, forCellType: _reflect(cell.dynamicType)) {
            reaction.reactionData = CellConfiguration(cell:cell, indexPath:indexPath)
            reaction.perform()
        }
        return cell
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if configuration.sectionHeaderStyle == .View { return nil }
        
        return self.headerModelForSectionIndex(section) as? String
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if configuration.sectionFooterStyle == .View { return nil }
        
        return self.footerModelForSectionIndex(section) as? String
    }
    
    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if let storage = self.storage as? MemoryStorage
        {
            if let from = storage.sections[sourceIndexPath.section] as? SectionModel,
               let to = storage.sections[destinationIndexPath.section] as? SectionModel
            {
                    let item = from.objects[sourceIndexPath.row]
                    
                    from.objects.removeAtIndex(sourceIndexPath.row)
                    to.objects.insert(item, atIndex: destinationIndexPath.row)
            }
        }
    }
}

extension DTTableViewManager: UITableViewDelegate
{
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if configuration.sectionHeaderStyle == .Title { return nil }
        
        if let model = self.headerModelForSectionIndex(section) {
            let view = self.cellFactory.headerViewForModel(model)
            if let reaction = self.reactionOfReactionType(.HeaderConfiguration, forCellType: _reflect(view!.dynamicType)),
                let createdView = view
            {
                reaction.reactionData = ViewConfiguration(view: createdView, sectionIndex: section)
                reaction.perform()
            }
            return view
        }
        return nil
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if configuration.sectionFooterStyle == .Title { return nil }
        
        if let model = self.footerModelForSectionIndex(section) {
            let view = self.cellFactory.footerViewForModel(model)
            if let reaction = self.reactionOfReactionType(.FooterConfiguration, forCellType: _reflect(view!.dynamicType)),
                let createdView = view
            {
                reaction.reactionData = ViewConfiguration(view: createdView, sectionIndex: section)
                reaction.perform()
            }
            return view
        }
        return nil
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if configuration.sectionHeaderStyle == .Title {
            if let _ = self.headerModelForSectionIndex(section) {
                return UITableViewAutomaticDimension
            }
            return CGFloat.min
        }
        
        if let _ = self.headerModelForSectionIndex(section) {
            return self.tableView.sectionHeaderHeight
        }
        return CGFloat.min
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if configuration.sectionFooterStyle == .Title {
            if let _ = self.footerModelForSectionIndex(section) {
                return UITableViewAutomaticDimension
            }
            return CGFloat.min
        }
        
        if let _ = self.footerModelForSectionIndex(section) {
            return self.tableView.sectionFooterHeight
        }
        return CGFloat.min
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        if let reaction = self.reactionOfReactionType(.Selection, forCellType: _reflect(cell.dynamicType)) {
            reaction.reactionData = indexPath
            reaction.perform()
        }
    }
}

extension DTTableViewManager : StorageUpdating
{
    public func storageDidPerformUpdate(update : StorageUpdate)
    {
        self.controllerWillUpdateContent()

        tableView.beginUpdates()
        
        tableView.deleteSections(update.deletedSectionIndexes, withRowAnimation: configuration.deleteSectionAnimation)
        tableView.insertSections(update.insertedSectionIndexes, withRowAnimation: configuration.insertSectionAnimation)
        tableView.reloadSections(update.updatedSectionIndexes, withRowAnimation: configuration.reloadSectionAnimation)
        
        tableView.deleteRowsAtIndexPaths(update.deletedRowIndexPaths, withRowAnimation: configuration.deleteRowAnimation)
        tableView.insertRowsAtIndexPaths(update.insertedRowIndexPaths, withRowAnimation: configuration.insertRowAnimation)
        tableView.reloadRowsAtIndexPaths(update.updatedRowIndexPaths, withRowAnimation: configuration.reloadRowAnimation)
        
        tableView.endUpdates()
        
        self.controllerDidUpdateContent()
    }
    
    public func storageNeedsReloading()
    {
        self.controllerWillUpdateContent()
        tableView.reloadData()
        self.controllerDidUpdateContent()
    }
    
    func controllerWillUpdateContent()
    {
        if let reaction = self.reactionOfReactionType(.ControllerWillUpdateContent, forCellType: nil)
        {
            reaction.perform()
        }
    }
    
    func controllerDidUpdateContent()
    {
        if let reaction = self.reactionOfReactionType(.ControllerDidUpdateContent, forCellType: nil)
        {
            reaction.perform()
        }
    }
}

extension DTTableViewManager : TableViewStorageUpdating
{
    public func performAnimatedUpdate(block: UITableView -> Void) {
        block(self.tableView)
    }
}