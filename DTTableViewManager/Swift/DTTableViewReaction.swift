//
//  DTTableViewReaction.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 19.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import DTModelStorage

enum TableViewReactionType
{
    case Selection
}

struct TableViewReaction
{
    let reactionType : TableViewReactionType
    let cellType : MirrorType
    let reactionBlock: (NSIndexPath) -> Void
}