//
//  TableViewUpdater.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 03.09.16.
//  Copyright © 2016 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import DTModelStorage

/// `TableViewUpdater` is responsible for updating `UITableView`, when it receives storage updates.
open class TableViewUpdater : StorageUpdating {
    
    /// table view, that will be updated
    weak var tableView: UITableView?
    
    /// closure to be executed before content is updated
    open var willUpdateContent: ((StorageUpdate?) -> Void)? = nil
    
    /// closure to be executed after content is updated
    open var didUpdateContent: ((StorageUpdate?) -> Void)? = nil
    
    /// Insert section animation. Default - .None.
    open var insertSectionAnimation = UITableViewRowAnimation.none
    
    /// Delete section animation. Default - .Automatic
    open var deleteSectionAnimation = UITableViewRowAnimation.automatic
    
    /// Reload section animation. Default - .Automatic.
    open var reloadSectionAnimation = UITableViewRowAnimation.automatic
    
    /// Insert row animation. Default - .Automatic.
    open var insertRowAnimation = UITableViewRowAnimation.automatic
    
    /// Delete row animation. Default - .Automatic.
    open var deleteRowAnimation = UITableViewRowAnimation.automatic
    
    /// Reload row animation. Default - .Automatic.
    open var reloadRowAnimation = UITableViewRowAnimation.automatic
    
    /// Closure to be executed, when reloading a row.
    ///
    /// If this property is not nil, then reloadRowAnimation property is ignored.
    /// - SeeAlso: `DTTableViewManager.updateCellClosure()` method and `DTTableViewManager.coreDataUpdater()` method.
    open var reloadRowClosure : ((IndexPath,Any) -> Void)?
    
    /// When this property is true, move events will be animated as delete event and insert event.
    open var animateMoveAsDeleteAndInsert: Bool
    
    /// Creates updater with tableView.
    public init(tableView: UITableView, reloadRow: ((IndexPath,Any) -> Void)? = nil, animateMoveAsDeleteAndInsert: Bool = false) {
        self.tableView = tableView
        self.reloadRowClosure = reloadRow
        self.animateMoveAsDeleteAndInsert = animateMoveAsDeleteAndInsert
    }
    
    open func storageDidPerformUpdate(_ update : StorageUpdate)
    {
        willUpdateContent?(update)
        
        tableView?.beginUpdates()
        
        applyObjectChanges(from: update)
        applySectionChanges(from: update)
        
        tableView?.endUpdates()
        didUpdateContent?(update)
    }
    
    private func applyObjectChanges(from update: StorageUpdate) {
        for (change,indexPaths) in update.objectChanges {
            switch change {
            case .insert:
                if let indexPath = indexPaths.first {
                    tableView?.insertRows(at: [indexPath], with: insertRowAnimation)
                }
            case .delete:
                if let indexPath = indexPaths.first {
                    tableView?.deleteRows(at: [indexPath], with: deleteRowAnimation)
                }
            case .update:
                if let indexPath = indexPaths.first {
                    if let closure = reloadRowClosure, let model = update.updatedObjects[indexPath] {
                        closure(indexPath,model)
                    } else {
                        tableView?.reloadRows(at: [indexPath], with: reloadRowAnimation)
                    }
                }
            case .move:
                if let source = indexPaths.first, let destination = indexPaths.last {
                    if animateMoveAsDeleteAndInsert {
                        tableView?.moveRow(at: source, to: destination)
                    } else {
                        tableView?.deleteRows(at: [source], with: deleteRowAnimation)
                        tableView?.insertRows(at: [destination], with: insertRowAnimation)
                    }
                }
            }
        }
    }
    
    private func applySectionChanges(from update: StorageUpdate) {
        for (change,indices) in update.sectionChanges {
            switch change {
            case .delete:
                if let index = indices.first {
                    tableView?.deleteSections([index], with: deleteSectionAnimation)
                }
            case .insert:
                if let index = indices.first {
                    tableView?.insertSections([index], with: insertSectionAnimation)
                }
            case .update:
                if let index = indices.first {
                    tableView?.reloadSections([index], with: reloadSectionAnimation)
                }
            case .move:
                if let source = indices.first, let destination = indices.last {
                    tableView?.moveSection(source, toSection: destination)
                }
            }
        }
    }
    
    /// Call this method, if you want UITableView to be reloaded, and beforeContentUpdate: and afterContentUpdate: closures to be called.
    open func storageNeedsReloading()
    {
        willUpdateContent?(nil)
        tableView?.reloadData()
        didUpdateContent?(nil)
    }
}
