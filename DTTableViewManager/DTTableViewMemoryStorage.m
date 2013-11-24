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

-(void)startUpdate
{
    self.currentUpdate = [DTTableViewUpdate new];
}

-(void)finishUpdate
{
    [self.delegate performUpdate:self.currentUpdate];
    self.currentUpdate = nil;
}

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

@end
