//
//  DTTableViewController+UnitTests.m
//  DTTableViewController
//
//  Created by Denys Telezhkin on 12/26/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "DTTableViewController+UnitTests.h"
#import "DTTableViewMemoryStorage.h"

@interface DTTableViewController()
-(BOOL)isSearching;
@end

@implementation DTTableViewController (UnitTests)

-(BOOL)verifyTableItem:(id)item atIndexPath:(NSIndexPath *)path
{
    id <DTStorage> currentStorage = [self isSearching] ? self.searchingDataStorage : self.dataStorage;
    id itemDatasource = [currentStorage objectAtIndexPath:path];
    id itemTable = [(id <DTModelTransfer>)[self tableView:self.tableView cellForRowAtIndexPath:path] model];
    
    if (![item isEqual:itemDatasource])
        return NO;
    
    if (![item isEqual:itemTable])
        return NO;
    
    // ALL 3 are equal
    return YES;
}

-(void)raiseInvalidSectionException
{
    NSException * exception = [NSException exceptionWithName:@""
                                                      reason:@"wrong section items"
                                                    userInfo:nil];
    [exception raise];
}

-(void)verifySection:(NSArray *)section withSectionNumber:(NSInteger)sectionNumber
{
    for (int itemNumber = 0; itemNumber < [section count]; itemNumber++)
    {
        if (![self verifyTableItem:section[itemNumber]
                            atIndexPath:[NSIndexPath indexPathForItem:itemNumber
                                                            inSection:sectionNumber]])
        {
            [self raiseInvalidSectionException];
        }
    }
    NSInteger itemsInSection = [self.tableView numberOfRowsInSection:sectionNumber];
    if (itemsInSection!=[section count])
    {
        [self raiseInvalidSectionException];
    }
}

@end
