//
//  TableViewController+UnitTests.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 14.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

protocol IntModelRetrievable
{
    var model : Int! { get }
}

extension DTTableViewController
{
    func verifyItem(item: Int, atIndexPath indexPath: NSIndexPath) -> Bool
    {
        let itemDatasource = self.storage.objectAtIndexPath(indexPath) as! Int
        let itemTable = (self.tableView(self.tableView, cellForRowAtIndexPath: indexPath) as! IntModelRetrievable).model

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