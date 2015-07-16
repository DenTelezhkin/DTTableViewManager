//
//  DTMemoryStorage_DTTableViewAdditions.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 21.08.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <DTModelStorage/DTMemoryStorage.h>

#pragma clang assume_nonnull begin

/**
 This category is used to adapt DTMemoryStorage for table view models. It adds UITableView specific methods like moving items between indexPaths and moving sections in UITableView.
 */
@interface DTMemoryStorage (DTTableViewManager_Additions)

///---------------------------------------
/// @name Moving items and sections
///---------------------------------------

/**
 Move table item from `sourceIndexPath` to `destinationIndexPath`.
 
 @param sourceIndexPath source indexPath of item to move.
 
 @param destinationIndexPath Index, where item should be moved.
 
 @warning Moving item at index, that is not valid, won't do anything, except logging into console about failure
 */
- (void)moveTableItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

/**
 Moves a section to a new location in the table view.
 
 @param indexFrom The index of the section to move.
 
 @param indexTo The index in the table view that is the destination of the move for the section. The existing section at that location slides up or down to an adjoining index position to make room for it.
 */
- (void)moveTableViewSection:(NSInteger)indexFrom toSection:(NSInteger)indexTo;

///---------------------------------------
/// @name Remove all items
///---------------------------------------

/**
 Removes all tableItems. This method will call UITableView -reloadData method on completion. This method does not remove sections and section header and footer models.
 */
- (void)removeAllTableItems;

/**
 Removes all tableItems with animation. This method does not remove sections and section header and footer models.
 */
- (void)removeAllTableItemsAnimated;

@end

#pragma clang assume_nonnull end
