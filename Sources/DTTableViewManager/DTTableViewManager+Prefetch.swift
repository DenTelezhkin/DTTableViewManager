//
//  DTTableViewManager+Prefetch.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 01.10.2022.
//  Copyright © 2022 Denys Telezhkin. All rights reserved.
//

import Foundation

/// Extension for prefetch events (UITableViewDataSourcePrefetching)
public extension CellViewModelMappingProtocolGeneric {
    
    /// Registers `closure` to be executed when `UITableViewDataSourcePrefetching.tableView(_:prefetchRowsAt:)` method is called, and indexPaths contains indexPath of Model in a storage.
    func prefetch(_ closure: @escaping (Model, IndexPath) -> Void) {
        reactions.append(EventReaction(modelType: Model.self, signature: EventMethodSignature.prefetchRowsAtIndexPaths.rawValue, closure))
    }
    
    /// Registers `closure` to be executed when `UITableViewDataSourcePrefetching.tableView(_:cancelPrefetchingForRowsAt:)` method is called, and indexPaths contains indexPath of Model in a storage.
    func cancelPrefetch(_ closure: @escaping (Model, IndexPath) -> Void) {
        reactions.append(EventReaction(modelType: Model.self, signature: EventMethodSignature.cancelPrefetchingForRowsAtIndexPaths.rawValue, closure))
    }
}
