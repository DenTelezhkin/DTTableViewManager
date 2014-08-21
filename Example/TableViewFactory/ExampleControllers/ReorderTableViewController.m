//
//  ReorderTableViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/16/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "ReorderTableViewController.h"
#import "Example.h"

@implementation ReorderTableViewController

-(void)addExampleCells
{
    DTMemoryStorage * storage = [self memoryStorage];
    
    [storage addItem:[Example exampleWithText:@"Section 1 cell" andDetails:@""] toSection:0];
    [storage addItem:[Example exampleWithText:@"Section 1 cell" andDetails:@""] toSection:0];
    [storage addItem:[Example exampleWithText:@"Section 2 cell" andDetails:@""] toSection:1];
    [storage addItem:[Example exampleWithText:@"Section 3 cell" andDetails:@""] toSection:2];
    [storage addItem:[Example exampleWithText:@"Section 3 cell" andDetails:@""] toSection:2];
    [storage addItem:[Example exampleWithText:@"Section 3 cell" andDetails:@""] toSection:2];
    
    [storage setSectionHeaderModels:@[@"Section 1", @"Section 2", @" Section 3"]];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.tableView setEditing:editing animated:animated];
}

#pragma  mark - view activity

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Reorder";
    
    [self addExampleCells];
    
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
}

#pragma mark - TableView delegate methods

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

@end
