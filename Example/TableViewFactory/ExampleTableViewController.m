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
#import "StoryboardController.h"
#import "DTTableViewMemoryStorage.h"
#import "DTTableViewSectionModel.h"
#import "AppleCoreDataExampleController.h"
#import "BanksCoreDataViewController.h"

@implementation ExampleTableViewController

#pragma mark - View activity

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCellClass:[ControllerCell class]
              forModelClass:[ControllerModel class]];
    
    self.title = @"Examples";
    
    DTTableViewMemoryStorage * storage = (DTTableViewMemoryStorage *)self.dataStorage;
    
    [storage addTableItem:[ControllerModel modelWithClass:[AddRemoveTableViewController class]
                                              andTitle:@"Add/Remove cells"]];
    
    [storage addTableItem:[ControllerModel modelWithClass:[ReorderTableViewController class]
                                              andTitle:@"Reorder cells"]];
    [storage addTableItem:[ControllerModel modelWithClass:[CustomCellsTableViewController class]
                                              andTitle:@"Custom cells from NIB"]];
    [storage addTableItem:[ControllerModel modelWithClass:[CustomHeaderController class]
                                              andTitle:@"Custom header/footer"]];
    
    [storage addTableItem:[ControllerModel modelWithClass:[CustomHeaderFooterController class]
                                              andTitle:@"UITableViewHeaderFooterView"]];
    
    [storage addTableItem:[ControllerModel modelWithClass:[InsertReplaceTableViewController class]
                                              andTitle:@"Insert/replace cells"]];
    [storage addTableItem:[ControllerModel modelWithClass:[MoveSectionTableViewController class]
                                              andTitle:@"Move section"]];
    
    [storage addTableItem:[ControllerModel modelWithClass:[SearchController class]
                                              andTitle:@"Search"]];
    [storage addTableItem:[ControllerModel modelWithClass:[StoryboardController class]
                                              andTitle:@"Storyboard"]];
    [storage addTableItem:[ControllerModel modelWithClass:[AppleCoreDataExampleController class]
                                                 andTitle:@"Simple CoreData"]];
    [storage addTableItem:[ControllerModel modelWithClass:[BanksCoreDataViewController class]
                                                 andTitle:@"CoreData search"]];
}

#pragma mark - Table View

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    DTTableViewMemoryStorage * storage = (DTTableViewMemoryStorage *)self.dataStorage;
    id model = [[storage sections][indexPath.section] objects][indexPath.row];
    if ([model isKindOfClass:[ControllerModel class]])
    {
        ControllerModel * selectedController = model;
     
        if (selectedController.controllerClass == [StoryboardController class])
        {
            UIStoryboard * exampleStoryBoard = [UIStoryboard storyboardWithName:@"ExampleStoryboard" bundle:[NSBundle mainBundle]];
            UIViewController * presentExampleClass = [exampleStoryBoard instantiateInitialViewController];
            [self.navigationController pushViewController:presentExampleClass animated:YES];
        }
        else {
            UIViewController * presentExampleClass = [[selectedController.controllerClass alloc] init];
            
            [self.navigationController pushViewController:presentExampleClass animated:YES];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

@end
