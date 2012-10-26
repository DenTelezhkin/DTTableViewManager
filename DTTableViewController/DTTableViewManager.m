//
//  DTTableViewManager.m
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

#pragma mark - initialize, clean

- (void)dealloc
{
    self.sections = nil;
    self.tableView = nil;
    self.headers = nil;
    self.footers = nil;
    [super dealloc];
}

-(id)initWithDelegate:(id<UITableViewDelegate>)delegate andTableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        self.delegate =(id <DTTableViewManagerProtocol, UITableViewDelegate,UITableViewDataSource>) delegate;
        self.tableView = tableView;
        tableView.dataSource = self;
        tableView.delegate = delegate;
        
        if (!tableView.dataSource || !tableView.delegate)
        {
            NSLog(@"delegate:%@ has not created tableView before allocating DTTableViewManager",
                            delegate);
            NSException * exc =
                        [NSException exceptionWithName:@"DTTableViewManager: Check your tableView"
                                                reason:@"Datasource and delegate cannot be nil"
                                              userInfo:nil];
            [exc raise];
        }
    }
    return self;
}

+(id)managerWithDelegate:(id<UITableViewDelegate>)delegate andTableView:(UITableView *)tableView
{
    DTTableViewManager * manager = [[DTTableViewManager alloc] initWithDelegate:delegate
                                                                   andTableView:tableView];
    return [manager autorelease];
}

#pragma mark - getters, setters

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

#pragma mark - mapping

-(void)setCellMappingforClass:(Class)cellClass modelClass:(Class)modelClass
{
    [[DTCellFactory sharedInstance] setCellClassMapping:cellClass
                                          forModelClass:modelClass];
}

-(void)setCellMappingForNib:(NSString *)nibName cellClass:(Class)cellClass modelClass:(Class)modelClass
{
    [self.tableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
         forCellReuseIdentifier:NSStringFromClass([modelClass class])];
    
    [self setCellMappingforClass:cellClass modelClass:modelClass];
}

-(void)setObjectMappingDictionary:(NSDictionary *)mapping
{
    [[DTCellFactory sharedInstance] setObjectMappingDictionary:mapping];
}

#pragma mark - search

-(int)numberOfTableItemsInSection:(NSInteger)section
{
    NSArray * itemsInSection = [self tableItemsInSection:section];
    return [itemsInSection count];
}

-(int)numberOfSections
{
    return [self.sections count];
}

- (id)tableItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *section=nil;
    if (indexPath.section < [self.sections count])
    {
        section = [self tableItemsInSection:indexPath.section];
    }
    else {
        NSLog(@"DTTableViewManager: Section not found while searching for table item");
        return nil;
    }
    if (indexPath.row < [section count])
    {
        return [section objectAtIndex:indexPath.row];
    }
    else {
        NSLog(@"DTTableViewManager: Row not found while searching for table item");
        return nil;
    }
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
    NSLog(@"DTTableViewManager: table item not found, cannot return it's indexPath");
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
            NSLog(@"DTTableViewManager: object %@ not found, returning nil", [tableItems objectAtIndex:i]);
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
            NSLog(@"DTTableViewManager: item not found. Returning nil for NSArrayForIndexPaths");
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
    else {
        //        NSLog(@"DTTableViewManager: section %d not found",section);
        return nil;
    }
}

#pragma mark - add items

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
    
    // We need to get a valid section before table updates
    // So we don't mess up animations
    [self getValidTableSection:section withAnimation:animation];
    
    
    [self.tableView beginUpdates];
    for (id tableItem in tableItems)
    {
        [self addTableItem:tableItem toSection:section withRowAnimation:animation];
    }
    [self.tableView endUpdates];
}

-(void)addNonRepeatingItems:(NSArray *)tableitems
                  toSection:(NSInteger)section
           withRowAnimation:(UITableViewRowAnimation)animation
{
    NSArray * validSection = [self getValidTableSection:section withAnimation:animation];
    
    [self.tableView beginUpdates];
    for (id model in tableitems)
    {
        if (![validSection containsObject:model])
        {
            [self addTableItem:model toSection:section withRowAnimation:animation];
        }
    }
    [self.tableView endUpdates];
}

#pragma mark - insert items

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
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

#pragma  mark - reload/replace items

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

#pragma  mark - remove items

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
    
    [self.tableView reloadData];
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
    }
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
    NSMutableArray *array = [self.sections objectAtIndex:sourceIndexPath.section];
    id tableItem = [[self tableItemAtIndexPath:sourceIndexPath] retain];
    [array removeObjectAtIndex:sourceIndexPath.row];
    
    array = [self.sections objectAtIndex:destinationIndexPath.section];
    [array insertObject:tableItem atIndex:destinationIndexPath.row];
    [tableItem release];
}

@end
