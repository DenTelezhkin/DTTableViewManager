//
//  BaseTableViewController.h
//  ainifinity
//
//  Created by Alexey Belkevich on 6/19/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseTableViewController : BaseViewController 
<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, retain) IBOutlet UITableView *table;

// actions
- (id)tableItemAtIndexPath:(NSIndexPath *)indexPath;

//this method returns lowest index item, that is equal to tableItem
- (NSIndexPath *)indexPathOfTableItem:(NSObject *)tableItem;

// this methods returns array of lowest index paths items, that are equal to table items
- (NSArray *)indexPathArrayForTableItems:(NSArray *)tableItems;

- (NSArray *)tableItemsArrayForIndexPaths:(NSArray *)indexPaths;

- (NSArray *)tableItemsInSection:(int)section;

- (void)addTableItem:(NSObject *)tableItem;

- (void)addTableItem:(NSObject *)tableItem withRowAnimation:(UITableViewRowAnimation)animation;

- (void)addTableItems:(NSArray *)tableItems;

- (void)addTableItems:(NSArray *)tableItems withRowAnimation:(UITableViewRowAnimation)animation;

- (void)addTableItem:(NSObject *)tableItem toSection:(NSInteger)section;

- (void)addTableItem:(NSObject *)tableItem toSection:(NSInteger)section
                                       withAnimation:(UITableViewRowAnimation)animation;

- (void)addTableItems:(NSArray *)tableItems toSection:(NSInteger)section;

- (void)addTableItems:(NSArray *)tableItems toSection:(NSInteger)section
                                        withAnimation:(UITableViewRowAnimation)animation;

- (void)insertTableItem:(NSObject *)tableItem toIndexPath:(NSIndexPath *)indexPath;

- (void)insertTableItem:(NSObject *)tableItem toIndexPath:(NSIndexPath *)indexPath
                                            withAnimation:(UITableViewRowAnimation)animation;

- (void)replaceTableItem:(NSObject *)tableItemToReplace
           withTableItem:(NSObject *)replacingTableItem;

- (void)replaceTableItem:(NSObject *)tableItemToReplace
           withTableItem:(NSObject *)replacingTableItem
         andRowAnimation:(UITableViewRowAnimation)animation;

- (void)removeTableItem:(NSObject *)tableItem;

- (void)removeTableItem:(NSObject *)tableItem withAnimation:(UITableViewRowAnimation)animation;

- (void)removeTableItems:(NSArray *)tableItems;

- (void)removeTableItems:(NSArray *)tableItems withRowAnimation:(UITableViewRowAnimation)animation;

- (void)removeAllTableItems;

- (int)numberOfTableItemsInSection:(NSInteger)section;

- (void)setSectionHeaders:(NSArray *)headers;
- (void)setSectionFooters:(NSArray *)footers;

@end
