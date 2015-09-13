//
//  DTTableViewReaction.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 19.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
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

/// Various DTTableViewManager events, that require some action.
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

/// This class represents reaction to certain event in DTTableViewManager - defined in TableViewReactionType enum.
class TableViewReaction
{
    let reactionType : TableViewReactionType
    var viewType : _MirrorType?
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

struct ViewConfiguration : TableViewReactionData
{
    let view : UIView
    let indexPath : NSIndexPath
}