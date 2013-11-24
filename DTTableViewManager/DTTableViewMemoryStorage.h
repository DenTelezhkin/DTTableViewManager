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

@end
