//
//  DTTableViewController+UnitTests.m
//  DTTableViewController
//
//  Created by Denys Telezhkin on 12/26/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "DTTableViewController+UnitTests.h"
#import "DTTableViewMemoryStorage.h"

@implementation DTTableViewController (UnitTests)

-(BOOL)verifyTableItem:(id)item atIndexPath:(NSIndexPath *)path
{
    id itemDatasource = [(DTTableViewMemoryStorage *)self.dataStorage tableItemAtIndexPath:path];
    id itemTable = [(id <DTTableViewModelTransfer>)[self tableView:self.tableView cellForRowAtIndexPath:path] model];
    
    if (![item isEqual:itemDatasource])
        return NO;
    
    if (![item isEqual:itemTable])
        return NO;
    
    // ALL 3 are equal
    return YES;
}

@end
