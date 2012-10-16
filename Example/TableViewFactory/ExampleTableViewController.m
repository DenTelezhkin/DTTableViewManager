//
//  ViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 9/28/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "ExampleTableViewController.h"
#import "AddRemoveTableViewController.h"
#import "ReorderTableViewController.h"
#import "CustomCellsTableViewController.h"
#import "InsertReplaceTableViewController.h"
#import "MoveSectionTableViewController.h"

@interface ExampleTableViewController ()

@property (nonatomic,retain) DTTableViewManager * tableManager;
@end

@implementation ExampleTableViewController

-(void)dealloc
{
    self.tableManager = nil;
    [super dealloc];
}

-(DTTableViewManager *)tableManager
{
    if (!_tableManager)
    {
        _tableManager = [[DTTableViewManager alloc] initWithDelegate:self
                                                           andTableView:self.tableView];
        
        // Recommended to add mappings right here, in tableManager getter
        [self.tableManager addCellClassMapping:[ExampleCell class] forModelClass:[Example class]];
        
        // Uncomment this line if you want to NOT reuse cells.
        // self.doNotReuseCells = YES;
    }
    return _tableManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Examples";
    
    [self.tableManager addTableItem:[Example exampleWithController:[AddRemoveTableViewController class]
                                                           andText:@"Add/Remove cells"]];
    [self.tableManager addTableItem:[Example exampleWithController:[ReorderTableViewController class]
                                                           andText:@"Reorder cells"]];
    [self.tableManager addTableItem:[Example exampleWithController:[CustomCellsTableViewController class]
                                                           andText:@"Custom cells from NIB"]];
    [self.tableManager addTableItem:[Example exampleWithController:[InsertReplaceTableViewController class]
                                                           andText:@"Insert/replace cells"]];
    [self.tableManager addTableItem:[Example exampleWithController:[MoveSectionTableViewController class]
                                                           andText:@"Move section"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    id model = [self.tableManager tableItemAtIndexPath:indexPath];
    if ([model isKindOfClass:[Example class]])
    {
        Example * selectedExample = model;
        
        UIViewController * presentExampleClass = [[selectedExample.controllerClass alloc] init];
        
        [self.navigationController pushViewController:presentExampleClass animated:YES];
        [presentExampleClass release];
    }
}

-(void)createdCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Do anything you want with created cell
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
