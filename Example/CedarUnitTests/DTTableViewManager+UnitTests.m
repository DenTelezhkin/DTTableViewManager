//
//  DTTableViewManager+UnitTests.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 12/26/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "DTTableViewManager+UnitTests.h"

@implementation DTTableViewManager (UnitTests)

-(BOOL)verifyTableItem:(id)item atIndexPath:(NSIndexPath *)path
{
    id itemDatasource = [self tableItemAtIndexPath:path];
    id itemTable = [(id <DTTableViewModelTransfer>)[self tableView:self.tableView cellForRowAtIndexPath:path] model];
    
    if (![item isEqual:itemDatasource])
        return NO;
    
    if (![item isEqual:itemTable])
        return NO;
    
    // ALL 3 are equal
    return YES;
}

@end
