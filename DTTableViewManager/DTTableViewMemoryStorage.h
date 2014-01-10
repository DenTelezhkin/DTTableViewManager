//
//  DTTableViewDatasource.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.11.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
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
#import "DTTableViewDataStorage.h"
#import "DTModelSearching.h"
#import "DTSectionModel+HeaderFooterModel.h"
#import "DTMemoryStorage.h"

/**
 This class is used as a default storage for table view models. To populate this storage with data, call one of many add or insert methods available below. Every change in data storage causes delegate call to `DTTableViewController` instance with `DTStorageUpdate` instance. It is then expected to update UITableView with appropriate animations.
 
 ## Searching
 
 To implement search, your data models should implement `DTModelSearching` protocol. Specifically, on every change in UISearchBar, every model will get called with `shouldShowInSearchResultsForSearchString:inScopeIndex:` method. Based on the results, new searching storage will be created and used by `DTTableViewController` instance.
 */

@interface DTTableViewMemoryStorage : DTMemoryStorage <DTTableViewDataStorage>

/**
 Delegate object, that gets notified about data storage updates. If delegate does not respond to optional `DTTableViewDataStorageUpdating` methods, it will not get called.
 */
@property (nonatomic, weak) id <DTTableViewDataStorageUpdating> delegate;

/**
 Move table item from `sourceIndexPath` to `destinationIndexPath`.
 
 @param sourceIndexPath source indexPath of item to move.
 
 @param destinationIndexPath Index, where item should be moved.
 
 @warning Moving item at index, that is not valid, won't do anything, except logging into console about failure
 */
- (void)moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

/**
 Removes all tableItems. This method will call UITableView -reloadData method on completion. This method does not remove sections and section header and footer models.
 */
- (void)removeAllTableItems;

///---------------------------------------
/// @name Managing sections
///---------------------------------------

/**
 Set header models for UITableView sections. `DTSectionModel` objects are created automatically, if they don't exist already. Pass nil or empty array to this method to clear all section header models.
 
 @param headerModels Section header models to use.
 */
- (void)setSectionHeaderModels:(NSArray *)headerModels;

/**
 Set footer models for UITableView sections. `DTSectionModel` objects are created automatically, if they don't exist already. Pass nil or empty array to this method to clear all section footer models.
 
 @param footerModels Section footer models to use.
 */
- (void)setSectionFooterModels:(NSArray *)footerModels;

/**
 Moves a section to a new location in the table view.
 
 @param indexFrom The index of the section to move.
 
 @param indexTo The index in the table view that is the destination of the move for the section. The existing section at that location slides up or down to an adjoining index position to make room for it.
 */
- (void)moveSection:(NSInteger)indexFrom toSection:(NSInteger)indexTo;

@end
