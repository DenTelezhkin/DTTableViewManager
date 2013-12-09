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
#import "DTTableViewModelSearching.h"
#import "DTTableViewSectionModel.h"

/**
 This class is used as a default storage for table view models. To populate this storage with data, call one of many add or insert methods available below. Every change in data storage causes delegate call to `DTTableViewController` instance with `DTTableViewUpdate` instance. It is then expected to update UITableView with appropriate animations.
 
 ## Searching
 
 To implement search, your data models should implement `DTTableViewModelSearching` protocol. Specifically, on every change in UISearchBar, every model will get called with `shouldShowInSearchResultsForSearchString:inScopeIndex:` method. Based on the results, new searching storage will be created and used by `DTTableViewController` instance.
 */

@interface DTTableViewMemoryStorage : NSObject <DTTableViewDataStorage>

/**
 Creates DTTableViewMemoryStorage with default configuration.
 */

+(instancetype)storage;

/**
 Contains array of DTTableViewSectionModel's. Every DTTableViewSectionModel contains NSMutableArray of objects - there all table view models are stored. Every DTTableViewSectionModel also contains header and footer models for sections.
 */

@property (nonatomic, strong) NSMutableArray * sections;

/**
 Delegate object, that gets notified about data storage updates. This property is automatically set by `DTTableViewController` instance, when setter for dataStorage property is called.
 */
@property (nonatomic, weak) id <DTTableViewDataStorageUpdating> delegate;


///---------------------------------------
/// @name Add table items
///---------------------------------------

/**
 Add tableItem to section 0.
 
 @param tableItem Model you want to add to the table
 */
- (void)addTableItem:(NSObject *)tableItem;

/**
 Add table items to section `section`.
 
 @param tableItem Model to add.
 
 @param section Section, where item will be added
 */
- (void)addTableItem:(NSObject *)tableItem toSection:(NSInteger)sectionNumber;

/**
 Add table items to section 0.
 
 @param tableItems models to add.
 */
- (void)addTableItems:(NSArray *)tableItems;

/**
 Add table items to section `section`.
 
 @param tableItems Models to add.
 
 @param section Section, where items will be added
 */
- (void)addTableItems:(NSArray *)tableItems
            toSection:(NSInteger)sectionNumber;

///---------------------------------------
/// @name Insert table items
///---------------------------------------

/**
 Insert table item to indexPath `indexPath`.
 
 @param tableItem model to insert.
 
 @param indexPath Index, where item should be inserted.
 
 @warning Inserting item at index, that is not occupied, will not throw an exception, and won't do anything, except logging into console about failure
 */
- (void)insertTableItem:(NSObject *)tableItem toIndexPath:(NSIndexPath *)indexPath;

///---------------------------------------
/// @name Reloading, replacing table items
///---------------------------------------

/**
 Reload UITableViewCell, that currently displays `tableItem`.
 
 @param tableItem model, which needs to be reloaded in the cell
 
 @param animation animation, that will be applied while cell is reloading
 */

-(void)reloadTableItem:(NSObject *)tableItem;

/**
 Replace tableItemToReplace with replacingTableItem. If tableItemToReplace is not found, or replacingTableItem is `nil`, this method does nothing.
 
 @param tableItemToReplace Model object you want to replace.
 
 @param replacingTableItem Model object you are replacing it with.
 */
- (void)replaceTableItem:(NSObject *)tableItemToReplace
           withTableItem:(NSObject *)replacingTableItem;

///---------------------------------------
/// @name Removing table items
///---------------------------------------

/**
 Removing tableItem. If tableItem is not found,  this method does nothing.
 
 @param tableItem Model object you want to remove.
 */
- (void)removeTableItem:(NSObject *)tableItem;

/**
 Removing tableItems. If some tableItem is not found, it is skipped.
 
 @param tableItems Models you want to remove.
 */
- (void)removeTableItems:(NSArray *)tableItems;

/**
 Removes all tableItems. This method DOES NOT reload data on tableView.
 */
- (void)removeAllTableItems;

///---------------------------------------
/// @name Managing sections
///---------------------------------------

/**
 Set header models for UITableView sections. `DTTableViewSectionModel` objects are created automatically, if they don't exist already. Pass nil or empty array to this method to clear all section header models.
 
 @param headerModels Section header models to use.
 */
-(void)setSectionHeaderModels:(NSArray *)headerModels;

/**
 Set footer models for UITableView sections. `DTTableViewSectionModel` objects are created automatically, if they don't exist already. Pass nil or empty array to this method to clear all section footer models.
 
 @param footerModels Section footer models to use.
 */
-(void)setSectionFooterModels:(NSArray *)footerModels;

/**
 Moves a section to a new location in the table view.
 
 @param indexFrom The index of the section to move.
 
 @param indexTo The index in the table view that is the destination of the move for the section. The existing section at that location slides up or down to an adjoining index position to make room for it.
 */
- (void)moveSection:(NSInteger)indexFrom toSection:(NSInteger)indexTo;

/**
 Deletes one or more sections in the receiver.
 
 @param indexSet An index set that specifies the sections to delete from the receiving table view. If a section exists after the specified index location, it is moved up one index location.
 */
- (void)deleteSections:(NSIndexSet *)indexSet;

///---------------------------------------
/// @name Search
///---------------------------------------

/**
 If item exists at `indexPath`, it's model will be returned. If section or row does not exist, method will return `nil`.
 
 @param indexPath Index of the item you wish to retrieve.
 
 @return model at indexPath. If section or row does not exist - `nil`.
 */
- (id)tableItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Searches for tableItem and returns it's indexPath. If there are many equal tableItems, indexPath of the first one will be returned.
 
 @param tableItem Model of the item you wish to find.
 
 @return indexPath of `tableItem`. If there are many equal tableItems, indexPath of the first one will be returned.
 */
- (NSIndexPath *)indexPathOfTableItem:(NSObject *)tableItem;

/**
 Returns array with table items in section.
 
 @param section Number of the section in table.
 
 @return array of table items in section. Empty array if section does not exist.
 */
- (NSArray *)tableItemsInSection:(NSInteger)section;

/**
 Method to retrieve section model from memory storage. This method safely creates section, if it doesn't exist already.
 
 You can use section model to change header and footer model. However, if you change objects of section manually, you are responsible for updating UITableView. Take a look at `DTTableViewDataStorageUpdating` protocol methods to do that.
 
 @param sectionNumber Number of section to retrieve
 
 @return DTTableViewSectionModel instance for current section
 */
- (DTTableViewSectionModel *)sectionAtIndex:(NSInteger)sectionNumber;

@end
