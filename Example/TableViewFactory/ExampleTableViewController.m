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

@implementation ExampleTableViewController

#pragma mark - View activity

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCellClass:[ControllerCell class]
              forModelClass:[ControllerModel class]];
    
    self.title = @"Examples";
    
    [self addTableItem:[ControllerModel modelWithClass:[AddRemoveTableViewController class]
                                              andTitle:@"Add/Remove cells"]];
    
    [self addTableItem:[ControllerModel modelWithClass:[ReorderTableViewController class]
                                              andTitle:@"Reorder cells"]];
    [self addTableItem:[ControllerModel modelWithClass:[CustomCellsTableViewController class]
                                              andTitle:@"Custom cells from NIB"]];
    [self addTableItem:[ControllerModel modelWithClass:[CustomHeaderController class]
                                              andTitle:@"Custom header/footer"]];
    
    [self addTableItem:[ControllerModel modelWithClass:[CustomHeaderFooterController class]
                                              andTitle:@"UITableViewHeaderFooterView"]];
    
    [self addTableItem:[ControllerModel modelWithClass:[InsertReplaceTableViewController class]
                                              andTitle:@"Insert/replace cells"]];
    [self addTableItem:[ControllerModel modelWithClass:[MoveSectionTableViewController class]
                                              andTitle:@"Move section"]];
    
    [self addTableItem:[ControllerModel modelWithClass:[SearchController class]
                                              andTitle:@"Search"]];
}

#pragma mark - Table View

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    id model = [self tableItemAtIndexPath:indexPath];
    if ([model isKindOfClass:[ControllerModel class]])
    {
        ControllerModel * selectedController = model;
        
        UIViewController * presentExampleClass = [[selectedController.controllerClass alloc] init];
        
        [self.navigationController pushViewController:presentExampleClass animated:YES];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

@end
