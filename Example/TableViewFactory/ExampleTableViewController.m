//
//  ViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 9/28/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "ExampleTableViewController.h"
#import "Example.h"
#import "ExampleCell.h"
#import "CustomCell.h"
#import "CustomModel.h"
#import "AddRemoveTableViewController.h"
#import "ReorderTableViewController.h"

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
        
        // CustomCell is created from NIB
        // IMPORTANT to register cell nib for reuse identifier IDENTICAL to your model class name
        [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil]
             forCellReuseIdentifier:@"CustomModel"];
        
        // Recommended to add mappings right here, in tableManager getter
        [self.tableManager addCellClassMapping:[ExampleCell class] forModelClass:[Example class]];
        [self.tableManager addCellClassMapping:[CustomCell class] forModelClass:[CustomModel class]];
        
        // Uncomment this line if you want to NOT reuse cells.
        // self.doNotReuseCells = YES;
    }
    return _tableManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Examples";

  /*  [self.tableManager insertTableItem:[Example exampleWithText:@"Hello" andDetails:@"World"]
              toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.tableManager setSectionHeaders:@[@"A", @"B", @"C", @"D", @"E"]];*/
    
    [self.tableManager addTableItem:[Example exampleWithController:[AddRemoveTableViewController class]
                                                           andText:@"Add/Remove cells"]];
    [self.tableManager addTableItem:[Example exampleWithController:[ReorderTableViewController class]
                                                           andText:@"Reorder cells"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableManager addTableItem:[Example exampleWithText:@"Hello section 1!" andDetails:@"Woohoo!"]
                              toSection:1
                       withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableManager insertTableItem:[Example exampleWithText:@"Hello section 3!" andDetails:@"Woohoo!"]
                               toIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableManager deleteSections:[NSIndexSet indexSetWithIndex:3]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableManager addTableItem:[Example exampleWithText:@"Reloaded row from section 2"
                                                      andDetails:@""]
                              toSection:2];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableManager reloadSections:[NSIndexSet indexSetWithIndex:2]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableManager moveSection:1 toSection:3];
    });
 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableManager addTableItem:[Example exampleWithText:@"Add item and reload section"
                                                      andDetails:@""]
                 toSection:4];
        [self.tableManager reloadSections:[NSIndexSet indexSetWithIndex:4]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableManager addTableItem:[CustomModel modelWithText1:@"Very"
                                                 text2:@"Customized"
                                                 text3:@"Table"
                                                 text4:@"Cell"]
                              toSection:4];
    });*/
    
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
