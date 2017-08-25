//
//  DTTableViewDragDelegate.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 20.08.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

#if os(iOS) && swift(>=3.2)
    
@available(iOS 11.0, *)
open class DTTableViewDragDelegate: DTTableViewDelegateWrapper, UITableViewDragDelegate {
    public func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession,
                          at indexPath: IndexPath) -> [UIDragItem]
    {
        if let items = performCellReaction(.itemsForBeginningDragSession,
                                                     argument: session,
                                                     location: indexPath,
                                                     provideCell: true) as? [UIDragItem]
        {
            return items
        }
        return (delegate as? UITableViewDragDelegate)?.tableView(tableView, itemsForBeginning: session, at:indexPath) ?? []
    }
    
    public func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession,
                          at indexPath: IndexPath,
                          point: CGPoint) -> [UIDragItem]
    {
        if let items = performCellReaction(.itemsForAddingToDragSession,
                                           argumentOne: session,
                                           argumentTwo: point,
                                           location: indexPath,
                                           provideCell: true) as? [UIDragItem] {
            return items
        }
        return (delegate as? UITableViewDragDelegate)?.tableView?(tableView, itemsForAddingTo: session, at: indexPath, point: point) ?? []
    }
    
    public func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        if let reaction = cellReaction(.dragPreviewParametersForRowAtIndexPath, location: indexPath) {
            return performNillableCellReaction(reaction, location: indexPath, provideCell: true) as? UIDragPreviewParameters
        }
        return nil
    }
    
    override func delegateWasReset() {
        tableView?.dragDelegate = nil
        tableView?.dragDelegate = self
    }
}
#endif
