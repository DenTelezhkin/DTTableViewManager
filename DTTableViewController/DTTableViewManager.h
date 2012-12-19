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

#import "DTTableViewModelTransfer.h"
#import "DTTableViewCellCreation.h"

/**
 `DTTableViewManager` manages all `UITableView` datasource methods and provides API for managing your data models in the table. It can be subclassed by your controller, containing UITableView or used as a separate object, that will manage all your data models, creating correctly typed cells for them.
 
 ## Setup
 
 - You should have classes that manage cell layout, using given data model.
 - Every cell class should be mapped to model class using setCellMappingforClass:modelClass:
 - `UITableView` delegate should be set to DTTableViewManager object.
 
 # Subclassing
 
 This is recommended approach, if you don't need to subclass your `UIViewController` from another controller. In this case `UITableView` delegate and datasource is your controller. Any UITableViewDatasource method can be overridden in your controller.
 
 # Separate manager
 
 This is needed, when your controller inherits from custom class, and you need to have `DTTableViewManager` as a separate object. In this case you should create `DTTableViewManager` object using [DTTableViewManager managerWithDelegate:andTableView:], and make it a property in your controller. Current implementation sets `UITableView`'s delegate and datasource property to `DTTableViewManager` object. Delegate methods are then trampolined to your controller if it implements them.
 
 There's a `DTTableViewCellCreation` protocol that can be used to modify cell after it has been created.
 
 ## Loading cells from XIB
 
 `DTTableViewManager` internally uses `registerNib:forCellReuseIdentifier:` method for making this happen, which requires iOS 5.0 and higher to work. Use setCellMappingForNib:cellClass:modelClass: for mapping NIB to cell class and model. 
 
 @warning Before executing setCellMappingForNib:cellClass:modelClass:, make sure that tableView property is set and tableView is created. This can be done in viewDidLoad method, for example.
 
 */

@interface DTTableViewManager : UIViewController
                                     <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView * tableView;

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

/**
 This method is used to set mapping from model to custom cell created from XIB with `nibName` name. Cell data is then populated by `cellClass` class.
 
 @param nibName Name of custom XIB that is used to create a cell.
 
 @param cellClass Class of the cell you want to be created for model with modelClass.
 
 @param modelClass Class of the model you want to be mapped to cellClass.
 
 @warning This method need to be called after tableView has been created, in `viewDidLoad`, for example. Underneath this method uses UITableView `registerNib:forCellReuseIdentifier:` method.
 
 */

// create your custom cells from IB, call this method only when outlets are loaded,
// in viewDidLoad for example :
-(void)setCellMappingForNib:(NSString *)nibName
                  cellClass:(Class)cellClass
                 modelClass:(Class)modelClass;


// Not recommended, but you can do it if you like. Just take a look, how
// this is done in setCellClassMapping:forModelClass method
-(void)setObjectMappingDictionary:(NSDictionary *)mapping;

@end
