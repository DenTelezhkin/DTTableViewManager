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

- (NSMutableArray *)getValidTableSection:(NSInteger)index;

@property (nonatomic,strong) NSMutableArray * sections;
@property (nonatomic, strong) NSMutableArray * searchResultSections;
@property (nonatomic, strong) NSMutableArray * searchSectionHeaderTitles;
@property (nonatomic, strong) NSMutableArray * searchSectionFooterTitles;
@property (nonatomic, strong) NSMutableArray * searchSectionHeaderModels;
@property (nonatomic, strong) NSMutableArray * searchSectionFooterModels;
@property (nonatomic, assign) int currentSearchScope;
@property (nonatomic, copy) NSString * currentSearchString;
@property (nonatomic, retain) DTCellFactory * cellFactory;
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

#pragma mark - getters, setters

-(DTCellFactory *)cellFactory {
    if (!_cellFactory)
    {
        _cellFactory = [[DTCellFactory alloc] init];
    }
    return _cellFactory;
}

-(NSMutableArray *)sections
{
    if (!_sections)
    {
        _sections = [NSMutableArray new];
    }
    return _sections;
}

-(NSMutableArray *)sectionHeaderTitles {
    if (!_sectionHeaderTitles)
    {
        _sectionHeaderTitles = [NSMutableArray new];
    }
    return _sectionHeaderTitles;
}

-(NSMutableArray *)searchSectionHeaderTitles
{
    if (!_searchSectionHeaderTitles) {
        _searchSectionHeaderTitles = [NSMutableArray new];
    }
    return _searchSectionHeaderTitles;
}

-(NSMutableArray *)sectionFooterTitles {
    if (!_sectionFooterTitles)
    {
        _sectionFooterTitles = [NSMutableArray new];
    }
    return _sectionFooterTitles;
}

-(NSMutableArray *)searchSectionFooterTitles {
    if (!_searchSectionFooterTitles)
    {
        _searchSectionFooterTitles = [NSMutableArray new];
    }
    return _searchSectionFooterTitles;
}

-(NSMutableArray *)sectionHeaderModels
{
    if (!_sectionHeaderModels)
        _sectionHeaderModels = [NSMutableArray new];
    return _sectionHeaderModels;
}

-(NSMutableArray *)searchSectionHeaderModels {
    if (!_searchSectionHeaderModels)
    {
        _searchSectionHeaderModels = [NSMutableArray new];
    }
    return _searchSectionHeaderModels;
}

-(NSMutableArray *)sectionFooterModels
{
    if (!_sectionFooterModels)
        _sectionFooterModels = [NSMutableArray new];
    return _sectionFooterModels;
}

-(NSMutableArray *)searchSectionFooterModels {
    if (!_searchSectionFooterModels)
    {
        _searchSectionFooterModels = [NSMutableArray new];
    }
    return _searchSectionFooterModels;
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
               forCellReuseIdentifier:[self.cellFactory reuseIdentifierForClass:modelClass]];
    }
    
    if ([self nibExistsWIthNibName:NSStringFromClass(cellClass)])
    {
       [self registerNibNamed:NSStringFromClass(cellClass)
                 forCellClass:cellClass
                   modelClass:modelClass];
    }
    
    [self.cellFactory setCellClassMapping:cellClass
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
         forCellReuseIdentifier:[self.cellFactory reuseIdentifierForClass:modelClass]];
    
    [self.cellFactory setCellClassMapping:cellClass
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
 forHeaderFooterViewReuseIdentifier:[self.cellFactory reuseIdentifierForClass:modelClass]];
    }
    
    [self.cellFactory setHeaderClassMapping:headerClass
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
 forHeaderFooterViewReuseIdentifier:[self.cellFactory reuseIdentifierForClass:modelClass]];
    }
    
    [self.cellFactory setFooterClassMapping:footerClass
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
    
    [self searchAndReload];
}

-(void)searchAndReload
{
    self.searchResultSections = [self searchResultsArray];
    
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
    if ([self isSearching])
    {
        if (index<[self.searchSectionHeaderModels count])
        {
            return self.searchSectionHeaderModels[index];
        }
    }
    else
    {
        if (index<[self.sectionHeaderModels count])
        {
            return self.sectionHeaderModels[index];
        }
    }
    
    return nil;
}

-(id)footerItemAtIndex:(int)index
{
    if ([self isSearching])
    {
        if (index<[self.searchSectionFooterModels count])
        {
            return self.searchSectionFooterModels[index];
        }
    }
    else
    {
        if (index<[self.sectionFooterModels count])
        {
            return self.sectionFooterModels[index];
        }
    }
    
    return nil;
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
    NSIndexPath * indexPath = [self indexPathOfItem:tableItem inArray:[self currentSections]];
    if (!indexPath)
    {
        NSLog(@"DTTableViewManager: table item not found, cannot return it's indexPath");
        return nil;
    }
    else {
        return indexPath;
    }
}

-(NSIndexPath *)originalIndexPathOfTableItem:(NSObject *)tableItem
{
    NSIndexPath * indexPath = [self indexPathOfItem:tableItem inArray:self.sections];
    if (!indexPath)
    {
        NSLog(@"DTTableViewManager: table item not found, cannot return it's indexPath");
        return nil;
    }
    else {
        return indexPath;
    }
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

-(void)clearSearchHeadersFooters {
    [self.searchSectionFooterModels removeAllObjects];
    [self.searchSectionHeaderModels removeAllObjects];
    [self.searchSectionFooterTitles removeAllObjects];
    [self.searchSectionHeaderTitles removeAllObjects];
}

-(void)addSectionHeaderFootersForSection:(int)section
{
    if (section<[self.sectionHeaderTitles count])
    {
        [self.searchSectionHeaderTitles addObject:self.sectionHeaderTitles[section]];
    }
    if (section<[self.sectionFooterTitles count])
    {
        [self.searchSectionFooterTitles addObject:self.sectionFooterTitles[section]];
    }
    if (section<[self.sectionHeaderModels count])
    {
        [self.searchSectionHeaderModels addObject:self.sectionHeaderModels[section]];
    }
    if (section<[self.sectionFooterModels count])
    {
        [self.searchSectionFooterModels addObject:self.sectionFooterModels[section]];
    }
}

// Rebuild searchResultsArray from scratch
-(NSMutableArray *)searchResultsArray
{
    NSMutableArray * searchResults = [NSMutableArray array];
    [self clearSearchHeadersFooters];
    for (int section = 0; section < [self.sections count]; section ++)
    {
        [searchResults addObject:[NSMutableArray array]];
        
        NSMutableArray * rows = self.sections[section];
        
        for (int row = 0; row < [rows count];row ++)
        {
            NSObject <DTTableViewModelSearching> * item = rows[row];
            
            if ([item respondsToSelector:@selector(shouldShowInSearchResultsForSearchString:inScopeIndex:)])
            {
                BOOL shouldShow = [item shouldShowInSearchResultsForSearchString:self.currentSearchString
                                                                    inScopeIndex:self.currentSearchScope];
                
                if (shouldShow)
                {
                    [[searchResults lastObject] addObject:item];
                }
            }
        }
        
        if (![[searchResults lastObject] count])
        {
            [searchResults removeLastObject];
        }
        else {
            // Add section header-footer stuff
            [self addSectionHeaderFootersForSection:section];
        }
    }
    return searchResults;
}

-(NSIndexPath *)indexPathOfItem:(NSObject *)item inArray:(NSArray *)array
{
    for (NSInteger section=0; section<array.count; section++)
    {
        NSArray *rows = array[section];
        NSInteger index = [rows indexOfObject:item];
        
        if (index != NSNotFound)
        {
            return [NSIndexPath indexPathForRow:index inSection:section];
        }
    }
    return nil;
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
    // Update original datasource
    NSMutableArray *array = [self getValidTableSection:section];
    
    int itemsCountInSection = [array count];
    
    [array addObject:tableItem];
    
    //update interface
    if ([self isSearching])
    {
        [self searchAndReload];
        return;
    }
    else {
        // We are not searching, lets find out where we will insert tableItem
        NSIndexPath * modelItemPath = [NSIndexPath indexPathForRow:itemsCountInSection
                                                         inSection:section];
        
        UITableViewCell * modelCell = [self.tableView cellForRowAtIndexPath:modelItemPath];
        if (!modelCell)
        {
            [self.tableView insertRowsAtIndexPaths:@[modelItemPath] withRowAnimation:animation];
        }
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
    [self getValidTableSection:section];
    
    
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
    NSArray * validSection = [self getValidTableSection:section];
    
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
    NSMutableArray *array = [self getValidTableSection:indexPath.section];
    
    if ([array count] < indexPath.row)
    {
        NSLog(@"DTTableViewManager: failed to insert item for indexPath section: %d, row: %d, only %d items in section",
              indexPath.section,
              indexPath.row,
              [array count]);
        return;
    }
    [array insertObject:tableItem atIndex:indexPath.row];
    
    
    // Update UI
    if ([self isSearching])
    {
        [self searchAndReload];
    }
    else {
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    }
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
    NSIndexPath * originalIndexPath = [self originalIndexPathOfTableItem:tableItemToReplace];
    
    if (originalIndexPath && replacingTableItem)
    {
        NSMutableArray *section = [self getValidTableSection:originalIndexPath.section];
        
        [section replaceObjectAtIndex:originalIndexPath.row withObject:replacingTableItem];
    }
    else {
        NSLog(@"DTTableViewManager: failed to replace item %@ at indexPath: %@",replacingTableItem,originalIndexPath);
        return;
    }
    
    if ([self isSearching])
    {
        [self searchAndReload];
    }
    else {
        //Update UI
        [self.tableView reloadRowsAtIndexPaths:@[originalIndexPath]
                              withRowAnimation:animation];
    }
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
    NSIndexPath * originalIndexPath = [self originalIndexPathOfTableItem:tableItem];
    
    if (originalIndexPath)
    {
        NSMutableArray * section = (NSMutableArray *)[self tableItemsInOriginalSection:originalIndexPath.section];
        [section removeObjectAtIndex:originalIndexPath.row];
    }
    else {
        NSLog(@"DTTableViewManager: item to delete: %@ was not found in table view",tableItem);
        return;
    }
    
    if ([self isSearching])
    {
        [self searchAndReload];
    }
    else
    {
       [self.tableView deleteRowsAtIndexPaths:@[originalIndexPath]
                             withRowAnimation:animation];
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
    return [self numberOfSections];
}

-(void)moveSection:(int)indexFrom toSection:(int)indexTo
{
    NSMutableArray * validSectionFrom = [self getValidTableSection:indexFrom];
    [self getValidTableSection:indexTo];
    
    [self.sections removeObject:validSectionFrom];
    [self.sections insertObject:validSectionFrom atIndex:indexTo];
    
    
    if ([self isSearching])
    {
        [self searchAndReload];
    }
    else {
        if (self.sections.count > self.tableView.numberOfSections)
        {
            //Row does not exist, moving section causes many sections to change, so we just reload
            [self.tableView reloadData];
        }
        else {
            [self.tableView moveSection:indexFrom toSection:indexTo];
        }
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
    
    
    // Update interface
    if ([self isSearching])
    {
        [self searchAndReload];
    }
    else
    {
        [self.tableView deleteSections:indexSet withRowAnimation:animation];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = [self tableItemsInSection:section];
    return sectionArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self isSearching])
    {
       return (section < self.searchSectionHeaderTitles.count) ? [self.searchSectionHeaderTitles objectAtIndex:section] : nil;
    }
    else {
        return (section < self.sectionHeaderTitles.count) ? [self.sectionHeaderTitles objectAtIndex:section] : nil;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ([self isSearching])
    {
        return (section < self.searchSectionFooterTitles.count) ? [self.searchSectionFooterTitles objectAtIndex:section] : nil;
    }
    else {
        return (section < self.sectionFooterTitles.count) ? [self.sectionFooterTitles objectAtIndex:section] : nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *model = [self tableItemAtIndexPath:indexPath];

    UITableViewCell *cell = [self.cellFactory cellForModel:model
                                                   inTable:tableView];
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - private

- (NSMutableArray *)getValidTableSection:(NSInteger)index
{
    if (index < self.sections.count)
    {
        return (NSMutableArray *)self.sections[index];
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

-(NSMutableArray *)getValidSearchTableSection:(NSInteger)index
{
    if (index < [self.searchResultSections count])
    {
        return (NSMutableArray*) self.searchResultSections[index];
    }
    else {
        for (int i = self.searchResultSections.count; i <= index ; i++)
        {
            //Update datasource
            NSMutableArray *newSection = [NSMutableArray array];
            [self.searchResultSections addObject:newSection];
            
            //Update UI
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:i]
                          withRowAnimation:UITableViewRowAnimationNone];
        }
        return [self.searchResultSections lastObject];
    }
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
    
    UIView * headerView = [self.cellFactory headerViewForModel:model
                                                   inTableView:tableView];
    return headerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    id model = [self footerItemAtIndex:section];
    
    if (!model) {
        return nil;
    }
    UIView * footerView = [self.cellFactory footerViewForModel:model
                                                   inTableView:tableView];
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

#pragma  mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterTableItemsForSearchString:searchText];
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self filterTableItemsForSearchString:searchBar.text inScope:selectedScope];
}

@end
