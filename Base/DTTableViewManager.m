//
//  BaseTableViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 6/19/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//

#import "DTTableViewManager.h"
#import "DTCellFactory.h"

@interface DTTableViewManager ()
- (NSMutableArray *)getValidTableSection:(NSInteger)index withAnimation:(UITableViewRowAnimation)animation;
@property (nonatomic,retain) NSMutableArray * sections;
@property (nonatomic,retain) NSArray * headers;
@property (nonatomic,retain) NSArray * footers;

@property (nonatomic,assign) id <UITableViewDelegate,UITableViewDataSource, DTTableViewManagerProtocol> delegate;
@end

@implementation DTTableViewManager

@synthesize tableView=_tableView, headers=_headers, sections=_sections,footers = _footers;

#pragma mark - Getters, initializers and cleaning

-(id)initWithDelegate:(id<UITableViewDelegate>)delegate andTableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        self.delegate =(id <DTTableViewManagerProtocol, UITableViewDelegate,UITableViewDataSource>) delegate;
        self.tableView = tableView;
        tableView.dataSource = self;
        tableView.delegate = delegate;
    }
    return self;
}

+(id)managerWithDelegate:(id<UITableViewDelegate>)delegate andTableView:(UITableView *)tableView
{
    DTTableViewManager * manager = [[DTTableViewManager alloc] initWithDelegate:delegate
                                                                         andTableView:tableView];
    return [manager autorelease];
}

-(NSMutableArray *)sections
{
    if (!_sections)
    {
        _sections = [NSMutableArray new];
    }
    return _sections;
}

-(NSArray *)headers {
    if (!_headers)
    {
        _headers = [NSArray new];
    }
    return _headers;
}

-(NSArray *)footers {
    if (!_footers)
    {
        _footers = [NSArray new];
    }
    return _footers;
}

- (void)dealloc
{
    self.sections = nil;
    self.tableView = nil;
    self.headers = nil;
    self.footers = nil;
    [super dealloc];
}

#pragma mark - mapping 

-(void)addCellClassMapping:(Class)cellClass forModelClass:(Class)modelClass
{
    [[DTCellFactory sharedInstance] addCellClassMapping:cellClass
                                          forModelClass:modelClass];
}

-(void)addObjectMappingDictionary:(NSDictionary *)mapping
{
    [[DTCellFactory sharedInstance] addObjectMappingDictionary:mapping];
}

#pragma mark - search

- (id)tableItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *section=nil;
    if (indexPath.section < [self.sections count])
    {
        section = [self tableItemsInSection:indexPath.section];
    }
    else {
        NSLog(@"Table item not found");
        return nil;
    }
    if (indexPath.row < [section count])
    {
        return [section objectAtIndex:indexPath.row];
    }
    else return nil;
}

- (NSIndexPath *)indexPathOfTableItem:(NSObject *)tableItem
{
    for (NSInteger i=0; i<self.sections.count; i++)
    {
        NSArray *section = [self tableItemsInSection:i];
        NSInteger index = [section indexOfObject:tableItem];
        if (index != NSNotFound)
        {
            return [NSIndexPath indexPathForRow:index inSection:i];
        }
    }
    return nil;
}

//This implementation is not optimized, and may behave poorly over tables with lot of sections
-(NSArray *)indexPathArrayForTableItems:(NSArray *)tableItems
{
    NSMutableArray * indexPaths = [[NSMutableArray alloc] initWithCapacity:[tableItems count]];
    
    for (NSInteger i=0; i<[tableItems count]; i++)
    {
        NSIndexPath * foundIndexPath = [self indexPathOfTableItem:[tableItems objectAtIndex:i]];
        if (!foundIndexPath)
        {
            NSLog(@"object %@ not found, returning nil", [tableItems objectAtIndex:i]);
            [indexPaths release];
            return nil;
        }
        
        [indexPaths addObject:foundIndexPath];
    }
    return [indexPaths autorelease];
}

-(NSArray *)tableItemsArrayForIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray * items = [[NSMutableArray alloc] initWithCapacity:[indexPaths count]];
    
    for (NSIndexPath * path in indexPaths)
    {
        NSIndexPath * foundIndexPath = [self tableItemAtIndexPath:path];
        if (foundIndexPath)
        {
            [items addObject:foundIndexPath];
        }
        else {
            NSLog(@"item not found. Returning nil for NSArrayForIndexPaths");
            [items release];
            return nil;
        }
    }
    return [items autorelease];
}

- (NSArray *)tableItemsInSection:(int)section
{
    if (section<[self.sections count])
    {
        return [self.sections objectAtIndex:section];
    }
    else return nil;
}

- (void)addTableItem:(NSObject *)tableItem
{
    [self addTableItem:tableItem toSection:0 withRowAnimation:UITableViewRowAnimationNone];
}

-(void)addTableItem:(NSObject *)tableItem withRowAnimation:(UITableViewRowAnimation)animation
{
    [self addTableItem:tableItem toSection:0 withRowAnimation:animation];
}

- (void)addTableItems:(NSArray *)tableItems
{
    [self addTableItems:tableItems toSection:0  withRowAnimation:UITableViewRowAnimationNone];
}

-(void)addTableItems:(NSArray *)tableItems withRowAnimation:(UITableViewRowAnimation)animation
{
    [self addTableItems:tableItems toSection:0 withRowAnimation:animation];
}

- (void)addTableItem:(NSObject *)tableItem toSection:(NSInteger)section
{
    [self addTableItem:tableItem toSection:section withRowAnimation:UITableViewRowAnimationNone];
}

-(void)addTableItem:(NSObject *)tableItem
          toSection:(NSInteger)section
   withRowAnimation:(UITableViewRowAnimation)animation
{
   // Update datasource
    NSMutableArray *array = [self getValidTableSection:section withAnimation:animation];
    [array addObject:tableItem];
    
    
    //update UI
    NSIndexPath * modelItemPath = [self indexPathOfTableItem:tableItem];
    
    UITableViewCell * modelCell = [self.tableView cellForRowAtIndexPath:modelItemPath];
    if (!modelCell)
    {
        [self.tableView insertRowsAtIndexPaths:@[modelItemPath] withRowAnimation:animation];
    }
}

- (void)addTableItems:(NSArray *)tableItems toSection:(NSInteger)section
{
    [self addTableItems:tableItems toSection:section withRowAnimation:UITableViewRowAnimationNone];
}

-(void)addTableItems:(NSArray *)tableItems
           toSection:(NSInteger)section
    withRowAnimation:(UITableViewRowAnimation)animation
{
    //update Datasource and UI
    [self.tableView beginUpdates];
    for (id tableItem in tableItems)
    {
        [self addTableItem:tableItem toSection:section withRowAnimation:animation];
    }
    [self.tableView endUpdates];
}

-(void)insertTableItem:(NSObject *)tableItem toIndexPath:(NSIndexPath *)indexPath
{
    [self insertTableItem:tableItem toIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
}

-(void)insertTableItem:(NSObject *)tableItem
           toIndexPath:(NSIndexPath *)indexPath
      withRowAnimation:(UITableViewRowAnimation)animation
{
    // Update datasource
    NSMutableArray *array = [self getValidTableSection:indexPath.section
                                         withAnimation:animation];
    [array insertObject:tableItem atIndex:indexPath.row];
    
    
    // UPdate UI
    NSIndexPath * modelItemPath = [self indexPathOfTableItem:tableItem];
    
    UITableViewCell * modelCell = [self.tableView cellForRowAtIndexPath:modelItemPath];
    if (!modelCell)
    {
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    }
}

-(void)reloadTableSections
{
    for (int i = 0; i<self.sections.count ; i++)
    {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)replaceTableItem:(NSObject *)tableItemToReplace
          withTableItem:(NSObject *)replacingTableItem
{
    [self replaceTableItem:tableItemToReplace
             withTableItem:replacingTableItem
           andRowAnimation:UITableViewRowAnimationNone];
}

-(void)replaceTableItem:(NSObject *)tableItemToReplace
          withTableItem:(NSObject *)replacingTableItem
        andRowAnimation:(UITableViewRowAnimation)animation
{
    //Update datasource
    NSIndexPath * indexPathToReplace = [self indexPathOfTableItem:tableItemToReplace];
    
    NSMutableArray *section = [self getValidTableSection:indexPathToReplace.section
                                           withAnimation:animation];
    [section replaceObjectAtIndex:indexPathToReplace.row withObject:replacingTableItem];
    
    //Update UI
    [self.tableView reloadRowsAtIndexPaths:@[indexPathToReplace]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)removeTableItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *section = [self tableItemsInSection:indexPath.section];
    NSMutableArray *castedSection = (NSMutableArray *)section;
    [castedSection removeObjectAtIndex:indexPath.row];
}

- (void)removeTableItem:(NSObject *)tableItem
{
    [self removeTableItem:tableItem withRowAnimation:UITableViewRowAnimationNone];
}

-(void)removeTableItem:(NSObject *)tableItem withRowAnimation:(UITableViewRowAnimation)animation
{
    // Update datasource
    NSIndexPath *indexPath = [self indexPathOfTableItem:tableItem];
    
    if (indexPath)
    {
        //update datasource
        [self removeTableItemAtIndexPath:indexPath];
        
        //Update UI
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    }
    
}

-(void)removeTableItems:(NSArray *)tableItems
{
    for (NSObject * item in tableItems)
    {
        [self removeTableItem:item];
    }
}

-(void)removeTableItems:(NSArray *)tableItems
       withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView beginUpdates];
    for (NSObject * item in tableItems)
    {
        [self removeTableItem:item withRowAnimation:animation];
    }
    [self.tableView endUpdates];
}

- (void)removeAllTableItems
{
    [self.sections removeAllObjects];
}

#pragma mark -
#pragma mark table delegate/data source implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

-(void)moveSection:(int)indexFrom toSection:(int)indexTo
{
    NSMutableArray * validSectionFrom = [[self getValidTableSection:indexFrom
                                                      withAnimation:UITableViewRowAnimationNone]
                                         retain];
    [self getValidTableSection:indexTo withAnimation:UITableViewRowAnimationNone];
    
    [self.sections removeObject:validSectionFrom];
    [self.sections insertObject:validSectionFrom atIndex:indexTo];
    [validSectionFrom release];
    
    if (self.sections.count > self.tableView.numberOfSections)
    {
        //Row does not exist, moving section causes many sections to change, so we just reload
        [self.tableView reloadData];
    }
    else {
        [self.tableView moveSection:indexFrom toSection:indexTo];
    }
}

-(void)deleteSections:(NSIndexSet *)indexSet
{
    [self deleteSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

-(void)deleteSections:(NSIndexSet *)indexSet withRowAnimation:(UITableViewRowAnimation)animation
{
    // Update datasource
    [self.sections removeObjectsAtIndexes:indexSet];
    
    // Update UI
    [self.tableView deleteSections:indexSet withRowAnimation:animation];
}

-(void)reloadSections:(NSIndexSet *)indexSet withRowAnimation:(UITableViewRowAnimation)animation
{
   [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
       [self getValidTableSection:idx withAnimation:animation];
   }];
    
    [self.tableView reloadSections:indexSet withRowAnimation:animation];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = [self tableItemsInSection:section];
    return sectionArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section < self.headers.count) ? [self.headers objectAtIndex:section] : nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return (section < self.footers.count) ? [self.footers objectAtIndex:section] : nil;
}

-(NSString *)defaultReuseIdentifierForModel:(id)model
{
    return NSStringFromClass([model class]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *model = [self tableItemAtIndexPath:indexPath];
    
    NSString * reuseIdentifier = [self defaultReuseIdentifierForModel:model];
    
    if (self.doNotReuseCells)
        reuseIdentifier = nil;
    
    UITableViewCell *cell = [[DTCellFactory sharedInstance] cellForModel:model
                                                                 inTable:tableView
                                                         reuseIdentifier:reuseIdentifier];
    
    if ([self.delegate respondsToSelector:@selector(createdCell:forTableView:forRowAtIndexPath:)])
    {
        [self.delegate createdCell:cell forTableView:tableView forRowAtIndexPath:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - private

- (NSMutableArray *)getValidTableSection:(NSInteger)index withAnimation:(UITableViewRowAnimation)animation
{
    if (index < self.sections.count)
    {
        return (NSMutableArray *)[self tableItemsInSection:index];
    }
    else 
    {
        for (int i = self.sections.count; i <= index ; i++)
        {
            //Update datasource
            NSMutableArray *newSection = [NSMutableArray array];
            [self.sections addObject:newSection];
            
            //Update UI
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:i]
                      withRowAnimation:animation];
        }
        return [self.sections lastObject];
    }/*
      NSString *reason = [NSString stringWithFormat:@"Can't get section with index '%d',\
      contain only '%d' sections", index, self.sections.count];
      @throw [NSException exceptionWithName:@"Can't get section" reason:reason userInfo:nil];*/
}

-(void)setSectionHeaders:(NSArray *)headers
{
    self.headers = headers;
    
    [self.tableView reloadData];
}

-(void)setSectionFooters:(NSArray *)footers
{
    self.footers = footers;
    
    [self.tableView reloadData];
}

-(int)numberOfTableItemsInSection:(NSInteger)section
{
    NSArray * itemsInSection = [self tableItemsInSection:section];
    return [itemsInSection count];
}

-(int)numberOfSections
{
    return [self.sections count];
}

#pragma mark - Datasource methods, trampoline to our delegate

-(BOOL)delegateRespondsToSelector:(SEL)selector
{
    return [self.delegate respondsToSelector:selector];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self delegateRespondsToSelector:_cmd])
    {
        [self.delegate tableView:tableView
              commitEditingStyle:editingStyle
               forRowAtIndexPath:indexPath];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self delegateRespondsToSelector:_cmd])
    {
        return [self.delegate tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self delegateRespondsToSelector:_cmd])
    {
        return [self.delegate tableView:tableView canMoveRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
     toIndexPath:(NSIndexPath *)destinationIndexPath
{
#warning we should update our model here, test this.
}

@end
