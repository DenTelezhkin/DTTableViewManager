//
//  CustomCellsTableViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/16/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "CustomCellsTableViewController.h"
#import "CustomCell.h"
#import "CustomModel.h"
#import "DTTableViewManager.h"

@implementation CustomCellsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataStorage = [DTTableViewMemoryStorage storageWithDelegate:self];
    self.title = @"Custom NIB";
    
    // CustomCell is created from NIB
    [self registerCellClass:[CustomCell class]
              forModelClass:[CustomModel class]];
    
    [(DTTableViewMemoryStorage *)self.dataStorage addTableItem:[CustomModel modelWithText1:@"Very"
                                                                                     text2:@"Custom"
                                                                                     text3:@"Table"
                                                                                     text4:@"Cell"]];
}

@end
