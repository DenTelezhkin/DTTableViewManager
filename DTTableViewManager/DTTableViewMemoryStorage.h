//
//  DTTableViewDatasource.h
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.11.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTTableViewDataStorage.h"

@interface DTTableViewMemoryStorage : NSObject <DTTableViewDataStorage>

/**
 Contains array of DTTableViewSectionModel's.
 */

@property (nonatomic, strong) NSMutableArray * sections;

@property (nonatomic, weak) id <DTTableViewDataStorageUpdating> delegate;


///---------------------------------------
/// @name Add table items
///---------------------------------------

/**
 Add tableItem to section 0. Table will be automatically updated with `UITableViewRowAnimationNone` animation.
 
 @param tableItem Model you want to add to the table
 */
- (void)addTableItem:(NSObject *)tableItem;

/**
 Add table items to section `section`. Table will be automatically updated using `UITableViewRowAnimationNone` animation.
 
 @param tableItem Model to add.
 
 @param section Section, where item will be added
 */
- (void)addTableItem:(NSObject *)tableItem toSection:(NSInteger)sectionNumber;

/**
 Add table items to section 0. Table will be automatically updated using `UITableViewRowAnimationNone`` animation.
 
 @param tableItems models to add.
 */
- (void)addTableItems:(NSArray *)tableItems;

/**
 Add table items to section `section`. Table will be automatically updated using `UITableViewRowAnimationNone` animation.
 
 @param tableItems Models to add.
 
 @param section Section, where items will be added
 */
- (void)addTableItems:(NSArray *)tableItems
            toSection:(NSInteger)sectionNumber;

///---------------------------------------
/// @name Insert table items
///---------------------------------------

/**
 Insert table item to indexPath `indexPath`. Table will be automatically updated using `UITableViewRowAnimationNone` style.
 
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
 Replace tableItemToReplace with replacingTableItem. Table is immediately updated with `UITableViewRowAnimationNone` animation. If tableItemToReplace is not found, or replacingTableItem is `nil`, this method does nothing.
 
 @param tableItemToReplace Model object you want to replace.
 
 @param replacingTableItem Model object you are replacing it with.
 */
- (void)replaceTableItem:(NSObject *)tableItemToReplace
           withTableItem:(NSObject *)replacingTableItem;

///---------------------------------------
/// @name Removing table items
///---------------------------------------

/**
 Removing tableItem. Table is immediately updated with `UITableViewRowAnimationNone` animation. If tableItem is not found,  this method does nothing.
 
 @param tableItem Model object you want to remove.
 */
- (void)removeTableItem:(NSObject *)tableItem;

/**
 Removing tableItems. All deletions are made inside beginUpdates and endUpdates tableView block. After all deletions are made, `UITableViewRowAnimationNone` animation is applied. If some tableItem is not found, it is skipped.
 
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

-(void)setSectionHeaderModels:(NSArray *)headerModels;
-(void)setSectionHeaderTitles:(NSArray *)headerTitles;
-(void)setSectionFooterModels:(NSArray *)footerModels;
-(void)setSectionFooterTitles:(NSArray *)footerTitles;

/**
 Moves a section to a new location in the table view.
 
 @param indexFrom The index of the section to move.
 
 @param indexTo The index in the table view that is the destination of the move for the section. The existing section at that location slides up or down to an adjoining index position to make room for it.
 */
- (void)moveSection:(NSInteger)indexFrom toSection:(NSInteger)indexTo;

/**
 Deletes one or more sections in the receiver, with `UITableViewRowAnimationNone` animation.
 
 @param indexSet An index set that specifies the sections to delete from the receiving table view. If a section exists after the specified index location, it is moved up one index location.
 */
- (void)deleteSections:(NSIndexSet *)indexSet;

///---------------------------------------
/// @name Search
///---------------------------------------

/**
 If item exists at `indexPath`, it's model will be returned. If section or row does not exist, method will return `nil`. If this method is called when search is active, it will return model with indexPath in filtered table.
 
 @param indexPath Index of the item you wish to retrieve.
 
 @return model at indexPath. If section or row does not exist - `nil`.
 */
- (id)tableItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Searches for tableItem and returns it's indexPath. If there are many equal tableItems, indexPath of the first one will be returned. If this method is called when search is active, it will return indexPath of the item in filtered table.
 
 @param tableItem Model of the item you wish to find.
 
 @return indexPath of `tableItem`. If there are many equal tableItems, indexPath of the first one will be returned.
 */
- (NSIndexPath *)indexPathOfTableItem:(NSObject *)tableItem;

/**
 Returns array with table items in section. If search is active, this method will return tableItems in filtered table. Section numbers may differ, since empty sections are not shown in search results.
 
 @param section Number of the section in table.
 
 @return array of table items in section. Empty array if section does not exist.
 */
- (NSArray *)tableItemsInSection:(NSInteger)section;



@end
