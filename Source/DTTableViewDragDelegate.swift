//
//  DTTableViewDragDelegate.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 20.08.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

#if os(iOS)

@available(iOS 11.0, *)
open class DTTableViewDragDelegate: DTTableViewDelegateWrapper, UITableViewDragDelegate {
    public func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let item = storage.item(at: indexPath),
            let model = RuntimeHelper.recursivelyUnwrapAnyValue(item),
            let cell = tableView.cellForRow(at: indexPath) else { return [] }
        if let items = tableViewEventReactions
               .perform4ArgumentsReaction(of: .cell,
                                   signature: EventMethodSignature.itemsForBeginningDragSession.rawValue,
                                    argument: session,
                                        view: cell,
                                       model: model,
                                    location: indexPath) as? [UIDragItem] {
            return items
        }
        return (delegate as? UITableViewDragDelegate)?.tableView(tableView, itemsForBeginning: session, at:indexPath) ?? []
    }
    
    override func delegateWasReset() {
        tableView?.dragDelegate = nil
        tableView?.dragDelegate = self
    }
}

#endif
