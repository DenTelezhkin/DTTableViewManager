//
//  AddRemoveTableViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/16/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "AddRemoveTableViewController.h"
#import "Example.h"

@interface AddRemoveTableViewController ()

@property (nonatomic, assign) int rowCount;

@end

@implementation AddRemoveTableViewController

- (void)addButtonTapped
{
    self.rowCount++;
    NSString * rowText = [NSString stringWithFormat:@"Row # %d", self.rowCount];

    [[self memoryStorage] addItem:[Example exampleWithText:rowText andDetails:nil]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem * barItem = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                 target:self
                                 action:@selector(addButtonTapped)];
    self.navigationItem.rightBarButtonItem = barItem;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTMemoryStorage * storage = [self memoryStorage];
    [storage removeItem:[storage itemAtIndexPath:indexPath]];
}

@end
