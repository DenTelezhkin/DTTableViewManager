//
//  DTTableViewUpdate.m
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
