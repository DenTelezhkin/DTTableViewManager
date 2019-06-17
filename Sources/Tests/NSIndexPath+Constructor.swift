//
//  NSIndexPath+Constructor.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

func indexPath(_ item: Int, _ section: Int) -> IndexPath
{
    return IndexPath(item: item, section: section)
}
