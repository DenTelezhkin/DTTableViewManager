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
