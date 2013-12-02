//
//  MoveSectionTableViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/16/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "MoveSectionTableViewController.h"

@implementation MoveSectionTableViewController

-(void)moveSection
{
    DTTableViewMemoryStorage * storage = self.dataStorage;
    [storage moveSection:0 toSection:([[storage sections] count]-1)];
}

-(void)addExampleRows
{
    DTTableViewMemoryStorage * storage = self.dataStorage;
    [storage addTableItem:[Example exampleWithText:@"Section 1 cell" andDetails:@""] toSection:0];
    [storage addTableItem:[Example exampleWithText:@"Section 1 cell" andDetails:@""] toSection:0];
    
    [storage addTableItem:[Example exampleWithText:@"Section 2 cell" andDetails:@""] toSection:1];
    
    [storage addTableItem:[Example exampleWithText:@"Section 3 cell" andDetails:@""] toSection:2];
    [storage addTableItem:[Example exampleWithText:@"Section 3 cell" andDetails:@""] toSection:2];
    [storage addTableItem:[Example exampleWithText:@"Section 3 cell" andDetails:@""] toSection:2];
    
    [storage setSectionHeaderModels:@[@"Section 1", @"Section 2", @" Section 3"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataStorage = [DTTableViewMemoryStorage storageWithDelegate:self];
    
    self.title = @"Move section";

    UIBarButtonItem * moveButton = [[UIBarButtonItem alloc] initWithTitle:@"Move!"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(moveSection)];
    self.navigationItem.rightBarButtonItem = moveButton;
    
    [self addExampleRows];
}

@end
