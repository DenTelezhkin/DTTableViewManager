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
#import "CustomHeaderFooterController.h"
#import "CustomHeaderController.h"
#import "SearchController.h"
#import "ControllerModel.h"
#import "ControllerCell.h"

@interface ExampleTableViewController ()

@property (nonatomic,strong) DTTableViewManager * tableManager;
@end

@implementation ExampleTableViewController


#pragma mark - getters

-(DTTableViewManager *)tableManager
{
    if (!_tableManager)
    {
        _tableManager = [[DTTableViewManager alloc] initWithDelegate:self
                                                           andTableView:self.tableView];
        
        // Recommended to add mappings right here, in tableManager getter
        [self.tableManager registerCellClass:[ControllerCell class]
                               forModelClass:[ControllerModel class]];
        
        // Uncomment this line if you want to NOT reuse cells.
        // self.doNotReuseCells = YES;
    }
    return _tableManager;
}

#pragma mark - View activity

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Examples";
    
    [self.tableManager addTableItem:[ControllerModel modelWithClass:[AddRemoveTableViewController class]
                                                           andTitle:@"Add/Remove cells"]];
    
    [self.tableManager addTableItem:[ControllerModel modelWithClass:[ReorderTableViewController class]
                                                           andTitle:@"Reorder cells"]];
    [self.tableManager addTableItem:[ControllerModel modelWithClass:[CustomCellsTableViewController class]
                                                           andTitle:@"Custom cells from NIB"]];
    [self.tableManager addTableItem:[ControllerModel modelWithClass:[CustomHeaderController class]
                                                            andTitle:@"Custom header - iOS 5"]];
    
    if ([UITableViewHeaderFooterView class])
    {
        // WE are running on iOS 6 and higher, which actually has reusable headers
        [self.tableManager addTableItem:[ControllerModel modelWithClass:[CustomHeaderFooterController class]
                                                               andTitle:@"Custom header - iOS 6"]];
    }
    
    [self.tableManager addTableItem:[ControllerModel modelWithClass:[InsertReplaceTableViewController class]
                                                           andTitle:@"Insert/replace cells"]];
    [self.tableManager addTableItem:[ControllerModel modelWithClass:[MoveSectionTableViewController class]
                                                           andTitle:@"Move section"]];
    
    [self.tableManager addTableItem:[ControllerModel modelWithClass:[SearchController class]
                                                           andTitle:@"Search"]];
}

#pragma mark - Table View

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    id model = [self.tableManager tableItemAtIndexPath:indexPath];
    if ([model isKindOfClass:[ControllerModel class]])
    {
        ControllerModel * selectedController = model;
        
        UIViewController * presentExampleClass = [[selectedController.controllerClass alloc] init];
        
        [self.navigationController pushViewController:presentExampleClass animated:YES];
    }
}

-(void)createdCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Do anything you want with created cell
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
