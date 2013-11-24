//
//  DTTableViewUpdate.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.11.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTTableViewUpdate.h"

@implementation DTTableViewUpdate

-(NSMutableIndexSet *)deletedSectionIndexes
{
    if (!_deletedSectionIndexes)
    {
        _deletedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    return _deletedSectionIndexes;
}

-(NSMutableIndexSet *)insertedSectionIndexes
{
    if (!_insertedSectionIndexes)
    {
        _insertedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    return _insertedSectionIndexes;
}

-(NSMutableIndexSet *)updatedSectionIndexes
{
    if (!_updatedSectionIndexes)
    {
        _updatedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    return _updatedSectionIndexes;
}

-(NSMutableArray *)deletedRowIndexPaths
{
    if (!_deletedRowIndexPaths)
    {
        _deletedRowIndexPaths = [NSMutableArray array];
    }
    return _deletedRowIndexPaths;
}

-(NSMutableArray *)insertedRowIndexPaths
{
    if (!_insertedRowIndexPaths)
    {
        _insertedRowIndexPaths = [NSMutableArray array];
    }
    return _insertedRowIndexPaths;
}

-(NSMutableArray *)updatedRowIndexPaths
{
    if (!_updatedRowIndexPaths)
    {
        _updatedRowIndexPaths = [NSMutableArray array];
    }
    return _updatedRowIndexPaths;
}

-(BOOL)isEqual:(DTTableViewUpdate *)update
{
    if (![update isKindOfClass:[DTTableViewUpdate class]])
    {
        return NO;
    }
    if (![self.deletedSectionIndexes isEqualToIndexSet:update.deletedSectionIndexes])
    {
        return NO;
    }
    if (![self.insertedSectionIndexes isEqualToIndexSet:update.insertedSectionIndexes])
    {
        return NO;
    }
    if (![self.updatedSectionIndexes isEqualToIndexSet:update.updatedSectionIndexes])
    {
        return NO;
    }
    if (![self.deletedRowIndexPaths isEqualToArray:update.deletedRowIndexPaths])
    {
        return NO;
    }
    if (![self.insertedRowIndexPaths isEqualToArray:update.insertedRowIndexPaths])
    {
        return NO;
    }
    if (![self.updatedRowIndexPaths isEqualToArray:update.updatedRowIndexPaths])
    {
        return NO;
    }
    
    return YES;
}

@end
