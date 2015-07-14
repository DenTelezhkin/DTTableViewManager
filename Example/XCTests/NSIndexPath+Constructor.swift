//
//  NSIndexPath+Constructor.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

func indexPath(item: Int, section: Int) -> NSIndexPath
{
    return NSIndexPath(forItem: item, inSection: section)
}