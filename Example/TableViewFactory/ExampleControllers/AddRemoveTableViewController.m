//
//  AddRemoveTableViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/16/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "AddRemoveTableViewController.h"
#import "DTTableViewMemoryStorage.h"

@interface AddRemoveTableViewController ()

@property (nonatomic,assign) int rowCount;

@end

@implementation AddRemoveTableViewController

-(void)addButtonTapped
{
    self.rowCount ++;
    NSString * rowText = [NSString stringWithFormat:@"Row # %d",self.rowCount];
    
    DTTableViewMemoryStorage * storage = (DTTableViewMemoryStorage *)self.dataStorage;
    
    [storage addTableItem:[Example exampleWithText:rowText andDetails:nil]];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                 target:self
                                                                 action:@selector(addButtonTapped)];
    self.navigationItem.rightBarButtonItem = barItem;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTTableViewMemoryStorage * storage = self.dataStorage;
    [storage removeTableItem:[storage tableItemAtIndexPath:indexPath]];
}

@end
