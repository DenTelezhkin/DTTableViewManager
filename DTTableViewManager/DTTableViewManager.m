//
//  DTTableViewManager.m
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

@property (nonatomic,strong) NSMutableArray * sections;
@property (nonatomic, strong) NSMutableArray * searchResultSections;
@property (nonatomic, assign) int currentSearchScope;
@property (nonatomic, copy) NSString * currentSearchString;

@property (nonatomic,weak) id <UITableViewDelegate,UITableViewDataSource, DTTableViewCellCreation> delegate;
@end

@implementation DTTableViewManager

#pragma mark - initialize, clean

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.currentSearchScope = -1;
    }
    return self;
}

-(id)initWithDelegate:(id<UITableViewDelegate>)delegate andTableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        self.delegate =(id <DTTableViewCellCreation, UITableViewDelegate,UITableViewDataSource>) delegate;
        self.tableView = tableView;
        tableView.dataSource = self;
        tableView.delegate = delegate;
        
        if (!tableView)
        {
            NSLog(@"delegate:%@ has not created tableView before allocating DTTableViewManager",
                            delegate);
            NSException * exc =
                        [NSException exceptionWithName:@"DTTableViewManager: Check your tableView"
                                                reason:@"Datasource and delegate cannot be nil"
                                              userInfo:nil];
            [exc raise];
        }
        
        if (!delegate)
        {
            NSLog(@"nil delegate passed to DTTableViewManager");
        }
    }
    return self;
}

+(id)managerWithDelegate:(id<UITableViewDelegate>)delegate andTableView:(UITableView *)tableView
{
    DTTableViewManager * manager = [[DTTableViewManager alloc] initWithDelegate:delegate
                                                                   andTableView:tableView];
    return manager;
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

-(NSArray *)sectionHeaderTitles {
    if (!_sectionHeaderTitles)
    {
        _sectionHeaderTitles = [NSMutableArray new];
    }
    return _sectionHeaderTitles;
}

-(NSArray *)sectionFooterTitles {
    if (!_sectionFooterTitles)
    {
        _sectionFooterTitles = [NSMutableArray new];
    }
    return _sectionFooterTitles;
}

-(NSArray *)sectionHeaderModels
{
    if (!_sectionHeaderModels)
        _sectionHeaderModels = [NSMutableArray new];
    return _sectionHeaderModels;
}

-(NSArray *)sectionFooterModels
{
    if (!_sectionFooterModels)
        _sectionFooterModels = [NSMutableArray new];
    return _sectionFooterModels;
}

-(NSMutableArray *)searchResultSections
{
    if (!_searchResultSections)
        _searchResultSections = [NSMutableArray array];
    return _searchResultSections;
}

-(NSMutableArray *)currentSections
{
    if ([self isSearching]) {
        return self.searchResultSections;
    }
    else {
        return self.sections;
    }
}

#pragma mark - check for features

-(BOOL)tableViewRespondsToCellClassRegistration
{
    // iOS 6.0
    if ([self.tableView respondsToSelector:@selector(registerClass:forCellReuseIdentifier:)])
    {
        return YES;
    }
    return NO;
}

-(BOOL)tableViewRespondsToHeaderFooterViewNibRegistration
{
    if ([self.tableView respondsToSelector:
         @selector(registerNib:forHeaderFooterViewReuseIdentifier:)])
    {
        return YES;
    }
    return NO;
}

-(void)checkClassForModelTransferProtocolSupport:(Class)class
{
    if (![class conformsToProtocol:@protocol(DTTableViewModelTransfer)])
    {
        NSString * reason = [NSString stringWithFormat:@"class %@ should conform\n"
                             "to DTTableViewModelTransfer protocol",
                             NSStringFromClass(class)];
        NSException * exc =
        [NSException exceptionWithName:@"DTTableViewManager API exception"
                                reason:reason
                              userInfo:nil];
        [exc raise];
    }
}

#pragma mark - mapping

-(BOOL)nibExistsWIthNibName:(NSString *)nibName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:nibName
                                                     ofType:@"nib"];
    
    if (path)
    {
        return YES;
    }
    return NO;
}

-(void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass
{
    [self checkClassForModelTransferProtocolSupport:cellClass];
    
    if ([self tableViewRespondsToCellClassRegistration])
    {
        [self.tableView registerClass:cellClass
               forCellReuseIdentifier:NSStringFromClass([modelClass class])];
    }
    
    if ([self nibExistsWIthNibName:NSStringFromClass(cellClass)])
    {
       [self registerNibNamed:NSStringFromClass(cellClass)
                 forCellClass:cellClass
                   modelClass:modelClass];
    }
    
    [[DTCellFactory sharedInstance] setCellClassMapping:cellClass
                                          forModelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName
           forCellClass:(Class)cellClass
             modelClass:(Class)modelClass
{
    [self checkClassForModelTransferProtocolSupport:cellClass];

    if (![self nibExistsWIthNibName:nibName])
    {
        NSString * reason = [NSString stringWithFormat:@"cannot find nib with name: %@",
                             NSStringFromClass(cellClass)];
        NSException * exc =
        [NSException exceptionWithName:@"DTTableViewManager API exception"
                                reason:reason
                              userInfo:nil];
        [exc raise];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
         forCellReuseIdentifier:NSStringFromClass([modelClass class])];
    
    [[DTCellFactory sharedInstance] setCellClassMapping:cellClass
                                          forModelClass:modelClass];
}

-(void)registerHeaderClass:(Class)headerClass forModelClass:(Class)modelClass
{
    [self registerNibNamed:NSStringFromClass(headerClass)
            forHeaderClass:headerClass
                modelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName forHeaderClass:(Class)headerClass
             modelClass:(Class)modelClass
{
    [self checkClassForModelTransferProtocolSupport:headerClass];

    if (![self nibExistsWIthNibName:nibName])
    {
        NSString * reason = [NSString stringWithFormat:@"cannot find nib with name: %@",
                             nibName];
        NSException * exc =
        [NSException exceptionWithName:@"DTTableViewManager API exception"
                                reason:reason
                              userInfo:nil];
        [exc raise];
    }
    
    if ([self tableViewRespondsToHeaderFooterViewNibRegistration] &&
        [headerClass isSubclassOfClass:[UITableViewHeaderFooterView class]])
    {
        [self.tableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
 forHeaderFooterViewReuseIdentifier:NSStringFromClass([modelClass class])];
    }
    
    [[DTCellFactory sharedInstance] setHeaderClassMapping:headerClass
                                            forModelClass:modelClass];
}

-(void)registerFooterClass:(Class)footerClass forModelClass:(Class)modelClass
{
    [self registerNibNamed:NSStringFromClass(footerClass)
            forFooterClass:footerClass
                modelClass:modelClass];
}

-(void)registerNibNamed:(NSString *)nibName forFooterClass:(Class)footerClass
             modelClass:(Class)modelClass
{
    [self checkClassForModelTransferProtocolSupport:footerClass];
    
    if (![self nibExistsWIthNibName:nibName])
    {
        NSString * reason = [NSString stringWithFormat:@"cannot find nib with name: %@",
                             nibName];
        NSException * exc =
        [NSException exceptionWithName:@"DTTableViewManager API exception"
                                reason:reason
                              userInfo:nil];
        [exc raise];
    }
    
    if ([self tableViewRespondsToHeaderFooterViewNibRegistration] &&
        [footerClass isSubclassOfClass:[UITableViewHeaderFooterView class]])
    {
        [self.tableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
 forHeaderFooterViewReuseIdentifier:NSStringFromClass([modelClass class])];
    }
    
    [[DTCellFactory sharedInstance] setFooterClassMapping:footerClass
                                            forModelClass:modelClass];
}

#pragma mark - search

-(BOOL)isSearching
{
    // If search scope is selected, we are already searching, even if dataset is all items
    if (((self.currentSearchString) && (![self.currentSearchString isEqualToString:@""]))
        ||
        self.currentSearchScope>-1)
    {
        return YES;
    }
    return NO;
}

-(void)filterTableItemsForSearchString:(NSString *)searchString
{
    [self filterTableItemsForSearchString:searchString inScope:-1];
}

-(void)filterTableItemsForSearchString:(NSString *)searchString
                               inScope:(int)scopeNumber
{
    BOOL wereSearching = [self isSearching];
    
    if (![searchString isEqualToString:self.currentSearchString] ||
        scopeNumber!=self.currentSearchScope)
    {
        self.currentSearchScope = scopeNumber;
        self.currentSearchString = searchString;
    }
    else {
        return;
    }
    
    if (wereSearching && ![self isSearching])
    {
        [self.tableView reloadData];
        return;
    }
    
    [self.searchResultSections removeAllObjects];
    
    
    for (int section = 0; section< [self numberOfOriginalSections]; section ++)
    {
        [self.searchResultSections addObject:[NSMutableArray array]];
        
        for (int row = 0; row < [self numberOfTableItemsInOriginalSection:section];row ++)
        {
            NSObject <DTTableViewModelSearching> * item;
            
            item = [self tableItemAtOriginalIndexPath:[NSIndexPath indexPathForRow:row
                                                                         inSection:section]];
            
            if ([item respondsToSelector:@selector(shouldShowInSearchResultsForSearchString:inScopeIndex:)])
            {
                BOOL shouldShow = [item shouldShowInSearchResultsForSearchString:searchString
                                                                    inScopeIndex:scopeNumber];
                
                if (shouldShow)
                {
                    [[self.searchResultSections lastObject] addObject:item];
                }
            }
        }
        
        if (![[self.searchResultSections lastObject] count])
        {
            [self.searchResultSections removeLastObject];
        }
    }
    
    [self.tableView reloadData];
}

-(int)numberOfTableItemsInSection:(NSInteger)section
{
    NSArray * itemsInSection = [self tableItemsInSection:section];
    return [itemsInSection count];
}

-(int)numberOfTableItemsInOriginalSection:(NSInteger)section
{
    NSArray * itemsInSection = [self tableItemsInOriginalSection:section];
    return [itemsInSection count];
}

-(int)numberOfSections
{
    return [[self currentSections] count];
}

-(int)numberOfOriginalSections
{
    return [self.sections count];
}

-(id)headerItemAtIndex:(int)index
{
    if (index<[self.sectionHeaderModels count])
    {
        return self.sectionHeaderModels[index];
    }
    else {
//        NSLog(@"DTTableViewManager: Header not found at index: %d",index);
        return nil;
    }
}

-(id)footerItemAtIndex:(int)index
{
    if (index<[self.sectionFooterModels count])
    {
        return self.sectionFooterModels[index];
    }
    else {
//        NSLog(@"DTTableViewManager: Footer not found at index: %d",index);
        return nil;
    }
}

- (id)tableItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *section=nil;
    if (indexPath.section < [[self currentSections] count])
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

-(id)tableItemAtOriginalIndexPath:(NSIndexPath *)indexPath
{
    NSArray *section=nil;
    if (indexPath.section < [self.sections count])
    {
        section = [self tableItemsInOriginalSection:indexPath.section];
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
    for (NSInteger i=0; i<[self currentSections].count; i++)
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

-(NSIndexPath *)originalIndexPathOfTableItem:(NSObject *)tableItem
{
    for (NSInteger i=0; i<self.sections.count; i++)
    {
        NSArray *section = [self tableItemsInOriginalSection:i];
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
            NSLog(@"DTTableViewManager: object %@ not found",
                  [tableItems objectAtIndex:i]);
        }
        else {
            [indexPaths addObject:foundIndexPath];
        }
    }
    return indexPaths;
}

-(NSArray *)originalIndexPathArrayOfTableItems:(NSArray *)tableItems
{
    NSMutableArray * indexPaths = [[NSMutableArray alloc] initWithCapacity:[tableItems count]];
    
    for (NSInteger i=0; i<[tableItems count]; i++)
    {
        NSIndexPath * foundIndexPath = [self originalIndexPathOfTableItem:[tableItems objectAtIndex:i]];
        if (!foundIndexPath)
        {
            NSLog(@"DTTableViewManager: object %@ not found",
                  [tableItems objectAtIndex:i]);
        }
        else {
            [indexPaths addObject:foundIndexPath];
        }
    }
    return indexPaths;
}

- (NSArray *)tableItemsInSection:(int)section
{
    NSMutableArray * sectionsArray = [self currentSections];
    
    if (section<[sectionsArray count])
    {
        return [sectionsArray objectAtIndex:section];
    }
    else {
        //        NSLog(@"DTTableViewManager: section %d not found",section);
        return @[];
    }
}

-(NSArray *)tableItemsInOriginalSection:(int)section
{
    if (section<[self.sections count])
    {
        return [self.sections objectAtIndex:section];
    }
    else {
        //        NSLog(@"DTTableViewManager: section %d not found",section);
        return @[];
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
    
    int itemsCountInSection = [array count];
    
    [array addObject:tableItem];
    
    //update UI
    NSIndexPath * modelItemPath = [NSIndexPath indexPathForRow:itemsCountInSection
                                                     inSection:section];
    
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

-(void)addNonRepeatingItems:(NSArray *)tableItems
                  toSection:(NSInteger)section
           withRowAnimation:(UITableViewRowAnimation)animation
{
    NSArray * validSection = [self getValidTableSection:section withAnimation:animation];
    
    [self.tableView beginUpdates];
    for (id model in tableItems)
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
    
    if ([[self tableItemsInSection:indexPath.section] count]<indexPath.row)
    {
        NSLog(@"DTTableViewManager: failed to insert item for indexPath section: %d, row: %d, only %d items in section",
              indexPath.section,
              indexPath.row,
              [[self tableItemsInSection:indexPath.section] count]);
        return;
    }
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
    
    if (!indexPathToReplace)
    {
        NSLog(@"DTTableViewManager: table item to replace not found.");
        return;
    }
    if (!replacingTableItem)
    {
        NSLog(@"DTTableViewManager: replacing table item is nil.");
        return;
    }
    
    NSMutableArray *section = [self getValidTableSection:indexPathToReplace.section
                                           withAnimation:animation];
    
    [section replaceObjectAtIndex:indexPathToReplace.row withObject:replacingTableItem];
    
    //Update UI
    [self.tableView reloadRowsAtIndexPaths:@[indexPathToReplace]
                          withRowAnimation:animation];
}

-(void)reloadTableItem:(NSObject *)tableItem
      withRowAnimation:(UITableViewRowAnimation)animation
{
    NSIndexPath * indexPathToReload = [self indexPathOfTableItem:tableItem];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPathToReload]
                          withRowAnimation:animation];
}

-(void)reloadTableItems:(NSArray *)tableItems
       withRowAnimation:(UITableViewRowAnimation)animation
{
    NSArray * indexPathsToReload = [self indexPathArrayForTableItems:tableItems];
    
    [self.tableView reloadRowsAtIndexPaths:indexPathsToReload
                          withRowAnimation:animation];
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
    [self removeTableItems:tableItems withRowAnimation:UITableViewRowAnimationNone];
}

-(void)removeTableItems:(NSArray *)tableItems
       withRowAnimation:(UITableViewRowAnimation)animation
{
    NSArray * indexPaths = [self indexPathArrayForTableItems:tableItems];
    
    for (NSObject * item in tableItems)
    {
        NSIndexPath *indexPath = [self indexPathOfTableItem:item];
        
        if (indexPath)
        {
            //update datasource
            [self removeTableItemAtIndexPath:indexPath];
        }
    }
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
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
    NSMutableArray * validSectionFrom = [self getValidTableSection:indexFrom
                                                      withAnimation:UITableViewRowAnimationNone];
    [self getValidTableSection:indexTo withAnimation:UITableViewRowAnimationNone];
    
    [self.sections removeObject:validSectionFrom];
    [self.sections insertObject:validSectionFrom atIndex:indexTo];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = [self tableItemsInSection:section];
    return sectionArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section < self.sectionHeaderTitles.count) ? [self.sectionHeaderTitles objectAtIndex:section] : nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return (section < self.sectionFooterTitles.count) ? [self.sectionFooterTitles objectAtIndex:section] : nil;
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

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - private

- (NSMutableArray *)getValidTableSection:(NSInteger)index
                           withAnimation:(UITableViewRowAnimation)animation
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
                          withRowAnimation:UITableViewRowAnimationNone];
        }
        return [self.sections lastObject];
    }
}

#pragma mark - Datasource methods, trampoline to our delegate

-(BOOL)delegateRespondsToSelector:(SEL)selector
{
    return [self.delegate respondsToSelector:selector];
}

-(void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
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
    id tableItem = [self tableItemAtIndexPath:sourceIndexPath];
    [array removeObjectAtIndex:sourceIndexPath.row];
    
    array = [self.sections objectAtIndex:destinationIndexPath.section];
    [array insertObject:tableItem atIndex:destinationIndexPath.row];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    id model = [self headerItemAtIndex:section];
    
    if (!model) {
        return nil;
    }
    
    NSString * reuseIdentifier = [self defaultReuseIdentifierForModel:model];
    
    UIView * headerView = [[DTCellFactory sharedInstance] headerViewForModel:model
                                                                 inTableView:tableView
                                                             reuseIdentifier:reuseIdentifier];
    return headerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    id model = [self footerItemAtIndex:section];
    
    if (!model) {
        return nil;
    }
    
    NSString * reuseIdentifier = [self defaultReuseIdentifierForModel:model];
    
    UIView * footerView = [[DTCellFactory sharedInstance] footerViewForModel:model
                                                                 inTableView:tableView
                                                             reuseIdentifier:reuseIdentifier];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section>[self.sectionHeaderTitles count])
    {
        return 0;
    }
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section>[self.sectionFooterTitles count])
    {
        return 0;
    }
    return UITableViewAutomaticDimension;
}
@end
