//
//  DTTableViewReaction.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 19.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import ModelStorage
import UIKit

enum TableViewReactionType
{
    case Selection
    case CellConfiguration
    case HeaderConfiguration
    case FooterConfiguration
}

protocol TableViewReactionData {}
extension NSIndexPath : TableViewReactionData{}
    
class TableViewReaction
{
    let reactionType : TableViewReactionType
    let cellType : MirrorType
    var reactionBlock: (() -> Void)?
    var reactionData : TableViewReactionData?
    
    func perform()
    {
        reactionBlock?()
    }
    
    init(reactionType : TableViewReactionType, cellType: MirrorType)
    {
        self.reactionType = reactionType
        self.cellType = cellType
    }
}

struct CellConfiguration : TableViewReactionData
{
    let cell : UITableViewCell
    let indexPath: NSIndexPath
}

struct ViewConfiguration : TableViewReactionData
{
    let view : UIView
    let sectionIndex : Int
}