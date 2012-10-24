//
//  DTTableViewManager.h
//  DTTableViewController
//
//  Created by Denys Telezhkin on 6/19/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
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

#import "DTTableViewModelProtocol.h"

@protocol DTTableViewManagerProtocol
@optional
-(void)createdCell:(UITableViewCell *)cell
      forTableView:(UITableView *)tableView
 forRowAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface DTTableViewManager : UIViewController
                                     <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, retain) IBOutlet UITableView * tableView;

@property (nonatomic,assign) BOOL doNotReuseCells;


//////////////////////////
// Initialization

-(id)initWithDelegate:(id <UITableViewDelegate>)delegate andTableView:(UITableView *)tableView;
+(id)managerWithDelegate:(id <UITableViewDelegate>)delegate andTableView:(UITableView *)tableView;

//////////////////////////
// Search and setup

- (id)tableItemAtIndexPath:(NSIndexPath *)indexPath;
//this method returns lowest index item, that is equal to tableItem
- (NSIndexPath *)indexPathOfTableItem:(NSObject *)tableItem;
// this methods returns array of lowest index paths items, that are equal to table items
- (NSArray *)indexPathArrayForTableItems:(NSArray *)tableItems;
- (NSArray *)tableItemsArrayForIndexPaths:(NSArray *)indexPaths;
- (NSArray *)tableItemsInSection:(int)section;

- (int)numberOfSections;
- (int)numberOfTableItemsInSection:(NSInteger)section;

- (void)setSectionHeaders:(NSArray *)headers;
- (void)setSectionFooters:(NSArray *)footers;

///////////////////////
// Add table items.
// Methods without rowAnimation in name will update UI with UITableViewRowAnimationNone

- (void)addTableItem:(NSObject *)tableItem;
- (void)addTableItem:(NSObject *)tableItem withRowAnimation:(UITableViewRowAnimation)animation;
- (void)addTableItems:(NSArray *)tableItems;
- (void)addTableItems:(NSArray *)tableItems withRowAnimation:(UITableViewRowAnimation)animation;

// Will check, if items are not already in the table, then add them
-(void)addNonRepeatingItems:(NSArray *)tableitems
                  toSection:(NSInteger)section
           withRowAnimation:(UITableViewRowAnimation)animation;

- (void)addTableItem:(NSObject *)tableItem toSection:(NSInteger)section;
- (void)addTableItem:(NSObject *)tableItem
           toSection:(NSInteger)section
    withRowAnimation:(UITableViewRowAnimation)animation;

- (void)addTableItems:(NSArray *)tableItems
            toSection:(NSInteger)section;
- (void)addTableItems:(NSArray *)tableItems
            toSection:(NSInteger)section
     withRowAnimation:(UITableViewRowAnimation)animation;


///////////////////////
// Insertion of table items

- (void)insertTableItem:(NSObject *)tableItem toIndexPath:(NSIndexPath *)indexPath;
- (void)insertTableItem:(NSObject *)tableItem toIndexPath:(NSIndexPath *)indexPath
       withRowAnimation:(UITableViewRowAnimation)animation;

//////////////////////
// Replace and remove

- (void)replaceTableItem:(NSObject *)tableItemToReplace
           withTableItem:(NSObject *)replacingTableItem;

- (void)replaceTableItem:(NSObject *)tableItemToReplace
           withTableItem:(NSObject *)replacingTableItem
         andRowAnimation:(UITableViewRowAnimation)animation;

- (void)removeTableItem:(NSObject *)tableItem;
- (void)removeTableItem:(NSObject *)tableItem withRowAnimation:(UITableViewRowAnimation)animation;

- (void)removeTableItems:(NSArray *)tableItems;
- (void)removeTableItems:(NSArray *)tableItems withRowAnimation:(UITableViewRowAnimation)animation;

- (void)removeAllTableItems;

///////////////////////
// Move, delete, reload sections

// Move section to section will update both model and UI
- (void)moveSection:(int)indexFrom toSection:(int)indexTo;

- (void)deleteSections:(NSIndexSet *)indexSet;
- (void)deleteSections:(NSIndexSet *)indexSet withRowAnimation:(UITableViewRowAnimation)animation;

- (void)reloadSections:(NSIndexSet *)indexSet withRowAnimation:(UITableViewRowAnimation)animation;


///////////////////////
// Mapping
// redirect to CellFactory

// Designated setters

// create your cells from code, or use standard cells:
-(void)setCellMappingforClass:(Class)cellClass modelClass:(Class)modelClass;

// create your custom cells from IB:
-(void)setCellMappingForNib:(NSString *)nibName
                  cellClass:(Class)cellClass
                 modelClass:(Class)modelClass;


// Not recommended, but you can do it if you like. Just take a look, how
// this is done in setCellClassMapping:forModelClass method
-(void)setObjectMappingDictionary:(NSDictionary *)mapping;

@end
