//
//  DTTableViewReaction.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 19.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import DTModelStorage
import UIKit

enum TableViewReactionType
{
    case Selection
    case CellConfiguration
    case HeaderConfiguration
    case FooterConfiguration
    case ControllerWillUpdateContent
    case ControllerDidUpdateContent
}

protocol TableViewReactionData {}
extension NSIndexPath : TableViewReactionData{}
    
class TableViewReaction
{
    let reactionType : TableViewReactionType
    var cellType : _MirrorType?
    var reactionBlock: (() -> Void)?
    var reactionData : TableViewReactionData?
    
    func perform()
    {
        reactionBlock?()
    }
    
    init(reactionType : TableViewReactionType)
    {
        self.reactionType = reactionType
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