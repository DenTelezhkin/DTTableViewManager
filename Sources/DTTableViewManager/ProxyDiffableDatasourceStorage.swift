//
//  ProxyDiffableDatasourceStorage.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 7/23/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
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
import DTModelStorage
import UIKit

@available(iOS 13, tvOS 13, *)
public class ProxyDiffableDataSourceStorage: BaseSupplementaryStorage, Storage {
    private let numberOfSectionsInTableView: () -> Int
    public func numberOfSections() -> Int {
        return numberOfSectionsInTableView()
    }
    
    private let numberOfItemsInSection: (Int) -> Int
    public func numberOfItems(inSection section: Int) -> Int {
        return numberOfItemsInSection(section)
    }
    
    private let itemAtIndexPath: (IndexPath) -> Any?
    public func item(at indexPath: IndexPath) -> Any? {
        return itemAtIndexPath(indexPath)
    }
    
    public weak var delegate: StorageUpdating?
    
    public init<SectionIdentifier, ItemIdentifier>(tableView: UITableView, dataSource: UITableViewDiffableDataSource<SectionIdentifier, ItemIdentifier>, modelProvider: @escaping (IndexPath, ItemIdentifier) -> Any) {
        numberOfSectionsInTableView = { dataSource.numberOfSections(in: tableView) }
        numberOfItemsInSection = { dataSource.tableView(tableView, numberOfRowsInSection: $0) }
        itemAtIndexPath = {
            guard let itemIdentifier = dataSource.itemIdentifier(for: $0) else {
                return nil
            }
            return modelProvider($0, itemIdentifier)
        }
    }
    
    public init(tableView: UITableView, dataSource: UITableViewDiffableDataSourceReference, modelProvider: @escaping (IndexPath, Any) -> Any) {
            numberOfSectionsInTableView = { dataSource.numberOfSections(in: tableView) }
            numberOfItemsInSection = { dataSource.tableView(tableView, numberOfRowsInSection: $0) }
            itemAtIndexPath = {
                guard let itemIdentifier = dataSource.itemIdentifier(for: $0) else {
                    return nil
                }
                return modelProvider($0, itemIdentifier)
            }
        }
}
