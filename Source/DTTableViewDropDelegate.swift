//
//  DTTableViewDropDelegate.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 20.08.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
//

import UIKit

#if os(iOS) && swift(>=3.2)
@available(iOS 11.0, *)
open class DTTableViewDropDelegate: DTTableViewDelegateWrapper, UITableViewDropDelegate {
    public func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
    }
    
    override func delegateWasReset() {
        tableView?.dropDelegate = nil
        tableView?.dropDelegate = self
    }
}
#endif
