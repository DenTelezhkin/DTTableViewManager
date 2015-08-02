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
#import "MoveSectionTableViewController.h"
#import "CustomHeaderFooterController.h"
#import "SearchController.h"
#import "ControllerModel.h"
#import "ControllerCell.h"
#import "StoryboardController.h"
#import "DTMemoryStorage_DTTableViewManagerAdditions.h"
#import "DTSectionModel.h"
#import "AppleCoreDataExampleController.h"
#import "BanksCoreDataViewController.h"
#import "LegacyExample-Swift.h"
#import "Example.h"

@implementation ExampleTableViewController

#pragma mark - View activity

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCellClass:[ControllerCell class]
              forModelClass:[ControllerModel class]];
    
    self.title = @"Examples";
    
    DTMemoryStorage * storage = [self memoryStorage];
    
    [storage addItem:[ControllerModel modelWithClass:[AddRemoveTableViewController class]
                                              andTitle:@"Add/Remove cells"]];
    
    [storage addItem:[ControllerModel modelWithClass:[ReorderTableViewController class]
                                              andTitle:@"Reorder cells"]];
    [storage addItem:[ControllerModel modelWithClass:[CustomCellsTableViewController class]
                                              andTitle:@"Custom cells from NIB"]];
    
    [storage addItem:[ControllerModel modelWithClass:[CustomHeaderFooterController class]
                                              andTitle:@"Custom headers/footers"]];

    [storage addItem:[ControllerModel modelWithClass:[MoveSectionTableViewController class]
                                              andTitle:@"Move section"]];
    
    [storage addItem:[ControllerModel modelWithClass:[SearchController class]
                                              andTitle:@"Search"]];
    [storage addItem:[ControllerModel modelWithClass:[StoryboardController class]
                                              andTitle:@"Storyboard prototypes"]];
    [storage addItem:[ControllerModel modelWithClass:[AppleCoreDataExampleController class]
                                                 andTitle:@"CoreData add/remove"]];
    [storage addItem:[ControllerModel modelWithClass:[BanksCoreDataViewController class]
                                                 andTitle:@"CoreData search"]];
    [storage addItem:[ControllerModel modelWithClass:[SwiftViewController class]
                                            andTitle:@"Swift"]];
}

#pragma mark - Table View

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    id model = [self.memoryStorage objectAtIndexPath:indexPath];
    
    if ([model isKindOfClass:[ControllerModel class]])
    {
        ControllerModel * selectedController = model;
     
        if (selectedController.controllerClass == [StoryboardController class])
        {
            UIStoryboard * exampleStoryBoard = [UIStoryboard storyboardWithName:@"ExampleStoryboard" bundle:[NSBundle mainBundle]];
            UIViewController * presentExampleClass = [exampleStoryBoard instantiateInitialViewController];
            [self.navigationController pushViewController:presentExampleClass animated:YES];
        }
        else{
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
