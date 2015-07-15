//
//  TableViewController+UnitTests.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 14.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

protocol ModelRetrievable
{
    var model : Any! { get }
}

func recursiveForceUnwrap<T>(any: T) -> T
{
    let mirror = reflect(any)
    if mirror.disposition != .Optional
    {
        return any
    }
    let (_,some) = mirror[0]
    return recursiveForceUnwrap(some.value as! T)
}

extension DTTableViewController
{
    func verifyItem<T:Equatable>(item: T, atIndexPath indexPath: NSIndexPath) -> Bool
    {
        let itemTable = (self.tableView(self.tableView, cellForRowAtIndexPath: indexPath) as! ModelRetrievable).model as! T
        let itemDatasource = recursiveForceUnwrap(self.storage.objectAtIndexPath(indexPath)!) as! T
        
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
    
    func verifySection(section: [Int], withSectionNumber sectionNumber: Int) -> Bool
    {
        for itemNumber in 0..<section.count
        {
            if !(self.verifyItem(section[itemNumber], atIndexPath: NSIndexPath(forItem: itemNumber, inSection: sectionNumber)))
            {
                return false
            }
        }
        if self.tableView(self.tableView, numberOfRowsInSection: sectionNumber) == section.count
        {
            return true
        }
        return false
    }
}