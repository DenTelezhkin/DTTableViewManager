//
//  TableViewController+UnitTests.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 14.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import DTTableViewManager
import UIKit

protocol ModelRetrievable
{
    var model : Any! { get }
}

func recursiveForceUnwrap<T>(_ any: T) -> T
{
    let mirror = Mirror(reflecting: any)
    if mirror.displayStyle != .optional
    {
        return any
    }
    let (_,some) = mirror.children.first!
    return recursiveForceUnwrap(some) as! T
}

extension DTTestTableViewController
{
    func verifyItem<T:Equatable>(_ item: T, atIndexPath indexPath: IndexPath) -> Bool
    {
        let itemTable = (self.manager.tableDataSource?.tableView(self.tableView, cellForRowAt: indexPath) as! ModelRetrievable).model as! T
        let itemDatasource = recursiveForceUnwrap(self.manager.storage?.item(at: indexPath)!) as! T
        
        if !(item == itemDatasource)
        {
            return false
        }
        
        if !(item == itemTable)
        {
            return false
        }
        
        return true
    }
    
    func verifySection(_ section: [Int], withSectionNumber sectionNumber: Int) -> Bool
    {
        for itemNumber in 0..<section.count
        {
            if !(self.verifyItem(section[itemNumber], atIndexPath: IndexPath(item: itemNumber, section: sectionNumber)))
            {
                return false
            }
        }
        if self.manager.tableDataSource?.tableView(self.tableView, numberOfRowsInSection: sectionNumber) == section.count
        {
            return true
        }
        return false
    }
}
