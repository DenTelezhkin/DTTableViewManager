//
//  AddRemoveTableViewController.m
//  TableViewFactory
//
//  Created by Denys Telezhkin on 10/16/12.
//  Copyright (c) 2012 Denys Telezhkin. All rights reserved.
//

#import "AddRemoveTableViewController.h"

@interface AddRemoveTableViewController ()

@property (nonatomic,assign) int rowCount;

@end

@implementation AddRemoveTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self addCellClassMapping:[ExampleCell class] forModelClass:[Example class]];
    }
    return self;
}

-(void)addButtonTapped
{
    self.rowCount ++;
    NSString * rowText = [NSString stringWithFormat:@"Row # %d",self.rowCount];
    [self addTableItem:[Example exampleWithText:rowText
                                     andDetails:nil]
      withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                              target:self
                                                                              action:@selector(addButtonTapped)];
    self.navigationItem.rightBarButtonItem = barItem;
    [barItem release];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self removeTableItem:[self tableItemAtIndexPath:indexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
