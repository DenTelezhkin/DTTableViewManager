//
//  DTTableViewDatasource.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.11.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
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

#import "DTTableViewMemoryStorage.h"
#import "DTTableViewController.h"

@interface DTTableViewMemoryStorage()

@property (nonatomic, strong) DTTableViewUpdate * currentUpdate;

@end

@implementation DTTableViewMemoryStorage

+(instancetype)storage
{
    DTTableViewMemoryStorage * storage = [self new];

    storage.sections = [NSMutableArray array];
    
    return storage;
}

-(id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    id <DTTableViewSection> sectionModel = [self sections][indexPath.section];
    return [sectionModel.objects objectAtIndex:indexPath.row];
}

#pragma mark - Searching

-(instancetype)searchingStorageForSearchString:(NSString *)searchString
                                 inSearchScope:(NSInteger)searchScope
{
    DTTableViewMemoryStorage * storage = [[self class] storage
                                          ];
    
    for (int sectionNumber = 0; sectionNumber < [self.sections count]; sectionNumber++)
    {
        DTTableViewSectionModel * searchSection = [self filterSection:self.sections[sectionNumber]
                                                     withSearchString:searchString
                                                          searchScope:searchScope];
        if (searchSection)
        {
            [storage.sections addObject:searchSection];
        }
    }
    
    return storage;
}

-(DTTableViewSectionModel *)filterSection:(DTTableViewSectionModel*)section
                         withSearchString:(NSString *)searchString
                              searchScope:(NSInteger)searchScope
{
    NSMutableArray * searchResults = [NSMutableArray array];
    for (int row = 0; row < section.objects.count ; row++)
    {
        NSObject <DTTableViewModelSearching> * item = section.objects[row];
        
        if ([item respondsToSelector:@selector(shouldShowInSearchResultsForSearchString:inScopeIndex:)])
        {
            BOOL shouldShow = [item shouldShowInSearchResultsForSearchString:searchString
                                                                inScopeIndex:searchScope];
            if (shouldShow)
            {
                [searchResults addObject:item];
            }
        }
    }
    if ([searchResults count])
    {
        DTTableViewSectionModel * searchSection = [DTTableViewSectionModel new];
        searchSection.objects = searchResults;
        searchSection.headerModel = section.headerModel;
        searchSection.footerModel = section.footerModel;
        return searchSection;
    }
    return nil;
}

#pragma mark - Updates

-(void)startUpdate
{
    self.currentUpdate = [DTTableViewUpdate new];
}

-(void)finishUpdate
{
    [self.delegate performUpdate:self.currentUpdate];
    self.currentUpdate = nil;
}

#pragma mark - Adding items

-(void)addTableItem:(NSObject *)tableItem
{
    [self addTableItem:tableItem toSection:0];
}

-(void)addTableItem:(NSObject *)tableItem toSection:(NSInteger)sectionNumber
{
    [self startUpdate];
    
    DTTableViewSectionModel * section = [self getValidSection:sectionNumber];
    NSUInteger numberOfItems = [section numberOfObjects];
    [section.objects addObject:tableItem];
    [self.currentUpdate.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfItems
                                                                           inSection:sectionNumber]];
    
    [self finishUpdate];
}

-(void)addTableItems:(NSArray *)tableItems
{
    [self addTableItems:tableItems toSection:0];
}

-(void)addTableItems:(NSArray *)tableItems toSection:(NSInteger)sectionNumber
{
    [self startUpdate];
    
    DTTableViewSectionModel * section = [self getValidSection:sectionNumber];
    
    for (id tableItem in tableItems)
    {
        NSUInteger numberOfItems = [section numberOfObjects];
        [section.objects addObject:tableItem];
        [self.currentUpdate.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfItems
                                                                               inSection:sectionNumber]];
    }
    
    [self finishUpdate];
}

-(void)insertTableItem:(NSObject *)tableItem toIndexPath:(NSIndexPath *)indexPath
{
    [self startUpdate];
    // Update datasource
    DTTableViewSectionModel * section = [self getValidSection:indexPath.section];
    
    if ([section.objects count] < indexPath.row)
    {
        if ([[DTTableViewController class] loggingEnabled]) {
            NSLog(@"DTTableViewMemoryStorage: failed to insert item for indexPath section: %ld, row: %ld, only %lu items in section",
                  (long)indexPath.section,
                  (long)indexPath.row,
                  (unsigned long)[section.objects count]);
        }
        return;
    }
    [section.objects insertObject:tableItem atIndex:indexPath.row];
    
    [self.currentUpdate.insertedRowIndexPaths addObject:indexPath];
    
    [self finishUpdate];
}

#pragma mark - reloading, replacing items

-(void)reloadTableItem:(NSObject *)tableItem
{
    [self startUpdate];
    
    NSIndexPath * indexPathToReload = [self indexPathOfTableItem:tableItem];
    
    if (indexPathToReload)
    {
        [self.currentUpdate.updatedRowIndexPaths addObject:indexPathToReload];
    }
    
    [self finishUpdate];
}

- (void)replaceTableItem:(NSObject *)tableItemToReplace
           withTableItem:(NSObject *)replacingTableItem
{
    [self startUpdate];
    
    NSIndexPath * originalIndexPath = [self indexPathOfTableItem:tableItemToReplace];
    if (originalIndexPath && replacingTableItem)
    {
        DTTableViewSectionModel *section = [self getValidSection:originalIndexPath.section];
        
        [section.objects replaceObjectAtIndex:originalIndexPath.row
                                   withObject:replacingTableItem];
    }
    else {
        if ([[DTTableViewController class] loggingEnabled]) {
            NSLog(@"DTTableViewMemoryStorage: failed to replace item %@ at indexPath: %@",replacingTableItem,originalIndexPath);
        }
        return;
    }
    
    [self.currentUpdate.updatedRowIndexPaths addObject:originalIndexPath];
    
    [self finishUpdate];
}

#pragma mark - Removing items

- (void)removeTableItem:(NSObject *)tableItem
{
    [self startUpdate];
    
    NSIndexPath * indexPath = [self indexPathOfTableItem:tableItem];
    
    if (indexPath)
    {
        DTTableViewSectionModel * section = [self getValidSection:indexPath.section];
        [section.objects removeObjectAtIndex:indexPath.row];
    }
    else {
        if ([[DTTableViewController class] loggingEnabled]) {
            NSLog(@"DTTableViewMemoryStorage: item to delete: %@ was not found in table view",tableItem);
        }
        return;
    }
    [self.currentUpdate.deletedRowIndexPaths addObject:indexPath];
    [self finishUpdate];
}

- (void)removeTableItems:(NSArray *)tableItems
{
    [self startUpdate];
    
    NSArray * indexPaths = [self indexPathArrayForTableItems:tableItems];
    
    for (NSObject * item in tableItems)
    {
        NSIndexPath *indexPath = [self indexPathOfTableItem:item];
        
        if (indexPath)
        {
            DTTableViewSectionModel * section = [self getValidSection:indexPath.section];
            [section.objects removeObjectAtIndex:indexPath.row];
        }
    }
    [self.currentUpdate.deletedRowIndexPaths addObjectsFromArray:indexPaths];
    [self finishUpdate];
}

- (void)removeAllTableItems
{
    for (DTTableViewSectionModel * section in self.sections)
    {
        [section.objects removeAllObjects];
    }
    [self.delegate performAnimation:^(UITableView * tableView) {
        [tableView reloadData];
    }];
}

#pragma mark - Section management

-(id)headerModelForSectionIndex:(NSInteger)index
{
    DTTableViewSectionModel * section = self.sections[index];
    return section.headerModel;
}

-(id)footerModelForSectionIndex:(NSInteger)index
{
    DTTableViewSectionModel * section = self.sections[index];
    return section.footerModel;
}

-(void)setSectionHeaderModels:(NSArray *)headerModels
{
    [self startUpdate];
    if (!headerModels || [headerModels count] == 0)
    {
        for (DTTableViewSectionModel * section in self.sections)
        {
            section.headerModel = nil;
        }
        return;
    }
    [self getValidSection:([headerModels count]-1)];
    
    for (int sectionNumber = 0; sectionNumber < [headerModels count]; sectionNumber++)
    {
        DTTableViewSectionModel * section = self.sections[sectionNumber];
        section.headerModel = headerModels[sectionNumber];
    }
    [self finishUpdate];
}

-(void)setSectionFooterModels:(NSArray *)footerModels
{
    [self startUpdate];
    
    if (!footerModels || [footerModels count] == 0)
    {
        for (DTTableViewSectionModel * section in self.sections)
        {
            section.footerModel = nil;
        }
        return;
    }
    
    [self getValidSection:([footerModels count]-1)];
    
    for (int sectionNumber = 0; sectionNumber < [footerModels count]; sectionNumber++)
    {
        DTTableViewSectionModel * section = self.sections[sectionNumber];
        section.footerModel = footerModels[sectionNumber];
    }
    [self finishUpdate];
}

-(void)moveSection:(NSInteger)indexFrom toSection:(NSInteger)indexTo
{
    DTTableViewSectionModel * validSectionFrom = [self getValidSection:indexFrom];
    [self getValidSection:indexTo];
    
    [self.sections removeObject:validSectionFrom];
    [self.sections insertObject:validSectionFrom atIndex:indexTo];
    
    [self.delegate performAnimation:^(UITableView * tableView) {
        [tableView moveSection:indexFrom toSection:indexTo];
    }];
}

-(void)deleteSections:(NSIndexSet *)indexSet
{
    [self startUpdate];
    // Update datasource
    [self.sections removeObjectsAtIndexes:indexSet];
    
    // Update interface
    [self.currentUpdate.deletedSectionIndexes addIndexes:indexSet];
    
    [self finishUpdate];
}

#pragma mark - Search

-(id)tableItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * section = nil;
    if (indexPath.section < [self.sections count])
    {
        section = [self tableItemsInSection:indexPath.section];
    }
    else {
        if ([DTTableViewController loggingEnabled])
        {
             NSLog(@"DTTableViewMemoryStorage: Section not found while searching for table item");
        }
        return nil;
    }
    
    if (indexPath.row < [section count])
    {
        return [section objectAtIndex:indexPath.row];
    }
    else {
        if ([[DTTableViewController class] loggingEnabled]) {
            NSLog(@"DTTableViewMemoryStorage: Row not found while searching for table item");
        }
        return nil;
    }
}

-(NSIndexPath *)indexPathOfTableItem:(NSObject *)tableItem
{
    for (NSInteger sectionNumber=0; sectionNumber<self.sections.count; sectionNumber++)
    {
        NSArray *rows = [self.sections[sectionNumber] objects];
        NSInteger index = [rows indexOfObject:tableItem];
        
        if (index != NSNotFound)
        {
            return [NSIndexPath indexPathForRow:index inSection:sectionNumber];
        }
    }
    return nil;
}

-(NSArray *)tableItemsInSection:(NSInteger)sectionNumber
{
    if ([self.sections count] > sectionNumber)
    {
        DTTableViewSectionModel * section = self.sections[sectionNumber];
        return [section objects];
    }
    else
    {
        return nil;
    }
}

-(DTTableViewSectionModel *)sectionAtIndex:(NSInteger)sectionNumber
{
    [self startUpdate];
    DTTableViewSectionModel * section = [self getValidSection:sectionNumber];
    [self finishUpdate];
    
    return section;
}

#pragma mark - private

-(DTTableViewSectionModel *)getValidSection:(NSUInteger)sectionNumber
{
    if (sectionNumber < self.sections.count)
    {
        return self.sections[sectionNumber];
    }
    else {
        for (NSInteger i = self.sections.count; i <= sectionNumber ; i++)
        {
            DTTableViewSectionModel * section = [DTTableViewSectionModel new];
            [self.sections addObject:section];
            
            [self.currentUpdate.insertedSectionIndexes addIndex:i];
        }
        return [self.sections lastObject];
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
            if ([[DTTableViewController class] loggingEnabled]) {
                NSLog(@"DTTableViewMemoryStorage: object %@ not found",
                      [tableItems objectAtIndex:i]);
            }
        }
        else {
            [indexPaths addObject:foundIndexPath];
        }
    }
    return indexPaths;
}

@end
