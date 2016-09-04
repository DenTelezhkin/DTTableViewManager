//
//  TableViewUpdater.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 03.09.16.
//  Copyright © 2016 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

/// `TableViewUpdater` is responsible for updating `UITableView`, when it receives storage updates.
open class TableViewUpdater : StorageUpdating {
    
    /// table view, that will be updated
    weak var tableView: UITableView?
    
    /// closure to be executed before content is updated
    public var willUpdateContent: ((StorageUpdate?) -> Void)? = nil
    
    /// closure to be executed after content is updated
    public var didUpdateContent: ((StorageUpdate?) -> Void)? = nil
    
    /// Insert section animation. Default - .None.
    public var insertSectionAnimation = UITableViewRowAnimation.none
    
    /// Delete section animation. Default - .Automatic
    public var deleteSectionAnimation = UITableViewRowAnimation.automatic
    
    /// Reload section animation. Default - .Automatic.
    public var reloadSectionAnimation = UITableViewRowAnimation.automatic
    
    /// Insert row animation. Default - .Automatic.
    public var insertRowAnimation = UITableViewRowAnimation.automatic
    
    /// Delete row animation. Default - .Automatic.
    public var deleteRowAnimation = UITableViewRowAnimation.automatic
    
    /// Reload row animation. Default - .Automatic.
    public var reloadRowAnimation = UITableViewRowAnimation.automatic
    
    /// Closure to be executed, when reloading a row.
    ///
    /// If this property is not nil, then reloadRowAnimation property is ignored.
    /// - SeeAlso: `DTTableViewManager.updateCellClosure()` method and `DTTableViewManager.coreDataUpdater()` method.
    public var reloadRowClosure : ((IndexPath) -> Void)?
    
    /// When this property is true, move events will be animated as delete event and insert event.
    public var animateMoveAsDeleteAndInsert: Bool
    
    /// Creates updater with tableView.
    public init(tableView: UITableView, reloadRow: ((IndexPath) -> Void)? = nil, animateMoveAsDeleteAndInsert: Bool = false) {
        self.tableView = tableView
        self.reloadRowClosure = reloadRow
        self.animateMoveAsDeleteAndInsert = animateMoveAsDeleteAndInsert
    }
    
    open func storageDidPerformUpdate(_ update : StorageUpdate)
    {
        willUpdateContent?(update)
        
        tableView?.beginUpdates()
        
        if update.deletedRowIndexPaths.count > 0 { tableView?.deleteRows(at: Array(update.deletedRowIndexPaths), with: deleteRowAnimation) }
        if update.insertedRowIndexPaths.count > 0 { tableView?.insertRows(at: Array(update.insertedRowIndexPaths), with: insertRowAnimation) }
        if update.updatedRowIndexPaths.count > 0 {
            if let closure = reloadRowClosure {
                update.updatedRowIndexPaths.forEach(closure)
            } else {
                tableView?.reloadRows(at: Array(update.updatedRowIndexPaths), with: reloadRowAnimation)
            }
        }
        if update.movedRowIndexPaths.count > 0 {
            for moveUpdate in update.movedRowIndexPaths {
                if let from = moveUpdate.first, let to = moveUpdate.last {
                    if animateMoveAsDeleteAndInsert {
                        tableView?.moveRow(at: from, to: to)
                    } else {
                        tableView?.deleteRows(at: [from], with: deleteRowAnimation)
                        tableView?.insertRows(at: [to], with: insertRowAnimation)
                    }
                }
            }
        }
        
        if update.deletedSectionIndexes.count > 0 { tableView?.deleteSections(IndexSet(update.deletedSectionIndexes), with: deleteSectionAnimation) }
        if update.insertedSectionIndexes.count > 0 { tableView?.insertSections(IndexSet(update.insertedSectionIndexes), with: insertSectionAnimation) }
        if update.updatedSectionIndexes.count > 0 { tableView?.reloadSections(IndexSet(update.updatedSectionIndexes), with: reloadSectionAnimation)}
        if update.movedSectionIndexes.count > 0 {
            for moveUpdate in update.movedSectionIndexes {
                if let from = moveUpdate.first, let to = moveUpdate.last {
                    tableView?.moveSection(from, toSection: to)
                }
            }
        }
        tableView?.endUpdates()
        didUpdateContent?(update)
    }
    
    /// Call this method, if you want UITableView to be reloaded, and beforeContentUpdate: and afterContentUpdate: closures to be called.
    open func storageNeedsReloading()
    {
        willUpdateContent?(nil)
        tableView?.reloadData()
        didUpdateContent?(nil)
    }
}
