//
//  DTTableViewManager+Drag.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 26.08.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
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
import UIKit
import DTModelStorage

extension DTTableViewManager
{
    #if os(iOS) && swift(>=3.2)
    
    // MARK: - Drag
    @available(iOS 11, *)
    open func itemsForBeginningDragSession<T:ModelTransfer>(from cellClass: T.Type, _ closure: @escaping (UIDragSession, T,T.ModelType, IndexPath) -> [UIDragItem]) where T:UITableViewCell
    {
        tableDragDelegate?.append4ArgumentReaction(for: T.self,
                                                   signature: .itemsForBeginningDragSession,
                                                   closure: closure)
    }
    
    @available(iOS 11, *)
    open func itemsForAddingToDragSession<T:ModelTransfer>(from cellClass: T.Type, _ closure: @escaping (UIDragSession, CGPoint, T, T.ModelType, IndexPath) -> [UIDragItem]) where T: UITableViewCell
    {
        tableDragDelegate?.append5ArgumentReaction(for: T.self,
                                                   signature: .itemsForAddingToDragSession,
                                                   closure: closure)
    }
    
    @available(iOS 11, *)
    open func dragPreviewParameters<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> UIDragPreviewParameters?) where T:UITableViewCell {
        tableDragDelegate?.appendReaction(for: T.self,
                                          signature: .dragPreviewParametersForRowAtIndexPath,
                                          closure: closure)
    }
    
    @available(iOS 11, *)
    open func dragSessionWillBegin(_ closure: @escaping (UIDragSession) -> Void) {
        tableDragDelegate?.appendNonCellReaction(.dragSessionWillBegin, closure: closure)
    }
    
    @available(iOS 11, *)
    open func dragSessionDidEnd(_ closure: @escaping (UIDragSession) -> Void) {
        tableDragDelegate?.appendNonCellReaction(.dragSessionDidEnd, closure: closure)
    }
    
    @available(iOS 11, *)
    open func dragSessionAllowsMoveOperation(_ closure: @escaping (UIDragSession) -> Bool) {
        tableDragDelegate?.appendNonCellReaction(.dragSessionAllowsMoveOperation, closure: closure)
    }
    
    @available(iOS 11, *)
    open func dragSessionIsRestrictedToDraggingApplication(_ closure: @escaping (UIDragSession) -> Bool) {
        tableDragDelegate?.appendNonCellReaction(.dragSessionIsRestrictedToDraggingApplication, closure: closure)
    }
    #endif
}
