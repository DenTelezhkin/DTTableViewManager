//
//  BaseTableViewController.h
//  TableViewFactory
//
//  Created by Denys Telezhkin on 6/19/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//

//Optional protocol, but with required method
@protocol DTTableViewManagerProtocol
@required
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
// Methods without rowAnimation parameter will update UI with UITableViewRowAnimationNone

- (void)addTableItem:(NSObject *)tableItem;
- (void)addTableItem:(NSObject *)tableItem withRowAnimation:(UITableViewRowAnimation)animation;
- (void)addTableItems:(NSArray *)tableItems;
- (void)addTableItems:(NSArray *)tableItems withRowAnimation:(UITableViewRowAnimation)animation;

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

-(void)addObjectMappingDictionary:(NSDictionary *)mapping;
-(void)addCellClassMapping:(Class)cellClass forModelClass:(Class)modelClass;


@end
