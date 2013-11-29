//
//  DTTableViewDatasource.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.11.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTTableViewMemoryStorage.h"
#import "DTTableViewSectionModel.h"

@interface DTTableViewMemoryStorage()

@property (nonatomic, strong) DTTableViewUpdate * currentUpdate;

@end

@implementation DTTableViewMemoryStorage

+(instancetype)storageWithDelegate:(id<DTTableViewDataStorageUpdating>)delegate
{
    DTTableViewMemoryStorage * storage = [self new];
    
    storage.delegate = delegate;
    storage.sections = [NSMutableArray array];
    
    return storage;
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
        if ([[self class] loggingEnabled]) {
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
        if ([[self class] loggingEnabled]) {
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
    [self.sections removeAllObjects];
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
        if ([[self class] loggingEnabled]) {
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
    else if ([self.sections count] == sectionNumber)
    {
        DTTableViewSectionModel * section =[DTTableViewSectionModel new];
        [self.sections addObject:section];
        return [section objects];
    }
    else
    {
        return nil;
    }
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
